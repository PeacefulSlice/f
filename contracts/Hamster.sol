// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "../base64-sol/base64.sol";
import "../contracts-upgradeable/security/PausableUpgradeable.sol";
import "../contracts-upgradeable/utils/ContextUpgradeable.sol";
import "../contracts-upgradeable/proxy/utils/Initializable.sol";
import "../contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Hamster is Initializable, ContextUpgradeable, ERC721Upgradeable, AccessControlUpgradeable, PausableUpgradeable {

    // struct Hero{
    //     Animal pet;
    //     uint256[4] Max_Amount;
    //     uint256[4] Minted_Amount;
    //     uint128[4] Price;
    //     uint128[4][4] Skill_Upgrade_price;
    //     uint128[4] Hamsters_amount;
    // }

    // bytes32 public constant DEFAULT_ADMIN_ROLE = keccak256("DEFAULT_ADMIN_ROLE");
    enum AnimalType{
        Hamster,
        Bull,
        Bear,
        Whale
    }

    struct Animal{
        AnimalType name;
        uint256[8] Color_and_effects;
        uint8 speed; 
        uint8 immunity;
        uint8 armor;
        uint32 response;
        mapping (uint256 => bool) items;
    }

    mapping(uint8 => uint32) animalMaxAmount;
    mapping(uint8 => uint64) animalMintedAmount;
    mapping(uint8 => uint256) animalPrices;
    mapping(uint8 => mapping(uint8 => uint256)) animalSkillUpgradePrices;
    mapping(uint8 => uint256) animalHamsterBurnAmount;


    //tpkenID => Animal
    mapping(uint256 => Animal) animals;


    function supportsInterface(bytes4 interfaceID) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable)  returns (bool) {
        return AccessControlUpgradeable.supportsInterface(interfaceID);
    }
    
    
    function initialize(
        address _admin

    ) public initializer{
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);

        uint256 mhtDecimals = 10**18;

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
                             animals[tokenID].Color_and_effects,
                             '", "Speed":" ',
                             animals[tokenID].speed,
                             '", "Immunity":" ',
                             animals[tokenID].immunity,
                             '", "Armor":" ',
                             animals[tokenID].armor,
                             '", "Response":" ',
                             animals[tokenID].response,
                             '"}'
                         )
                     )
                 )   
                )
            );


    }


}