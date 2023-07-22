// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyToken is ERC1155, Ownable, ERC1155Burnable, ERC1155Supply {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    struct Batch {
        uint16 maxSuply;
        uint256 price;
        string uri;
    }

    struct PartialData {
        uint256 id;
        uint256 price;
    }

    mapping(uint256 => Batch) Collections;
    uint256[] private keys;

    constructor() ERC1155("") {}

    function addProduct(
        uint16 supply,
        uint256 price,
        string memory uri
    ) public {
        Batch memory newBatch = Batch(supply + 1, price, uri);
        Collections[_tokenIdCounter.current()] = newBatch;
        keys.push(_tokenIdCounter.current());
        _mint(msg.sender, _tokenIdCounter.current(), 1, "");
        _tokenIdCounter.increment();
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount
    ) public payable {
        _setURI(Collections[id].uri);
        require(msg.value >= Collections[id].price);
        require(totalSupply(id) + amount <= Collections[id].maxSuply);
        _mint(account, id, amount, "");
        _tokenIdCounter.increment();
    }

    function getNftData(string memory uri)
        public
        view
        returns (PartialData memory)
    {
        uint256 totalBatches = _tokenIdCounter.current(); // Obtenemos el número total de lotes

        for (uint256 i = 0; i < totalBatches; i++) {
            string memory _uriCollection = Collections[i].uri;
            if (keccak256(bytes(_uriCollection)) == keccak256(bytes(uri))) {
                PartialData memory data = PartialData(i, Collections[i].price);

                return data;
            }
        }
        revert("This NFT does not exist");
    }

    function getCurrentId() public view returns (string[] memory) {
        uint256 currentId = keys.length;
        string[] memory uris = new string[](currentId);

        for (uint256 i = 0; i < currentId; i++) {
            uris[i] = Collections[i].uri;
        }

        return uris;
    }

    function Burn(uint256 id) public {
        _burn(msg.sender, id, balanceOf(msg.sender, id));
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}

