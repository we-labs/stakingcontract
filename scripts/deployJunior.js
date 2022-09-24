// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  const JuniorKongzNFT = await hre.ethers.getContractFactory("JuniorKongzNFT", "JUNIOR");
  const juniorKongzNFT = await JuniorKongzNFT.deploy();

  await juniorKongzNFT.deployed();


  console.log("JuniorKongzNFT deployed to:", juniorKongzNFT.address);


}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
