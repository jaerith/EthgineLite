var ConvertLib = artifacts.require("./ConvertLib.sol");
var WaEngine = artifacts.require("./WonkaEngine.sol");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, WaEngine);
  deployer.deploy(WaEngine);
};
