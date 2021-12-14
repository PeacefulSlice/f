// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "../node_modules/base64-sol/base64.sol";
// import "../node_modules/@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Hamster is Initializable, ERC721Upgradeable, AccessControlUpgradeable {

    struct Hero{
        Animal pet;
        uint256[4] Max_Amount;
        uint256[4] Minted_Amount;
        uint128[4] Price;
        uint128[4][4] Skill_Upgrade_price;
        uint128[4] Hamsters_amount;
    }

    // bytes32 public constant DEFAULT_ADMIN_ROLE = keccak256("DEFAULT_ADMIN_ROLE");
    enum AnimalType{
        Hamster,
        Bull,
        Bear,
        Whale

    }
    struct Animal{
        AnimalType[] name;
        uint256[8] Color_and_effects;
        uint8 speed; 
        uint8 immunity;
        uint8 armor;
        uint32 response;
        uint256 games_played;
        uint8 wins_percent;
        uint256 p2p_Games_played;
        uint8 p2p_Wins_percent;
        uint256 Tournaments_played;
        uint8 Tournaments_wins_percent;
        uint256 MHT_paid;
        uint256 MHT_won;
        // uint256[100] Items
    }

    function supportsInterface(bytes4 interfaceID) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable)  returns (bool) {
        return AccessControlUpgradeable.supportsInterface(interfaceID);
    }
    
    Animal[] private _animals;
    function initialize(
        address _admin

    ) public initializer{
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);

        

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
                             _animals[tokenID].name,
                             '", "Color and effects":" ',
                             _animals[tokenID].Color_and_effects,
                             '", "Speed":" ',
                             _animals[tokenID].speed,
                             '", "Immunity":" ',
                             _animals[tokenID].immunity,
                             '", "Armor":" ',
                             _animals[tokenID].armor,
                             '", "Response":" ',
                             _animals[tokenID].response,
                             '", "Games played":" ',
                             _animals[tokenID].games_played,
                             '", "Wins %":" ',
                             _animals[tokenID].wins_percent,
                             '", "p2p Games played":" ',
                             _animals[tokenID].p2p_Games_played,
                             '", "p2p Wins %":" ',
                             _animals[tokenID].p2p_Wins_percent,
                             '", "Tournaments played":" ',
                             _animals[tokenID].Tournaments_played,
                             '", "Tournaments wins %":" ',
                             _animals[tokenID].Tournaments_wins_percent,
                             '", "MHT paid":" ',
                             _animals[tokenID].MHT_paid,
                             '", "MHT won":" ',
                             _animals[tokenID].MHT_won,
                             '"}'
                         )
                     )
                 )   
                )
            );


    }





    uint256[50] private __gap;
}