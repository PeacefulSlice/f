// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./../contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./../contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./../contracts-upgradeable/security/PausableUpgradeable.sol";
import "./../contracts-upgradeable/proxy/utils/Initializable.sol";
import "./../contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";
import "./../interfaces/IHamster.sol";



contract Shop is Initializable, AccessControlUpgradeable, PausableUpgradeable, ERC2771ContextUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    address public tokenMHT;


    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");
    function _msgSender() internal override(ContextUpgradeable, ERC2771ContextUpgradeable) view returns (address) {
        return ERC2771ContextUpgradeable._msgSender();
    }
    function _msgData() internal override(ContextUpgradeable, ERC2771ContextUpgradeable) view returns (bytes calldata) {
        return ERC2771ContextUpgradeable._msgData();
    }

    function initialize(
        address _admin,
        address _tokenMHT
        )public initializer{
        __Context_init_unchained();
        __AccessControl_init();
        __Pausable_init_unchained();
        
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        tokenMHT = _tokenMHT;



    }

    function setTokenMHT(address _tokenMHT) external onlyAdmin{
        tokenMHT = _tokenMHT;

    }

    // function _mintAnimal(uint256 _tokenID, uint256 _amount) public onlyAdmin{
    //     _mintAnimal(_tokenID, _amount);
    // }

    function 



    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not the Admin");
        _;
    }

    function pause() external onlyAdmin {
        _pause();
    }

    function unpause() external onlyAdmin {
        _unpause();
    }

}