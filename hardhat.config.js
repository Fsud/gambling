require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});


/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity:{
    compilers: [

      {version: "0.8.0",settings: {},},
    ],
  } ,
  networks: {
    rinkeby: {
      url: process.env.RINKEBY_ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
    },
    kovan: {
      url: process.env.KOVAN_ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
    }
  },

};