// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./../contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./../contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./../contracts-upgradeable/security/PausableUpgradeable.sol";
import "./../contracts-upgradeable/proxy/utils/Initializable.sol";

import "./MarketHeroAnimal.sol";


interface IToken {
    function decimals() external view returns(uint8);
}


contract MarketHeroShop is Initializable, AccessControlUpgradeable, PausableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    address public tokenMHT;
    address public marketHeroAnimalContract;
    
    address public admin;


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


        setDefaultAnimalPrices(
            10, // _priceHamster
            150,// _priceBull
            150,// _priceBear
            300 // _priceWhale
        );
        setDefaultUpgradePrices(0,5,10,15,20);     // _priceHamster
        setDefaultUpgradePrices(1,75,150,225,300); // _priceBull
        setDefaultUpgradePrices(2,75,150,225,300); // _priceBear
        setDefaultUpgradePrices(3,150,300,450,600);// _priceWhale
    }

    function setTokenMHT(address _tokenMHT) external onlyAdmin{
        tokenMHT = _tokenMHT;

    }

    function setDefaultAnimalPrices(
        uint256 _priceHamster,
        uint256 _priceBull,
        uint256 _priceBear,
        uint256 _priceWhale
    ) private{
        uint8 _decimals = uint8(IToken(tokenMHT).decimals());
         //hamster
        animalPrices[0] = _priceHamster*(10**_decimals);
        //bull
        animalPrices[1] = _priceBull*(10**_decimals);
        //bear
        animalPrices[2] = _priceBear*(10**_decimals);
        //whale
        animalPrices[3] = _priceWhale*(10**_decimals);
    }

    function getAnimalPrices() external view returns(uint256, uint256, uint256, uint256){
        return (
            animalPrices[0],
            animalPrices[1],
            animalPrices[2],
            animalPrices[3]
        );
    }



    function setDefaultUpgradePrices(
        uint8 _AnimalType,
        uint256 _1stLevelPrice,
        uint256 _2ndLevelPrice,
        uint256 _3rdLevelPrice,
        uint256 _4thLevelPrice
    ) private{
        uint8 _decimals = uint8(IToken(tokenMHT).decimals());
        animalSkillUpgradePrices[_AnimalType][0] = _1stLevelPrice*(10**_decimals);
        animalSkillUpgradePrices[_AnimalType][1] = _2ndLevelPrice*(10**_decimals);
        animalSkillUpgradePrices[_AnimalType][2] = _3rdLevelPrice*(10**_decimals);
        animalSkillUpgradePrices[_AnimalType][3] = _4thLevelPrice*(10**_decimals);
    }

    function getUpgradePrices(
        uint8 _AnimalType
    ) external view returns(uint256, uint256, uint256, uint256) {
        return(
            animalSkillUpgradePrices[_AnimalType][0],
            animalSkillUpgradePrices[_AnimalType][1],
            animalSkillUpgradePrices[_AnimalType][2],
            animalSkillUpgradePrices[_AnimalType][3]);
    }

    function setMarketHeroAnimalContract(address _marketHeroAnimalContract) external onlyAdmin {
        marketHeroAnimalContract = _marketHeroAnimalContract;
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
        require(IERC20Upgradeable(tokenMHT).balanceOf(_msgSender())>=animalPrices[_animalType],"not enough money");

        IERC20Upgradeable(tokenMHT).safeTransferFrom(_msgSender(), address(this), animalPrices[_animalType]);

        MarketHeroAnimal(marketHeroAnimalContract).mintAnimal(_animalType, _msgSender());
        
    }
    // 7) Upgrade parameters of hero 
    function upgradeSpecificTrait(uint256 _tokenID, uint8 _trait) external whenNotPaused{
        // require((_msgSender()== ),"");
        uint8 _level = 0;
 
        (
            uint8 _animalType,
            uint8 _speed,
            uint8 _immunity,
            uint8 _armor,
            uint32 _response
        ) = MarketHeroAnimal(marketHeroAnimalContract).getAnimalParameters(_tokenID);
        
        // Calculating level of trait
        // Speed
        if (_trait==0){
            _level = _speed;
            require (((_level>=0)&&(_level<=3)),"speed is not in boundaries");
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
        require ((IERC20Upgradeable(tokenMHT).balanceOf(_msgSender())>=animalSkillUpgradePrices[_animalType][_level]),"not enough money for upgrade this trait");
        IERC20Upgradeable(tokenMHT).safeTransferFrom(_msgSender(), address(this), animalSkillUpgradePrices[_animalType][_level]);
        // Upgrading trait
        // Speed
        if (_trait==0){
            MarketHeroAnimal(marketHeroAnimalContract).renewAnimalParameters(
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
            MarketHeroAnimal(marketHeroAnimalContract).renewAnimalParameters(
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
            MarketHeroAnimal(marketHeroAnimalContract).renewAnimalParameters(
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
            MarketHeroAnimal(marketHeroAnimalContract).renewAnimalParameters(
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