// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "base64-sol/base64.sol";

error DynamicNFT__URIQueryForNonExistentToken();

contract DynamicNFT is ERC721 {
    AggregatorV3Interface internal immutable i_priceFeed;
    uint256 s_tokenCounter;
    string i_lowImageURI;
    string i_highImageURI;
    string constant BASE64_ENCODED_SVG_PREFIX = "data:image/svg+xml;base64,";

    mapping(uint256 => int256) public s_tokenIdToHighValue;

    event CreatedNFT(uint256 indexed tokenId, int256 highValue);

    constructor(
        address priceFeedAddress,
        string memory lowSVG,
        string memory highSVG
    ) ERC721("Dynamic NFT Collection", "DNC") {
        s_tokenCounter = 0;
        i_lowImageURI = convertSVGToImageURI(lowSVG);
        i_highImageURI = convertSVGToImageURI(highSVG);
        i_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function convertSVGToImageURI(string memory anySVG)
        public
        pure
        returns (string memory)
    {
        string memory base64SVGEncoded = Base64.encode(
            bytes(string(abi.encodePacked(anySVG)))
        );
        return
            string(
                abi.encodePacked(BASE64_ENCODED_SVG_PREFIX, base64SVGEncoded)
            );
    }

    // Let the minters choose the value.
    function mintNFT(int256 highValue) public {
        s_tokenIdToHighValue[s_tokenCounter] = highValue;
        s_tokenCounter = s_tokenCounter + 1;
        _safeMint(msg.sender, s_tokenCounter);
        emit CreatedNFT(s_tokenCounter, highValue);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert DynamicNFT__URIQueryForNonExistentToken();
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        string memory imageURI = i_lowImageURI;
        if (price >= s_tokenIdToHighValue[tokenId]) {
            imageURI = i_lowImageURI;
        }
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(),
                                '","description":"An NFT that changes based on the Chainlink Feed.",',
                                '"attributes":[{"trait":"Epic","value":1000}],"image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
