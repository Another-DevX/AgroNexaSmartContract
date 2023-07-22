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

    mapping(uint256 => Batch) Collections;

    constructor() ERC1155("") {}

    function addProduct(
        uint16 supply,
        uint256 price,
        string memory uri
    ) public {
        Batch memory newBatch = Batch(supply, price, uri);
        Collections[_tokenIdCounter.current()] = newBatch;
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

    function getCurrentId() public view returns (string[] memory) {
        uint256 totalIds = _tokenIdCounter.current();
        string[] memory uris = new string[](totalIds);

        for (uint256 i = 1; i <= totalIds; i++) {
            uris[i - 1] = Collections[i].uri;
        }

        return uris;
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
