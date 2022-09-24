// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {

  const LandNFT = await hre.ethers.getContractFactory("LandNFT");
  const landNFT = await LandNFT.deploy('LandNFT', 'LAND', '0x5FbDB2315678afecb367f032d93F642f64180aa3');


  await landNFT.deployed();

  console.log("LandNFT deployed to:", landNFT.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
