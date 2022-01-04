
pragma solidity ^0.8.0;

import "../contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "../base64-sol/base64.sol";
import "../contracts-upgradeable/security/PausableUpgradeable.sol";
import "../contracts-upgradeable/proxy/utils/Initializable.sol";
import "../contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../openzeppelin-contracts/utils/Strings.sol";

contract Hamster is Initializable, ContextUpgradeable, ERC721Upgradeable, OwnableUpgradeable, PausableUpgradeable {

address public verifiedContract; // Shop contract

   enum AnimalType{
        Hamster,
        Bull,
        Bear,
        Whale
   }
    Animal public adminAnimal; // Animal template for token 
    uint256 private lastMintedTokenID;

// 
    struct Animal{
        AnimalType name;
        uint64[8] color_and_effects;
        uint8 speed; 
        uint8 immunity;
        uint8 armor;
        uint32 response;
    }

    // contract limit parameters
    mapping(uint8 => uint32)  animalMaxAmount;
    mapping(uint8 => uint64)  animalMintedAmount;
    mapping(uint8 => uint256)  animalHamsterBurnAmount;

    // NFT Tokens
    mapping(uint256 => Animal) public animals;
    
    function initialize(
        address _admin,
        address _shop
    ) public initializer{
        __ERC721_init("MarketHero","MKH");
        __Context_init_unchained();
        __Pausable_init_unchained();
        __Ownable_init_unchained();
        transferOwnership(_admin);

        verifiedContract = _shop;
        //hamster
        animalHamsterBurnAmount[0] = 1;
        animalMaxAmount[0] = 0;
        //bull
        animalHamsterBurnAmount[1] = 20;
        animalMaxAmount[1] = 5000;
        //bear
        animalHamsterBurnAmount[2] = 20;
        animalMaxAmount[2] = 5000;
        //whale
        animalHamsterBurnAmount[3] = 50;
        animalMaxAmount[3] = 1000;
    }
    
    function pause() external onlyOwner {
        _pause();
    }
    function unpause() external onlyOwner {
        _unpause();
    }
    function tokenURI(uint256 _tokenID) public view virtual override returns(string memory){
        require(_exists(_tokenID),"That hero doesn`t exist");
 
        string memory _link = getAnimalPhoto(uint8(animals[_tokenID].name));
        string memory _name = Strings.toString(uint8(animals[_tokenID].name));
        string memory _speed = Strings.toString(animals[_tokenID].speed);
        string memory _immunity = Strings.toString(animals[_tokenID].immunity);
        string memory _armor = Strings.toString(animals[_tokenID].armor);
        string memory _response = Strings.toString(animals[_tokenID].response);
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64, ",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(),
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
//  1) read parameters of specific character
    function getAnimalParameters(uint256 _tokenID) public view returns(
        uint8,
        uint8,
        uint8,
        uint8,
        uint32
        ) {
        return(
            uint8(animals[_tokenID].name),
            animals[_tokenID].speed,
            animals[_tokenID].immunity,
            animals[_tokenID].armor,
            animals[_tokenID].response
        );

    }
    function getAnimalColorAndEffects(uint256 _tokenID) public view returns(
        uint64,
        uint64,
        uint64,
        uint64,
        uint64,
        uint64,
        uint64,
        uint64
        ){
        uint index = 0;
        uint64[8] memory colordata = animals[_tokenID].color_and_effects;
        return(
            colordata[index++],
            colordata[index++],
            colordata[index++],
            colordata[index++],
            colordata[index++],
            colordata[index++],
            colordata[index++],
            colordata[index++]
        );
    }

//  2) Renew parameters of specific character

    // changes all parameters except color_and_effects array by owner
    function _renewAnimalParameters(
        uint256 _tokenID,
        uint8 _animalType,
        uint8 _speed,
        uint8 _immunity,
        uint8 _armor,
        uint32 _response
        ) private {
        animals[_tokenID].name = AnimalType(_animalType);
        animals[_tokenID].speed = _speed;
        animals[_tokenID].immunity = _immunity;
        animals[_tokenID].armor = _armor;
        animals[_tokenID].response = _response;
    }
    // returns color_and_effects array
    function _renewAnimalColorAndEffects(
        uint256 _tokenID
        )private{
            uint64[8] memory _color_and_effects;
            (
                _color_and_effects[0],
                _color_and_effects[1],
                _color_and_effects[2],
                _color_and_effects[3],
                _color_and_effects[4],
                _color_and_effects[5],
                _color_and_effects[6],
                _color_and_effects[7]) = getAnimalColorAndEffects(_tokenID);
                
            animals[_tokenID].color_and_effects[0]=_color_and_effects[0];
            animals[_tokenID].color_and_effects[1]=_color_and_effects[1];
            animals[_tokenID].color_and_effects[2]=_color_and_effects[2];
            animals[_tokenID].color_and_effects[3]=_color_and_effects[3];
            animals[_tokenID].color_and_effects[3]=_color_and_effects[3];
            animals[_tokenID].color_and_effects[3]=_color_and_effects[3];
            animals[_tokenID].color_and_effects[4]=_color_and_effects[4];
            animals[_tokenID].color_and_effects[5]=_color_and_effects[5];
            animals[_tokenID].color_and_effects[6]=_color_and_effects[6];
            animals[_tokenID].color_and_effects[7]=_color_and_effects[7];
    }

    // function upgrade only in shop(by user)
    function renewAnimalParameters(
        uint256 _tokenID,
        uint8 _animalType,
        uint8 _speed,
        uint8 _immunity,
        uint8 _armor,
        uint32 _response
        )external whenNotPaused{
            require(_msgSender() == verifiedContract, "");
            animals[_tokenID].name = AnimalType(_animalType);
            animals[_tokenID].speed = _speed;
            animals[_tokenID].immunity = _immunity;
            animals[_tokenID].armor = _armor;
            animals[_tokenID].response = _response;
        }

//  3)Read default character parameters
    function getDefaultColorAndEffects() external view returns(
        uint64,
        uint64,
        uint64,
        uint64,
        uint64,
        uint64,
        uint64,
        uint64
        ){
        return(
            adminAnimal.color_and_effects[0],
            adminAnimal.color_and_effects[1],
            adminAnimal.color_and_effects[2],
            adminAnimal.color_and_effects[3],
            adminAnimal.color_and_effects[4],
            adminAnimal.color_and_effects[5],
            adminAnimal.color_and_effects[6],
            adminAnimal.color_and_effects[7]
        );
    }


    function getDefaultParameters() external view  returns(
        uint8,
        uint8,
        uint8,
        uint8,
        uint32
        ) {
        return(
            uint8(adminAnimal.name),
            adminAnimal.speed,
            adminAnimal.immunity,
            adminAnimal.armor,
            adminAnimal.response
            );
    }

//  4) Renew default character parameters
    function setDefaultAnimalParameters() external onlyOwner{
        adminAnimal.color_and_effects[0]=0;
        adminAnimal.color_and_effects[1]=0;
        adminAnimal.color_and_effects[2]=0;
        adminAnimal.color_and_effects[3]=0;
        adminAnimal.color_and_effects[4]=0;
        adminAnimal.color_and_effects[5]=0;
        adminAnimal.color_and_effects[6]=0;
        adminAnimal.color_and_effects[7]=0;
        
        adminAnimal.speed = 0;
        adminAnimal.immunity = 0;
        adminAnimal.armor = 4;
        adminAnimal.response = 2000;

    }

//  6) Opportunity to mint a certain amount of heroes for free(presale or airdrop)
    function createAnimals(uint8 _animalType, uint256 _animalAmount) external onlyOwner {
        require(animalMaxAmount[_animalType] == 0 || animalMaxAmount[_animalType] >= animalMintedAmount[_animalType] + _animalAmount, "Can't mint that much of animals");
        

        for (uint256 animalID = 0; animalID < _animalAmount; animalID++){
            _mintAnimal(_animalType, msg.sender);

        }
        
    }
    // base mint
    function _mintAnimal(uint8 _animalType, address _to) private {
        // require(animalMaxAmount[_animalType] == 0 || animalMaxAmount[_animalType] >= animalMintedAmount[_animalType] + 1, "Can't mint that much of animals");
        uint256 _tokenID = ++lastMintedTokenID;
        _safeMint(_to, _tokenID);
        animals[_tokenID].name = AnimalType(_animalType);
        animals[_tokenID].color_and_effects[0]= adminAnimal.color_and_effects[0];
        animals[_tokenID].color_and_effects[1]= adminAnimal.color_and_effects[1];
        animals[_tokenID].color_and_effects[2]= adminAnimal.color_and_effects[2];
        animals[_tokenID].color_and_effects[3]= adminAnimal.color_and_effects[3];
        animals[_tokenID].color_and_effects[4]= adminAnimal.color_and_effects[4];
        animals[_tokenID].color_and_effects[5]= adminAnimal.color_and_effects[5];
        animals[_tokenID].color_and_effects[6]= adminAnimal.color_and_effects[6];
        animals[_tokenID].color_and_effects[7]= adminAnimal.color_and_effects[7];
        animals[_tokenID].speed = adminAnimal.speed;
        animals[_tokenID].immunity = adminAnimal.immunity;
        animals[_tokenID].armor = adminAnimal.armor;
        animals[_tokenID].response = adminAnimal.response;

        animalMintedAmount[_animalType]++;


        
    }
    // mint for shop(by user)
    function mintAnimal(uint8 _animalType, address _to) external whenNotPaused{
        require(animalMaxAmount[_animalType] == 0 || animalMaxAmount[_animalType] >= animalMintedAmount[_animalType] + 1, "Can't mint that much of animals");
        require(_msgSender() == verifiedContract, "");
        
        _mintAnimal(_animalType, _to);
    }

}













