//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

// We first import some OpenZeppelin Contracts.
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//import helper functions from Base64.sol
import {Base64} from "./libraries/Base64.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract MyEpicNFT is ERC721URIStorage {
    // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // We need to pass the name of our NFTs token and its symbol.
    constructor() ERC721("SquareNFT", "SQUARE") {
        console.log("This is my NFT contract");
    }

    //Base SVG Code. All we need to change is the word theat is displayed
    string baseSvg =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    //create threee arrays with their own theme of random words

    string[] basketBallers = [
        "LeBron",
        "Durant",
        "Curry",
        "Kyrie",
        "Morant",
        "Antetokounmpo",
        "Thompson",
        "Poole",
        "Doncic",
        "Harden",
        "Westbrook",
        "Davis",
        "Tatum",
        "Butler"
    ];
    string[] cars = [
        "Ferrari",
        "Benzo",
        "Volkswagen",
        "Nissan",
        "Toyota",
        "Tesla",
        "BMW",
        "Honda",
        "Pajero",
        "Jeep",
        "Audi",
        "Mitsubishi",
        "Subaru"
    ];
    string[] food = [
        "Pizza",
        "Burger",
        "Chips",
        "Hotdog",
        "Stake",
        "Chapati",
        "Madondo",
        "Mandazi",
        "Ugali",
        "Rice",
        "Beef",
        "Pork"
    ];

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    //Pick random words function. Takes a tokenId and array of words
    function pickRandomWord(
        uint256 tokenId,
        string[] memory words,
        string memory randomWord
    ) public view returns (string memory) {
        uint256 rand = random(
            string(abi.encodePacked(randomWord, Strings.toString(tokenId)))
        );

        rand = rand % words.length;
        return words[rand];
    }

    // A function our user will hit to get their NFT.
    function makeAnEpicNFT() public {
        // Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();

        //Randomly grab one word from each of the three arrays
        string memory first = pickRandomWord(
            newItemId,
            basketBallers,
            "FIRST_WORD"
        );
        string memory second = pickRandomWord(newItemId, cars, "SECOND_WORD");
        string memory third = pickRandomWord(newItemId, food, "THIRD_WORD");
        string memory combinedWord = string(
            abi.encodePacked(first, second, third)
        );

        //concatinate it all together and close the <text> and <svg> tags
        string memory finalSvg = string(
            abi.encodePacked(baseSvg, combinedWord, "</text></svg>")
        );

        //Get all the JSON data metadata in place and base64 encode it
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        //Set the title of our NFT as the generated word
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image" : "data:image/svg+xml;base64,',
                        //Add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        console.log("\n-------------");
        console.log(finalTokenUri);
        console.log("-------------\n");

        // Actually mint the NFT to the sender using msg.sender.
        _safeMint(msg.sender, newItemId);

        // Set the NFTs data.
        _setTokenURI(newItemId, finalTokenUri);

        console.log(
            "An NFT with ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();
    }
}
