const {ethers} = require('hardhat');
/** This is a function used to deploy contract */
const hre = require('hardhat');

async function main() {
  const MarketPlace = await hre.ethers.getContractFactory('MarketPlace');
  const _MarketPlace = await MarketPlace.deploy();
  console.log(
      'MarketPlace deployed to:',
      _MarketPlace.address,
  );
}

main().
    then(() => process.exit(0)).
    catch((error) => {
      console.error(error);
      process.exit(1);
    });