const { network, ethers } = require("hardhat");
const { networkConfig } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

const fs = require("fs");

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    let priceFeedAddress;

    if (chainId == 31337) {
        const aggregator = await ethers.getContract("MockV3Aggregator");
        priceFeedAddress = aggregator.address;
    } else {
        priceFeedAddress = networkConfig[chainId].ethUsdPriceFeed;
    }

    const lowSVG = await fs.readFileSync("./images/low.svg", {
        encoding: "utf8",
    });
    const highSVG = await fs.readFileSync("./images/high.svg", {
        encoding: "utf8",
    });

    log("--------------------------------------------------");

    const arguments = [priceFeedAddress, lowSVG, highSVG];
    const dynamicNFT = await deploy("DynamicNFT", {
        args: arguments,
        from: deployer,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    });

    if (!chainId == 31337 && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...");
        await verify(dynamicNFT.address, arguments);
    }
};

module.exports.tags = ["all", "dynamic-nft", "main"];
