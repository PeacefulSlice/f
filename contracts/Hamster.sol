// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "../base64-sol/base64.sol";
import "../contracts-upgradeable/security/PausableUpgradeable.sol";
import "../contracts-upgradeable/utils/ContextUpgradeable.sol";
import "../contracts-upgradeable/proxy/utils/Initializable.sol";
import '../contracts-upgradeable/access/OwnableUpgradeable.sol';

contract Hamster is Initializable, ContextUpgradeable, ERC721Upgradeable, OwnableUpgradeable, PausableUpgradeable {

   enum AnimalType{
        Hamster,
        Bull,
        Bear,
        Whale
    }
    AnimalType public Convert;
    uint256 public adminAnimal;
    

    struct Animal{
        AnimalType name;
        uint256[8] color_and_effects;
        // mapping(uint8 => uint256) color_and_effects;
        uint8 speed; 
        uint8 immunity;
        uint8 armour;
        uint32 response;
        mapping (uint256 => bool) items;
    }

    mapping(uint8 => AnimalType) animalConvert;
    mapping(uint8 => uint32) animalMaxAmount;
    mapping(uint8 => uint64) animalMintedAmount;
    mapping(uint8 => uint256) animalPrices;
    mapping(uint8 => mapping(uint8 => uint256)) animalSkillUpgradePrices;
    mapping(uint8 => uint256) animalHamsterBurnAmount;
    mapping(uint256 => Animal) animals;
   
    
    function initialize(
        address _admin

    ) public initializer{
        
        __Context_init_unchained();
        __Pausable_init_unchained();
        __Ownable_init_unchained();
        transferOwnership(_admin);
        
        uint256 mhtDecimals = 10**18;
        adminAnimal = 0;

        
        animalConvert[0] = AnimalType.Hamster;
        animalConvert[1] = AnimalType.Bull;
        animalConvert[2] = AnimalType.Bear;
        animalConvert[3] = AnimalType.Whale;
        
        //hamster
        animalMintedAmount[0] = 0;
        animalPrices[0] = 10*mhtDecimals;
        animalSkillUpgradePrices[0][0] = 5*mhtDecimals;
        animalSkillUpgradePrices[0][1] = 10*mhtDecimals;
        animalSkillUpgradePrices[0][2] = 15*mhtDecimals;
        animalSkillUpgradePrices[0][3] = 20*mhtDecimals;
        animalHamsterBurnAmount[0] = 1;
        //bull
        animalMintedAmount[1] = 0;
        animalPrices[1] = 150*mhtDecimals;
        animalSkillUpgradePrices[1][0] = 75*mhtDecimals;
        animalSkillUpgradePrices[1][1] = 150*mhtDecimals;
        animalSkillUpgradePrices[1][2] = 225*mhtDecimals;
        animalSkillUpgradePrices[1][3] = 300*mhtDecimals;
        animalHamsterBurnAmount[1] = 20;
        //bear
        animalMintedAmount[2] = 0;
        animalPrices[2] = 150*mhtDecimals;
        animalSkillUpgradePrices[2][0] = 75*mhtDecimals;
        animalSkillUpgradePrices[2][1] = 150*mhtDecimals;
        animalSkillUpgradePrices[2][2] = 225*mhtDecimals;
        animalSkillUpgradePrices[2][3] = 300*mhtDecimals;
        animalHamsterBurnAmount[2] = 20;
        //whale
        animalMintedAmount[3] = 0;
        animalPrices[3] = 300*mhtDecimals;
        animalSkillUpgradePrices[3][0] = 150*mhtDecimals;
        animalSkillUpgradePrices[3][1] = 300*mhtDecimals;
        animalSkillUpgradePrices[3][2] = 450*mhtDecimals;
        animalSkillUpgradePrices[3][3] = 600*mhtDecimals;
        animalHamsterBurnAmount[3] = 50;

        renewAnimalParameters(adminAnimal, 0, 0, 4, 2000);
    }


    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }


    function tokenURI(uint256 tokenID) public view virtual override returns(string memory){
        require(_exists(tokenID),"That hero doesn`t exist");
        return
            string(
                abi.encodePacked(
                 "data:application/json;base64, ",
                 Base64.encode(
                     bytes(
                         abi.encodePacked(
                             '{"type":"',
                             animals[tokenID].name,
                             '", "Color and effects":" ',
                             animals[tokenID].color_and_effects,
                             '", "Speed":" ',
                             animals[tokenID].speed,
                             '", "Immunity":" ',
                             animals[tokenID].immunity,
                             '", "Armour":" ',
                             animals[tokenID].armour,
                             '", "Response":" ',
                             animals[tokenID].response,
                             '"}'
                         )
                     )
                 )   
                )
            );


    }

    function readParameters(uint256 tokenID) public view onlyOwner returns(
        AnimalType, 
        // uint256[] memory , 
        uint8,uint8,uint8,uint32) {
        
        return(
            animals[tokenID].name,
            // animals[tokenID].color_and_effects,
            animals[tokenID].speed,
            animals[tokenID].immunity,
            animals[tokenID].armour,
            animals[tokenID].response
        );

    }
    function createAnimal(uint256 tokenID, uint8 _animalType) public {
        require((balanceOf(msg.sender)>=animalPrices[_animalType]),'not enough money');
        _mintAnimal(tokenID, _animalType);
    }
    
    function _mintAnimal(uint256 tokenID, uint8 _animalType) public virtual onlyOwner{
        // require((balanceOf(msg.sender)>=animalPrices[_animalType]),'not enough money');
        animals[tokenID].name = animalConvert[_animalType];

        animals[tokenID].speed = animals[adminAnimal].speed;
        animals[tokenID].immunity = animals[adminAnimal].immunity;
        animals[tokenID].armour = animals[adminAnimal].armour;
        animals[tokenID].response = animals[adminAnimal].response;

        
    }



    function renewAnimalParameters(
        uint256 _adminAnimal,
        uint8 _speed,
        uint8 _immunity,
        uint8 _armour,
        uint32 _response
        ) public onlyOwner returns(uint256){

        animals[_adminAnimal].speed = _speed;
        animals[_adminAnimal].immunity = _immunity;
        animals[_adminAnimal].armour = _armour;
        animals[_adminAnimal].response = _response;

        return _adminAnimal;
    }


}