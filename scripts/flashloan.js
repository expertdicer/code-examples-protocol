// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through node <script>.
//
// When running the script with npx hardhat run <script> you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
    const testFlashLoan = await hre.ethers.getContractAt("FlashloanV2","0xAe0e562DDE50B769b3216Bb7f9B809a6e583e016");
    // 0x7483c8621DAFB5BcaB557E09b8dFCA3c7A57A3F8
    console.log("FlashloanV2: ", testFlashLoan.address);
    
    var temp = await testFlashLoan.flashloan("0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD",{gasLimit:800000,gasPrice:1000000000});
    await temp.wait();
    console.log("tx: ", temp);
    var temp = await testFlashLoan.withdraw("0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD");
    await temp.wait();
    console.log("temp: ", temp);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });