// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./IERC721Metadata.sol";
import "./Address.sol";
import "./Context.sol";
import "./Strings.sol";
import "./ERC165.sol";


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;
    string private _symbol;

    mapping(uint256 => address) private _owners;
//*** MODIFIED ***//
    mapping(uint256 => address) private _ownersMale;
    mapping(uint256 => address) private _ownersFemale;
//***----------***//

    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns(bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721Metadata).interfaceId || super.supportsInterface(interfaceId);
    }
    
    function balanceOf(address owner) public view virtual override returns(uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns(address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }
//*** MODIFIED ***//    
    function ownerOfMale(uint256 tokenId) public view virtual returns(address) {
        address owner = _ownersMale[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }
    function ownerOfFemale(uint256 tokenId) public view virtual  returns(address) {
        address owner = _ownersFemale[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }
//***----------***//

    function name() public view virtual override returns(string memory) {
        return _name;
    }

    function symbol() public view virtual override returns(string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns(string memory) {
        _requireMinted(tokenId);
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
//*** MODIFIED ***//
    
    function tokenMaleURI(uint256 tokenId) public view virtual  returns(string memory) {
        _requireMintedMale(tokenId);
        string memory baseURI = _baseMaleURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
    function tokenFemaleURI(uint256 tokenId) public view virtual  returns(string memory) {
        _requireMintedFemale(tokenId);
        string memory baseURI = _baseFemaleURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
//***----------***//
    
    function _baseURI() internal view virtual returns(string memory) {
        return "";
    }
//*** MODIFIED ***//
    function _baseMaleURI() internal view virtual returns(string memory) {
        return "";
    }
    function _baseFemaleURI() internal view virtual returns(string memory) {
        return "";
    }
//***----------***//
    
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()), "ERC721: approve caller is not token owner or approved for all");
        _approve(to, tokenId);
    }
//*** MODIFIED ***//
    function approveMale(address to, uint256 tokenId) public virtual  {
        address owner = ERC721.ownerOfMale(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()), "ERC721: approve caller is not token owner or approved for all");
        _approve(to, tokenId);
    }
    function approveFemale(address to, uint256 tokenId) public virtual  {
        address owner = ERC721.ownerOfFemale(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()), "ERC721: approve caller is not token owner or approved for all");
        _approve(to, tokenId);
    }
//***----------***//

    function getApproved(uint256 tokenId) public view virtual override returns(address) {
        _requireMinted(tokenId);
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns(bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns(bool) {
        return _owners[tokenId] != address(0);
    }
//*** MODIFIED ***//
    function _existsMale(uint256 tokenId) internal view virtual returns(bool) {
        return _ownersMale[tokenId] != address(0);
    }
    function _existsFemale(uint256 tokenId) internal view virtual returns(bool) {
        return _ownersFemale[tokenId] != address(0);
    }
//***----------***//
    
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns(bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }
//*** MODIFIED ***//
    function _isApprovedOrOwnerMale(address spender, uint256 tokenId) internal view virtual returns(bool) {
        address owner = ERC721.ownerOfMale(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }
    function _isApprovedOrOwnerFemale(address spender, uint256 tokenId) internal view virtual returns(bool) {
        address owner = ERC721.ownerOfFemale(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }
//***----------***//

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");
        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
        _afterTokenTransfer(address(0), to, tokenId);
    }
//*** MODIFIED ***//
    function _mintMale(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_existsMale(tokenId), "ERC721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_existsMale(tokenId), "ERC721: token already minted");
        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }
        _ownersMale[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
        _afterTokenTransfer(address(0), to, tokenId);
    }
    function _mintFemale(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_existsFemale(tokenId), "ERC721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_existsFemale(tokenId), "ERC721: token already minted");
        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }
        _ownersFemale[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
        _afterTokenTransfer(address(0), to, tokenId);
    }
//***----------***//
   
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);
        // Clear approvals
        delete _tokenApprovals[tokenId];
        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
        _afterTokenTransfer(owner, address(0), tokenId);
    }
//*** MODIFIED ***//
    function _burnMale(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOfMale(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOfMale(tokenId);
        // Clear approvals
        delete _tokenApprovals[tokenId];
        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _ownersMale[tokenId];
        emit Transfer(owner, address(0), tokenId);
        _afterTokenTransfer(owner, address(0), tokenId);
    }
    function _burnFemale(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOfFemale(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOfFemale(tokenId);
        // Clear approvals
        delete _tokenApprovals[tokenId];
        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _ownersFemale[tokenId];
        emit Transfer(owner, address(0), tokenId);
        _afterTokenTransfer(owner, address(0), tokenId);
    }
//***----------***//
    
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId);
        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];
        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
        _afterTokenTransfer(from, to, tokenId);
    }
//*** MODIFIED ***//
    function _transferMale(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOfMale(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId);
        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOfMale(tokenId) == from, "ERC721: transfer from incorrect owner");
        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];
        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _ownersMale[tokenId] = to;
        emit Transfer(from, to, tokenId);
        _afterTokenTransfer(from, to, tokenId);
    }
    function _transferFemale(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOfFemale(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId);
        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOfFemale(tokenId) == from, "ERC721: transfer from incorrect owner");
        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];
        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _ownersFemale[tokenId] = to;
        emit Transfer(from, to, tokenId);
        _afterTokenTransfer(from, to, tokenId);
    }  
//***----------***//
    
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

//*** MODIFIED ***//
    function _approveMale(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOfMale(tokenId), to, tokenId);
    }
    function _approveFemale(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOfFemale(tokenId), to, tokenId);
    }
//***----------***//
    
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }
//*** MODIFIED ***//
    function _requireMintedMale(uint256 tokenId) internal view virtual {
        require(_existsMale(tokenId), "ERC721: invalid token ID");
    }
    function _requireMintedFemale(uint256 tokenId) internal view virtual {
        require(_existsFemale(tokenId), "ERC721: invalid token ID");
    }
//***----------***//
    
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns(bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns(bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }


//*** MODIFIED ***//
    function _safeMintFemale(address to, uint256 tokenId) internal virtual {
        _safeMintFemale(to, tokenId, "");
    }
    function _safeMintFemale(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mintFemale(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _safeMintMale(address to, uint256 tokenId) internal virtual {
        _safeMintMale(to, tokenId, "");
    }
    function _safeMintMale(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mintMale(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }
//***----------***//
    
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual {}
    
    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal virtual {}
    
}
