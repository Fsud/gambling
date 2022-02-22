## 对赌合约

### 部署方式：
拉取代码
在项目目录新建 .env 文件，配置以下三项
```
RINKEBY_ALCHEMY_KEY=""
KOVAN_ALCHEMY_KEY=""
PRIVATE_KEY=""
```
执行
```
npm install
npx hardhat compile
npx hardhat run scripts/deploy.js --network rinkeby //部署到rinkeby测试网，使用uniswap v2 预言机接口
或 npx hardhat run scripts/chainlink_deploy.js --network kovan //部署到 kovan测试网，使用 chainlink 预言机接口
```
rinkeby 部署文件中，配置的是 weth/dai交易对。
kovan 部署文件中，配置的是 link/usd 价格。

已部署的合约地址：
```
rinkeby uniswap：
Oracle address:  0x5af7fd2D346a4215FaCFED913Bedd08C0e6E6D01
Gambling address:  0xbE74A12EcA3cF2c9EE157144bEb44B91362550C7

kovan chainlink：
ChainLink Oracle address:  0xFD15a0C8e17dBF0019784225567b7a454045b383
Gambling address:  0x581abe9e115EAb9Cb69F896C24Fc8cCe3380FA80

```

### 测试流程
1. 玩家1 对gambling合约 调用 ` function start(uint256 _endTime, uint256 _gamblingPrice,bool _bigger) ` 方法，传入截止时间戳，兑换价格（包含8位小数点）和 赌大于等于 还是 小于，同时传入一定以太币。
2. 玩家2 对gambling合约 调用 ` function join() ` 方法，传入和玩家1相同的以太币（可以通过 `getAmount()` 查询金额）。
   1. 如果玩家2一直不出现，玩家一可以调用 `exit()` 取出以太币。
3. 等待 时间到达 endTime 后，任何玩家都可调用 `withdraw()`， 合约计算此刻的价格，把以太币转给获胜者。
4. 取出奖励之后，可以从步骤1重新开始游戏。

