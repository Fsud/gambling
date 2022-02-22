// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/FeedRegistryInterface.sol";
import "@chainlink/contracts/src/v0.8/Denominations.sol";

contract PriceConsumer {
    FeedRegistryInterface internal registry;

    /**
     * Network: Ethereum Kovan
     * Feed Registry: 0xAa7F6f7f507457a1EE157fE97F6c7DB2BEec5cD0
     */
    constructor(address _registry) {
        registry = FeedRegistryInterface(_registry);
    }

    event Consult(address token0,address token1, uint amountIn,uint amountOut);
    
    function update() external{
        //empty
    }
    
    //  默认8位小数
    function consult(address token0,address token1, uint amountIn) external returns (uint amountOut){
        uint price = uint(getPrice(token0, token1));
        emit Consult(token0, token1, amountIn, price);
        return price;
    }



    /**
     * Returns the ETH / USD price
     */
    function getEthUsdPrice() public view returns (int) {
        (
            ,
            int price,
            ,
            ,
            
        ) = registry.latestRoundData(Denominations.ETH, Denominations.USD);
        return price;
    }

    /**
     * Returns the latest price
     */
    function getPrice(address base, address quote) public view returns (int) {
        (
            , 
            int price,
            ,
            ,
            
        ) = registry.latestRoundData(base, quote);
        return price;
    }
}
