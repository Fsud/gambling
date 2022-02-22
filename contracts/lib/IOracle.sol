// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOracle{
    
    event Consult(address token, uint amountIn,uint amountOut);

    function update() external;

    //return包含小数点后8位
    function consult(address token0, address token1, uint amountIn) external returns (uint amountOut);
}