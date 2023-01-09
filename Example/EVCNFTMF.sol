//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";

contract EVCNFT is ERC721Enumerable, Ownable {

    using Strings for uint256;

//*** MODIFIED ***//
    string public baseMaleURI;
    string public baseFemaleURI;
//***----------***//
    
    string public baseExtension = ".json";

    uint256 public cost = 0.05 ether;
    uint256 public maxSupply = 10000;
    uint256 public maxMintAmount = 10;

    bool public paused = false;

    mapping(address => bool) public whitelisted;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initMaleBaseURI,
        string memory _initFemaleBaseURI
    ) ERC721(_name, _symbol) {
        setMaleBaseURI(_initMaleBaseURI);
        setFemaleBaseURI(_initFemaleBaseURI);
        mintMale(msg.sender, 10);
        mintFemale(msg.sender, 10);
    }

//*** MODIFIED ***//
    // internal
    function _baseMaleURI() internal view virtual override returns(string memory) {
        return baseMaleURI;
    }
    function _baseFemaleURI() internal view virtual  override returns(string memory) {
        return baseFemaleURI;
    }
//***----------***//

//*** MODIFIED ***//
    // public
    function mintMale(address _to, uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(!paused);
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require(supply + _mintAmount <= maxSupply);
        if (msg.sender != owner()) {
            if (whitelisted[msg.sender] != true) {
                require(msg.value >= cost * _mintAmount);
            }
        }
        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMintMale(_to, supply + i);
        }
    }
    function mintFemale(address _to, uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(!paused);
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require(supply + _mintAmount <= maxSupply);
        if (msg.sender != owner()) {
            if (whitelisted[msg.sender] != true) {
                require(msg.value >= cost * _mintAmount);
            }
        }
        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMintFemale(_to, supply + i);
        }
    }
//***----------***//
    
    function walletOfOwner(address _owner) public view returns(uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

//*** MODIFIED ***//
    function tokenMaleURI(uint256 tokenId) public view override virtual returns(string memory) {
        require(_existsMale(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory currentBaseURI = _baseMaleURI();
        return bytes(currentBaseURI).length > 0 ?
            string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) :
            "";
    }
    function tokenFemaleURI(uint256 tokenId) public view override virtual returns(string memory) {
        require(_existsFemale(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory currentBaseURI = _baseFemaleURI();
        return bytes(currentBaseURI).length > 0 ?
            string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) :
            "";
    }
//***----------***//
    
    //only owner
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

//*** MODIFIED ***//
    function setMaleBaseURI(string memory _newBaseURI) public onlyOwner {
        baseMaleURI = _newBaseURI;
    }
    function setFemaleBaseURI(string memory _newBaseURI) public onlyOwner {
        baseFemaleURI = _newBaseURI;
    }
//***----------***//
    
    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function whitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = true;
    }

    function removeWhitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }

    function withdraw() public payable onlyOwner {
        // This will pay HashLips 5% of the initial sale.
        // You can remove this if you want, or keep it in to support HashLips and his channel.
        // =============================================================================
        (bool hs, ) = payable(0x8a85AAA434273A3018d8E38B09839f194c0D2e2d).call {
            value: address(this).balance * 5 / 100
        }("");
        require(hs);
        // =============================================================================
        // This will payout the owner 95% of the contract balance.
        // Do not remove this otherwise you will not be able to withdraw the funds.
        // =============================================================================
        (bool os, ) = payable(owner()).call {
            value: address(this).balance
        }("");
        require(os);
        // =============================================================================
    }

}



// Avatar : 
// Male = _initMaleBaseURI =   ipfs://QmbuNncRyi1m4a34ansXLQB9g535cwGwvnKtX9BYy6vay2/
// Female = _initFemaleBaseURI =   ipfs://QmY4d9urgFPi7cy2rVreYV9qsNNp7qXRoeSYEjiNyMfuoP/



// Example FitWork:-
// _initBaseURI =   ipfs://QmbuNncRyi1m4a34ansXLQB9g535cwGwvnKtX9BYy6vay2/
/*   Metadata - https://ipfs.io/ipfs/QmbuNncRyi1m4a34ansXLQB9g535cwGwvnKtX9BYy6vay2/   */
