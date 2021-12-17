// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {

  // Magic given to us by OpenZeppelin to help us keep track of tokenIds
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  uint256 private _totalSupply = 50;

  // We split the SVG at the part where it asks for the background color.
  string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
  string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  // Base SVG url that all NFTs will use that should allow us to dynamically change the text
  //string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='purple' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  // Three arrays of random words - 15 words per array is recommended
  string[] firstWords = ["Dynamic", "Explosive","Superfluous","Generic","Dubious","Energetic","Lazy","Lackadaisical","Formidable","Adorable","Dramatic","Excessive","Enraged","Sisyphean","Monstrous"];
  string[] secondWords = ["HotDog", "Pizza", "Milkshake", "Coffee", "CheeseSteak", "Cookie", "Eggroll", "Steak", "OnionRing", "Hamburger", "PeanutButter", "Chocolate", "MeatPie", "Casserole", "Lasagna", "Burrito"];
  string[] thirdWords = ["Batteries", "Hands", "Legs", "EyeBalls", "Bullets", "Dogs", "Cats", "Keyboards", "Headphones", "Pants", "Shirts", "BellyButtons", "Trains", "Phones", "HardDrives"];
 
  // Get fancy with it! Declare a bunch of colors.
  string[] colors = ["red", "#60c657", "black", "pink", "blue", "#35aee2"];

  event NewEpicNFTMinted(address sender, uint256 tokenId);

  // We need to pass the name of our NFTs token and it's symbol.
  constructor() ERC721 ("SquareNFT", "SQUARE") {
    console.log("This is my NFT contract. OMG");
  }

  function getTotalNFTsMintedCount () public view returns (uint256) {
    return uint256(_tokenIds.current());
  }

  // A function to randomly pick a word from each array
  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    // calls the random generator
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    // keep the random number in the bounds of the array 
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    // calls the random generator
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    // keep the random number in the bounds of the array 
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    // calls the random generator
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    // keep the random number in the bounds of the array 
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  } 

  function pickRandomColor(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
    rand = rand % colors.length;
    return colors[rand];
  }

  // random function

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  // A function our user will hit to get their NFT
  function makeAnEpicNFT() public {

    // Get the current token Id - this starts at 0
    uint256 newItemId = _tokenIds.current();

    require(_totalSupply > newItemId, "NFTs SOLD OUT: Mint limit of 50 reached");

    // Go and grab a random word from each array 
    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(first, second, third));
    string memory randomColor = pickRandomColor(newItemId);
    // Concat it all together and close the svg tags
    string memory finalSvg = string(abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combinedWord, "</text></svg>"));

    // Get all the JSON metadata and then Base64 encode it 
    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
                    // We set the title of our NFT as the generated word.
                    combinedWord,
                    '", "description": "A highly acclaimed collection of silly squares.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
          )
        )
      )
    );

    // We are going to create our JSON string prepended with data:application/json;base64,
    string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));

    console.log("\n---------debug token uri-----------");
    console.log(
      string(
          abi.encodePacked(
              "https://nftpreview.0xdev.codes/?code=",
              finalTokenUri
          )
      )
    );
    console.log("--------end debug token uri------------\n");

    console.log("\n-------------------");
    console.log(finalSvg);
    console.log("\n-------------------");

    // Mint the NFT to the sender using msg.sender
    _safeMint(msg.sender, newItemId);

    // Set the NFT data.
    _setTokenURI(newItemId, finalTokenUri);
    //_setTokenURI(newItemId, "data:application/json;base64,ewogICJuYW1lIjogIkdyZW5hZGVGbGF2b3JlZFdhdGVyIiwKICAiZGVzY3JpcHRpb24iOiAiQW4gZXBpYyBhbmQgZnVubnkgTkZUIGZyb20gU3F1YXJlIHRoYXQgamFtcyB0aHJlZSBoaWxhcmlvdXMgd29yZHMgdG9nZXRoZXIiLAogICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0S0lDQWdJRHh6ZEhsc1pUNHVZbUZ6WlNCN0lHWnBiR3c2SUhkb2FYUmxPeUJtYjI1MExXWmhiV2xzZVRvZ2MyVnlhV1k3SUdadmJuUXRjMmw2WlRvZ01UUndlRHNnZlR3dmMzUjViR1UrQ2lBZ0lDQThjbVZqZENCM2FXUjBhRDBpTVRBd0pTSWdhR1ZwWjJoMFBTSXhNREFsSWlCbWFXeHNQU0p3ZFhKd2JHVWlJQzgrQ2lBZ0lDQThkR1Y0ZENCNFBTSTFNQ1VpSUhrOUlqVXdKU0lnWTJ4aGMzTTlJbUpoYzJVaUlHUnZiV2x1WVc1MExXSmhjMlZzYVc1bFBTSnRhV1JrYkdVaUlIUmxlSFF0WVc1amFHOXlQU0p0YVdSa2JHVWlQa2R5Wlc1aFpHVkdiR0YyYjNKbFpGZGhkR1Z5UEM5MFpYaDBQZ284TDNOMlp6ND0iCn0=");

    // Console log to help see when the NFT is minted and to who
    console.log("An NFT w/ ID: %s has been minted to %s", newItemId, msg.sender);

    // Increment the token counter for when the next NFT is minted
    _tokenIds.increment();

    emit NewEpicNFTMinted(msg.sender, newItemId);
  }
}