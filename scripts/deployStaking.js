// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {

  const StakingNFT = await hre.ethers.getContractFactory("StakingNFT");
  const stakingNFT = await StakingNFT.deploy('0x5FbDB2315678afecb367f032d93F642f64180aa3', '0x5FbDB2315678afecb367f032d93F642f64180aa3');


  await stakingNFT.deployed();


  console.log("StakingNFT deployed to:", stakingNFT.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
