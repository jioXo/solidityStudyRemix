/**
 *Submitted for verification at basescan.org on 2025-11-18
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.21;

/**
開發者免責聲明
本聲明由[AQ]（以下簡稱“開發者”）針對[DINO]（以下簡稱“項目”）的開發與交付作出，明確開發者與項目方（以下簡稱“客戶”）之間的責任界限。 使用本項目的任何人或實體（以下簡稱“用戶”）在使用前應仔細閱讀本聲明。

1.項目合規性
客戶須確保其在使用本項目時遵守所有適用的法律法規、行業標準及相關政策。 開發者在專案開發過程中，已依據客戶的要求提供科技實現及相關服務，但不對客戶使用本項目的合規性作出任何保證或承擔任何責任。

2.違規操作責任

若客戶在使用本項目的過程中，出現任何形式的違規操作，包括但不限於違反法律法規、侵害協力廠商權益、未履行合規性義務等，開發者不對因這些違規操作引發的任何損失、責任、索賠、費用或開支承擔任何責任。 客戶應自行承擔因其違規操作導致的所有後果，並承擔相應的賠償責任。

3.協力廠商風險
本項目可能涉及到與協力廠商服務、系統或平臺的對接。 客戶在使用這些協力廠商服務時，應自行判斷其合法性和合規性。 開發者不對任何協力廠商的行為或產品的合法性、合規性或適用性承擔責任。

Developer Disclaimer

This statement is made by [AQ] (hereinafter referred to as "Developer") for the development and delivery of [DINO] (hereinafter referred to as "project"), and clarifies the responsibility boundary between the developer and the project party (hereinafter referred to as "customer"). Any person or entity using this project (hereinafter referred to as "user") should read this statement carefully before using it.

1. Project Compliance
Customers must ensure that they comply with all applicable laws, regulations, industry standards and relevant policies when using this project. During the project development process, the developer has provided technical implementation and related services according to the customer's requirements, but does not make any guarantee or assume any responsibility for the compliance of the customer's use of this project.

2. Responsibility for Illegal Operations
If the customer has any form of illegal operation during the use of this project, including but not limited to violation of laws and regulations, infringement of third-party rights, failure to perform compliance obligations, etc., the developer shall not be responsible for any losses, liabilities, claims, costs or expenses caused by these illegal operations. The customer shall bear all consequences caused by its illegal operations and bear the corresponding compensation liability.

3. Third-party risks
This project may involve docking with third-party services, systems or platforms. When using these third-party services, customers should make their own judgments on their legality and compliance. Developers are not responsible for the legality, compliance, or applicability of any third-party actions or products.
**/
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);

    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct Int256Slot {
        int256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    function getInt256Slot(bytes32 slot) internal pure returns (Int256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }

    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }
}

abstract contract ReentrancyGuard {
    using StorageSlot for bytes32;

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant REENTRANCY_GUARD_STORAGE =
        0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    error ReentrancyGuardReentrantCall();

    constructor() {
        _reentrancyGuardStorageSlot().getUint256Slot().value = NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    modifier nonReentrantView() {
        _nonReentrantBeforeView();
        _;
    }

    function _nonReentrantBeforeView() private view {
        if (_reentrancyGuardEntered()) {
            revert ReentrancyGuardReentrantCall();
        }
    }

    function _nonReentrantBefore() private {
        _nonReentrantBeforeView();
        _reentrancyGuardStorageSlot().getUint256Slot().value = ENTERED;
    }

    function _nonReentrantAfter() private {
        _reentrancyGuardStorageSlot().getUint256Slot().value = NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _reentrancyGuardStorageSlot().getUint256Slot().value == ENTERED;
    }

    function _reentrancyGuardStorageSlot() internal pure virtual returns (bytes32) {
        return REENTRANCY_GUARD_STORAGE;
    }
}


interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC1363 is IERC20, IERC165 {

    function transferAndCall(address to, uint256 value) external returns (bool);

    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    function approveAndCall(address spender, uint256 value) external returns (bool);

    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

library SafeERC20 {

    error SafeERC20FailedOperation(address token);

    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        if (!_safeTransfer(token, to, value, true)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        if (!_safeTransferFrom(token, from, to, value, true)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _safeTransfer(token, to, value, false);
    }

    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _safeTransferFrom(token, from, to, value, false);
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        if (!_safeApprove(token, spender, value, false)) {
            if (!_safeApprove(token, spender, 0, true)) revert SafeERC20FailedOperation(address(token));
            if (!_safeApprove(token, spender, value, true)) revert SafeERC20FailedOperation(address(token));
        }
    }

    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    function _safeTransfer(IERC20 token, address to, uint256 value, bool bubble) private returns (bool success) {
        bytes4 selector = IERC20.transfer.selector;

        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(0x00, selector)
            mstore(0x04, and(to, shr(96, not(0))))
            mstore(0x24, value)
            success := call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
            // if call success and return is true, all is good.
            // otherwise (not success or return is not true), we need to perform further checks
            if iszero(and(success, eq(mload(0x00), 1))) {
                // if the call was a failure and bubble is enabled, bubble the error
                if and(iszero(success), bubble) {
                    returndatacopy(fmp, 0x00, returndatasize())
                    revert(fmp, returndatasize())
                }
                // if the return value is not true, then the call is only successful if:
                // - the token address has code
                // - the returndata is empty
                success := and(success, and(iszero(returndatasize()), gt(extcodesize(token), 0)))
            }
            mstore(0x40, fmp)
        }
    }

    function _safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value,
        bool bubble
    ) private returns (bool success) {
        bytes4 selector = IERC20.transferFrom.selector;

        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(0x00, selector)
            mstore(0x04, and(from, shr(96, not(0))))
            mstore(0x24, and(to, shr(96, not(0))))
            mstore(0x44, value)
            success := call(gas(), token, 0, 0x00, 0x64, 0x00, 0x20)
            // if call success and return is true, all is good.
            // otherwise (not success or return is not true), we need to perform further checks
            if iszero(and(success, eq(mload(0x00), 1))) {
                // if the call was a failure and bubble is enabled, bubble the error
                if and(iszero(success), bubble) {
                    returndatacopy(fmp, 0x00, returndatasize())
                    revert(fmp, returndatasize())
                }
                // if the return value is not true, then the call is only successful if:
                // - the token address has code
                // - the returndata is empty
                success := and(success, and(iszero(returndatasize()), gt(extcodesize(token), 0)))
            }
            mstore(0x40, fmp)
            mstore(0x60, 0)
        }
    }

    function _safeApprove(IERC20 token, address spender, uint256 value, bool bubble) private returns (bool success) {
        bytes4 selector = IERC20.approve.selector;

        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(0x00, selector)
            mstore(0x04, and(spender, shr(96, not(0))))
            mstore(0x24, value)
            success := call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
            // if call success and return is true, all is good.
            // otherwise (not success or return is not true), we need to perform further checks
            if iszero(and(success, eq(mload(0x00), 1))) {
                // if the call was a failure and bubble is enabled, bubble the error
                if and(iszero(success), bubble) {
                    returndatacopy(fmp, 0x00, returndatasize())
                    revert(fmp, returndatasize())
                }
                // if the return value is not true, then the call is only successful if:
                // - the token address has code
                // - the returndata is empty
                success := and(success, and(iszero(returndatasize()), gt(extcodesize(token), 0)))
            }
            mstore(0x40, fmp)
        }
    }
}

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
    function getMyTeam(address account) external view returns (address[] memory);
}

