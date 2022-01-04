// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./../contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./../contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./../contracts-upgradeable/security/PausableUpgradeable.sol";
import "./../contracts-upgradeable/proxy/utils/Initializable.sol";
import "./../contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";
import "./Hamster.sol";


interface IToken {
    function decimals() external view returns(uint8);
}


contract Shop is Initializable, AccessControlUpgradeable, PausableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    address public tokenMHT;
    address public hamsterContract;


    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    mapping(uint8 => uint256) animalPrices;
    mapping(uint8 => mapping(uint8 => uint256)) animalSkillUpgradePrices;

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

    function setDefaultAnimalPrices() external onlyAdmin{
        uint8 _decimals = uint8(IToken(tokenMHT).decimals());
         //hamster
        animalPrices[0] = 10*(10**_decimals);
        //bull
        animalPrices[1] = 150*(10**_decimals);
        //bear
        animalPrices[2] = 150*(10**_decimals);
        //whale
        animalPrices[3] = 300*(10**_decimals);
    }

    function setDefaultUpgradePrices() external onlyAdmin{
        uint8 _decimals = uint8(IToken(tokenMHT).decimals());
        //hamster
        animalSkillUpgradePrices[0][0] = 5*(10**_decimals);
        animalSkillUpgradePrices[0][1] = 10*(10**_decimals);
        animalSkillUpgradePrices[0][2] = 15*(10**_decimals);
        animalSkillUpgradePrices[0][3] = 20*(10**_decimals);
        //bull
        animalSkillUpgradePrices[1][0] = 75*(10**_decimals);
        animalSkillUpgradePrices[1][1] = 150*(10**_decimals);
        animalSkillUpgradePrices[1][2] = 225*(10**_decimals);
        animalSkillUpgradePrices[1][3] = 300*(10**_decimals);
        //bear
        animalSkillUpgradePrices[2][0] = 75*(10**_decimals);
        animalSkillUpgradePrices[2][1] = 150*(10**_decimals);
        animalSkillUpgradePrices[2][2] = 225*(10**_decimals);
        animalSkillUpgradePrices[2][3] = 300*(10**_decimals);
        //whale
        animalSkillUpgradePrices[3][0] = 150*(10**_decimals);
        animalSkillUpgradePrices[3][1] = 300*(10**_decimals);
        animalSkillUpgradePrices[3][2] = 450*(10**_decimals);
        animalSkillUpgradePrices[3][3] = 600*(10**_decimals);

    }
    function setHamsterContract(address _hamsterContract) external onlyAdmin {
        hamsterContract = _hamsterContract;
    }

    /**
    * @dev Throws if called by any account other than the one with the Admin role granted.
    */
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

    // 5) Ability to mint hero for money 
    function buyAnimal(uint8 _animalType) external whenNotPaused{
        require(IERC20Upgradeable(tokenMHT).balanceOf(_msgSender())>=animalPrices[_animalType],"");

        IERC20Upgradeable(tokenMHT).safeTransferFrom(_msgSender(), address(this), animalPrices[_animalType]);

        Hamster(hamsterContract).mintAnimal(_animalType, _msgSender());
        
    }
    // 7) Upgrade parameters of hero 
    function upgradeSpecificTrait(uint256 _tokenID, uint8 _trait) external whenNotPaused{
        uint8 _level = 0;
 
        (
            uint8 _animalType,
            uint8 _speed,
            uint8 _immunity,
            uint8 _armor,
            uint32 _response
        ) = Hamster(hamsterContract).getAnimalParameters(_tokenID);
        
        // Calculating level of trait
        // Speed
        if (_trait==0){
            _level = _speed;
        } else
        // Immunity
        if (_trait==1){
            _level = _immunity;
        } else
        // Armor
        if (_trait==2){
            _level = 4-_armor;
        } else
        // Response
        if (_trait==3){
            _level = uint8(4 - (_response)/500);
        } 
        require (((_level>=0)&&(_level<=3)),"level is not in boundaries");
        require ((IERC20Upgradeable(tokenMHT).balanceOf(_msgSender())>=animalSkillUpgradePrices[_animalType][_level]),"");
        IERC20Upgradeable(tokenMHT).safeTransferFrom(_msgSender(), address(this), animalSkillUpgradePrices[_animalType][_level]);
        // Upgrading trait
        // Speed
        if (_trait==0){
            Hamster(hamsterContract).renewAnimalParameters(
                _tokenID,
                _animalType,
                _speed += 1,
                _immunity,
                _armor,
                _response
            );
        } else
        // Immunity 
        if (_trait==1){
            Hamster(hamsterContract).renewAnimalParameters(
                _tokenID,
                _animalType,
                _speed,
                _immunity += 1,
                _armor,
                _response
            );
        } else
        // Armor
        if (_trait==2){
            Hamster(hamsterContract).renewAnimalParameters(
                _tokenID,
                _animalType,
                _speed,
                _immunity,
                _armor -= 1,
                _response
            );
        } else
        // Response
        if (_trait==3){
            Hamster(hamsterContract).renewAnimalParameters(
                _tokenID,
                _animalType,
                _speed,
                _immunity,
                _armor,
                _response -= 500
            );
        } 
    }

}