// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./../contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./../contracts-upgradeable/security/PausableUpgradeable.sol";
import "./../contracts-upgradeable/proxy/utils/Initializable.sol";
import "./../contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";



contract Shop is Initializable, AccessControlUpgradeable, PausableUpgradeable, ERC2771ContextUpgradeable {



    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");
    function _msgSender() internal override(ContextUpgradeable, ERC2771ContextUpgradeable) view returns (address) {
        return ERC2771ContextUpgradeable._msgSender();
    }
    function _msgData() internal override(ContextUpgradeable, ERC2771ContextUpgradeable) view returns (bytes calldata) {
        return ERC2771ContextUpgradeable._msgData();
    }

    function initialize(address _admin)public initializer{
        __Context_init_unchained();
        __AccessControl_init();
        __Pausable_init_unchained();
        
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);


    }

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