interface ILastFinance {
    function getAccountGrade(address account) external view returns (uint8);
}

contract DINOFinanceTokenV3 is Ownable(msg.sender), ReentrancyGuard {
    using SafeERC20 for IERC20;

    // === 外部合约 ===
    IUniswapV2Router02 internal immutable uniswapRouter;
    address internal relShip;
    IERC20 public DINOToken;
    address[2] public launcher;

    // address internal usdt = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913; 
    // address internal constant uRouter = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
    // address internal constant TARGET_TOKEN = 0x6dB171BC785386973994072729D8fC707C2948e4;
    // address internal burnWallet = 0x000000000000000000000000000000000000dEaD;

    // address public marketingWallet;
    // address public immutable WETH;

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
    uint256 internal snapshotTotalSupply;
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
        bool isOut;
        uint256 index;
        address account;
        uint256 ratioDebt; // used by accRatioPerShare model to track per-order reward debt
    }

    mapping(uint256 => Order) internal orders;
    uint256 public orderCount;
    mapping(address => uint256[]) internal userOrders;
    mapping(address => uint256) internal activeOrders;
    uint256 internal totalActiveUsers;

    uint256 internal activeValidOrderCount;
    uint256 internal activeTotalStake;
    // list of active accounts (have activeOrders > 0) to avoid scanning all orders
    address[] internal activeAccounts;
    mapping(address => uint256) internal activeAccountIndex;

    // === 等级分红 ===
    mapping(uint256 => uint256) internal rewardPerLevelStored;
    mapping(address => mapping(uint256 => uint256))
        internal lastLevelRewardPaid;
    mapping(uint8 => uint8) public levelActiveSupply;
    uint256 internal actualOrderCount;
    uint256 public lastUpdateDailyRewardTime;
    uint256 public dailyRewardInterval = 1 days;

    // === 领取限制 ===
    uint256 internal constant RATIO_SCALE = 1e18;
    mapping(address => uint256) internal lastClaimTime;
    uint256 public getIntervalTime = 4 hours;
    uint256 internal minRequiredAmount = 100 ether;
    uint8 internal  outMultiple = 2;
    // 旧的即时排队分配已移除（使用 epoch snapshot 机制替代）
    uint256 internal blackHolePool;
    uint256 internal last30NewPoolTime = 0;

    // === 日志 & 等级 ===
    struct Log {
        uint256 timestamp;
        uint256 quantity;
        uint256 value;
        uint8 from;
    }
    mapping(address => Log[]) internal accountLogs;

    // 日志来源代码：
    // 0 = 队列分配总金额 updateQueueTopList
    // 1 = 比例分配总金额  distributeRatioReward
    // 2 = 用户领取级别奖励 getLevelReward
    // 3 = 新池分配总金额 distributeLevelReward
    // 4 = 为指定用户结算并（根据类型）支付奖励 _claimRewards（总体 payout）
    // 5 = 为指定用户结算时单独记录“排队奖”支付部分 _claimRewards（queue 部分）
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

    // === 排队奖队列相关 ===
    // 当前排队奖队列的最新 快照 ID 
    uint256 public queueEpoch;
    // 快照 ID -> 该快照分配的总排队奖金额
    mapping(uint256 => uint256) public queueEpochReward;
    // 快照 ID -> 该快照创建时的初始分配金额（用于按固定初始值计算每个 order 的份额）
    mapping(uint256 => uint256) public queueEpochInitialReward;
    // 累计已分配（用于判断是否已分发完，便于清理）
    // NOTE: 为减少合约体积，已移除显式的 queueEpochAllocated 存储。
    // 可通过 queueEpochInitialReward[epoch] - queueEpochReward[epoch] 推导已分配量。
    event QueueEpochProcessingTruncated(uint256 indexed orderId, uint256 processed, uint256 remaining);
    // 快照 ID -> 该快照中包含的总权益余额（用于份额计算）
    mapping(uint256 => uint256) public queueEpochTotalBalance;
    // 快照 ID -> 包含的订单列表
    mapping(uint256 => uint256[]) internal queueEpochOrders;
    // 分批登记相关状态：记录待登记数量与已登记索引
    mapping(uint256 => uint256) public queueEpochRemainingCount;
    mapping(uint256 => uint256) public queueEpochRecordedIndex;
    // (legacy) 分片登记相关状态已移除；本份实现把 top-N 在 epoch 创建时一次性登记
    // 订单 ID -> 包含的快照列表
    mapping(uint256 => uint256[]) internal orderQueueEpochs;
    // 订单 ID -> 在对应快照列表中的索引位置
    mapping(uint256 => uint256) internal orderQueueEpochIndex;
    // Maintain an on-chain top-N list to avoid full-table scans at epoch creation
    uint256 public constant QUEUE_TOP_N = 50;
    uint256[] internal queueTopList; // current top-N order ids
    mapping(uint256 => uint256) public queueTopIndex;
    // 订单 ID -> 最近已处理的 queue epoch ID （懒处理模型使用）
    mapping(uint256 => uint256) internal orderLastProcessedEpoch;


    // --- Ratio epoch (deferred ratio reward) ---
    uint256 internal ratioEpoch;
    // are replaced by the `accRatioPerShare` model to avoid OOG when distributing to many orders.
    mapping(uint256 => uint256) public ratioEpochReward;
    mapping(uint256 => uint256) public ratioEpochInitialReward;
    mapping(uint256 => uint256) public ratioEpochTotalBalance;
    // accumulated ratio per share scaled by RATIO_SCALE
    uint256 public accRatioPerShare;

    function getQueueEpochInfo(uint256 epoch) public view returns (
        uint256 reward,
        uint256 initial,
        uint256 totalBalance,
        uint256 remainingCount,
        uint256 ordersCount
    ) {
        reward = queueEpochReward[epoch];
        initial = queueEpochInitialReward[epoch];
        totalBalance = queueEpochTotalBalance[epoch];
        // remainingCount is number of order ids still to be recorded for this epoch
        remainingCount = queueEpochRemainingCount[epoch];
        // ordersCount is number of order ids already recorded into the epoch
        ordersCount = queueEpochRecordedIndex[epoch];
    }

    // levelRequiredAmount 存为标准的 USDT 最小单位（每项 = 人类可读值 * 1e6）
    // 例如：数组项 `1_000` 表示 1_000 USDT，可表示为 1_000 * 1e6 = 1_000_000_000
    uint256[] internal levelRequiredAmount = [
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
    uint256 internal dailyRate = 5;  // 每日释放
    uint256 internal queueRate = 10; // 排队奖
    uint256 internal ratioRate = 50; // 比例奖
    uint256 internal levelRate = 40; // 级别奖
    uint256 internal recRate = 25;   // 推荐奖
    uint256 internal levelPesRate = 80; // 级别奖个人
    uint256 internal levelMktRate = 5; // 级别奖营销
    uint256 internal levelBakRate = 4; // 级别奖反流
    uint256 internal levelSwpRate = 9; // 级别奖兑换
    uint256 internal levelPoolRate = 2; // 级别奖新奖池

    uint256 internal nostakePoolRate = 30; // 一小时没有捐赠释放比例
    uint256 internal nostakeTimeout = 1 hours; // 一小时没有捐赠释放比例
    uint256 internal fullPoolRate = 70; // 奖池满比例
    uint256 internal fullPoolCount = 100; // 奖池满分发订单数
    uint256 internal fullPoolThreshold = 100_000_000_000; // 满奖池阈值

    uint256 internal totalLevel = 9;
    mapping(address => bool) public blacklist;
    bool public stakeState = true;

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
    mapping(address => bool) public syncAccountLevel;
    mapping(uint8 => mapping(address => bool)) public hasLevelInitialized;
    mapping(address => uint256) public refReward_map;
    // 子树累计业绩（包含自身 + 所有下级），以 stake.value 单位计
    mapping(address => uint256) public teamPerformances;

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

    event LevelInitialized(address indexed account, uint8 level);

    // Unified epoch events to save bytecode and on-chain event types
    // kind: 0 = Queue, 1 = Level, 2 = Ratio
    event EpochCreated(uint8 indexed kind, uint256 indexed epoch, uint256 a, uint256 b, uint256 c);
    event EpochOrderRecorded(uint8 indexed kind, uint256 indexed epoch, uint256 indexed orderId, uint256 stakeBalance);
    event EpochProcessed(uint8 indexed kind, uint256 indexed epoch, uint256 indexed orderId, uint256 amount);
    // 当某个 queue epoch 的所有订单都已被处理，但该 epoch 仍有少量残余奖励时，回收该残余
    event QueueEpochResidualReclaimed(uint256 indexed epoch, uint256 amount);
    // 当兑换销毁时触发
    event SwapError(address indexed account, uint256 blackhole, uint256 dinoAmt, uint256 trexAmt);

    // === 修饰器 ===
    modifier onlyLauncher() {
        require((msg.sender == launcher[0] || msg.sender == launcher[1]), "Not launcher");
        _;
    }

    modifier updateReward() {
        _distributeDailyRewards(false);
        _;
    }

    function updateReward1() public{
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

            updateQueueTopList((dayReward* queueRate) / 100);
            _autoRecordQueueOrders();
            distributeLevelReward((dayReward * levelRate) / 100);
            distributeRatioReward((dayReward * ratioRate) / 100);

            // clear snapshot after distribution
            snapshotTotalSupply = 0;
            lastUpdateDailyRewardTime = block.timestamp;
            // rewardPerRatioStored = 0;
        }
    }

    modifier checkLevel(address account) {
        if (isSyncLevel && lastFinance != address(0)) {
            uint8 lastLevel = ILastFinance(lastFinance).getAccountGrade(account);
            if (lastLevel > 0 && lastLevel <= totalLevel &&
                !hasLevelInitialized[lastLevel][account] &&
                !syncAccountLevel[account]
            ) {
                if(lastLevel > 0 && lastLevel < totalLevel){
                    lastLevel++;
                }
                hasLevelInitialized[lastLevel][account] = true;
                syncAccountLevel[account] = true;
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
        launcher[0] = msg.sender;

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
     function stake(uint256 amount) external nonReentrant checkLevel(msg.sender) updateReward {
        require(msg.sender.code.length == 0, "NotEOA");
        require(amount >= minRequiredAmount, "Toosmall");
        require(stakeState, "Stake disabled");

        DINOToken.safeTransferFrom(msg.sender, address(this), amount);

        if (activeOrders[msg.sender] == 0) {
            totalActiveUsers++;
            // add to activeAccounts
            activeAccountIndex[msg.sender] = activeAccounts.length;
            activeAccounts.push(msg.sender);
        }
        activeOrders[msg.sender]++;

        // 在新的 stake 交互中，先处理该账户可能存在的未结算 epochs（懒处理）
        // (level + per-order queue/ratio)，通过 helper 统一处理以减少重复代码。
        processPendingEpochsForUser(msg.sender);

        Order storage o = orders[++orderCount];
        o.index = orderCount;
        o.account = msg.sender;
        o.stake.balance = amount;
        o.stake.value = calculateTokenToValue(amount);
        o.stake.remain = o.stake.value * outMultiple;
        o.stake.stakeTime = block.timestamp;
        // initialize ratio debt so new orders don't retroactively receive past ratio distributions
        o.ratioDebt = (o.stake.balance * accRatioPerShare) / RATIO_SCALE;

        // 只在 stake 时累加，不在出局时减少，避免重复累加。
        achievement(msg.sender, o.stake.value);

        totalPool += amount;
        _totalSupply += amount;
        userOrders[msg.sender].push(orderCount);
        // maintain incremental totals used by updateQueueTopList to avoid O(orderCount) scan
        activeValidOrderCount += 1;
        activeTotalStake += amount;
        // maintain chain-side top-N list incrementally to avoid large SSTORE bursts later
        _tryAddToTopList(orderCount);
        // 记录会员的累计捐赠与预期可获取价值（按每次捐赠时的估值 * outMultiple）
        members[msg.sender].donated += amount;
        members[msg.sender].expectedValue += o.stake.value * outMultiple;
  
           // 触发 newPool 分发逻辑（30%）
        if(last30NewPoolTime > 0){
            distributeNewPool30Percent();
        }
        last30NewPoolTime = block.timestamp;
    
        emit Stake(msg.sender, amount, o.stake.value);
    }

     // 处理某一订单的未结算 queue epoch，把份额累加到 orders[orderId].rewards.queue
    function processOrderQueueEpochs(uint256 orderId) internal {
        Order storage ord = orders[orderId];
        if (ord.isOut) return;

        uint256 last = orderLastProcessedEpoch[orderId];
        uint256 curEpoch = last + 1;
        // scan newly created epochs and check whether this order is included in each
        for (uint256 eid = curEpoch; eid <= queueEpoch; eid++) {
            uint256 reward = queueEpochReward[eid];
            uint256 initial = queueEpochInitialReward[eid];
            uint256 total = queueEpochTotalBalance[eid];

            // if nothing to distribute or no weight, mark as processed and continue
            if (reward == 0 || total == 0) {
                orderLastProcessedEpoch[orderId] = eid;
                continue;
            }

            // scan the small top-N list for membership
            uint256[] storage ids = queueEpochOrders[eid];
            bool found = false;
            for (uint256 j = 0; j < ids.length; j++) {
                if (ids[j] == orderId) {
                    found = true;
                    break;
                }
            }

            // mark processed even if not found to advance pointer
            orderLastProcessedEpoch[orderId] = eid;

            if (!found) {
                // not part of this epoch's top-N
                continue;
            }

            // compute share based on epoch's initial and total balance
            uint256 share = 0;
            if (initial > 0 && total > 0) {
                share = (initial * ord.stake.balance) / total;
            }

            if (share == 0) {
                // nothing practically distributable
                continue;
            }

            ord.rewards.queue += share;
            emit EpochProcessed(0, eid, orderId, share);

            if (queueEpochReward[eid] > share) queueEpochReward[eid] -= share;
            else queueEpochReward[eid] = 0;
        }
    }

    // 处理某一订单的未结算 ratio epochs（把份额累加到 orders[orderId].rewards.ratio）
    function processOrderRatioEpochs(uint256 orderId) internal {
        // Using accRatioPerShare model: compute current accumulated debt and credit delta to order
        Order storage ord = orders[orderId];
        if (ord.isOut) return;
        uint256 currentDebt = (ord.stake.balance * accRatioPerShare) / RATIO_SCALE;
        if (currentDebt > ord.ratioDebt) {
            uint256 delta = currentDebt - ord.ratioDebt;
            ord.rewards.ratio += delta;
            ord.ratioDebt = currentDebt;
            // emit a generic processed event (epoch unknown here), use 2 as kind with epoch=0
            emit EpochProcessed(2, 0, orderId, delta);
        }
    }

    // 把 perUser 分配到用户订单的逻辑抽成一个内部函数，返回未分配的剩余值
    function _allocateLevelToUserOrders(address user, uint256 perUser) internal returns (uint256) {
        uint256 remaining = perUser;
        uint256[] storage uords = userOrders[user];
        for (uint256 j = 0; j < uords.length && remaining > 0; j++) {
            uint256 oid = uords[j];
            Order storage ord = orders[oid];
            if (ord.isOut) continue;
            if (ord.stake.remain <= ord.stake.received) continue;
            uint256 remainingValue = ord.stake.remain - ord.stake.received;
            uint256 allowedDino = calculateValueToToken(remainingValue);
            if (allowedDino == 0) continue;
            uint256 toAlloc = remaining <= allowedDino ? remaining : allowedDino;
            ord.rewards.level += toAlloc;
            remaining -= toAlloc;
        }
        return remaining;
    }

    // 处理用户的未结算 level epochs（把每个 epoch 的 perUser 分配到该用户的订单上）
    // legacy per-user epoch processing removed — baseline model used instead

    // 统一处理用户的未结算 epoch：先处理 level epoch（按用户），再对该用户的每个活跃订单
    // 处理 queue 与 ratio 的 order-level epochs（懒处理）。抽象出来以减少重复代码。
    function processPendingEpochsForUser(address user) internal {
        // try to auto-record a small batch for latest epoch during this interaction
        _autoRecordQueueOrders();
        // Apply baseline per-level snapshot (rewardPerLevelStored) lazily to the user's orders.
        uint8 currLevel = members[user].level;
        if (currLevel > 0) {
            uint256 baseline = 0;
            if (rewardPerLevelStored[currLevel] > lastLevelRewardPaid[user][currLevel]) {
                baseline = rewardPerLevelStored[currLevel] - lastLevelRewardPaid[user][currLevel];
            }
            if (baseline > 0) {
                lastLevelRewardPaid[user][currLevel] = rewardPerLevelStored[currLevel];
                uint256 remaining = _allocateLevelToUserOrders(user, baseline);
                if (remaining > 0) {
                    // return unallocatable remainder to total supply
                    _totalSupply += remaining;
                }
            }
        }

        // 然后对该用户的所有订单做 queue/ratio 懒处理，便于在单处调用时暴露最新分配
        uint256[] storage uords = userOrders[user];
        for (uint256 _i = 0; _i < uords.length; _i++) {
            uint256 _oid = uords[_i];
            if (_oid == 0) continue;
            if (!orders[_oid].isOut) {
                processOrderQueueEpochs(_oid);
                processOrderRatioEpochs(_oid);
            }
        }
    }

    function getReward() external nonReentrant updateReward {
        // if (lastClaimTime[msg.sender] != 0) {
        //     require(
        //         block.timestamp >= lastClaimTime[msg.sender] + getIntervalTime,
        //         "Claim too soon"
        //     );
        // }
        //如果有未处理的排队奖记录，禁止领取主奖池奖励，等待stake或者getLevelReward处理完毕
        if(queueEpochRemainingCount[queueEpoch] > 0){
            require(queueEpochRemainingCount[queueEpoch] == 0, "Pending queue record");
        }

        uint256 paid = _claimRewards(msg.sender, RewardType.Main);
        if (paid > 0) {
            lastClaimTime[msg.sender] = block.timestamp;
        }
    }

    function getLevelReward() external nonReentrant updateReward {
        // 获取用户的级别奖金总额（以 DINO 单位返回），但不要在 _claimRewards 内做转账
        uint256 grossLevelPayout = _claimRewards(msg.sender, RewardType.Level);

        if (grossLevelPayout > 0) {
            // 按规则拆分：2% 新奖池、9% 黑洞、4% 返还总池、5% 营销，剩余 80% 为个人份额
             uint256 partNewPool = (grossLevelPayout * levelPoolRate) / 100;
            uint256 partBlackHole = (grossLevelPayout * levelSwpRate) / 100;
            uint256 partTotalPool = (grossLevelPayout * levelBakRate) / 100;
            uint256 partMarketing = (grossLevelPayout * levelMktRate) / 100;

            uint256 personalPart = grossLevelPayout -
                (partNewPool + partBlackHole + partTotalPool + partMarketing);

            // 累计到新奖池/总池/黑洞/营销
            newPool += partNewPool;
            blackHolePool += partBlackHole;
            // 黑洞购买由管理员/keeper 异步触发，改为只累积 blackHolePool（避免在用户领取路径做外部 swap）
            _executeBlackHoleSwap();
            // 把级别奖励的一部分（4%）直接回流到 `_totalSupply`，以便重新参与后续分发
            // 以前这里是累加到 `totalPool`（只做统计），但业务上该部分应可被再次用于分发。
            _totalSupply += partTotalPool;
            if (partMarketing > 0 && marketingWallet != address(0)) {
                DINOToken.safeTransfer(marketingWallet, partMarketing);
            }

            // 对个人部分先扣手续费，然后转给用户
            uint256 personalNet = personalPart;

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

            // 触发 newPool 分发逻辑（70%）
            distributeNewPool70Percent();
        }
    }

    enum RewardType {
        Main,
        Level
    }

    function _claimRewards(address user, RewardType rtype) internal returns (uint256) {
        require(!blacklist[user], "Blacklisted");
        uint256[] memory ids = userOrders[user];
        require(ids.length > 0, "No orders");

        // auto-record disabled in this branch

        // 新规则（仅对非级别领取生效）: 只要用户在过去 getIntervalTime（默认 4 小时）内有任何一次下单，
        // 则该用户不得进行非级别领取（Main）。Level 类型领取不受此限制。
        // if (rtype == RewardType.Main) {
        //     for (uint256 _i = 0; _i < ids.length; _i++) {
        //         Order storage _ord = orders[ids[_i]];
        //         if (_ord.stake.stakeTime + getIntervalTime > block.timestamp) {
        //             revert("Order too recent");
        //         }
        //     }
        // }


        uint256 actualPayout = 0;
        // 本次领取中实际由排队奖支付的累计量（DINO 单位），用于统一写入日志
        uint256 totalQueuePaid = 0;

        // 在领取入口统一处理该用户的所有 pending epochs（level + per-order queue/ratio），
        // 以便后续遍历订单时能直接看到已分配的值。
        processPendingEpochsForUser(user);

        // For Level-type claims: also apply baseline snapshot rewards (rewardPerLevelStored)
        // to the user's orders lazily here to avoid per-level per-user writes at distribution time.
        if (rtype == RewardType.Level) {
            uint8 currLevel = members[user].level;
            if (currLevel > 0) {
                uint256 baseline = 0;
                if (rewardPerLevelStored[currLevel] > lastLevelRewardPaid[user][currLevel]) {
                    baseline = rewardPerLevelStored[currLevel] - lastLevelRewardPaid[user][currLevel];
                }
                if (baseline > 0) {
                    // advance user's baseline pointer
                    lastLevelRewardPaid[user][currLevel] = rewardPerLevelStored[currLevel];
                    // allocate baseline DINO to user's orders (lazy per-order writes)
                    uint256 remaining = _allocateLevelToUserOrders(user, baseline);
                    if (remaining > 0) {
                        // unallocatable remainder returns to total supply
                        _totalSupply += remaining;
                    }
                }
            }
        }

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            Order storage ord = orders[id];
            if (ord.isOut) continue;

            // 把单笔订单的核算逻辑抽到单独函数，减少本函数局部变量使用，避免 stack too deep
            (uint256 payoutForOrder, uint256 paidFromQueueThisOrder) = _claimOrder(id, user, rtype);
            if (payoutForOrder == 0 && paidFromQueueThisOrder == 0) continue;
            actualPayout += payoutForOrder;
            totalQueuePaid += paidFromQueueThisOrder;
        }

        if (actualPayout == 0) {
            emit RewardPaid(user, 0);
            return 0;
        }

        // 对于 Level 类型：不要在此处执行转账（由 getLevelReward 统一拆分并转账）
        if (rtype == RewardType.Level) {
            return actualPayout;
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

        // 记录本次领取中来自排队奖的部分（单独一条日志，来源码 5）
        if (totalQueuePaid > 0) {
            _pushAccountLog(user, totalQueuePaid, 5);
        }

        return actualPayout;
    }

    // === 配置函数 ===
    function setLauncher(uint256 idx, address _launcher) external onlyLauncher {
        require(idx < 2, "Too big");
        launcher[idx] = _launcher;
    }

    // 开启级别同步
    function setSyncLevelParams(bool _isSyncLevel, address _lastFinance) external onlyLauncher {
        isSyncLevel = _isSyncLevel;
        lastFinance = _lastFinance;
    }

    function setblacklist(address a, bool v) external onlyLauncher {
        blacklist[a] = v;
    }

    function setState(bool v) external onlyLauncher {
        stakeState = v;
    }


    function initLevelData(uint8 level,address[] memory accounts) external onlyLauncher {
        require(level > 0 && level <= totalLevel, "Invalid level");
        for (uint256 i = 0; i < accounts.length; i++) {
            address a = accounts[i];
            require(a != address(0), "Zero addr");
            hasLevelInitialized[level][a] = true;
            if (!syncAccountLevel[a]) syncAccountLevel[a] = true;
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
        uint8 levelFromPerf = getLevelByTeamValue(a);
        if (levelFromPerf > target) target = levelFromPerf;

        if (target == 0) return;

        uint8 oldLevel = members[a].level;
        if (oldLevel == target) {
            // 等级未变，只需确保快照一致（避免历史分配重放）
            lastLevelRewardPaid[a][target] = rewardPerLevelStored[target];
            return;
        }

        // 调整活跃用户计数（如果用户当前有活跃订单才计入 levelActiveSupply）
        if (oldLevel > 0 && levelActiveSupply[oldLevel] > 0) {
            levelActiveSupply[oldLevel]--;
        }
        if (levelActiveSupply[target] < type(uint8).max) {
            levelActiveSupply[target]++;
        }

        // 更新等级快照并写入 members
        lastLevelRewardPaid[a][target] = rewardPerLevelStored[target];
        members[a].level = target;
    }

    function setLevelRequiredAmount( uint256 i, uint256 v) external onlyLauncher {
        require(i < 9 && v > 0);
        levelRequiredAmount[i] = v;
    }

    function setLevelDailyRates(uint8 i, uint256 v) external onlyLauncher {
        require(i <= 9 && v <= 99);
        levelParams[i][1] = v * 100;
    }

    // 设置发奖间隔
    function setDailyRewardInterval(uint256 v) external onlyLauncher {
        dailyRewardInterval = v;
    }

    // 设置领奖间隔
    function setGetIntervalTime(uint256 v) external onlyLauncher {
        getIntervalTime = v;
    }

    // 设置捐赠奖励参数   
    function setStakeParams(uint256 _minAmt, uint256 _dayRate, 
        uint256 _lvRate, uint256 _queRate, uint256 _ratRate, uint256 _recRate) external onlyLauncher {
        minRequiredAmount = _minAmt;
        dailyRate = _dayRate;
        levelRate = _lvRate;
        queueRate = _queRate;
        ratioRate = _ratRate;
        recRate = _recRate;
    }

    // 设置级别奖励参数   
    function setLevelParams(uint256 _pesRate, uint256 _mktRate, 
        uint256 _swpRate, uint256 _bakRate, uint256 _poolRate) external onlyLauncher {
        levelPesRate = _pesRate;
        levelMktRate = _mktRate;
        levelSwpRate = _swpRate;
        levelBakRate = _bakRate;
        levelPoolRate = _poolRate;
    }

    // 设置新奖池比例
    function setNewPoolParams(uint256 _nostkTime, uint256 _nostkRate, uint256 _fullCount,
        uint256 _fullAmt, uint256 _fullRate) external onlyLauncher {
        nostakeTimeout = _nostkTime;
        nostakePoolRate = _nostkRate;
        fullPoolCount = _fullCount;
        fullPoolThreshold = _fullAmt;
        fullPoolRate = _fullRate;
    }

    function setMarketingWallet(address v) external onlyLauncher {
        require(v != address(0));
        marketingWallet = v;
    }

    // === 内部函数 ===
    function distributeLevelReward(uint256 total) internal {
        if (total == 0) return;

        uint256 distributed = 0;
        uint256 backflow = 0;

        for (uint8 lv = 1; lv <= 9; lv++) {
            uint256 cnt = levelActiveSupply[lv];
            // base share: levels 1-4 get 12.5% each (125/1000), others 10% (100/1000)
            uint256 full = lv <= 4 ? (total * 125) / 1000 : (total * 100) / 1000;

            if (cnt == 0) {
                backflow += full;
                continue;
            }

            uint256 reward;
            // if active count below threshold, scale down by levelParams[lv][1] (万分比)
            if (cnt < levelParams[lv][0]) {
                reward = (full * levelParams[lv][1]) / 10000;
                if (full > reward) backflow += (full - reward);
            } else {
                reward = full;
            }

            if (reward == 0) continue;

            // per-account amount (DINO) to be accounted as a baseline snapshot
            uint256 perUser = reward / cnt;
            if (perUser == 0) {
                // nothing practically distributable; return whole reward to pool
                backflow += reward;
                continue;
            }

            rewardPerLevelStored[lv] += perUser;
            distributed += perUser * cnt; // account for integer division truncation
        }

        // Ensure we don't distribute more than `total` and return leftovers
        if (distributed > total) distributed = total;
        if (backflow > 0) _totalSupply += backflow;
        if (distributed > 0) _pushAccountLog(address(this), distributed, 3);
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

        uint256 totalValidOrders = activeValidOrderCount;
        uint256 totalBalance = activeTotalStake;

        actualOrderCount = totalValidOrders < max ? totalValidOrders : max;

        // 如果存在有效订单，把这次队列奖励做成一个 epoch 快照，实际的 top-N ID 会在后续由用户交互分批登记。
        if (actualOrderCount > 0) {
            // 创建 epoch
            uint256 epoch = ++queueEpoch;
            queueEpochReward[epoch] = pool;
            // 保存初始分配量（用于按固定初始值计算每个 order 的份额，避免处理顺序影响）
            queueEpochInitialReward[epoch] = pool;

            // 存储期望的 totalBalance 与 expected count
            if (totalBalance == 0) {
                // 回流
                _totalSupply += pool;
                queueEpochReward[epoch] = 0;
                return;
            }
            queueEpochTotalBalance[epoch] = totalBalance;
            // Do NOT prefill order ids here to avoid a single large SSTORE burst and high gas.
            // Defer actual id recording to `recordEpochOrderBatch` / `_autoRecordQueueOrders`
            // which will be executed in bounded batches during user interactions.
            queueEpochRecordedIndex[epoch] = 0;
            queueEpochRemainingCount[epoch] = actualOrderCount;
            emit EpochCreated(0, epoch, pool, totalBalance, actualOrderCount);
        }
    }

    // External batch recorder: records up to `count` top-N active order ids for `epoch`.
    // Returns number of ids recorded in this call.
    function recordEpochOrderBatch(uint256 epoch, uint256 count) public returns (uint256) {
        require(epoch > 0 && epoch <= queueEpoch, "Invalid epoch");
        uint256 remaining = queueEpochRemainingCount[epoch];
        if (remaining == 0 || count == 0) return 0;

        uint256 start = queueEpochRecordedIndex[epoch];
        uint256 toRecord = count > remaining ? remaining : count;

        uint256[] memory ids = getTopNActiveOrderIds(start, toRecord);
        uint256 recorded = 0;
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 oid = ids[i];
            queueEpochOrders[epoch].push(oid);
            orderQueueEpochs[oid].push(epoch);
            emit EpochOrderRecorded(0, epoch, oid, orders[oid].stake.balance);
            recorded++;
        }

        if (recorded > 0) {
            queueEpochRecordedIndex[epoch] = start + recorded;
            queueEpochRemainingCount[epoch] = remaining - recorded;
        }

        return recorded;
    }

    // Small auto-record trigger executed during user interactions to progressively
    // register top-N ids. It records up to `autoRecordBatchSize` ids for the latest epoch.
    uint256 internal autoRecordBatchSize = 20;

    function setAutoRecordBatchSize(uint256 v) external onlyLauncher {
        require(v > 0 && v <= 1000, "invalid batch");
        autoRecordBatchSize = v;
    }

    function _autoRecordQueueOrders() internal {
        if (queueEpoch == 0) return;
        uint256 epoch = queueEpoch;
        uint256 remaining = queueEpochRemainingCount[epoch];
        if (remaining == 0) return;
        // record a bounded batch for the latest epoch
        recordEpochOrderBatch(epoch, autoRecordBatchSize);
    }


    // legacy: auto-recording removed in this branch to keep contract size smaller

    // batch recorder removed in this branch

    function distributeRatioReward(uint256 pool) internal {
        _pushAccountLog(address(this), pool, 1);
        if (pool == 0) return;
        if (snapshotTotalSupply == 0) {
            _totalSupply += pool;
            return;
        }

        uint256 epoch = ++ratioEpoch;
        accRatioPerShare += (pool * RATIO_SCALE) / snapshotTotalSupply;
        emit EpochCreated(2, epoch, pool, snapshotTotalSupply, 0);
    }

    function distributeNewPool30Percent() internal {
        if (
            block.timestamp < last30NewPoolTime + nostakeTimeout ||
            newPool == 0
        ) return;

        Order[] memory orders20 = getNewNActiveOrders(20);
        if (orders20.length == 0) return; // 没有可分配的订单
        uint256 reward30 = (newPool * nostakePoolRate) / 100;
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
        if (value < fullPoolThreshold) return;
        uint256 reward70 = (newPool * fullPoolRate) / 100;
        Order[] memory orders100 = getNewNActiveOrders(fullPoolCount);
        if (orders100.length == 0) return; // 没有可分配的订单
        uint256 per = reward70 / orders100.length;
        for (uint256 i = 0; i < orders100.length; i++) {
            orders[orders100[i].index].rewards.reward70 += per;
        }
        newPool -= reward70;
        emit NewPoolTriggered(newPool, value, 0, reward70, block.timestamp);
    }


    // 在新的逻辑中：仅在 stake 时增加业绩（没有减少分支）
    function achievement(address account, uint256 delta) internal {
        if (delta == 0 || account == address(0)) return;

        // 给当前账户增加业绩
        teamPerformances[account] += delta;

        // 每次更新后尝试触发等级重算，并记录升级前后的等级以便追踪
        upgradeAccountLevel(account);

        // 向上遍历邀请链，把增量累加到每一层（深度上限 100）
        // 直接调用 getInviter（任何外部错误将向上抛出）
        // NOTE: first inviter must be fetched for the supplied `account` (bugfix)
        address superior = IRelation(relShip).getInviter(account);
        for (uint256 curLoop = 0; superior != address(0) && curLoop < 100; curLoop++) {
            teamPerformances[superior] += delta;
            // 尝试升级该上级并记录变更
            upgradeAccountLevel(superior);
            superior = IRelation(relShip).getInviter(superior);
        }
    }

    // --- top-N list maintenance helpers ---
    function _tryAddToTopList(uint256 orderId) internal {
        if (orderId == 0) return;
        if (queueTopIndex[orderId] != 0) return; // already present
        uint256 len = queueTopList.length;
        uint256 bal = orders[orderId].stake.balance;
        if (len < QUEUE_TOP_N) {
            queueTopList.push(orderId);
            queueTopIndex[orderId] = len + 1;
            return;
        }

        // find minimum stake in top list
        uint256 minIdx = 0;
        uint256 minStake = type(uint256).max;
        for (uint256 i = 0; i < len; i++) {
            uint256 oid = queueTopList[i];
            uint256 b = orders[oid].stake.balance;
            if (b < minStake) {
                minStake = b;
                minIdx = i;
            }
        }

        if (bal > minStake) {
            uint256 replaced = queueTopList[minIdx];
            queueTopList[minIdx] = orderId;
            queueTopIndex[replaced] = 0;
            queueTopIndex[orderId] = minIdx + 1;
        }
    }

    function _removeFromTopList(uint256 orderId) internal {
        uint256 idx1 = queueTopIndex[orderId];
        if (idx1 == 0) return;
        uint256 idx = idx1 - 1;
        uint256 last = queueTopList.length - 1;
        if (idx != last) {
            uint256 lastId = queueTopList[last];
            queueTopList[idx] = lastId;
            queueTopIndex[lastId] = idx + 1;
        }
        queueTopList.pop();
        queueTopIndex[orderId] = 0;
    }

  // 将原本在 _claimRewards 中的邀请链分发逻辑抽到此处，返回订单所有者实际应得的 ownerPort（DINO 单位）
    function _distributeReferral(uint256 orderRatio, uint256 orderId, address account) internal returns (uint256 ownerPort) {
        if (orderRatio == 0) return 0;

        uint256 curRefAmount = (orderRatio * recRate) / 100; // 25% reserved for referral chain
        address cur ;
        cur = IRelation(relShip).getInviter(account);
        uint256 depth = 0;
        uint256 backflowLocal = 0;
        while (cur != address(0) && depth < 100) {
            if (curRefAmount < 1) break;
            uint256 nextAmount = (curRefAmount * 50) / 100;
            uint256 netAmount;
            if (nextAmount < 1) {
                netAmount = curRefAmount;
                curRefAmount = 0;
            } else {
                netAmount = curRefAmount - nextAmount;
                curRefAmount = nextAmount;
            }

            if (netAmount >= 1) {
                if (activeOrders[cur] > 0) {
                    refReward_map[cur] += netAmount;
                    emit RefCredit(cur, netAmount, orderId);
                } else {
                    backflowLocal += netAmount;
                }
            }

            address next;
            next = IRelation(relShip).getInviter(cur);
            cur = next;
            depth++;
            if (curRefAmount == 0) break;
        }

        if (curRefAmount > 0) {
            backflowLocal += curRefAmount;
            curRefAmount = 0;
        }
        if (backflowLocal > 0) {
            _totalSupply += backflowLocal;
            emit RefBackflow(orderId, backflowLocal);
        }

        uint256 reserved = (orderRatio * 2500) / 10000;
        if (orderRatio > reserved) ownerPort = orderRatio - reserved;
        else ownerPort = 0;
    }

    // 返回值为本订单实际由 queue 支付的数量（DINO 单位）。
    function _consumeExcessAndComputePaidFromQueue(
        uint256 qQueue,
        uint256 ownerPort,
        uint256 tempExcess,
        address user
    ) internal returns (uint256 paidFromQueue) {
        if (tempExcess == 0) {
            return qQueue; // 没有要扣减的，queue 全额支付
        }

        uint256 refBal = refReward_map[user];
        if (refBal > 0) {
            if (tempExcess >= refBal) {
                tempExcess -= refBal;
                refReward_map[user] = 0;
            } else {
                refReward_map[user] = refBal - tempExcess;
                tempExcess = 0;
            }
        }

        if (tempExcess == 0) {
            return qQueue; // ref 扣除后无超额，queue 未被扣减
        }

        uint256 sumQR = qQueue + ownerPort;
        if (sumQR > 0) {
            uint256 deductQ = (qQueue * tempExcess) / sumQR;
            uint256 deductR = tempExcess - deductQ;
            _totalSupply += (deductQ + deductR);
            if (qQueue > deductQ) paidFromQueue = qQueue - deductQ;
            else paidFromQueue = 0;
        } else {
            // 没有 queue 与 ownerPort，则直接回流剩余
            _totalSupply += tempExcess;
            paidFromQueue = 0;
        }
    }

    // 以及本笔订单中实际由 queue 支付的量（paidFromQueue），用于汇总日志
    function _claimOrder(uint256 id, address user, RewardType rtype) internal returns (uint256 payout, uint256 paidFromQueue) {
        Order storage ord = orders[id];
        if (ord.isOut) return (0, 0);

        uint256 ownerPort = 0;
        uint256 pending = 0;
        if (rtype == RewardType.Main) {
            uint256 orderRatio = ord.rewards.ratio;
            if (orderRatio > 0) {
                ownerPort = _distributeReferral(orderRatio, id, ord.account);
            }
            pending = (ord.rewards.queue + ownerPort + refReward_map[user] + ord.rewards.reward30 + ord.rewards.reward70);
        } else {
            pending = ord.rewards.level;
        }

        if (pending == 0) return (0, 0);

        uint256 qQueue = ord.rewards.queue;
        uint256 maxValue = ord.stake.remain;
        uint256 pendingValue = calculateTokenToValue(pending);

        if (ord.stake.received + pendingValue > maxValue) {
            uint256 allowDino = calculateValueToToken(maxValue - ord.stake.received);
            uint256 tempExcess = pending - allowDino;

            paidFromQueue = _consumeExcessAndComputePaidFromQueue(qQueue, ownerPort, tempExcess, user);

            ord.stake.received = maxValue;
            ord.isOut = true;
            // remove from chain-side top list if present
            _removeFromTopList(id);
            if (activeValidOrderCount > 0) activeValidOrderCount -= 1;
            if (activeTotalStake >= ord.stake.balance) activeTotalStake -= ord.stake.balance;
            if (activeOrders[ord.account] > 0) activeOrders[ord.account]--;
            if (activeOrders[ord.account] == 0) {
                totalActiveUsers--;
                uint256 idx = activeAccountIndex[ord.account];
                uint256 lastIdx = activeAccounts.length - 1;
                if (idx != lastIdx) {
                    address last = activeAccounts[lastIdx];
                    activeAccounts[idx] = last;
                    activeAccountIndex[last] = idx;
                }
                activeAccounts.pop();
                delete activeAccountIndex[ord.account];
            }

            payout = allowDino;
        } else {
            ord.stake.received += pendingValue;
            payout = pending;
            if (rtype == RewardType.Main) {
                if (refReward_map[user] > 0) refReward_map[user] = 0;
                paidFromQueue = qQueue;
            }
        }

        // 重置奖励槽
        if (rtype == RewardType.Main) {
            ord.rewards.queue = 0;
            ord.rewards.ratio = 0;
            ord.rewards.reward30 = 0;
            ord.rewards.reward70 = 0;
        } else {
            ord.rewards.level = 0;
        }

        return (payout, paidFromQueue);
    }


   function pendingEarned(address user) public view returns (uint256 reward, uint256 value) {
        if (activeOrders[user] == 0) return (0, 0);
        uint256 pending = 0;
        uint256 received = 0;
        uint256 cap = 0;

        pending += refReward_map[user];
        for (uint256 i = 0; i < userOrders[user].length; i++) {
            uint256 oid = userOrders[user][i];
            Order storage o = orders[oid];
            if (o.isOut) continue;

            // include unprocessed ratio delta based on accRatioPerShare (acc model)
            uint256 unprocessedRatio = 0;
            uint256 currentDebt = (o.stake.balance * accRatioPerShare) / RATIO_SCALE;
            if (currentDebt > o.ratioDebt) unprocessedRatio = currentDebt - o.ratioDebt;

            // include already-accumulated queue rewards stored in the order
            pending += (o.rewards.queue + o.rewards.ratio + unprocessedRatio + o.rewards.reward30 + o.rewards.reward70);

            // recorded per-order epoch ids are handled by _computePendingFromEpochs below

            // 模拟延迟按需处理：扫描 orderLastProcessedEpoch 到当前 queueEpoch
            // 并在 view 中计算那些尚未实际写入到订单记录中的分配份额（不改变状态）
            uint256 lastProcessed = orderLastProcessedEpoch[oid];
            uint256 startEpoch = lastProcessed + 1;
            if (startEpoch <= queueEpoch) {
                pending += _computePendingFromEpochs(oid, startEpoch, queueEpoch);
            }

            received += o.stake.received;
            cap += o.stake.remain; // 可释放总价值
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

    function pendingEarnedLevel(address user) public view returns (uint256 reward, uint256 value) {
        if (activeOrders[user] == 0) return (0, 0);
        uint256 pending = 0;
        uint256 received = 0;
        uint256 cap = 0;
 
        // 已分配到订单上的等级奖励
        for (uint256 i = 0; i < userOrders[user].length; i++) {
            Order storage o = orders[userOrders[user][i]];
            if (o.isOut) continue;
            pending += o.rewards.level;
            received += o.stake.received;
            cap += o.stake.remain;  // 可释放总价值
        }

     
        uint8 currLevel = members[user].level;
        if (currLevel > 0 && rewardPerLevelStored[currLevel] > lastLevelRewardPaid[user][currLevel]) {
            uint256 baseline = rewardPerLevelStored[currLevel] - lastLevelRewardPaid[user][currLevel];
            pending += baseline;
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
 * @dev 仅返回活跃订单的ID（替代原getTopNActiveOrders）
 * @param offset 偏移量（分页用，0表示从第一个开始）
 * @param n 要返回的订单数量上限
 * @return orderIds 符合条件的活跃订单ID数组
 */
function getTopNActiveOrderIds(
    uint256 offset,
    uint256 n
) internal view returns (uint256[] memory orderIds) {
    // 边界条件：n=0直接返回空数组
    if (n == 0) {
        return new uint256[](0);
    }
    uint256 totalOrderCount = orderCount; // cache
    uint256 seen = 0; // number of valid orders seen so far
    uint256 filled = 0; // number of ids added to result
    orderIds = new uint256[](n);

    for (uint256 id = 1; id <= totalOrderCount && filled < n; id++) {
        if (!orders[id].isOut && activeOrders[orders[id].account] > 0) {
            if (seen >= offset) {
                orderIds[filled++] = id;
            }
            seen++;
        }
    }

    // if we filled fewer than n, shrink the array
    if (filled == 0) return new uint256[](0);
    if (filled < n) {
        uint256[] memory small = new uint256[](filled);
        for (uint256 i = 0; i < filled; i++) small[i] = orderIds[i];
        return small;
    }
    return orderIds;
}

    // Helper: compute pending queue share for `oid` across epochs [startEpoch, endEpoch]
    // Extracted to avoid stack-too-deep when calling from larger functions.
    function _computePendingFromEpochs(
        uint256 oid,
        uint256 startEpoch,
        uint256 endEpoch
    ) internal view returns (uint256 sum) {
        sum = 0;
        for (uint256 eid = startEpoch; eid <= endEpoch; eid++) {
            uint256 initialE = queueEpochInitialReward[eid];
            uint256 totalE = queueEpochTotalBalance[eid];
            if (initialE == 0 || totalE == 0) continue;
            uint256[] storage ids = queueEpochOrders[eid];
            bool found = false;
            for (uint256 k = 0; k < ids.length; k++) {
                if (ids[k] == oid) {
                    found = true;
                    break;
                }
            }
            if (!found) continue;
            uint256 bal = orders[oid].stake.balance;
            uint256 shareE = (initialE * bal) / totalE;
            sum += shareE;
        }
        return sum;
    }

    // 返回从第 `offset` 个有效订单开始的最多 `n` 条有效订单（正序，从最旧到最新）。
    function getTopNActiveOrders(uint256 offset, uint256 n) public view returns (Order[] memory res) {
        if (n == 0) return new Order[](0);
        uint256[] memory ids = new uint256[](n);
        uint256 cnt = 0;
        uint256 seen = 0; // number of valid orders seen so far
        for (uint256 id = 1; id <= orderCount && cnt < n; id++) {
            if (!orders[id].isOut && activeOrders[orders[id].account] > 0) {
                if (seen >= offset) {
                    ids[cnt++] = id;
                }
                seen++;
            }
        }
        res = new Order[](cnt);
        for (uint256 i = 0; i < cnt; i++) res[i] = orders[ids[i]];
    }


    function getNewNActiveOrders(uint256 n) public view returns (Order[] memory res) {
        uint256[] memory ids = new uint256[](n);
        uint256 cnt = 0;
        // 关键：从最大订单ID（最新订单）开始遍历，取前 n 个有效订单
        for (uint256 id = orderCount; id > 0 && cnt < n; id--)
            if (!orders[id].isOut && activeOrders[orders[id].account] > 0)
                ids[cnt++] = id;
        res = new Order[](cnt);
        for (uint256 i = 0; i < cnt; i++) res[i] = orders[ids[i]];
    }

    function getLevelByTeamValue(address user) public view returns (uint8 level) {
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
            uint256 val = teamPerformances[member];
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

    // internal executor for black hole swap — no public call allowed
    function _executeBlackHoleSwap() internal {
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