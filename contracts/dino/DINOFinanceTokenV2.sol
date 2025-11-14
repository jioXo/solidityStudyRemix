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
  address public usdt = 0xAa8Ff530B040A36eaF29CF161F79b44F4e76d254;
    address public constant uRouter = 0x6682375ebC1dF04676c0c5050934272368e6e883;
    address public constant TARGET_TOKEN = 0x70bD93352615a810417C776942FeaED8c366f522;
    address public burnWallet = 0x0000000000000000000000000000000000000000;
    address public marketingWallet = 0x1a238010ff6f25BB34F42405C1EEa36aB87A1Bd5;
    address public immutable WETH;

    // === 质押与收益 ===
    uint256 public totalPool;
    uint256 public _totalSupply;
    // 每日分发前的总供应快照；用于按比例（ratio）权重计算
    uint256 public snapshotTotalSupply;
    uint256 public newPool;

    struct StakeInfo {
        uint256 balance;
        uint256 value;// 价值，USDT 单位
        uint256 remain;
        uint256 received;// 已领取的总价值（USDT 单位）
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
    // MAX_REF_DEPTH 与 MIN_REF_REWARD 不再暴露为 public 常量，已内联为代码中的字面量（100 / 1）以节省字节码

    // === 日志 & 等级 ===
    struct Log {
        uint256 timestamp;
        uint256 quantity;
        uint256 value;
        uint8 from;
    }
    mapping(address => Log[]) public accountLogs;

    // 日志来源代码：
    // 0 = 队列分配总金额 updateQueueTopList
    // 1 = 比例分配总金额  distributeRatioReward
    // 2 = 用户领取级别奖励 getLevelReward
    // 3 = 新池分配总金额 distributeLevelReward
    // 4 =为指定用户结算并（根据类型）支付奖励 _claimRewards


    function _pushAccountLog(
        address account,
        uint256 quantity,
        uint8 from
    ) internal {
        // 价值通过价格函数 calculateTokenToValue 计算
        uint256 value = 0;
        // 直接调用价格查询（调用失败将回退）。
        value = calculateTokenToValue(quantity);
        accountLogs[account].push(Log(block.timestamp, quantity, value, from));
    }




    // levelRequiredAmount 存为标准的 USDT 最小单位（每项 = 人类可读值 * 1e6）
    // 例如：数组项 `1_000` 表示 1_000 USDT，可表示为 1_000 * 1e6 = 1_000_000_000
    uint256[] public levelRequiredAmount = [
        1_000_000_000,    // 1_000 * 1e6
        5_000_000_000,    // 5_000 * 1e6
        10_000_000_000,   // 10_000 * 1e6
        50_000_000_000,   // 50_000 * 1e6
        100_000_000_000,  // 100_000 * 1e6
        500_000_000_000,  // 500_000 * 1e6
        1_000_000_000_000,// 1_000_000 * 1e6
        5_000_000_000_000,// 5_000_000 * 1e6
        10_000_000_000_000// 10_000_000 * 1e6
    ];

    mapping(uint8 => uint256[2]) public levelParams;
    uint256 public dailyRate = 5;
    uint256 public levelRate = 50;
    uint256 public totalLevel = 9;
    mapping(address => bool) public blacklist;
    bool public stakeState = true;
    bool public paused = false;

    // === 会员信息（便于外部与前端读取） ===
    struct MEMBER {
        uint8 level; // 当前等级
        uint256 received; // 累计已领取的 DINO 数量（按每次实际发放累加）
        uint256 receivedValue; // 累计已领取的价值（USDT 最小单位），按每次领取时的价格累加
        uint256 donated; // 累计捐赠/质押的 DINO 数量
        uint256 expectedValue; // 预期可获取的总价值（USDT 单位），按每次捐赠的价值 * outMultiple 累加
        uint256 rewards; // 预留字段：可用于记录待领取奖励总额
    }

    mapping(address => MEMBER) public members;

    // === 等级同步 ===
    bool public isSyncLevel = false;
    address public lastFinance;
    uint256 public profitRate;
    mapping(address => bool) public syncAccountLevel;
    mapping(uint8 => mapping(address => bool)) public hasLevelInitialized;
    mapping(address => uint256) public refReward_map;
    // 子树累计业绩（包含自身 + 所有下级），以 stake.value 单位计
    mapping(address => uint256) public subtreeTotal;

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

    
    event RefCredit(address indexed to, uint256 amount, uint256 orderId);
    // 当推荐链中有部分预留份额未分配（链断裂或达到 MIN_REF_REWARD），把该未分配部分回流到 _totalSupply
    event RefBackflow(uint256 indexed orderId, uint256 amount);


    // 通用调试事件，用于替代若干特定调试事件，节省字节码并便于统一处理。
    // kind: 1=getInviterFailed, 2=ancestorUpgradeStep, 3=stoppedByGas, etc.
    // subject: 受影响的地址；
    // oldLevel/newLevel: 在升级步骤时的等级对比（否则为 0）
    // 注意：为节省字节码已移除 depth 字段
    event DebugInfo(
        address indexed subject,
        uint8 kind,
        uint8 oldLevel,
        uint8 newLevel
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
        _distributeDailyRewards(false);
        _;
    }

    function updateReward1() public {
        // 原始逻辑在 updateReward1 中仅检查 _totalSupply>0，允许手动/测试时强制分发
        _distributeDailyRewards(true);
    }
    // 抽取到内部函数以避免在 modifier 与外部函数之间重复相同逻辑，节省字节码
    // 如果 force 为 true 则忽略时间间隔检查（用于手动触发或测试）
    function _distributeDailyRewards(bool force) internal {
        if (
            _totalSupply > 0 &&
            (force || block.timestamp >= lastUpdateDailyRewardTime + dailyRewardInterval)
        ) {
            uint256 dayReward = (_totalSupply * dailyRate) / 100;
            // 在分发前对总供应做快照，用于后续按比例权重的计算
            snapshotTotalSupply = _totalSupply;
            _totalSupply = _totalSupply > dayReward ? _totalSupply - dayReward : 0;

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

        // Initialize levelParams for levels 1..9 (index by level) to avoid off-by-one
        for (uint8 lv = 1; lv <= 9; lv++) {
            if (lv <= 6) levelParams[lv] = [21, 500];
            else if (lv == 7) levelParams[lv] = [10, 1000];
            else if (lv == 8) levelParams[lv] = [8, 1200];
            else levelParams[lv] = [5, 2000];
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

        // 增量维护子树总业绩：把新增的订单价值沿 inviter 链向上累加
        _propagateSubtreeDelta(msg.sender, int256(o.stake.value));

        totalPool += amount;
        _totalSupply += amount;
        userOrders[msg.sender].push(orderCount);
        // 记录会员的累计捐赠与预期可获取价值（按每次捐赠时的估值 * outMultiple）
        members[msg.sender].donated += amount;
        members[msg.sender].expectedValue += o.stake.value * outMultiple;
        last30NewPoolTime = block.timestamp;

        upgradeAccountLevel(msg.sender);
        // 自动尝试同步上级等级：在用户 stake 时向上遍历 inviter 链并调用 upgradeAccountLevel
        // 这能让满足条件的上级在下级质押时被自动升级，避免额外手动操作。
        address cur = address(0);
        // 读取直接上级（调用失败将回退）
        cur = IRelation(relShip).getInviter(msg.sender);
    uint8 _depth = 0;
        // 在遍历时同时检查剩余 gas，避免在循环中耗尽 gas 导致整个事务失败。
        while (cur != address(0)) {
            // 记录升级前等级
            uint8 oldLevel = members[cur].level;
            // 尝试升级该上级的等级（内部函数已防止不必要的 SSTORE）
            upgradeAccountLevel(cur);
            // 记录升级后等级并发事件以便线上追踪
            uint8 newLevel = members[cur].level;
            // 统一使用 DebugInfo 记录升级尝试及结果（oldLevel/newLevel 均可为 0 表示无变更）
            emit DebugInfo(cur, 2, oldLevel, newLevel);

            address next = IRelation(relShip).getInviter(cur);
            cur = next;
            _depth++;
            if (_depth >= 100) {
                break;
            }
        }

        // 如果因 gas 不足或深度限制而中断遍历（cur 非 0 表示还有未处理的上级），
        // if (cur != address(0)) {
        //     if (gasleft() <= gasBuffer) {
        //         emit DebugInfo(cur, 3, 0, 0);
        //     }
        // }
        emit Stake(msg.sender, amount, o.stake.value);
    }

    function getReward() external whenNotPaused nonReentrant updateReward {
        if (lastClaimTime[msg.sender] != 0) {
            require(
                block.timestamp >= lastClaimTime[msg.sender] + getIntervalTime,
                "Claim too soon"
            );
        }

        uint256 paid = _claimRewards(msg.sender, RewardType.Main);
        if (paid > 0) {
            lastClaimTime[msg.sender] = block.timestamp;
        }
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
            // 黑洞购买由管理员/keeper 异步触发，改为只累积 blackHolePool（避免在用户领取路径做外部 swap）
            // 通过调用 `executeBlackHoleSwap()`
            executeBlackHoleSwap();
            // 把级别奖励的一部分（4%）直接回流到 `_totalSupply`，以便重新参与后续分发
            // 以前这里是累加到 `totalPool`（只做统计），但业务上该部分应可被再次用于分发。
            _totalSupply += partTotalPool;
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
            // 记录用户已领取的 DINO 数量（链上精确）
            members[msg.sender].received += personalNet;
            // 记录本次领取的价值（USDT 单位），按领取时价格累加（失败将回退）
            members[msg.sender].receivedValue += calculateTokenToValue(personalNet);
            emit RewardPaid(msg.sender, personalNet);
            // record log for level personal payout
            _pushAccountLog(msg.sender, personalNet, 2);

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

        // 新规则（仅对非级别领取生效）: 只要用户在过去 getIntervalTime（默认 4 小时）内有任何一次下单，
        // 则该用户不得进行非级别领取（Main）。Level 类型领取不受此限制。
        if (rtype == RewardType.Main) {
            for (uint256 _i = 0; _i < ids.length; _i++) {
                Order storage _ord = orders[ids[_i]];
                if (_ord.stake.stakeTime + getIntervalTime > block.timestamp) {
                    revert("Order too recent");
                }
            }
        }

        uint256 actualPayout = 0;

        for (uint256 i = 0; i < ids.length; i++) {
            Order storage ord = orders[ids[i]];
            if (ord.isOut) continue;

            // 直接计算 pending，不定义任何中间变量
            // 对于 Main 类型：不在分发阶段预先给上级推荐奖，而是在领取时再分配推荐奖。
            // 因此在这里我们把 ord.rewards.ratio 拆分为两部分：一部分分配给上级（累加到 refReward_map），
            // 另一部分归属于订单所有者（ownerPort）。随后 ownerPort 与 queue + refReward_map[user] 一并作为 pending 发放。
            uint256 ownerPort = 0;
            uint256 pending = 0;
            if (rtype == RewardType.Main) {
                uint256 orderRatio = ord.rewards.ratio;
                if (orderRatio > 0) {
                    uint256 distributedRef = 0;
                    // 第一级理论预留份额为 25%（保留给邀请链）
                    uint256 curRefAmount = (orderRatio * 2500) / 10000; // 25%
                    address cur = IRelation(relShip).getInviter(ord.account);

                    uint256 depth = 0;
                    // MAX_REF_DEPTH = 100, MIN_REF_REWARD = 1 (写死)
                    while (cur != address(0) && depth < 100) {
                        if (curRefAmount < 1) break;
                        uint256 nextAmount = (curRefAmount * 5000) / 10000;
                        uint256 netAmount;
                        if (nextAmount < 1) {
                            netAmount = curRefAmount;
                            curRefAmount = 0;
                        } else {
                            netAmount = curRefAmount - nextAmount;
                            curRefAmount = nextAmount;
                        }

                        if (netAmount >= 1) {
                            refReward_map[cur] += netAmount;
                            distributedRef += netAmount;
                            // Emit an event so on-chain observers can see referral credits
                            emit RefCredit(cur, netAmount, ids[i]);
                        }

                        address next = IRelation(relShip).getInviter(cur);
                        cur = next;
                        depth++;
                        if (curRefAmount == 0) break;
                    }

                    // 当邀请链遍历结束后，若仍有未被分配的预留份额（curRefAmount > 0），
                    // 按新规则这些未分配的邀请链份额应回流到 `_totalSupply`，而不是归于订单所有者。
                    if (curRefAmount > 0) {
                        _totalSupply += curRefAmount;
                        emit RefBackflow(ids[i], curRefAmount);
                        // 未分配部分已回流，curRefAmount 清零以防误用
                        curRefAmount = 0;
                    }

                    // 订单所有者实际应得的比例奖部分 = 总比例奖 - 为邀请链预留的份额(25%)
                    uint256 reserved = (orderRatio * 2500) / 10000;
                    if (orderRatio > reserved) ownerPort = orderRatio - reserved;
                    else ownerPort = 0;
                }

                pending = ord.rewards.queue + ownerPort + refReward_map[user];
            } else {
                pending = ord.rewards.level + ord.rewards.reward30 + ord.rewards.reward70;
            }

            if (pending == 0) continue;

            // 重置奖励（直接操作状态）
            if (rtype == RewardType.Main) {
                ord.rewards.queue = 0;
                // 已把 ord.rewards.ratio 中分配给上级的部分累加到 refReward_map，上级会在各自的 claim 时领取。
                // 这里把订单的比例奖清零（ownerPort 已单独计算并包含在 pending）。
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
                // 如果 pending > allowDino 表示存在超额，需要把超额部分回流到 _totalSupply
                if (pending > allowDino) {
                    uint256 tempExcess = pending - allowDino;
                    _totalSupply += tempExcess;
                    if (rtype == RewardType.Main) {
                        if (refReward_map[user] > 0) {
                            if (tempExcess >= refReward_map[user]) {
                                refReward_map[user] = 0;
                            } else {
                                refReward_map[user] = refReward_map[user] - tempExcess;
                            }
                        }
                    }

                    ord.stake.received = maxValue;
                    // 订单出局：移除其价值对自己和祖先的贡献
                    _propagateSubtreeDelta(ord.account, -int256(ord.stake.value));
                    ord.isOut = true;
                    if (--activeOrders[ord.account] == 0) totalActiveUsers--;
                    actualPayout += allowDino;
                } else {
                    // allowDino >= pending：直接支付 pending（无 excess）
                    ord.stake.received = maxValue;
                    _propagateSubtreeDelta(ord.account, -int256(ord.stake.value));
                    ord.isOut = true;
                    if (--activeOrders[ord.account] == 0) totalActiveUsers--;
                    actualPayout += pending;
                }
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
        // 记录用户已领取的 DINO 数量（链上精确）
        members[user].received += actualPayout;
        // 记录本次领取的价值（USDT 单位）。直接查询价格并累加（调用失败将回退）
        members[user].receivedValue += calculateTokenToValue(actualPayout);
        emit RewardPaid(user, actualPayout);
        // record log for main payout
        _pushAccountLog(user, actualPayout, 4);

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
            // levelActiveSupply will be adjusted inside upgradeAccountLevel when syncing
            upgradeAccountLevel(a);
            emit LevelInitialized(a, level);
        }
    }

    function upgradeAccountLevel(address a) internal {
        // 新的等级判定：基于“小区业绩”（getTeamValue）来计算等级
        // 同时保留由 hasLevelInitialized 提供的初始等级保护（如果已初始化则作为最低门槛）
        // 计算初始保护等级（来自 hasLevelInitialized）
        uint8 target = 0;
        for (uint8 lv = 1; lv <= totalLevel; lv++) {
            if (hasLevelInitialized[lv][a]) {
                target = lv;
                break;
            }
        }

        // 基于小区业绩计算等级，并取更高值作为目标
        uint8 levelFromPerf = getLevelByTeamValue(a);
        if (levelFromPerf > target) target = levelFromPerf;

        if (target == 0) return;

        // 记录旧等级以便更新 levelActiveSupply（若发生变化）
        uint8 oldLevel = members[a].level;

        // 若目标等级等于当前 members 等级，先检测是否所有活跃订单已同步
        if (target == oldLevel) {
            bool needWrite = false;
            for (uint256 i = 0; i < userOrders[a].length; i++) {
                Order storage o = orders[userOrders[a][i]];
                if (!o.isOut && o.level != target) {
                    needWrite = true;
                    break;
                }
            }
            // 如果无需写入，则直接返回，避免额外 SSTORE
            if (!needWrite) return;

            // 否则只写不一致的订单等级（不调整 levelActiveSupply，因为成员等级未变）
            for (uint256 i = 0; i < userOrders[a].length; i++) {
                Order storage o = orders[userOrders[a][i]];
                if (!o.isOut && o.level != target) {
                    o.level = target;
                }
            }
            // 更新快照（安全覆盖）与 members 映射（无实际变化，但保持一致）
            lastLevelRewardPaid[a][target] = rewardPerLevelStored[target];
            members[a].level = target;
            return;
        }

        // 若目标等级与旧等级不同，执行变更：同步订单并调整 levelActiveSupply
        bool hadActive = false;
        for (uint256 i = 0; i < userOrders[a].length; i++) {
            Order storage o = orders[userOrders[a][i]];
            if (!o.isOut) {
                o.level = target;
                hadActive = true;
            }
        }

        // 调整 levelActiveSupply 计数：先减旧等级（如果存在），再增新等级（如果有活跃订单）
        if (oldLevel > 0 && levelActiveSupply[oldLevel] > 0) {
            levelActiveSupply[oldLevel]--;
        }
        if (hadActive) {
            if (levelActiveSupply[target] < type(uint8).max) levelActiveSupply[target]++;
        }

        // 更新用户在该等级的快照，避免历史分配重放
        lastLevelRewardPaid[a][target] = rewardPerLevelStored[target];
        // 同步 members 映射，记录用户等级
        members[a].level = target;
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

    // 测试辅助：在单元测试环境下可由 launcher 设置 blackHolePool（仅用于本地/测试）
    // 注意：生产环境不要滥用该接口；仅用于本地测试脚本快速构造场景。
    function setBlackHolePool(uint256 v) external onlyLauncher {
        blackHolePool = v;
    }

    // === 内部函数 ===
    function distributeLevelReward(uint256 total) internal {
                if (total == 0) return;
        uint256 base = 1000;
        uint256 distributed = 0;
        uint256 backflow = 0; // 未能分配出去应回流的总和（以 DINO 单位）

        for (uint8 lv = 1; lv <= 9; lv++) {
            uint256 cnt = levelActiveSupply[lv];
            uint256 full = lv <= 4
                ? (total * 125) / base
                : (total * 100) / base;

            // 没有符合要求的活跃用户：整份回流到池中
            if (cnt == 0) {
                backflow += full;
                continue;
            }

            // 新规则：当活跃用户数未达到阈值时，先以 full 为基准，再按 levelParams[lv][1] 的万分比缩放；
            // 当达到阈值时，按 full 直接分配。
            uint256 reward;
            if (cnt < levelParams[lv][0]) {
                reward = (full * levelParams[lv][1]) / 10000;
                // 未达到阈值的剩余部分回流
                if (full > reward) backflow += (full - reward);
            } else {
                reward = full;
            }

            // 将该等级的总奖励累加到 rewardPerLevelStored（以 DINO 单位保存总池）
            rewardPerLevelStored[lv] += reward;
            distributed += reward;
        }

        if (distributed > total) distributed = total;

        // dayReward 已在 updateReward 中从 `_totalSupply` 扣除。把未分配/回流的
        // 部分加回 `_totalSupply`，使其可以参与未来的分发。
        if (backflow > 0) {
            _totalSupply += backflow;
        }
        // 记录实际分配给等级用户的数量（减去回流到 `_totalSupply` 的部分）
        if (distributed > 0) {
            _pushAccountLog(address(this), distributed, 3);
        }
    }

    function updateQueueTopList(uint256 pool) internal {
        _pushAccountLog(address(this), pool, 0);
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
        if (pool > 0) {
            rewardPerRatioStored += pool;
        }
         _pushAccountLog(address(this), pool, 1);
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
        }
        newPool -= reward70;
        emit NewPoolTriggered(newPool, value, 0, reward70, block.timestamp);
    }

    // ===== 子树累计相关（增量维护） =====
    /**
     * @dev 将 delta（单位为 stake.value）应用到 user 及其所有上级的 subtreeTotal 中。
     * delta > 0 为增加，delta < 0 为减少。减少操作会在下溢时将值设为 0（防御性处理）。
     * 上溯深度受 MAX_REF_DEPTH 限制，且通过 try/catch 安全调用 relShip。
     */
    function _propagateSubtreeDelta(address user, int256 delta) internal {
        if (user == address(0) || delta == 0) return;

        // 应用到 user 自身
        if (delta > 0) {
            uint256 d = uint256(delta);
            subtreeTotal[user] += d;
        } else {
            uint256 d = uint256(-delta);
            if (subtreeTotal[user] <= d) subtreeTotal[user] = 0;
            else subtreeTotal[user] -= d;
        }

        // 向上传播到所有祖先（受深度限制，防止外部 relShip 返回超深链造成 gas 爆炸）
        address cur = IRelation(relShip).getInviter(user);
    uint256 depth = 0;
    // MAX_REF_DEPTH = 100 (写死)
    while (cur != address(0) && depth < 100) {
            if (delta > 0) {
                uint256 d = uint256(delta);
                subtreeTotal[cur] += d;
            } else {
                uint256 d = uint256(-delta);
                if (subtreeTotal[cur] <= d) subtreeTotal[cur] = 0;
                else subtreeTotal[cur] -= d;
            }

            address next = IRelation(relShip).getInviter(cur);
            cur = next;
            depth++;
        }
    }



    // Fallback：在 subtreeTotal 还未初始化时，计算子树总值（view，仅在回退场景使用）
    function _computeSubtreeRec(address user) internal view returns (uint256) {
        uint256 total = _getUserValue(user);
        address[] memory team = IRelation(relShip).getMyTeam(user);
        for (uint256 i = 0; i < team.length; i++) {
            total += _computeSubtreeRec(team[i]);
        }
        return total;
    }

    function setEarned() internal {
        // Queue: 按订单 stake.balance 加权分配（而不是简单平均）
        if (actualOrderCount > 0 && rewardPerQueueStored > 0) {
            Order[] memory top = getTopNActiveOrders(actualOrderCount);
            if (top.length > 0) {
                // 计算这些排队订单的总 stake.balance
                uint256 totalBalance = 0;
                for (uint256 i = 0; i < top.length; i++) {
                    totalBalance += top[i].stake.balance;
                }
                if (totalBalance > 0) {
                    uint256 distributed = 0;
                    for (uint256 i = 0; i < top.length; i++) {
                        uint256 share = (rewardPerQueueStored * top[i].stake.balance) / totalBalance;
                        // 累加到订单的 queue 奖励（保留历史值）
                        orders[top[i].index].rewards.queue += share;
                        distributed += share;
                    }
                    // 处理因除法产生的舍入误差，把残余加到第一个订单
                    if (rewardPerQueueStored > distributed) {
                        uint256 leftover = rewardPerQueueStored - distributed;
                        orders[top[0].index].rewards.queue += leftover;
                    }
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

                // 推荐分发新规则已简化：不在分发阶段沿邀请链写入 refReward_map，
                // 而是将完整的 orderShare 放入订单的 ratio 槽中，
                // 在用户 claim 时再沿链拆分并把上级份额累加到 refReward_map。
                // 这样可以把邀请链分配集中到 claim 时处理，便于审计与避免分发/claim 重复写入。
                o.rewards.ratio += orderShare;
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

        // 第二步：按用户等级分配奖励（按用户而非订单级别）
        // 每个等级的总份额先按用户数均分（levelActiveSupply 为活跃用户数），
        // 然后再把单个用户的份额按该用户的活跃订单数均分到其订单上。
        for (uint8 lv = 1; lv <= 9; lv++) {
            if (levelActiveSupply[lv] == 0 || rewardPerLevelStored[lv] == 0) continue;
            uint256 perUser = rewardPerLevelStored[lv] / levelActiveSupply[lv];
            for (uint256 i = 0; i < idx; i++) {
                address acct = users[i];
                // 仅按 members 映射的用户级别进行分配（而不是订单级别）
                if (members[acct].level != lv) continue;

                uint256 userActiveCount = activeOrders[acct];
                if (userActiveCount == 0) continue;

                // 新策略：按订单时间（最早订单优先）分配，优先把每笔订单分配到其 cap（maxValue）
                uint256 remainingUser = perUser;
                for (uint256 j = 0; j < userOrders[acct].length; j++) {
                    if (remainingUser == 0) break;
                    Order storage o = orders[userOrders[acct][j]];
                    if (o.isOut) continue;

                    // 每笔订单的上限（USDT 单位）
                    uint256 maxValue = o.stake.value * outMultiple;
                    // 剩余可领取价值（USDT 单位）
                    uint256 remainValue = maxValue > o.stake.received ? maxValue - o.stake.received : 0;
                    if (remainValue == 0) continue;

                    // 把 remainValue（USDT）转换为可领取的 DINO 数量
                    uint256 allowDino = calculateValueToToken(remainValue);
                    if (allowDino == 0) continue;

                    uint256 give = allowDino <= remainingUser ? allowDino : remainingUser;
                    o.rewards.level += give;
                    remainingUser -= give;
                }

                // 如果该用户所有订单已满仍有余额，回流到 _totalSupply（以便未来分配）
                if (remainingUser > 0) {
                    _totalSupply += remainingUser;
                }
            }
            // 本等级的奖励已分配，清零 avoid double-distribution
            rewardPerLevelStored[lv] = 0;
        }
    }

    // === 视图函数 ===
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

    /**
     * @notice 返回用户的统计信息：
     *  - donatedDino: 累计捐赠/质押的 DINO 数量（members[user].donated）
     *  - expectedValueUSDT: 预期可获取的总价值（USDT 最小单位，按每次捐赠价值 * outMultiple 累加，members[user].expectedValue）
     *  - receivedDino: 累计领取的 DINO 数量（members[user].received）
     *  - receivedValueUSDT: 累计领取的价值（USDT 最小单位，按每次领取时价格累加，members[user].receivedValue）
     */
    function getUserClaimed(
        address user
    ) public view returns (
        uint256 donatedDino,
        uint256 expectedValueUSDT,
        uint256 receivedDino,
        uint256 receivedValueUSDT
    ) {
        donatedDino = members[user].donated;
        expectedValueUSDT = members[user].expectedValue;
        receivedDino = members[user].received;
        receivedValueUSDT = members[user].receivedValue;
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
        // getTeamValue 返回的是以 USDT 最小单位（6 位小数）为单位的数值
        uint256 allTeamValue = getTeamValue(user);
        if (allTeamValue == 0) return 0;

        // levelRequiredAmount 已存为最小单位（USDT 的最小单位，等同于 *10e6），因此可直接比较
        for (uint8 i = 0; i < levelRequiredAmount.length; i++) {
            uint256 threshold = levelRequiredAmount[i];
            uint256 nextThreshold = type(uint256).max;
            if (i < levelRequiredAmount.length - 1) {
                nextThreshold = levelRequiredAmount[i + 1];
            }

            bool meetCurrentLevel = allTeamValue >= threshold;
            bool lessThanNextLevel = (i == levelRequiredAmount.length - 1) || (allTeamValue < nextThreshold);

            if (meetCurrentLevel && lessThanNextLevel) {
                return uint8(i + 1);
            }
        }

         // 如果没有匹配任何区间，表示未达到任何等级门槛
            return 0;
    }

    /**
    * @dev 返回用户的大区业绩与小区业绩：
    *  - bigArea: 直推团队中子树业绩最大的那一支（含其下级团队）
    *  - smallArea: 总业绩（所有直推成员含下级）减去 bigArea
    *
    * 为了兼容历史接口，保留 `getTeamValue` 和 `getAllTeamValue` 作为轻量包装，
    * 实际逻辑合并到本函数以避免重复代码。
    */
    function getTeamValues(address user) public view returns (uint256 bigArea, uint256 smallArea) {
        uint256 totalPerf = 0;
        uint256 maxValue = 0;
        address[] memory team = IRelation(relShip).getMyTeam(user);

        for (uint256 i = 0; i < team.length; i++) {
            address member = team[i];
            uint256 val = subtreeTotal[member];
            if (val == 0) {
                // 若尚未增量初始化，则回退到视图计算（可能较贵）
                val = _computeSubtreeRec(member);
            }
            totalPerf += val;
            if (val > maxValue) maxValue = val;
        }

        bigArea = maxValue;
        if (totalPerf > maxValue) smallArea = totalPerf - maxValue;
        else smallArea = 0;
    }

    // 向后兼容的包装：保留原名以免破坏外部调用
    function getTeamValue(address user) public view returns (uint256) {
        (, uint256 smallArea) = getTeamValues(user);
        return smallArea;
    }

    function getAllTeamValue(address user) public view returns (uint256) {
        (uint256 bigArea, ) = getTeamValues(user);
        return bigArea;
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
        // 保持对黑洞 swap 的容错：失败时不回退，记录/忽略失败
        try
            uniswapRouter.swapExactTokensForTokens(
                dinoAmount,
                0,
                path,
                burnWallet,
                block.timestamp + 300
            )
        returns (uint256[] memory) {
            // 成功才扣除
            blackHolePool -= dinoAmount;
        } catch {
            // ignore swap failure to avoid blocking user flows; monitoring via off-chain keeper
        }
    }

    // 手动/受控执行黑洞 swap 的入口
    function executeBlackHoleSwap() public {
        uint256 amount = blackHolePool;
        if (amount == 0) return;
        // 调用内部函数进行 swap（内部会 emit 成功/失败事件并在成功时扣除 blackHolePool）
        calculateTargetToken(amount);
    }

    // 分页查询我的订单
    function getMyOrders(uint256 index, uint256 n) public view returns (Order[] memory myOrders) {
        uint256 cnt = 0;
        address queryer = msg.sender;
        uint256[] memory ids = new uint256[](n);
        // 关键：按投入时间倒叙查询
        for (uint256 id = orderCount; id > 0 && cnt < n; id--) {
            if (orders[id].account == queryer && orders[id].index < index){
                ids[cnt++] = id;
            }
        }
        myOrders = new Order[](cnt);
        for (uint256 i = 0; i < cnt; i++) myOrders[i] = orders[ids[i]];
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
}
