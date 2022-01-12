
pragma solidity ^0.8.0;

import "../contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "../contracts-upgradeable/proxy/utils/Initializable.sol";
import "../contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./HamsterURI.sol";


contract Hamster is Initializable, ERC721PausableUpgradeable, OwnableUpgradeable {

address public verifiedContract; // Shop contract
address public hamsterURIContract;

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
        address _shop,
        address _hamsteruri
    ) public initializer{
        __ERC721_init("MarketHero","MKH");
        __Pausable_init_unchained();
        __Ownable_init_unchained();
        transferOwnership(_admin);


        setDefaultAnimalParameters();
        verifiedContract = _shop;
        hamsterURIContract = _hamsteruri;
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
        string memory _line = HamsterURI(hamsterURIContract).convert( 
            name(), 
            uint8(animals[_tokenID].name), 
            uint8(animals[_tokenID].name),
            animals[_tokenID].speed,
            animals[_tokenID].immunity,
            animals[_tokenID].armor,
            animals[_tokenID].response
        ); 
        return _line;
    }

    // function setHamsterURIContract(address _hamsterURIContract) external onlyOwner{
    //     hamsterURIContract = _hamsterURIContract;
    // }

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
//  1) 
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

    // function upgrade 
    function renewAnimalParameters(
        uint256 _tokenID,
        uint8 _animalType,
        uint8 _speed,
        uint8 _immunity,
        uint8 _armor,
        uint32 _response
        )public whenNotPaused{
            require(
                (_msgSender() == verifiedContract)||
            (_msgSender()==owner()), "not enough roots");
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
    function setDefaultAnimalParameters() private {
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
    function createAnimals(uint8 _animalType, uint256 _animalAmount) external  {
        require(animalMaxAmount[_animalType] == 0 || animalMaxAmount[_animalType] >= animalMintedAmount[_animalType] + _animalAmount, "Can't mint that much of animals");
        require(
                (_msgSender() == verifiedContract)||
            (_msgSender()==owner()), "not enough roots");

        for (uint256 animalID = 0; animalID < _animalAmount; animalID++){
            _mintAnimal(_animalType, msg.sender);

        }
        
    }
    // base mint
    function _mintAnimal(uint8 _animalType, address _to) private {
        require(animalMaxAmount[_animalType] == 0 || animalMaxAmount[_animalType] >= animalMintedAmount[_animalType] + 1, "Can't mint that much of animals");
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
        require((_msgSender() == verifiedContract)||(_msgSender()==owner()), "not enough roots");        
        _mintAnimal(_animalType, _to);
    }

}













