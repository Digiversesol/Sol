
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

}
//Certik Recommended the inclusion of the reentrancy guard.
/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function burn(
        address to
    ) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IAntisnipe {
    function assureCanTransfer(
        address sender,
        address from,
        address to,
        uint256 amount
    ) external;
}

contract DIGIVERSE is Context, IERC20, Ownable,ReentrancyGuard {
    using Address for address;

    //Dead Wallet for SAFU Contract
    address public constant deadWallet =
        0x000000000000000000000000000000000000dEaD;
    //Mapping section for better tracking.
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _noFeeWallet;

    event TransferStatus(string,bool);
    event UpdateAntiSnipe(address);
    event UpdateAntiSnipeStatus(bool);
    event UpdateDevOpsWallet(address);
    event UpdateStakingWallet(address);
    event UpdateTokensToSwap(uint256);
    event UpdateBuyFee(uint256);
    event UpdateSellFee(uint256);
    event TransferStatus(bool);
    event UpdateDistribution(uint256, uint256);
    event RecoveredETH(uint256);
    event RecoveredTokens(uint256);
    event TradingStarted(bool);
    event ExcludeStatus(address,bool);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event SwapTokensForETH(uint256 amountIn, address[] path);
    //Supply Definition.
    uint256 private _tTotal = 100_000_000 ether;
    //Token Distribution as requested by certik.
        // Seed
        uint256 private seedAmount = 5000000 ether;
        
        // Private Sale
        uint256 private privateSaleAmount = 1000000 ether;
        
        // Public
        uint256 private publicSaleAmount = 2000000 ether;
        
        // Kols
        uint256 private kolsAmount = 350000 ether;
        
        // Airdrop
        uint256 private airdropAmount = 1000000 ether;
        
        // Stake
        uint256 private stakeAmount = 3000000 ether;
        
        // Team
        uint256 private teamAmount = 10000000 ether;
        
        // Development
        uint256 private developmentAmount = 17000000 ether;
        
        // Marketing
        uint256 private marketingAmount = 7000000 ether;
        
        // Ecosystem
        uint256 private ecosystemAmount = 25650000 ether;
        
        // Advisors
        uint256 private advisorsAmount = 8000000 ether;
        
        // Liquidity
        uint256 private liquidityAmount = 20000000 ether;
    //Token Definition.
    string public constant name = "DIGIVERSE";
    string public constant symbol = "DIGI";
    uint8 public constant decimals = 18;
    //Definition of Wallets for Marketing or team.
    //Definitions of wallets for token distribution for certik requirements.
    address payable public marketingWallet =
        payable(0xF2BAeE0650E5314Be7Edb9fde13C64593aBDb9B5);
    address payable public seedWallet =
        payable(0x7984B279B2A58f2b5f67E835258E00dF33ef3f02);
    address payable public privateSaleWallet =
        payable(0x3fe7E88d5333fEf773dDe4710001A64cD389a9a2);
    address payable public publicSaleWallet =
        payable(0xB647670FAbB9b81CD1e65985d82ab479a88069a0);
    address payable public kolsWallet =
        payable(0x648D23189C40Cd488D6155E1A70036271f7c09f8);
    address payable public airdropWallet =
        payable(0xde5eef2C6CE87dbBDf80D063AbCde4AECc71638e);
    address payable public stakeWallet =
        payable(0x9c9D3bf3D24AdF91Ab013A818AC0b3aF49851A31);
    address payable public teamWallet =
        payable(0x9C5ea6E6B82A1fFa0f2a83c76b9bC4fb55c9e1DC);
    address payable public develomentWallet =
        payable(0xE2d1da613742B85FCBC2Ef6866CF29cC8BAA76E0);
    address payable public ecosystemWallet =
        payable(0x48e3Edd8ED1817E168f48C8792578Cdb73d76562);
    address payable public advisorsWallet =
        payable(0x25B5CAAedB7d1D58974375d4f27f9541E41ba222);
    address payable public liquidityWallet =
        payable(0x9d7DA83F282b99A96B4C0d169237F02FaB7Eb914);

    //Taxes Definition.
    uint public buyFee = 2;

    uint256 public sellFee = 2;

    uint256 public marketingTokensCollected = 0;


    uint256 public minimumTokensBeforeSwap = 500 ether;

    //Oracle Price Update, Manual Process.
    uint256 public swapOutput = 1;

    //Router and Pair Configuration.
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address private immutable WETH;
    //Tracking of Automatic Swap vs Manual Swap.
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;

    IAntisnipe public antisnipe;
    bool public antisnipeDisable;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        //Token Distribution and Balance Update as request by Certik.
        _tOwned[marketingWallet] = marketingAmount;
        _tOwned[seedWallet] = seedAmount;
        _tOwned[privateSaleWallet] = privateSaleAmount;
        _tOwned[publicSaleWallet] = publicSaleAmount;
        _tOwned[kolsWallet] = kolsAmount;
        _tOwned[airdropWallet] = airdropAmount;
        _tOwned[stakeWallet] = stakeAmount;
        _tOwned[teamWallet] = teamAmount;
        _tOwned[develomentWallet] = developmentAmount;
        _tOwned[ecosystemWallet] = ecosystemAmount;
        _tOwned[advisorsWallet] = advisorsAmount;
        _tOwned[liquidityWallet] = liquidityAmount;
        address currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //Mainnet
   
        //Create Pair in the contructor, this may fail on some blockchains and can be done in a separate line if needed.
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(currentRouter);
        WETH = _uniswapV2Router.WETH();
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), WETH);
        uniswapV2Router = _uniswapV2Router;
        _noFeeWallet[owner()] = true;
        _noFeeWallet[address(this)] = true;

        //Transfer of Token Distribution as requested by Certik.
        emit Transfer(address(0), marketingWallet, marketingAmount);
        emit Transfer(address(0), seedWallet, seedAmount);
        emit Transfer(address(0), privateSaleWallet, privateSaleAmount);
        emit Transfer(address(0), publicSaleWallet, publicSaleAmount);
        emit Transfer(address(0), kolsWallet, kolsAmount);
        emit Transfer(address(0), airdropWallet, airdropAmount);
        emit Transfer(address(0), stakeWallet, stakeAmount);
        emit Transfer(address(0), teamWallet, teamAmount);
        emit Transfer(address(0), develomentWallet, developmentAmount);
        emit Transfer(address(0), ecosystemWallet, ecosystemAmount);
        emit Transfer(address(0), advisorsWallet, advisorsAmount);
        emit Transfer(address(0), liquidityWallet, liquidityAmount);
    }

    //Readable Functions.
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    //ERC 20 Standard Transfer Functions
    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    //ERC 20 Standard Allowance Function
    //updated _owner to owner_ as requested by audit.
    function allowance(
        address owner_,
        address spender
    ) external  view override returns (uint256) {
        return _allowances[owner_][spender];
    }

    //ERC 20 Standard Approve Function
    function approve(
        address spender,
        uint256 amount
    ) external  override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    //ERC 20 Standard Transfer From
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        uint currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    //ERC 20 Standard increase Allowance
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) external virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    //ERC 20 Standard decrease Allowance
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) external virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    //Approve Function
    function _approve(address _owner, address spender, uint256 amount) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    //Transfer function, validate correct wallet structure, take fees, and other custom taxes are done during the transfer.
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            _tOwned[from] >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        if (!antisnipeDisable && address(antisnipe) != address(0))
            antisnipe.assureCanTransfer(msg.sender, from, to, amount);

        //Adding logic for automatic swap.
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >=
            minimumTokensBeforeSwap;
        uint fee = 0;
        //if any account belongs to _noFeeWallet account then remove the fee
        if (
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            overMinimumTokenBalance &&
            swapAndLiquifyEnabled
        ) {
            swapAndLiquify();
        }
        if (to == uniswapV2Pair && !_noFeeWallet[from]) {
            fee = (sellFee * amount) / 100;
        }
        if (from == uniswapV2Pair && !_noFeeWallet[to]) {
            fee = (buyFee * amount) / 100;
        }
        amount -= fee;
        if (fee > 0) {
            _tokenTransfer(from, address(this), fee);
            marketingTokensCollected += fee;
        }
        _tokenTransfer(from, to, amount);
    }

    //Swap Tokens for BNB or to add liquidity either automatically or manual, by default this is set to manual.
    //Corrected newBalance bug, it sending bnb to wallet and any remaining is on contract and can be recoverred.
    function swapAndLiquify() private lockTheSwap {
        uint256 totalTokens = balanceOf(address(this));
        swapTokensForEth(totalTokens);
        uint ethBalance = address(this).balance;

        transferToAddressETH(marketingWallet, ethBalance);

        marketingTokensCollected = 0;
    }

    //swap for eth is to support the converstion of tokens to weth during swapandliquify this is a supporting function
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            swapOutput, // it need to be higher than  1, it cannot be 0 as requested by certik.
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    //ERC 20 standard transfer, only added if taking fees to countup the amount of fees for better tracking and split purpose.
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _tOwned[sender] -= amount;
        _tOwned[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }
    //Excluded from Fees for Swap and others.
    function isExcludedFromFee(address account) external view returns (bool) {
        return _noFeeWallet[account];
    }

    //exclude wallets from fees, this is needed for launch or other contracts.
    //changed _noFeeWallet to NoFeeWallet, attempting to adddress Whiteliste Detection Issue.
    function setNoFeeWallets(address account, bool status) external onlyOwner {
        require(_noFeeWallet[account] != status, "The wallet already have that status.");
        _noFeeWallet[account] = status;
        emit ExcludeStatus(account,status);			   
		  
    }
    //Automatic Swap Configuration.
    function setTokensToSwap(
        uint256 _minimumTokensBeforeSwap
    ) external onlyOwner {
        require(
            _minimumTokensBeforeSwap >= 100 ether,
            "You need to enter more than 100 tokens."
        );
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
        emit UpdateTokensToSwap(_minimumTokensBeforeSwap);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        require(swapAndLiquifyEnabled != _enabled, "Value already set");
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    //set a new marketing wallet.
    //set a new team wallet.
    function setMarketingWallet(address _marketingWallet) external onlyOwner {
        require(_marketingWallet != address(0), "setMarketingWallet: ZERO");
        marketingWallet = payable(_marketingWallet);
        emit UpdateStakingWallet(_marketingWallet);
    }

    function transferToAddressETH(
        address payable recipient,
        uint256 amount
    ) private {
        (bool succ, ) = recipient.call{value: amount}("");
        emit TransferStatus(succ);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}


    // Withdraw ETH that's potentially stuck in the Contract
    function recoverETHfromContract() external nonReentrant {
        uint ethBalance = address(this).balance;
        (bool succ, ) = payable(marketingWallet).call{value: ethBalance}("");
        emit TransferStatus(succ);
        emit RecoveredETH(ethBalance);
    }

    // Withdraw ERC20 tokens that are potentially stuck in Contract
    function recoverTokensFromContract(
        address _tokenAddress,
        uint256 _amount
    ) external nonReentrant {
        require(
            _tokenAddress != address(this),
            "Owner can't claim contract's balance of its own tokens"
        );
        bool succ = IERC20(_tokenAddress).transfer(marketingWallet, _amount);
        emit TransferStatus(succ);
        emit RecoveredTokens(_amount);
    }
//function of anti-snipe added by team, this maybe similar to a blacklist function to avoid speciic addressed from transferring tokens.
    function setAntisnipeDisable() external onlyOwner {
        require(!antisnipeDisable);
        antisnipeDisable = true;
        emit UpdateAntiSnipeStatus(true);
    }
//added safety measures to avoid potential problems.
    function setAntisnipeAddress(address addr) external onlyOwner {
        require( addr != address(this),"You can't set contract.");
        require(addr != address(0), "setAntisnipeAddresst: ZERO");
        antisnipe = IAntisnipe(addr);
        emit UpdateAntiSnipe(addr);

    }
}
