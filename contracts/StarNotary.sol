//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.24;

import "../app/node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {

    struct Star {
        string name;
    }

    string public constant name = "Star Token";
    string public constant symbol = "STC"; 

    mapping(uint256 => Star) public tokenIdToStarInfo;

    mapping(uint256 => uint256) public starsForSale;

    
    function createStar(string memory _name, uint256 _tokenId) public { 
        Star memory newStar = Star(_name); 
        tokenIdToStarInfo[_tokenId] = newStar; 
        _mint(msg.sender, _tokenId); 
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Star you don't owned");
        starsForSale[_tokenId] = _price;
    }

    function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }

    function buyStar(uint256 _tokenId) public  payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        _transferFrom(ownerAddress, msg.sender, _tokenId); 
        address payable ownerAddressPayable = _make_payable(ownerAddress); 
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }
    }

    function lookUptokenIdToStarInfo (uint _tokenId) public view returns (string memory) {
        return tokenIdToStarInfo[_tokenId].name;
    }

    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        require(ownerOf(_tokenId1) == msg.sender || ownerOf(_tokenId2) == msg.sender, "Sender does not own one of the tokens");

        address owner1Address = ownerOf(_tokenId1);
        address owner2Address = ownerOf(_tokenId2);

        _transferFrom(owner1Address, owner2Address, _tokenId1);
        _transferFrom(owner2Address, owner1Address, _tokenId2);
    }

    function transferStar(address _to1, uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender);
        _transferFrom(msg.sender, _to1, _tokenId);
    }
}