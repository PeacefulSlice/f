
pragma solidity ^0.8.0;

import "../contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "../base64-sol/base64.sol";
import "../contracts-upgradeable/security/PausableUpgradeable.sol";
import "../contracts-upgradeable/utils/ContextUpgradeable.sol";
import "../contracts-upgradeable/proxy/utils/Initializable.sol";
import "../contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../openzeppelin-contracts/utils/Strings.sol";

contract Hamster is Initializable, ContextUpgradeable, ERC721Upgradeable, OwnableUpgradeable, PausableUpgradeable {

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
    mapping(uint8 => uint32) animalMaxAmount;
    mapping(uint8 => uint64) animalMintedAmount;
    mapping(uint8 => uint256) animalPrices;
    mapping(uint8 => mapping(uint8 => uint256)) animalSkillUpgradePrices;
    mapping(uint8 => uint256) animalHamsterBurnAmount;

    // NFT Tokens
    mapping(uint256 => Animal) animals;
    
    function initialize(
        address _admin
    ) public initializer{
        __ERC721_init("MarketHero","MKH");
        __Context_init_unchained();
        __Pausable_init_unchained();
        __Ownable_init_unchained();
        transferOwnership(_admin);
        
        uint256 mhtDecimals = 10**18;
        //hamster
        animalPrices[0] = 10*mhtDecimals;
        animalSkillUpgradePrices[0][0] = 5*mhtDecimals;
        animalSkillUpgradePrices[0][1] = 10*mhtDecimals;
        animalSkillUpgradePrices[0][2] = 15*mhtDecimals;
        animalSkillUpgradePrices[0][3] = 20*mhtDecimals;
        animalHamsterBurnAmount[0] = 1;
        //bull
        animalPrices[1] = 150*mhtDecimals;
        animalSkillUpgradePrices[1][0] = 75*mhtDecimals;
        animalSkillUpgradePrices[1][1] = 150*mhtDecimals;
        animalSkillUpgradePrices[1][2] = 225*mhtDecimals;
        animalSkillUpgradePrices[1][3] = 300*mhtDecimals;
        animalHamsterBurnAmount[1] = 20;
        //bear
        animalPrices[2] = 150*mhtDecimals;
        animalSkillUpgradePrices[2][0] = 75*mhtDecimals;
        animalSkillUpgradePrices[2][1] = 150*mhtDecimals;
        animalSkillUpgradePrices[2][2] = 225*mhtDecimals;
        animalSkillUpgradePrices[2][3] = 300*mhtDecimals;
        animalHamsterBurnAmount[2] = 20;
        //whale
        // animalMintedAmount[3] = 0;
        animalPrices[3] = 300*mhtDecimals;
        animalSkillUpgradePrices[3][0] = 150*mhtDecimals;
        animalSkillUpgradePrices[3][1] = 300*mhtDecimals;
        animalSkillUpgradePrices[3][2] = 450*mhtDecimals;
        animalSkillUpgradePrices[3][3] = 600*mhtDecimals;
        animalHamsterBurnAmount[3] = 50;
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
        }
        return _link;
    }
//  1) read parameters of specific character
    function getHeroParameters(uint256 _tokenID) external view returns(
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
    function getHeroColorAndEffects(uint256 _tokenID) external view returns(
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
    function renewAnimalParameters(
        uint256 _tokenID,
        uint8 _animalType,
        uint64[8] memory _color_and_effects,
        uint8 _speed,
        uint8 _immunity,
        uint8 _armor,
        uint32 _response
        ) private {
        animals[_tokenID].name = AnimalType(_animalType);
        animals[_tokenID].color_and_effects[0]=_color_and_effects[0];
        animals[_tokenID].color_and_effects[1]=_color_and_effects[1];
        animals[_tokenID].color_and_effects[2]=_color_and_effects[2];
        animals[_tokenID].color_and_effects[3]=_color_and_effects[3];
        animals[_tokenID].color_and_effects[4]=_color_and_effects[4];
        animals[_tokenID].color_and_effects[5]=_color_and_effects[5];
        animals[_tokenID].color_and_effects[6]=_color_and_effects[6];
        animals[_tokenID].color_and_effects[7]=_color_and_effects[7];
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
    function setDefaultAnimalParameters() private{
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
    function _mintAnimal(uint8 _animalType, address _to) private {
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

        
    }

 

 






}













