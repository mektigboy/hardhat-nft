const { developmentChains } = require("../helper-hardhat-config");
const { network } = require("hardhat");
const { verify } = require("../utils/verify");

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();

    log("--------------------------------------------------");

    const args = [];
    const basicNFT = await deploy("BasicNFT", {
        args: args,
        from: deployer,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    });

    if (!chainId == 31337 && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...");
        await verify(basicNFT.address, args);
    }
};

module.exports.tags = ["all", "basic-nft", "main"];
