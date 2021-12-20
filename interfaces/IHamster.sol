// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IHamster {
    enum AnimalType{
        Hamster,
        Bull,
        Bear,
        Whale
    }
    // function readParameters(uint256 tokenID) external view  returns(
        // AnimalType, 
        // uint256[] memory , 
        // uint8,uint8,uint8,uint32) ;
    // function createAnimal(uint256 tokenID, uint8 _animalType) external ;
    
    function _mintAnimal(uint256 tokenID, uint8 _animalType) external ;
    // function renewAnimalParameters(uint256 _adminAnimal, uint8 _speed, uint8 _immunity,uint8 _armour, uint32 _response) external returns(uint256);
}
