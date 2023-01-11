// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BancorFormula.sol";

abstract contract BondingCurve is ERC20, BancorFormula, Ownable {
    uint32 reserveRatio;
    uint gasPrice = 0 wei;

    function buy() public payable validGasPrice returns (bool) {
        require(msg.value > 0);

        uint256 reserveCurrency = address(this).balance;
        uint256 tokenSupply = totalSupply();
        uint256 tokensToMint = calculatePurchaseReturn(tokenSupply, reserveCurrency, reserveRatio, msg.value);

        _mint(msg.sender, tokensToMint);

        return true;
    }

    function sell(uint256 sellAmount) public validGasPrice returns(bool) {
        require(sellAmount > 0 && balanceOf(msg.sender) >= sellAmount);

        uint256 tokenSupply = totalSupply();
        uint256 reserveCurrency = address(this).balance;
        uint256 ethAmount = calculateSaleReturn(tokenSupply, reserveCurrency, reserveRatio, sellAmount);

        payable(msg.sender).transfer(ethAmount);

        _burn(msg.sender, sellAmount);

        return true;
    }

    modifier validGasPrice() {
        assert(tx.gasprice <= gasPrice);
        _;
    }
}