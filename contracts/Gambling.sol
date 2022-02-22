// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./lib/UniswapV2Library.sol";
import "./lib/UniswapV2OracleLibrary.sol";

contract Gambling {

        
    // 更通用的方案可以实现合约服用，支持存储多个赌局，暂未实现
    // mapping (address => Game) pairMap;

    // struct Game{
    //     address token0;
    //     address token1;
    //     address endTime;

    //     address player0;
    //     address player1;

    //     uint256 amount;
    // }

    address constant FACTORY = "";
    address token0;
    address token1;
    uint256 gamblingPrice;
    uint256 endTime;
    bool player0bigger; //player0下注的是否是“>=” gamblingPrice

    address player0;
    address player1;
    uint256 amount;

    address pair;

    //玩家0开设赌局
    constructor(address _token0, address _token1, uint256 _endTime, uint256 _gamblingPrice, bool _bigger) payable {
        require(msg.value >0 , "creater amount less than 0");
        require(block.timestamp < _endTime, "endTime has reached");
        //传入的两个token需按大小排列，这样gambling价格就是token0/token1的比值，也方便uniswap pair获取
        require(_token0 < _token1, "token0 and token1 should diffrent and in order");
        token0 = _token0;
        token1 = _token1;
        endTime = _endTime;
        player0bigger = _bigger;
        gamblingPrice = _gamblingPrice;
        pair = UniswapV2Library.pairFor(FACTORY, token0, token1);
        amount = msg.value;
        player0 = msg.sender;
    }

    //玩家1加入赌局
    function join() payable public{
        require(player1 == address(0) , "player1 has joined");
        require(msg.value == amount , "joiner amount wrong");
        require(block.timestamp < endTime, "endTime has reached");
        player1 = msg.sender;
    }

    //赢家提款
    function withdraw() public{
        require(block.timestamp > endTime, "endTime not reached");
        require(player1 != address(0) , "player1 not join, please exit");
        require(address(this).balance > 0, "no balance");
        //v2瞬时价格，会被闪电攻击，考虑使用v3的接口替换
        (
            uint256 price0Cumulative,
            uint256 price1Cumulative,
            uint32 blockTimestamp
        ) = UniswapV2OracleLibrary.currentCumulativePrices(pair);

        address winner;
        if(price0Cumulative >= gamblingPrice){
            winner = player0bigger ? player0 : player1;
        }else{
            winner = player0bigger ? player1 : player0;
        }
        (bool sent,) = winner.call{value:address(this).balance}("");
        require(sent, "failed to send Ether");
    }

    //玩家0退出
    function exit() public{
        require(player0 == msg.sender , "only player0 can exit");
        require(player1 == address(0) , "player1 has joined");
        (bool sent,) = player0.call{value:address(this).balance}("");
        require(sent, "failed to send Ether");
    }
}
