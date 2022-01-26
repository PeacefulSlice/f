
pragma solidity ^0.8.0;

import "../contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "../contracts-upgradeable/proxy/utils/Initializable.sol";
import "../contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./MarketHeroURI.sol";


contract MarketHeroAnimal is Initializable, ERC721PausableUpgradeable, OwnableUpgradeable {

address public verifiedContract; // Shop contract
address public marketHeroURIContract;

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
    mapping(uint8 => uint32)  animalHamsterBurnAmount;

    // NFT Tokens
    mapping(uint256 => Animal) public animals;
    
    function initialize(
        address _admin,
        address _MarketHeroShop,
        address _MarketHeroURI
    ) public initializer{
        __ERC721_init("MarketHero","MKH");
        __Pausable_init_unchained();
        __Ownable_init_unchained();
        transferOwnership(_admin);


        setDefaultAnimalParameters();
        verifiedContract = _MarketHeroShop;
        marketHeroURIContract = _MarketHeroURI;
        // //hamster
        // animalHamsterBurnAmount[0] = 1;
        // animalMaxAmount[0] = 0;
        // //bull
        // animalHamsterBurnAmount[1] = 20;
        // animalMaxAmount[1] = 5000;
        // //bear
        // animalHamsterBurnAmount[2] = 20;
        // animalMaxAmount[2] = 5000;
        // //whale
        // animalHamsterBurnAmount[3] = 50;
        // animalMaxAmount[3] = 1000;

        setDefaultContractParameters(
            0,    //_maxHamster,
            5000,//_maxBull,
            5000,//_maxBear,
            1000,//_maxWhale,
            1,//_burnHamster,
            20,//_burnBull,
            20,//_burnBear,
            50);//_burnWhale
    }
    
    function pause() external onlyOwner {
        _pause();
    }
    function unpause() external onlyOwner {
        _unpause();
    }

    function setDefaultContractParameters(
        uint32 _maxHamster,
        uint32 _maxBull,
        uint32 _maxBear,
        uint32 _maxWhale,
        uint32 _burnHamster,
        uint32 _burnBull,
        uint32 _burnBear,
        uint32 _burnWhale
    ) public onlyOwner{


        
        //hamster
        animalHamsterBurnAmount[0] = _burnHamster;
        animalMaxAmount[0] = _maxHamster;
        //bull
        animalHamsterBurnAmount[1] = _burnBull;
        animalMaxAmount[1] = _maxBull;
        //bear
        animalHamsterBurnAmount[2] = _burnBear;
        animalMaxAmount[2] = _maxBear;
        //whale
        animalHamsterBurnAmount[3] = _burnWhale;
        animalMaxAmount[3] = _maxWhale;
    }

    function tokenURI(uint256 _tokenID) public view virtual override returns(string memory){
        require(_exists(_tokenID),"That hero doesn`t exist");
        string memory _line = MarketHeroURI(marketHeroURIContract).convert( 
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


    /**
    * @dev function read parameters of specific animal
    * @param _tokenID ID of an animal
     */
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
    /**
    * @dev function read parameters from array "color_and_effects"
    * @param _tokenID ID of an animal
     */
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

    /**
    * @dev Function allows to renew "color_and_effects" array of specific animal
    * @param _tokenID ID of an animal
     */
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

    /**
    * @dev Function allows to renew base traits of specific animal
        (also used for upgrade in shop)
    * @param _tokenID ID of an animal
    
     */
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

    /**
    * @dev Reading default meanings of animal traits
     */
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


    /**
    * @dev setting default meanings for animal parameters 
     */
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

    /**
    * @dev minting a certain amount of heroes for free(presale or airdrop)
    * @param _animalType 1 of 4 types of animals
    * @param _animalAmount number of animals, which will be minted
     */
    function createAnimals(uint8 _animalType, uint256 _animalAmount) external  {
        require(animalMaxAmount[_animalType] == 0 || animalMaxAmount[_animalType] >= animalMintedAmount[_animalType] + _animalAmount, "Can't mint that much of animals");
        require(
                (_msgSender() == verifiedContract)||
            (_msgSender()==owner()), "not enough roots");

        for (uint256 animalID = 0; animalID < _animalAmount; animalID++){
            _mintAnimal(_animalType, msg.sender);

        }
        
    }

    /**
    * @dev base mint function
    * @param _animalType 1 of 4 types of animals
    * @param _to receiver address
     */
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

    /**
    * @dev  mint function for contract shop
    * @param _animalType 1 of 4 types of animals
    * @param _to receiver address
     */
    function mintAnimal(uint8 _animalType, address _to) external whenNotPaused{
        require(animalMaxAmount[_animalType] == 0 || animalMaxAmount[_animalType] >= animalMintedAmount[_animalType] + 1, "Can't mint that much of animals");
        require((_msgSender() == verifiedContract)||(_msgSender()==owner()), "not enough roots");        
        _mintAnimal(_animalType, _to);
    }

}













