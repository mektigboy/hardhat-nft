const {
    BASE_FEE,
    DECIMALS,
    GAS_PRICE_LINK,
    INITIAL_PRICE,
} = require("../helper-hardhat-config");
const { network } = require("hardhat");

module.exports = async ({ deployments, getNamedAccounts }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    if (chainId == 31337) {
        log("Local network detected. Deploying mocks...");

        await deploy("VRFCoordinatorV2Mock", {
            args: [BASE_FEE, GAS_PRICE_LINK],
            from: deployer,
            log: true,
        });

        await deploy("MockV3Aggregator", {
            args: [DECIMALS, INITIAL_PRICE],
            from: deployer,
            log: true,
        });

        log("Mocks Deployed!");
        log("-------------------------------------------------");
        log(
            "You are deploying to a local network, you will need a local network running to interact with the smart contracts."
        );
        log(
            "Please, run `yarn hardhat console --network localhost` to interact with the deployed smart contracts."
        );
    }
};

module.exports.tags = ["all", "main", "mocks"];
