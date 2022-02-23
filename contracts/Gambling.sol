// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./lib/UniswapV2Library.sol";
import "./lib/UniswapV2OracleLibrary.sol";
import "./lib/IOracle.sol";

contract Gambling {

    //-----
    //第一版原本实现的是可以打赌任意token pair。后面发现无论是uniswap oracle，还是 chainlink oracle
    //都没有找到方法可以通用的获取任意token pair或 任意币 的价格，所以暂且仅实现 DAI/WETH交易对
    //---------    
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
    //---------

    IOracle oracle;
    address token0; // eth address
    address token1; // dai address


    uint256 gamblingPrice; //每eth价值多少dai
    uint256 endTime;
    bool player0bigger; //player0下注的是否是“>=” gamblingPrice

    address player0;
    address player1;
    uint256 amount;


    event Start(address sender, address _token0, address _token1, uint256 _endTime, uint256 _gamblingPrice,
        bool _bigger, uint256 amount);

    event Join(address sender, uint256 amount);

    event Withdraw(address winner, uint256 price, uint256 amount);

    event Exit(address sender, uint256 amount);

    constructor(address _oracle, address _token0, address _token1){
        oracle = IOracle(_oracle);
        token0 = _token0;
        token1 = _token1;
    }

    //玩家0开设赌局
    function start(uint256 _endTime, uint256 _gamblingPrice,
        bool _bigger) public payable {
        require(player0 == address(0) , "gambling has start");
        require(msg.value >0 , "creater amount less than 0");
        require(block.timestamp < _endTime, "endTime has reached");
        endTime = _endTime;
        player0bigger = _bigger;
        gamblingPrice = _gamblingPrice;
        amount = msg.value;
        player0 = msg.sender;
        oracle.update();
        emit Start(player0, token0, token1, _endTime, _gamblingPrice, _bigger, amount);
    }

    //查询赌局金额
    function getAmount() public view returns (uint){
        return amount;
    }

    //玩家1加入赌局
    function join() payable public{
        require(block.timestamp < endTime, "endTime has reached");
        require(player0 != msg.sender , "player1 is palyer0");
        require(player1 == address(0) , "player1 has joined");
        require(msg.value == amount , "joiner amount wrong");
        player1 = msg.sender;
        oracle.update();
        emit Join(player1, msg.value);
    }

    //赢家提款
    function withdraw() public{
        require(block.timestamp > endTime, "endTime not reached");
        require(player1 != address(0) , "player1 not join, please exit");
        require(address(this).balance > 0, "no balance");

        uint price = oracle.consult(token0, token1, 1e18);

        
        address winner;
        uint256 winAmount = address(this).balance;
        if(price >= gamblingPrice){
            winner = player0bigger ? player0 : player1;
        }else{
            winner = player0bigger ? player1 : player0;
        }
        (bool sent,) = winner.call{value:winAmount}("");
        require(sent, "failed to send Ether");
        player0 = address(0);
        player1 = address(0);
        emit Withdraw(winner, price, winAmount);
    }

    //玩家0退出
    function exit() public{
        require(player0 == msg.sender , "only player0 can exit");
        require(player1 == address(0) , "player1 has joined");
        uint256 exitAmount = address(this).balance;
        (bool sent,) = player0.call{value:exitAmount}("");
        require(sent, "failed to send Ether");
        player0 = address(0);
        player1 = address(0);
        emit Exit(player0, exitAmount);
    }
}
