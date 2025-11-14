// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IRelation {
    function getInviter(address account) external view returns (address);

    function getMyTeam(
        address account
    ) external view returns (address[] memory);
}

interface ILastFinance {
    function getAccountGrade(address account) external view returns (uint8);

    function levelInit(
        uint8 level,
        address account
    ) external view returns (bool);
}

contract DINOFinanceTokenV2 is Ownable(msg.sender), ReentrancyGuard {
    using SafeERC20 for IERC20;

    // === 外部合约 ===
    IUniswapV2Router02 public immutable uniswapRouter;
    address public relShip;
    IERC20 public DINOToken;
    address public launcher;
    address public fundAddress;
    // address public usdt = 0xAa8Ff530B040A36eaF29CF161F79b44F4e76d254;
    address public usdt = 0x13512979AdE267aB5100878e2E0f485B5683289d;
    address public constant uRouter =
        0x6682375ebC1dF04676c0c5050934272368e6e883; //0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
    address public constant TARGET_TOKEN =
        0x6dB171BC785386973994072729D8fC707C2948e4;
    address public burnWallet = 0x0000000000000000000000000000000000000000;
    address public marketingWallet;
    address public immutable WETH;

    // === 质押与收益 ===
    uint256 public totalPool;
    uint256 public _totalSupply;
    // 每日分发前的总供应快照；用于按比例（ratio）权重计算
    uint256 public snapshotTotalSupply;
    uint256 public newPool;

    struct StakeInfo {
        uint256 balance;
        uint256 value;
        uint256 remain;
        uint256 received;
        uint256 stakeTime;
    }

    struct Rewards {
        uint256 queue;
        uint256 ratio;
        uint256 level;
        uint256 reward30;
        uint256 reward70;
    }

    struct Order {
        StakeInfo stake;
        Rewards rewards;
        uint8 level;
        bool isOut;
        uint256 index;
        address account;
    }

    mapping(uint256 => Order) public orders;
    uint256 public orderCount;
    mapping(address => uint256[]) public userOrders;
    mapping(address => uint256) public activeOrders;
    uint256 public totalActiveUsers;

    // === 等级分红 ===
    mapping(uint256 => uint256) public rewardPerLevelStored;
    mapping(address => mapping(uint256 => uint256))
        internal lastLevelRewardPaid;
    mapping(uint8 => uint8) public levelActiveSupply;
    uint256 public actualOrderCount;
    uint256 public lastUpdateDailyRewardTime;
    uint256 public dailyRewardInterval = 1 days;

    // === 领取限制 ===
    uint256 public constant RATIO_SCALE = 1e18;
    mapping(address => uint256) public lastClaimTime;
    uint256 public getIntervalTime = 4 hours;
    uint256 public minRequiredAmount = 100 ether;
    uint8 public outMultiple = 2;
    uint256 public rewardPerQueueStored;
    uint256 public rewardPerRatioStored;
    uint256 public blackHolePool;
    uint256 public last30NewPoolTime;
    uint256 public constant TRIGGER_THRESHOLD = 100_000 * 1e6;
    uint256 public constant NO_STAKE_DURATION = 1 hours;
    uint256 public constant MAX_REF_DEPTH = 50;//最多向上追溯 50 层，防止 gas 爆炸
    uint256 public constant MIN_REF_REWARD = 1; // 最小分配单位，低于则停止级联

    // === 日志 & 等级 ===
    struct Log {
        uint256 timestamp;
        uint256 quantity;
        uint256 value;
        uint8 from;
    }
    mapping(address => Log[]) public accountLogs;

    // 日志来源代码：
    // 0 = 队列分配
    // 1 = 比例分配
    // 2 = 推荐分配
    // 3 = 等级分配
    // 4 = 新池 30% 的分配
    // 5 = 新池 70% 分配

    function _pushAccountLog(
        address account,
        uint256 quantity,
        uint8 from
    ) internal {
        // 价值通过价格函数 calculateTokenToValue 计算
        uint256 value = 0;
        // 使用 try/catch 保护外部调用，避免路由器失败导致整个事务回滚
        try this.calculateTokenToValue(quantity) returns (uint256 v) {
            value = v;
        } catch {
            value = 0;
        }
        // 复用集中写入方法，便于以后修改写入逻辑
        addAccountLogs(account, quantity, value, from);
    }

    // 私有写入接口：直接写入已知价值（避免在调用方重复做价格查询）
    function addAccountLogs(
        address account,
        uint256 quantity,
        uint256 value,
        uint8 from
    ) private {
        accountLogs[account].push(Log(block.timestamp, quantity, value, from));
    }


    // 便捷接口：按数量返回账户最近的若干条日志（按写入时间从早到晚排序）
    // 返回类型为 Log[]，方便调用方一次性获取结构化日志
    function getAccountLogs(address account, uint256 quantity) public view returns (Log[] memory logList) {
        uint256 len = accountLogs[account].length;
        uint256 arrItem = len > quantity ? quantity : len;
        logList = new Log[](arrItem);
        if (arrItem == 0) return logList;
        uint256 floor = len - arrItem;
        uint256 index = 0;
        for (uint256 i = floor; i < len; i++) {
            logList[index] = accountLogs[account][i];
            index++;
        }
    }

    uint256[] public levelRequiredAmount = [
        1_000,
        5_000,
        10_000,
        50_000,
        100_000,
        500_000,
        1_000_000,
        5_000_000,
        10_000_000
    ];

    mapping(uint8 => uint256[2]) public levelParams;
    uint256 public dailyRate = 5;
    uint256 public levelRate = 50;
    uint256 public totalLevel = 9;
    mapping(address => bool) public blacklist;
    bool public stakeState = true;
    bool public paused = false;

    // === 等级同步 ===
    bool public isSyncLevel = false;
    address public lastFinance;
    uint256 public profitRate;
    mapping(address => bool) public syncAccountLevel;
    mapping(uint8 => mapping(address => bool)) public hasLevelInitialized;
    mapping(address => uint256) public refReward_map;

    // === 事件 ===
    event Stake(address indexed account, uint256 amount, uint256 value);
    event RewardPaid(address indexed user, uint256 reward);
    event NewPoolTriggered(
        uint256 pool,
        uint256 usdtValue,
        uint256 reward30,
        uint256 reward70,
        uint256 timestamp
    );
    event BurnToBlackHole(
        uint256 dinoAmount,
        uint256 usdtValue,
        uint256 timestamp
    );
    event LevelInitialized(address indexed account, uint8 level);

    // === 修饰器 ===
    modifier onlyLauncher() {
        require(msg.sender == launcher, "Not launcher");
        _;
    }
    modifier whenNotPaused() {
        require(!paused, "Paused");
        _;
    }
    modifier updateReward() {
        if (
            _totalSupply > 0 &&
            block.timestamp >= lastUpdateDailyRewardTime + dailyRewardInterval
        ) {
            uint256 dayReward = (_totalSupply * dailyRate) / 100;
            // 在分发前对总供应做快照，用于后续按比例权重的计算
            snapshotTotalSupply = _totalSupply;
            _totalSupply = _totalSupply > dayReward
                ? _totalSupply - dayReward
                : 0;

            updateQueueTopList(dayReward / 10);
            distributeLevelReward((dayReward * 4) / 10);
            distributeRatioReward(dayReward / 2);

            setEarned();
            // clear snapshot after distribution
            snapshotTotalSupply = 0;
            lastUpdateDailyRewardTime += 1 days;
            rewardPerQueueStored = rewardPerRatioStored = 0;
        }
        _;
    }

    function updateReward1() public {
        if (_totalSupply > 0) {
            uint256 dayReward = (_totalSupply * dailyRate) / 100;
            // 在分发前对总供应做快照，用于后续按比例权重的计算
            snapshotTotalSupply = _totalSupply;
            _totalSupply = _totalSupply > dayReward
                ? _totalSupply - dayReward
                : 0;

            updateQueueTopList(dayReward / 10);
            distributeLevelReward((dayReward * 4) / 10);
            distributeRatioReward(dayReward / 2);

            setEarned();
            // clear snapshot after distribution
            snapshotTotalSupply = 0;
            lastUpdateDailyRewardTime += 1 days;
            rewardPerQueueStored = rewardPerRatioStored = 0;
        }
    }

    modifier checkLevel(address account) {
        if (isSyncLevel && lastFinance != address(0)) {
            uint8 lastLevel = ILastFinance(lastFinance).getAccountGrade(
                account
            );
            if (
                lastLevel > 0 &&
                lastLevel <= totalLevel &&
                !hasLevelInitialized[lastLevel][account] &&
                !syncAccountLevel[account]
            ) {
                hasLevelInitialized[lastLevel][account] = true;
                syncAccountLevel[account] = true;

                bool hasActive = false;
                for (uint256 i = 0; i < userOrders[account].length; i++) {
                    Order storage ord = orders[userOrders[account][i]];
                    if (!ord.isOut) {
                        ord.level = lastLevel;
                        hasActive = true;
                    }
                }
                if (hasActive) levelActiveSupply[lastLevel]++;
                upgradeAccountLevel(account);
            }
        }
        _;
    }

    constructor(address _DINOToken, address _relShip) {
        DINOToken = IERC20(_DINOToken);
        relShip = _relShip;
        uniswapRouter = IUniswapV2Router02(uRouter);
        WETH = uniswapRouter.WETH();
        launcher = msg.sender;

        lastUpdateDailyRewardTime = block.timestamp;

        for (uint8 i = 0; i <= 8; i++) {
            if (i < 6) levelParams[i] = [21, 500];
            else if (i == 6) levelParams[i] = [10, 1000];
            else if (i == 7) levelParams[i] = [8, 1200];
            else levelParams[i] = [5, 2000];
        }
    }

    // === 核心功能 ===
    function stake(
        uint256 amount
    ) external nonReentrant whenNotPaused checkLevel(msg.sender) updateReward {
        require(msg.sender.code.length == 0, "Not EOA");
        require(amount >= minRequiredAmount, "Too small");
        require(stakeState, "Stake disabled");

        DINOToken.safeTransferFrom(msg.sender, address(this), amount);

        if (activeOrders[msg.sender] == 0) totalActiveUsers++;
        activeOrders[msg.sender]++;

        Order storage o = orders[++orderCount];
        o.index = orderCount;
        o.account = msg.sender;
        o.stake.balance = amount;
        o.stake.value = calculateTokenToValue(amount);
        o.stake.remain = o.stake.value * outMultiple;
        o.stake.stakeTime = block.timestamp;

        totalPool += amount;
        _totalSupply += amount;
        userOrders[msg.sender].push(orderCount);
        last30NewPoolTime = block.timestamp;

        upgradeAccountLevel(msg.sender);
        emit Stake(msg.sender, amount, o.stake.value);
    }

    function getReward() external whenNotPaused nonReentrant updateReward {
        _claimRewards(msg.sender, RewardType.Main);
        lastClaimTime[msg.sender] = block.timestamp;
    }

    function getLevelReward() external whenNotPaused nonReentrant updateReward {
        // 获取用户的级别奖金总额（以 DINO 单位返回），但不要在 _claimRewards 内做转账
        uint256 grossLevelPayout = _claimRewards(msg.sender, RewardType.Level);

        if (grossLevelPayout > 0) {
            // 按规则拆分：2% 新奖池、9% 黑洞、4% 返还总池、5% 营销，剩余 80% 为个人份额
            uint256 partNewPool = (grossLevelPayout * 2) / 100;
            uint256 partBlackHole = (grossLevelPayout * 9) / 100;
            uint256 partTotalPool = (grossLevelPayout * 4) / 100;
            uint256 partMarketing = (grossLevelPayout * 5) / 100;

            uint256 personalPart = grossLevelPayout -
                (partNewPool + partBlackHole + partTotalPool + partMarketing);

            // 累计到新奖池/总池/黑洞/营销
            newPool += partNewPool;
            blackHolePool += partBlackHole;
            // 触发黑洞购买（按现有逻辑尝试一次转换全部 blackHolePool）
            if (blackHolePool > 0) {
                calculateTargetToken(blackHolePool);
            }
            totalPool += partTotalPool;
            if (partMarketing > 0 && marketingWallet != address(0)) {
                DINOToken.safeTransfer(marketingWallet, partMarketing);
            }

            // 对个人部分先扣手续费，然后转给用户
            uint256 personalNet = personalPart;
            if (profitRate > 0 && fundAddress != address(0)) {
                uint256 fee = (personalNet * profitRate) / 1000;
                if (fee > 0) {
                    DINOToken.safeTransfer(fundAddress, fee);
                    personalNet -= fee;
                }
            }

            require(
                DINOToken.balanceOf(address(this)) >= personalNet,
                "Low balance"
            );
            DINOToken.safeTransfer(msg.sender, personalNet);
            emit RewardPaid(msg.sender, personalNet);
            // record log for level personal payout
            _pushAccountLog(msg.sender, personalNet, 3);

            // 触发 newPool 分发逻辑（30% / 70%）
            distributeNewPool30Percent();
            distributeNewPool70Percent();
        }
    }

    enum RewardType {
        Main,
        Level
    }

    function _claimRewards(
        address user,
        RewardType rtype
    ) internal returns (uint256) {
        require(!blacklist[user], "Blacklisted");
        uint256[] memory ids = userOrders[user];
        require(ids.length > 0, "No orders");

        uint256 actualPayout = 0;

        for (uint256 i = 0; i < ids.length; i++) {
            Order storage ord = orders[ids[i]];
            if (ord.isOut) continue;

            // 直接计算 pending，不定义任何中间变量
            uint256 pending = rtype == RewardType.Main
                ? ord.rewards.queue + ord.rewards.ratio + refReward_map[user]
                : ord.rewards.level +
                    ord.rewards.reward30 +
                    ord.rewards.reward70;

            if (pending == 0) continue;

            // 重置奖励（直接操作状态）
            if (rtype == RewardType.Main) {
                ord.rewards.queue = 0;
                ord.rewards.ratio = 0;
            } else {
                ord.rewards.level = 0;
                ord.rewards.reward30 = 0;
                ord.rewards.reward70 = 0;
            }

            // 仅保留 2 个必要局部变量，其余直接计算
            uint256 maxValue = ord.stake.value * outMultiple;
            uint256 pendingValue = calculateTokenToValue(pending);

            if (ord.stake.received + pendingValue > maxValue) {
                // 直接计算允许领取的 DINO 数量，无中间变量
                uint256 allowDino = calculateValueToToken(
                    maxValue - ord.stake.received
                );
                uint256 excess = pending - allowDino;

                if (excess > 0) {
                    _totalSupply += excess;
                    // 直接操作 refReward_map，不使用合并变量
                    if (rtype == RewardType.Main) {
                        // 仅从 refReward_map 中扣除实际存在的部分，避免下溢
                        if (refReward_map[user] > 0) {
                            if (excess >= refReward_map[user]) {
                                refReward_map[user] = 0;
                            } else {
                                refReward_map[user] = refReward_map[user] - excess;
                            }
                        }
                        // 其余的 excess 已增加回 _totalSupply（不再尝试从其他字段盲减）
                    }
                }

                ord.stake.received = maxValue;
                ord.isOut = true;
                if (--activeOrders[ord.account] == 0) totalActiveUsers--;
                actualPayout += allowDino;
            } else {
                ord.stake.received += pendingValue;
                actualPayout += pending;
                // 直接重置状态变量
                if (rtype == RewardType.Main) {
                    refReward_map[user] = 0;
                }
            }
        }

        if (actualPayout == 0) {
            emit RewardPaid(user, 0);
            return 0;
        }

        // 对于 Level 类型：不要在此处执行转账（由 getLevelReward 统一拆分并转账）
        if (rtype == RewardType.Level) {
            return actualPayout;
        }

        // Main 类型：正常收手续费并转账给用户
        if (profitRate > 0 && fundAddress != address(0)) {
            uint256 fee = (actualPayout * profitRate) / 1000;
            if (fee > 0) {
                DINOToken.safeTransfer(fundAddress, fee);
                actualPayout -= fee;
            }
        }

        require(
            DINOToken.balanceOf(address(this)) >= actualPayout,
            "Low balance"
        );
        DINOToken.safeTransfer(user, actualPayout);
        emit RewardPaid(user, actualPayout);
        // record log for main payout
        _pushAccountLog(user, actualPayout, 0);

        return actualPayout;
    }

    // === 配置函数 ===
    function setLauncher(address _launcher) external onlyLauncher {
        launcher = _launcher;
    }

    // function setSyncLevelParams(
    //     bool _isSyncLevel,
    //     address _lastFinance
    // ) external onlyOwner {
    //     isSyncLevel = _isSyncLevel;
    //     lastFinance = _lastFinance;
    // }

    function setblacklist(address a, bool v) external onlyLauncher {
        blacklist[a] = v;
    }

    function setState(bool v) external onlyLauncher {
        stakeState = v;
    }

    function emergencyPause(bool v) external onlyOwner {
        paused = v;
    }

    function initLevelData(
        uint8 level,
        address[] memory accounts,
        bool
    ) external onlyLauncher {
        require(level > 0 && level <= totalLevel, "Invalid level");
        for (uint256 i = 0; i < accounts.length; i++) {
            address a = accounts[i];
            require(a != address(0), "Zero addr");
            hasLevelInitialized[level][a] = true;
            if (!syncAccountLevel[a]) syncAccountLevel[a] = true;

            bool active = false;
            for (uint256 j = 0; j < userOrders[a].length; j++) {
                Order storage o = orders[userOrders[a][j]];
                if (!o.isOut) {
                    o.level = level;
                    active = true;
                }
            }
            if (active && levelActiveSupply[level] < type(uint8).max)
                levelActiveSupply[level]++;
            upgradeAccountLevel(a);
            emit LevelInitialized(a, level);
        }
    }

    function upgradeAccountLevel(address a) internal {
        uint256 perf = 0;
        try IRelation(relShip).getMyTeam(a) returns (address[] memory team) {
            for (uint256 i = 0; i < team.length; i++) {
                for (uint256 j = 0; j < userOrders[team[i]].length; j++) {
                    perf += orders[userOrders[team[i]][j]].stake.value;
                }
            }
        } catch {
            perf = 0; // 失败就当团队价值为0
        }
        uint8 target = 0;
        for (uint8 lv = 1; lv <= totalLevel; lv++)
            if (hasLevelInitialized[lv][a]) {
                target = lv;
                break;
            }

        for (uint8 i = 0; i < 9; i++)
            if (perf >= levelRequiredAmount[i])
                if (i + 1 > target) target = i + 1;
                else break;

        if (target == 0) return;

        uint8 curMax = 0;
        for (uint256 i = 0; i < userOrders[a].length; i++)
            if (orders[userOrders[a][i]].level > curMax)
                curMax = orders[userOrders[a][i]].level;

        if (target <= curMax) return;
        if (curMax > 0 && levelActiveSupply[curMax] > 0)
            levelActiveSupply[curMax]--;

        bool active = false;
        for (uint256 i = 0; i < userOrders[a].length; i++) {
            Order storage o = orders[userOrders[a][i]];
            if (!o.isOut) {
                o.level = target;
                active = true;
            }
        }
        if (active) levelActiveSupply[target]++;
        lastLevelRewardPaid[a][target] = rewardPerLevelStored[target];
    }

    function setLevelRequiredAmount(
        uint256 i,
        uint256 v
    ) external onlyLauncher {
        require(i < 9 && v > 0);
        levelRequiredAmount[i] = v;
    }

    function setLevelDailyRates(uint8 i, uint256 v) external onlyLauncher {
        require(i <= 9 && v <= 99);
        levelParams[i][1] = v * 100;
    }

    function setDailyRewardInterval(uint256 v) external onlyLauncher {
        dailyRewardInterval = v;
    }

    function setParams(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d
    ) external onlyLauncher {
        getIntervalTime = a;
        minRequiredAmount = b;
        dailyRate = c;
        levelRate = d;
    }

    function setConfigAddress(
        address a,
        address b,
        address c
    ) external onlyLauncher {
        DINOToken = IERC20(a);
        relShip = b;
        usdt = c;
    }

    function setMarketingWallet(address v) external onlyLauncher {
        require(v != address(0));
        marketingWallet = v;
    }

    function setBurnWallet(address v) external onlyLauncher {
        require(v != address(0));
        burnWallet = v;
    }

    function setFundParams(address a, uint256 r) external onlyLauncher {
        fundAddress = a;
        profitRate = r;
    }

    // === 内部函数 ===
    function distributeLevelReward(uint256 total) internal {
        if (total == 0) return;
        uint256 base = 1000;
        uint256 distributed = 0;
        for (uint8 lv = 1; lv <= 9; lv++) {
            uint256 cnt = levelActiveSupply[lv];
            if (cnt == 0) continue;
            uint256 full = lv <= 4
                ? (total * 125) / base
                : (total * 100) / base;
            uint256 reward = cnt < levelParams[lv][0]
                ? (total * levelParams[lv][1]) / 10000
                : full;
            rewardPerLevelStored[lv] += (reward * 1e18) / (cnt * 1e18);
            distributed += reward;
        }
        if (distributed > total) distributed = total;
        _totalSupply -= distributed;
    }

    function updateQueueTopList(uint256 pool) internal {
        if (pool == 0) return;
        uint256 value = calculateTokenToValue(pool);
    // value 以 USDT 最小单位（6 位小数）表示
    // 基准：当 value <= 1,000,000 USDT 时，max = 50
    // 之后每增加 100,000 USDT，max 增加 5 人
    uint256 usdtBase = 1_000_000 * 1e6;
        uint256 max;
        if (value <= usdtBase) {
            max = 50;
        } else {
            uint256 extra = value - usdtBase;
            uint256 step = 100_000 * 1e6;
            uint256 increments = extra / step;
            // each increment adds 5 people
            max = 50 + (increments * 5);
        }
        // 2. 新增：统计「有效订单数」（未出局 + 订单所属用户有有效订单）
        uint256 totalValidOrders = 0;
        for (uint256 id = 1; id <= orderCount; id++) {
            Order storage o = orders[id];
            // 有效订单条件：订单未出局 + 订单所属用户有活跃订单（activeOrders > 0）
            if (!o.isOut && activeOrders[o.account] > 0) {
                totalValidOrders++;
            }
        }

        actualOrderCount = totalValidOrders < max ? totalValidOrders : max;

        if (actualOrderCount > 0) rewardPerQueueStored += pool;
    }

    function distributeRatioReward(uint256 pool) internal {
        if (pool > 0) rewardPerRatioStored += pool;
    }

    function distributeNewPool30Percent() internal {
        if (
            block.timestamp < last30NewPoolTime + NO_STAKE_DURATION ||
            newPool == 0
        ) return;

    Order[] memory orders20 = getNewNActiveOrders(20);
    if (orders20.length == 0) return; // 没有可分配的订单
        uint256 reward30 = (newPool * 30) / 100;
        uint256 per = reward30 / orders20.length;
        for (uint256 i = 0; i < orders20.length; i++) {
            orders[orders20[i].index].rewards.reward30 += per;
            _pushAccountLog(orders[orders20[i].index].account, per, 4);
        }
        newPool -= reward30;
        emit NewPoolTriggered(
            newPool,
            calculateTokenToValue(newPool),
            reward30,
            0,
            block.timestamp
        );
    }

    function distributeNewPool70Percent() internal {
        if (newPool == 0) return;
        uint256 value = calculateTokenToValue(newPool);
        if (value < TRIGGER_THRESHOLD) return;
        uint256 reward70 = (newPool * 70) / 100;
    Order[] memory orders100 = getNewNActiveOrders(100);
    if (orders100.length == 0) return; // 没有可分配的订单
        uint256 per = reward70 / orders100.length;
        for (uint256 i = 0; i < orders100.length; i++) {
            orders[orders100[i].index].rewards.reward70 += per;
            _pushAccountLog(orders[orders100[i].index].account, per, 5);
        }
        newPool -= reward70;
        emit NewPoolTriggered(newPool, value, 0, reward70, block.timestamp);
    }

    function setEarned() internal {
        // Queue
        if (actualOrderCount > 0 && rewardPerQueueStored > 0) {
            Order[] memory top = getTopNActiveOrders(actualOrderCount);
            if (top.length > 0) {
                uint256 reward = (rewardPerQueueStored) / top.length;
                for (uint256 i = 0; i < top.length; i++) {
                    orders[top[i].index].rewards.queue = reward;
                    // record allocation log for queue
                    _pushAccountLog(orders[top[i].index].account, reward, 0);
                }
            }
        }

        // Ratio + Referral
    // Use snapshotTotalSupply (pre-distribution) if set; otherwise fall back to current _totalSupply
    uint256 supplyForWeight = snapshotTotalSupply > 0 ? snapshotTotalSupply : _totalSupply;
    if (rewardPerRatioStored > 0 && supplyForWeight > 0) {
            uint256 totalActiveOrderCount = 0;
            // 第一步：统计活跃订单总数（避免重复遍历）
            for (uint256 id = 1; id <= orderCount; id++) {
                Order storage o = orders[id];
                if (!o.isOut && activeOrders[o.account] > 0) {
                    totalActiveOrderCount++;
                }
            }
            if (totalActiveOrderCount == 0) return;

            // 第二步：遍历活跃订单，按权重分配奖励
            for (uint256 id = 1; id <= orderCount; id++) {
                Order storage o = orders[id];
                // 仅处理「未出局 + 所属用户有活跃订单」的有效订单
                if (o.isOut || activeOrders[o.account] == 0) continue;

                // 计算当前订单权重（balance / _totalSupply），用 RATIO_SCALE 放大避免精度丢失
                uint256 orderWeight = (o.stake.balance * RATIO_SCALE) / supplyForWeight;

                // 订单应得的比例奖份额（以 DINO 单位计）
                uint256 orderShare = (rewardPerRatioStored * orderWeight) / RATIO_SCALE;
                if (orderShare == 0) continue;

                // 推荐分发新规则：
                // - 第1级理论份额 = orderShare * 25%
                // - 第n级理论份额 = 上一级 * 50%
                // - 每层实际到账 = 本层理论份额 - 下一级理论份额（即差额）
                // 最终剩余 = orderShare - 已发放净额
                uint256 distributed = 0;
                // 第一级理论份额为 25%
                uint256 curRefAmount = (orderShare * 2500) / 10000; // 25%
                address cur = address(0);
                try IRelation(relShip).getInviter(o.account) returns (address _inv) {
                    cur = _inv;
                } catch {
                    cur = address(0);
                }

                uint256 depth = 0;
                while (cur != address(0) && depth < MAX_REF_DEPTH) {
                    if (curRefAmount < MIN_REF_REWARD) break;
                    // 下一级理论份额为当前的 50%
                    uint256 nextAmount = (curRefAmount * 5000) / 10000;
                    uint256 netAmount;
                    if (nextAmount < MIN_REF_REWARD) {
                        // 如果下一级太小，则把当前全部发给本层
                        netAmount = curRefAmount;
                        // 下一级将为 0，后续循环会因 curRefAmount < MIN_REF_REWARD 或 depth 限制而停止
                        curRefAmount = 0;
                    } else {
                        // 本层实际到账为本层理论减去下一级理论
                        netAmount = curRefAmount - nextAmount;
                        // 继续把下一级作为当前处理
                        curRefAmount = nextAmount;
                    }

                    if (netAmount >= MIN_REF_REWARD) {
                        refReward_map[cur] += netAmount;
                        // record allocation log for referral
                        _pushAccountLog(cur, netAmount, 2);
                        distributed += netAmount;
                    }

                    // 获取上级
                    address next;
                    try IRelation(relShip).getInviter(cur) returns (address _next) {
                        next = _next;
                    } catch {
                        next = address(0);
                    }
                    cur = next;
                    depth++;
                    if (curRefAmount == 0) break;
                }

                // 剩余的分配给订单本人
                if (orderShare > distributed) {
                    uint256 remainShare = orderShare - distributed;
                    o.rewards.ratio += remainShare;
                    // record allocation log for ratio
                    _pushAccountLog(o.account, remainShare, 1);
                }
            }

            // 分配完成后重置 rewardPerRatioStored（避免重复分配）
            rewardPerRatioStored = 0;
        }

        // Level
        address[] memory users = new address[](totalActiveUsers);
        uint256 idx = 0;
        for (uint256 id = 1; id <= orderCount && idx < totalActiveUsers; id++) {
            Order storage o = orders[id];
            if (!o.isOut && activeOrders[o.account] > 0) {
                bool isDuplicate = false;
                for (uint256 k = 0; k < idx; k++) {
                    if (users[k] == o.account) {
                        isDuplicate = true;
                        break;
                    }
                }
                if (!isDuplicate) {
                    users[idx++] = o.account;
                }
            }
        }

        // 第二步：按等级分配奖励
        for (uint8 lv = 1; lv <= 9; lv++) {
            if (levelActiveSupply[lv] == 0 || rewardPerLevelStored[lv] == 0)
                continue;
            uint256 per = rewardPerLevelStored[lv] / levelActiveSupply[lv];
            for (uint256 i = 0; i < idx; i++) {
                // 现在 idx 已定义
                for (uint256 j = 0; j < userOrders[users[i]].length; j++) {
                    // 现在 users 已定义
                    Order storage o = orders[userOrders[users[i]][j]]; // 修复 users[i] 引用
                    if (!o.isOut && o.level == lv) {
                        o.rewards.level += per;
                        // record allocation log for level
                        _pushAccountLog(o.account, per, 3);
                    }
                }
            }
        }
    }

    // === 视图函数 ===
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function getTotalPool() public view returns (uint256) {
        return totalPool;
    }

    function balanceOf(address a) public view returns (uint256) {
        if (activeOrders[a] == 0) return 0;
        uint256 bal = 0;
        for (uint256 i = 0; i < userOrders[a].length; i++)
            if (!orders[userOrders[a][i]].isOut)
                bal += orders[userOrders[a][i]].stake.balance;
        return bal;
    }

    function pendingEarned(
        address user
    ) public view returns (uint256 reward, uint256 value) {
        if (activeOrders[user] == 0) return (0, 0);
        uint256 pending = 0;
        uint256 received = 0;
        uint256 cap = 0;

        pending += refReward_map[user];
        for (uint256 i = 0; i < userOrders[user].length; i++) {
            Order storage o = orders[userOrders[user][i]];
            if (o.isOut) continue;
            pending += o.rewards.queue + o.rewards.ratio;
            received += o.stake.received;
            cap += o.stake.value;
        }
        if (pending == 0) return (0, 0);
        uint256 pValue = calculateTokenToValue(pending);
        if (received + pValue > cap) {
            uint256 allow = cap - received;
            reward = calculateValueToToken(allow);
            value = allow;
        } else {
            reward = pending;
            value = pValue;
        }
    }

    function pendingEarnedLevel(
        address user
    ) public view returns (uint256 reward, uint256 value) {
        if (activeOrders[user] == 0) return (0, 0);
        uint256 pending = 0;
        uint256 received = 0;
        uint256 cap = 0;
 
        for (uint256 i = 0; i < userOrders[user].length; i++) {
            Order storage o = orders[userOrders[user][i]];
            if (o.isOut) continue;
            pending += o.rewards.level;
            received += o.stake.received;
            cap += o.stake.value;
        }
        if (pending == 0) return (0, 0);
        uint256 pValue = calculateTokenToValue(pending);
        if (received + pValue > cap) {
            uint256 allow = cap - received;
            reward = calculateValueToToken(allow);
            value = allow;
        } else {
            reward = pending;
            value = pValue;
        }
    }

    function getTopNActiveOrders(
        uint256 n
    ) public view returns (Order[] memory res) {
        uint256[] memory ids = new uint256[](n);
        uint256 cnt = 0;
        // 改为正序遍历：从最旧订单（id=1）到最新订单（id=orderCount）
        for (uint256 id = 1; id <= orderCount && cnt < n; id++)
            if (!orders[id].isOut && activeOrders[orders[id].account] > 0)
                ids[cnt++] = id;
        res = new Order[](cnt);
        for (uint256 i = 0; i < cnt; i++) res[i] = orders[ids[i]];
    }

    function getNewNActiveOrders(
        uint256 n
    ) public view returns (Order[] memory res) {
        uint256[] memory ids = new uint256[](n);
        uint256 cnt = 0;
        // 关键：从最大订单ID（最新订单）开始遍历，取前 n 个有效订单
        for (uint256 id = orderCount; id > 0 && cnt < n; id--)
            if (!orders[id].isOut && activeOrders[orders[id].account] > 0)
                ids[cnt++] = id;
        res = new Order[](cnt);
        for (uint256 i = 0; i < cnt; i++) res[i] = orders[ids[i]];
    }

    function getLevelByTeamValue(
        address user
    ) public view returns (uint8 level) {
        uint256 allTeamValue = getTeamValue(user);
        if (allTeamValue == 0) return 0;

        for (uint8 i = 0; i < levelRequiredAmount.length; i++) {
            bool meetCurrentLevel = allTeamValue >= levelRequiredAmount[i];
            bool lessThanNextLevel = (i == levelRequiredAmount.length - 1) ||
                (allTeamValue < levelRequiredAmount[i + 1]);

            if (meetCurrentLevel && lessThanNextLevel) {
                return uint8(i + 1);
            }
        }

        return uint8(levelRequiredAmount.length);
    }

    function getTeamValue(address user) public view returns (uint256) {
        uint256 perf = 0;
        try IRelation(relShip).getMyTeam(user) returns (address[] memory team) {
            for (uint256 i = 0; i < team.length; i++) {
                for (uint256 j = 0; j < userOrders[team[i]].length; j++) {
                    perf += orders[userOrders[team[i]][j]].stake.value;
                }
            }
        } catch {
            // relShip 失败 → 返回 0
            return 0;
        }
        return perf;
    }

    function getAllTeamValue(address user) public view returns (uint256) {
        uint256 totalValue = 0;

        // 安全调用 relShip.getMyTeam
        try IRelation(relShip).getMyTeam(user) returns (address[] memory team) {
            for (uint256 i = 0; i < team.length; i++) {
                address member = team[i];
                totalValue += _getUserValue(member);
                totalValue += getAllTeamValue(member); // 递归（安全）
            }
        } catch {
            // relShip 失败或未实现 → 返回 0，不影响其他逻辑
            return 0;
        }

        return totalValue;
    }

    function _getUserValue(address user) internal view returns (uint256 value) {
        for (uint256 i = 0; i < userOrders[user].length; i++) {
            value += orders[userOrders[user][i]].stake.value;
        }
    }

    function calculateTokenToValue(
        uint256 amount
    ) public view returns (uint256) {
        // return amount * 2; // 仅作示例，实际逻辑请根据需求实现
        if (amount == 0) return 0;
        // 路径：DINO → WETH → USDT（符合 Uniswap V2 常见交易对逻辑）
        address[] memory path = new address[](2);
        path[0] = address(DINOToken); // 输入代币：DINO（IERC20 转 address 合法）
        // path[1] = WETH; // 中间代币：WETH（合约已定义为 Base 主网/测试网 WETH 地址）
        path[1] = usdt; // 输出代币：USDT（合约中已定义的地址）

        // 调用 getAmountsOut（带`s`），返回数组的最后一个元素是最终 USDT 数量
        uint256[] memory amounts = uniswapRouter.getAmountsOut(amount, path);
        return amounts[amounts.length - 1]; // 直接取最后一个元素，避免数组长度错误
    }

    function calculateValueToToken(
        uint256 value
    ) public view returns (uint256) {
        // return value / 2; // 仅作示例，实际逻辑请根据需求实现
        if (value == 0) return 0;
        // 反向路径：USDT → WETH → DINO
        address[] memory path = new address[](2);
        path[0] = usdt; // 输入代币：USDT
        // path[1] = WETH; // 中间代币：WETH
        path[1] = address(DINOToken); // 输出代币：DINO

        // 调用 getAmountsOut，返回数组的最后一个元素是最终 DINO 数量
        uint256[] memory amounts = uniswapRouter.getAmountsOut(value, path);
        return amounts[amounts.length - 1];
    }

    function calculateTargetToken(uint256 dinoAmount) internal {
        if (dinoAmount == 0) return;
        if (DINOToken.allowance(address(this), uRouter) < dinoAmount) {
            require(
                DINOToken.approve(uRouter, type(uint256).max),
                "Approve failed"
            );
        }
        address[] memory path = new address[](3);
        path[0] = address(DINOToken);
        path[1] = WETH;
        path[2] = TARGET_TOKEN;
        try
            uniswapRouter.swapExactTokensForTokens(
                dinoAmount,
                0,
                path,
                burnWallet,
                block.timestamp + 300
            )
        returns (uint256[] memory) {
            blackHolePool -= dinoAmount; // 成功才扣除
        } catch {
            // 失败不回滚
        }
    }
}
