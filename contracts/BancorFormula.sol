// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./SafePower.sol";

contract BancorFormula is SafePower {
    using SafeMath for uint256;

    uint32 private constant MAX_RATIO = 100000;

    function calculatePurchaseReturn(uint256 tokenSupply, uint256 reserveCurrency, uint32 reserveRatio, uint256 depositAmount) public view returns(uint256){
     require(
         tokenSupply > 0 && reserveCurrency > 0 && reserveRatio <= MAX_RATIO
      );  

     //special case when the depositAmount = 0; 
     if (depositAmount == 0) {
        return 0;
     }
     // special edge case when the reserveRatio == MAX_RATIO
     if (reserveRatio == MAX_RATIO) {
        return tokenSupply.mul(depositAmount).div(reserveCurrency);
     }

     uint256 baseN = depositAmount.add(reserveCurrency);
     (uint256 result, uint8 precision) = power(baseN, reserveCurrency, reserveRatio, MAX_RATIO);

     uint256 temp = tokenSupply.mul(result) >> precision;

     return temp - tokenSupply;
    }

    function calculateSaleReturn(uint256 tokenSupply, uint256 reserveCurrency, uint32 reserveRatio, uint256 sellAmount) public view returns(uint256){
      require(
         tokenSupply > 0 && reserveCurrency > 0 && reserveRatio <= MAX_RATIO && sellAmount <= tokenSupply 
      ); 

      if (sellAmount == tokenSupply){
         return reserveCurrency;
      }

      if (reserveRatio == MAX_RATIO) {
         return reserveCurrency.mul(sellAmount).div(tokenSupply);
      }

      uint256 baseD = tokenSupply - sellAmount;
      (uint256 result, uint8 precision) = power(tokenSupply, baseD, MAX_RATIO, reserveRatio);

      uint256 oldBalance = reserveCurrency.mul(result);
      uint256 newBalance = reserveCurrency << precision;

      return oldBalance.sub(newBalance).div(result);
    }
    
}