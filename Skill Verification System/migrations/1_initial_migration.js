const verification = artifacts.require('verification');
// Deploys the smart contract "Decentraskill"
module.exports = function (deployer) {
  deployer.deploy(Decentraskill);
};