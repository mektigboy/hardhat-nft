const { network, ethers } = require("hardhat");
const { networkConfig } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

const tokenURIs = [
    "ipfs://bafkreidiszt2rp5unghfq3xfdagqcl7b6z2yc4ef6bmkbqbrqrcvoahnby", // 1
    "ipfs://bafkreiaulh6ope6bamhyhlzgwisc3djffjuclt5zxxamsypmqrulb3kkqa", // 2
    "ipfs://bafkreiayes7ej5kzziio3fydpjjtdygtaxckjitka5z6txfgqgkfeticaq", // 3
];

const FUND_AMOUNT = "10000000000000000000"; // 10 LINK

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    let coordinatorAddress, subscriptionId;

    if (chainId == 31337) {
        const coordinatorMock = await ethers.getContract(
            "VRFCoordinatorV2Mock"
        );
        coordinatorAddress = coordinatorMock.address;
        const transaction = await coordinatorMock.createSubscription();
        const transactionReceipt = await transaction.wait(1);
        subscriptionId = transactionReceipt.events[0].args.subId;
        await coordinatorMock.fundSubscription(subscriptionId, FUND_AMOUNT);
    } else {
        coordinatorAddress = networkConfig[chainId].vrfCoordinatorV2;
        subscriptionId = networkConfig[chainId].subscriptionId;
    }

    log("--------------------------------------------------");

    const args = [
        coordinatorAddress,
        subscriptionId,
        networkConfig[chainId].gasLane,
        networkConfig[chainId].callbackGasLimit,
        tokenURIs,
        networkConfig[chainId].mintFee,
    ];

    const randomNFT = await deploy("RandomNFT", {
        args: args,
        from: deployer,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    });

    log("--------------------------------------------------");

    if (!chainId == 31337 && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...");
        await verify(randomNFT.address, args);
    }
};

module.exports.tags = ["all", "main", "random-nft"];
