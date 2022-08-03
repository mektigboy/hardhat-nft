// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract RandomNFT is ERC721, VRFConsumerBaseV2 {
    // Chainlink VRF Variables
    VRFCoordinatorV2Interface immutable i_coordinator;
    uint64 immutable i_subscriptionId;
    bytes32 immutable i_gasLane;
    uint32 immutable i_callbackGasLimit;
    uint16 constant REQ_CONFIRMATIONS = 3;
    uint32 constant NUM_WORDS = 1;

    // VRF Helpers
    mapping(uint256 => address) public s_requestIdToSender;

    // NFT Variables
    uint256 public s_tokenCounter;

    constructor(
        address coordinator,
        uint64 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit
    ) ERC721("Binary NFT Collection", "BNC") VRFConsumerBaseV2(coordinator) {
        i_coordinator = VRFCoordinatorV2Interface(coordinator);
        i_subscriptionId = subscriptionId;
        i_gasLane = gasLane;
        i_callbackGasLimit = callbackGasLimit;
    }

    function requestNFT() public returns (uint256 requestId) {
        requestId = i_coordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQ_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        address tokenOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;
        _safeMint(tokenOwner, newTokenId);
    }

    function tokenURI(uint256) public view override returns (string memory) {}
}
