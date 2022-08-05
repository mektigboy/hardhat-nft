const { ethers, network } = require("hardhat");

module.exports = async function ({ getNamedAccounts }) {
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    // Basic NFT
    const basicNFT = await ethers.getContract("BasicNFT", deployer);
    const basicMintTransaction = await basicNFT.mintNFT();

    await basicMintTransaction.wait(1);

    console.log(
        `Basic NFT index 0 has token URI: ${await basicNFT.tokenURI(0)}`
    );

    // Random NFT
    const randomNFT = await ethers.getContract("RandomNFT", deployer);
    const mintFee = await randomNFT.getMintFee();
    const randomMintTransaction = await randomNFT.requestNFT({
        value: mintFee.toString(),
    });
    const randomMintTransactionReceipt = await randomMintTransaction.wait(1);

    await new Promise(async function (resolve, reject) {
        setTimeout(
            () => reject("Timeout: event <NFTMinted> did not fire."),
            300000 // 5 minutes
        );
        randomNFT.once("NFTMinted", async function () {
            resolve();
        });

        if (chainId == 31337) {
            const requestId =
                randomMintTransactionReceipt.events[1].args.requestId.toString();
            const coordinatorMock = await ethers.getContract(
                "VRFCoordinatorV2Mock",
                deployer
            );
            await coordinatorMock.fulfillRandomWords(
                requestId,
                randomNFT.address
            );
        }
    });

    console.log(
        `Random NFT index 0 has token URI: ${await randomNFT.tokenURI(0)}`
    );

    // Dynamic NFT
    const highValue = ethers.utils.parseEther("4000");
    const dynamicNFT = await ethers.getContract("DynamicNFT", deployer);
    const dynamicMintTransaction = await dynamicNFT.mintNFT(highValue);

    await dynamicMintTransaction.wait(1);

    console.log(
        `Dynamic NFT index 0 has token URI: ${await dynamicNFT.tokenURI(0)}`
    );
};

module.exports.tags = ["all", "mint"];
