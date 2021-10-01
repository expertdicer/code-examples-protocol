pragma solidity ^0.8.0;
pragma abicoder v2;

import "./aave/FlashLoanReceiverBaseV2.sol";
import "../../interfaces/v2/ILendingPoolAddressesProviderV2.sol";
import {ILendingPoolV2} from "../../interfaces/v2/ILendingPoolV2.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {ISwapRouter} from "../../interfaces/v2/ISwapRouter.sol";
import "../../libraries/v2/TransferHelper.sol";

contract FlashloanV2 is FlashLoanReceiverBaseV2, Withdrawable {
    using SafeMath for uint256;
    ISwapRouter public immutable swapRouter;
    uint24 public constant poolFee = 3000;

    // kovan reserve asset addresses
    address kovanAave = 0xB597cd8D3217ea6477232F9217fa70837ff667Af;
    address kovanDai = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
    address kovanLink = 0xAD5ce863aE3E4E9394Ab43d4ba0D80f419F61789;
    address kovanADai = 0xdCf0aF9e59C002FA3AA091a46196b37530FD48a8;

    constructor(address _addressProvider, ISwapRouter _swapRouter)
        FlashLoanReceiverBaseV2(_addressProvider)
    {
        swapRouter  = _swapRouter;

    }

    /**
     * @dev This function must be called only be the LENDING_POOL and takes care of repaying
     * active debt positions, migrating collateral and incurring new V2 debt token debt.
     *
     * @param assets The array of flash loaned assets used to repay debts.
     * @param amounts The array of flash loaned asset amounts used to repay debts.
     * @param premiums The array of premiums incurred as additional debts.
     * @param initiator The address that initiated the flash loan, unused.
     * @param params The byte array containing, in this case, the arrays of aTokens and aTokenAmounts.
     */
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        //
        // This contract now has the funds requested.
        // Your logic goes here.
        //

        // At the end of your logic above, this contract owes
        // the flashloaned amounts + premiums.
        // Therefore ensure your contract has enough to repay
        // these amounts.
        
        // initialise lending pool instance
        ILendingPoolV2 lendingPool = ILendingPoolV2(LENDING_POOL);
        
        // deposits the flashed AAVE, DAI and Link liquidity onto the lending pool
        flashDeposit(lendingPool, amounts[0]);

        //uint256 borrowAmt = 100 * 1e18; // to borrow 100 units of x asset
        
        // borrows 'borrowAmt' amount of LINK using the deposited collateral
        //flashBorrow(lendingPool, kovanLink, borrowAmt);
        
        // repays the 'borrowAmt' mount of LINK to unlock the collateral
        //flashRepay(lendingPool, kovanLink, borrowAmt);
 
        // withdraws the AAVE, DAI and LINK collateral from the lending pool
        flashWithdraw(lendingPool, amounts[0]);
        

        // Approve the LendingPool contract allowance to *pull* the owed amount
        // i.e. AAVE V2's way of repaying the flash loan

        for (uint256 i = 0; i < assets.length; i++) {
            uint256 amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }

        return true;
    }

    /*
    * Deposits the flashed AAVE, DAI and LINK liquidity onto the lending pool as collateral
    */
    function flashDeposit(ILendingPoolV2 _lendingPool, uint256 _amount) internal {
        // approve lending pool
        IERC20(kovanDai).approve(address(LENDING_POOL), _amount);
        // deposit the flashed AAVE, DAI and LINK as collateral
        _lendingPool.deposit(kovanDai, _amount, address(this), uint16(0));
        
    }

    /*
    * Withdraws the AAVE, DAI and LINK collateral from the lending pool
    */
    function flashWithdraw(ILendingPoolV2 _lendingPool, uint256 _amount) internal {
        _lendingPool.withdraw(kovanDai, _amount, address(this));
    }

    function _flashloan(address[] memory assets, uint256[] memory amounts)
        internal
    {
        address receiverAddress = address(this);

        address onBehalfOf = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;

        uint256[] memory modes = new uint256[](assets.length);

        // 0 = no debt (flash), 1 = stable, 2 = variable
        for (uint256 i = 0; i < assets.length; i++) {
            modes[i] = 0;
        }

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }

    /*
     *  Flash multiple assets
     */
    function flashloan(address[] memory assets, uint256[] memory amounts)
        public
        onlyOwner
    {
        _flashloan(assets, amounts);
    }

    /*
     *  Flash loan 100000000000000000 wei (0.1 ether) worth of `_asset`
     */
    function flashloan(address _asset) public onlyOwner {
        bytes memory data = "";
        uint256 amount = 100000000000000000;

        address[] memory assets = new address[](1);
        assets[0] = _asset;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        _flashloan(assets, amounts);
    }
}
