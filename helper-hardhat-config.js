const networkConfig = {
    4: {
        callbackGasLimit: "500000", // 500,000 gas
        ethUsdPriceFeed: "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e",
        gasLane:
            "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
        mintFee: "10000000000000000", // 0.01 ETH
        name: "rinkeby",
        subscriptionId: "9747",
        vrfCoordinatorV2: "0x6168499c0cFfCaCD319c818142124B7A15E857ab",
    },
    31337: {
        callbackGasLimit: "500000", // 500,000 gas
        ethUsdPriceFeed: "0x9326BFA02ADD2366b30bacB125260Af641031331",
        gasLane:
            "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc", // 30 gwei
        mintFee: "10000000000000000", // 0.01 ETH
        name: "localhost",
    },
};

const developmentChains = ["hardhat", "localhost"];
const DECIMALS = "18";
const INITIAL_PRICE = "200000000000000000000";

module.exports = {
    networkConfig,
    developmentChains,
    DECIMALS,
    INITIAL_PRICE,
};
