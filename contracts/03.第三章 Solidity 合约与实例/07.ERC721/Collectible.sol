// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Collectible is ERC721, ERC721URIStorage,ERC721Enumerable  {
    constructor() ERC721("My Collectible", "MCL") {}
    // 创建新的 NFT
    function mintCollectible(
        address to,
        uint256 tokenId,
        string memory uri
    ) public {
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // 重写 supportsInterface 函数（解决冲突的核心）
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721URIStorage,ERC721Enumerable) // 声明重写自两个父类
        returns (bool)
    {
        // 调用 super 会按继承顺序优先使用 ERC721URIStorage 的实现
        return super.supportsInterface(interfaceId);
    }

    // 重写 tokenURI 函数（解决 ERC721 和 ERC721URIStorage 的冲突）
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId); // 优先使用 ERC721URIStorage 的实现
    }


     function _increaseBalance(address account, uint128 amount) internal virtual override(ERC721, ERC721Enumerable) {
        if (amount > 0) {
            revert ERC721EnumerableForbiddenBatchMint();
        }
        super._increaseBalance(account, amount);
    }


     function _update(address to, uint256 tokenId, address auth) internal virtual override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }
}
