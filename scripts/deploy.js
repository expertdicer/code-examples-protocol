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
    console.log("Address flashloanV2 contract: ", flashloanV2.address);

    // var flashLoanTx = await flashloanV2.flashloan("0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD");
    // await flashloanV2.waited();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });