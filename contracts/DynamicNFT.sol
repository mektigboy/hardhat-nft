// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "base64-sol/base64.sol";

error DynamicNFT__URIQueryForNonExistentToken();

contract DynamicNFT is ERC721 {
    uint256 s_tokenCounter;
    string i_lowImageURI;
    string i_highImageURI;
    string constant BASE64_ENCODED_SVG_PREFIX = "data:image/svg+xml;base64,";

    constructor(string memory lowSVG, string memory highSVG)
        ERC721("Dynamic NFT Collection", "DNC")
    {
        s_tokenCounter = 0;
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

    function mintNFT() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
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
        string memory imageURI = "Hi!";
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
