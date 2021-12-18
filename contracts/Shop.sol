// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./../contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./../contracts-upgradeable/security/PausableUpgradeable.sol";
import "./../contracts-upgradeable/proxy/utils/Initializable.sol";
import "./../contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";



contract Shop is Initializable, AccessControlUpgradeable, PausableUpgradeable, ERC2771ContextUpgradeable {


    function _msgSender() internal override(ContextUpgradeable, ERC2771ContextUpgradeable) view returns (address) {
        return ERC2771ContextUpgradeable._msgSender();
    }
    function _msgData() internal override(ContextUpgradeable, ERC2771ContextUpgradeable) view returns (bytes calldata) {
        return ERC2771ContextUpgradeable._msgData();
    }


}