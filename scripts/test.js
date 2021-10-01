// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through node <script>.
//
// When running the script with npx hardhat run <script> you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  const FlashloanV2 = await hre.ethers.getContractFactory("FlashloanV2");
  const flashloanV2 = await FlashloanV2.deploy("0x88757f2f99175387ab4c6a4b3067c77a695b0349","0xE592427A0AEce92De3Edee1F18E0157C05861564");
  await flashloanV2.deployed();
  console.log("Address test flash loan contract: ", testFlashLoan.address);
  var temp = await testFlashLoan.showAddress();
  console.log("temp: ", temp);
  var temp = await testFlashLoan.executeFlashLoans(1);
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