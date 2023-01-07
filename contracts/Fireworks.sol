// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


contract Fireworks is IERC165, IERC721Receiver {

  using ERC165Checker for address;

  bytes4 public constant IID_IERC165 = type(IERC165).interfaceId;
  bytes4 public constant IID_IERC1155 = type(IERC1155).interfaceId;
  bytes4 public constant IID_IERC721 = type(IERC721).interfaceId;

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == IID_IERC165;
  }

  function isERC1155(address tokenAddress) internal  returns (bool) {
    return tokenAddress.supportsInterface(IID_IERC1155);
  }    
    
  function isERC721(address tokenAddress) internal returns (bool) {
    return tokenAddress.supportsInterface(IID_IERC721);
  }

  /**
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

  /**
   * @dev 
   */
  function burn(address tokenContract, uint256[] calldata tokenIds, uint256[] calldata amount) external {
    require(_checkContract(tokenContract), "contract address error");
    require(_verifyApprove(tokenContract), "not authorized by contract");
    _transferToken(tokenContract, msg.sender, tokenIds, amount);
  }

  
  function _transferToken(address tokenContract, address from, uint256[] calldata tokenIds, uint256[] calldata amount) internal {
    if (isERC721(tokenContract)) {
      for(uint256 i = 0; i < tokenIds.length; i++) {
        IERC721(tokenContract).safeTransferFrom(msg.sender, address(this), tokenIds[i]);
      }
      
    }else {
      // todo
    }
  }

  function _verifyApprove(address tokenContract) internal returns(bool) {
    if (isERC721(tokenContract)) {
      return IERC721(tokenContract).isApprovedForAll(msg.sender, address(this));
    }else {
      return IERC1155(tokenContract).isApprovedForAll(msg.sender, address(this));
    }

  }

  // check whether the given contract is ERC721 or ERC1155, and return false if not
  function _checkContract(address tokenAddress) internal returns(bool) {
    return isERC1155(tokenAddress) || isERC721(tokenAddress);
  }
  
}