// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "hardhat/console.sol";

error RandomNFT__AlreadyInitialized();
error RandomNFT__RangeOutOfScope();
error RandomNFT__NotEnoughETHSent();
error RandomNFT__TransferFailed();

// Uses Ownable from OZ for access control.

contract RandomNFT is ERC721URIStorage, Ownable, VRFConsumerBaseV2 {
    // Type Declaration
    enum Selection {
        EPIC,
        RARE,
        COMMON
    }

    // Chainlink VRF Variables
    VRFCoordinatorV2Interface immutable i_coordinator;
    uint64 immutable i_subscriptionId;
    bytes32 immutable i_gasLane;
    uint32 immutable i_callbackGasLimit;
    uint16 constant REQ_CONFIRMATIONS = 3;
    uint32 constant NUM_WORDS = 1;

    // NFT Variables
    uint256 i_mintFee;
    uint256 public s_tokenCounter;
    mapping(uint256 => Selection) private s_tokenIdToBreed;
    uint256 internal constant MAX_CHANCE = 1000;
    string[] internal s_tokenURIs;
    bool s_initialized;

    // VRF Helpers
    mapping(uint256 => address) public s_requestIdToSender;

    // Events
    event NFTRequested(uint256 indexed requestId, address requester);
    event NFTMinted(Selection selection, address minter);

    constructor(
        address coordinator,
        uint64 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit,
        string[3] memory tokenURIs, // Set token URIs in the constructor of our contract.
        uint256 mintFee
    ) ERC721("Binary NFT Collection", "BNC") VRFConsumerBaseV2(coordinator) {
        i_coordinator = VRFCoordinatorV2Interface(coordinator);
        i_subscriptionId = subscriptionId;
        i_gasLane = gasLane;
        i_mintFee = mintFee;
        i_callbackGasLimit = callbackGasLimit;
        _initializeContract(tokenURIs);
    }

    function requestNFT() public payable returns (uint256 requestId) {
        if (msg.value < i_mintFee) {
            revert RandomNFT__NotEnoughETHSent();
        }
        requestId = i_coordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQ_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
        emit NFTRequested(requestId, msg.sender);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        address tokenOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter = s_tokenCounter + 1;
        uint256 moddedRNG = randomWords[0] % MAX_CHANCE;
        Selection selection = selectionFromModdedRNG(moddedRNG);
        _safeMint(tokenOwner, newTokenId);
        _setTokenURI(newTokenId, s_tokenURIs[uint256(selection)]);
        emit NFTMinted(selection, tokenOwner);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert RandomNFT__TransferFailed();
        }
    }

    function setChanceArray() public pure returns (uint256[3] memory) {
        // 0 - 10 = Epic
        // 11 - 100 = Rare
        // 101 - 100 = Common
        return [10, 100, MAX_CHANCE];
    }

    function selectionFromModdedRNG(uint256 moddedRNG)
        public
        pure
        returns (Selection)
    {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = setChanceArray();

        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (
                moddedRNG >= cumulativeSum &&
                moddedRNG < cumulativeSum + chanceArray[i]
            ) {
                return Selection(i);
            }
            cumulativeSum = chanceArray[i];
        }
        revert RandomNFT__RangeOutOfScope();
    }

    function _initializeContract(string[3] memory tokenURIs) private {
        if (s_initialized) {
            revert RandomNFT__AlreadyInitialized();
        }
        s_tokenURIs = tokenURIs;
        s_initialized = true;
    }

    function getInitialized() public view returns (bool) {
        return s_initialized;
    }
    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getTokenURIs(uint256 index) public view returns (string memory) {
        return s_tokenURIs[index];
    }
}
