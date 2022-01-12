pragma solidity ^0.8.10;

import "../base64-sol/base64.sol";

import "../openzeppelin-contracts/utils/Strings.sol";

contract HamsterURI {
    
    
    function convert(string memory __name, uint8 link, uint8 name, uint8 speed, uint8 immunity, uint8 armor, uint32 response) external pure returns(string memory){
        
 
        string memory _link = getAnimalPhoto(link);
        string memory _name = Strings.toString(name);
        string memory _speed = Strings.toString(speed);
        string memory _immunity = Strings.toString(immunity);
        string memory _armor = Strings.toString(armor);
        string memory _response = Strings.toString(response);
        return 
            string(
                abi.encodePacked(
                    "data:application/json;base64, ",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                __name,
                                '","description": "Animal for Market Hero ',  

                                '", "image": "',
                                _link,
                                
                                '", "attributes": [ ',
                                    '{ "trait_type": "Type","value": "',
                                    _name,
                                    '"},',
                                    '{ "trait_type": "Speed","value": "',
                                    _speed,
                                    '"},',
                                    '{ "trait_type": "Immunity","value": "',
                                    _immunity,
                                    '"},',
                                    '{ "trait_type": "Armor","value": "',
                                    _armor,
                                    '"},',
                                    '{ "trait_type": "Response","value": "',
                                    _response,
                                    '"} ]',
                                '}'
                            )
                        )
                    )   
                )
            );
 
 
    }
    function getAnimalPhoto(uint8 _animalType) public pure returns (string memory){
        string memory _link ="";
        if(_animalType==0){
            _link = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/Pearl_Winter_White_Russian_Dwarf_Hamster_-_Front.jpg/1920px-Pearl_Winter_White_Russian_Dwarf_Hamster_-_Front.jpg";
        } else 
        if(_animalType==1){
            _link = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Alas_Purwo_banteng_close_up.jpg/550px-Alas_Purwo_banteng_close_up.jpg";
        } else 
        if(_animalType==2){
            _link = "https://xakep.ru/wp-content/uploads/2017/12/147134/bear.jpg";
        } else 
        if(_animalType==3){
            _link = "https://images.immediate.co.uk/production/volatile/sites/23/2019/10/GettyImages-1164887104_Craig-Lambert-2faf563.jpg?quality=90&resize=620%2C413";
        }

        return _link;
    }

    

}


