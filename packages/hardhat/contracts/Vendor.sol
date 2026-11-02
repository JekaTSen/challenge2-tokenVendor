pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

    uint256 public constant tokensPerEth = 100;



    /////////////////
    /// Errors //////
    /////////////////

    error InvalidEthAmount();
    error InsufficientVendorTokenBalance(uint256 available, uint256 required);
    error EthTransferFailed(address to, uint256 amount);
    error BalanceIsZero();
    error InvalidTokenAmount();
    error InsufficientVendorEthBalance(uint256 available, uint256 required);

    //////////////////////
    /// State Variables //
    //////////////////////

    YourToken public immutable yourToken;

    ////////////////
    /// Events /////
    ////////////////

    event BuyTokens(address indexed buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(address indexed seller, uint256 amountOfTokens, uint256 amountOfETH);

    ///////////////////
    /// Constructor ///
    ///////////////////

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    ///////////////////
    /// Functions /////
    ///////////////////

    function buyTokens() external payable {
        if (msg.value == 0 ether) revert InvalidEthAmount();

        uint256 tokensToBuy = msg.value * tokensPerEth;
        uint256 vendorBalance = yourToken.balanceOf(address(this));
        if(vendorBalance < tokensToBuy) revert InsufficientVendorTokenBalance(vendorBalance, tokensToBuy);

        // if(yourToken.balanceOf(address(this)) < tokensToBuy) revert InsufficientVendorTokenBalance(yourToken.balance, tokensToBuy);
        // (success, ) = yourToken.transfer(msg.sender, tokensToBuy);
        // if(!success) revert UnsuccessfulTransfer();

        yourToken.transfer(msg.sender, tokensToBuy);
        emit BuyTokens(msg.sender, msg.value, tokensToBuy);

    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        if(amount == 0) revert BalanceIsZero();

        // (bool, ) = address(this).
        // (bool success, ) = payable(msg.sender).call{value : amount}("");
        (bool success,) = owner().call{value: amount}(""); 

        // The difference between payable(...) and owner().call that the functiona can be call by everyone and with owner only by owner
        // Even we have modifier onlyOwner it's more correct to use owner().call

        // if(!success) revert EthTransferFailed();
        if(!success) revert EthTransferFailed(owner(), amount);


    }

    function sellTokens(uint256 amount) public {
        if(amount == 0) revert InvalidTokenAmount();
        
        uint256 amountOfEth = amount / tokensPerEth;
        uint256 vendorEthBalance = address(this).balance;

        if(vendorEthBalance < amountOfEth) revert InsufficientVendorEthBalance(vendorEthBalance, amountOfEth);

        // yourToken.approve(address(this), tokensToSell);

        // (bool success, ) = yourToken.transferFrom(address.this, msg.sender, tokensToSell);
        (bool success,) = msg.sender.call{value: amountOfEth}("");
        if (!success) revert EthTransferFailed(msg.sender, amountOfEth);

        emit SellTokens(msg.sender, amount, amountOfEth);
    }
}
