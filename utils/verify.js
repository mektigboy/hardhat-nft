const { networkConfig } = require("../helper-hardhat-config");
const { run, network } = require("hardhat");

const verify = async (args, contractAddress) => {
    console.log("Verifying contract...");
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        });
    } catch (error) {
        if (error.message.toLowerCase().includes("already verified")) {
            console.log("Already verified!");
        } else {
            console.log(error);
        }
    }
};

module.exports = {
    verify,
};
