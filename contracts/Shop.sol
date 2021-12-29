// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "./../contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
// import "./../contracts-upgradeable/access/AccessControlUpgradeable.sol";
// import "./../contracts-upgradeable/security/PausableUpgradeable.sol";
// import "./../contracts-upgradeable/proxy/utils/Initializable.sol";
// import "./../contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";
// import "./Hamster.sol";


// interface IToken {
//     function decimals() external view returns(uint8);
// }


// contract Shop is Initializable, AccessControlUpgradeable, PausableUpgradeable {
//     using SafeERC20Upgradeable for IERC20Upgradeable;
//     address public tokenMHT;
//     address public hamsterContract;


//     bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

//     mapping(uint8 => uint256) animalPrices;
//     mapping(uint8 => mapping(uint8 => uint256)) animalSkillUpgradePrices;

//     function initialize(
//         address _admin,
//         address _tokenMHT
//         )public initializer{
//         __Context_init_unchained();
//         __AccessControl_init();
//         __Pausable_init_unchained();
        
//         _setupRole(DEFAULT_ADMIN_ROLE, _admin);
//         tokenMHT = _tokenMHT;

//         //hamster
//         animalPrices[0] = 10*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[0][0] = 5*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[0][1] = 10*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[0][2] = 15*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[0][3] = 20*IToken(tokenMHT).decimals;
//         //bull
//         animalPrices[1] = 150*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[1][0] = 75*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[1][1] = 150*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[1][2] = 225*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[1][3] = 300*IToken(tokenMHT).decimals;
//         //bear
//         animalPrices[2] = 150*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[2][0] = 75*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[2][1] = 150*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[2][2] = 225*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[2][3] = 300*IToken(tokenMHT).decimals;
//         //whale
//         // animalMintedAmount[3] = 0;
//         animalPrices[3] = 300*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[3][0] = 150*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[3][1] = 300*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[3][2] = 450*IToken(tokenMHT).decimals;
//         animalSkillUpgradePrices[3][3] = 600*IToken(tokenMHT).decimals;
//     }

//     function setTokenMHT(address _tokenMHT) external onlyAdmin{
//         tokenMHT = _tokenMHT;

//     }
//     function setHamsterContract(address _hamsterContract) external onlyAdmin {
//         hamsterContract = _hamsterContract;
//     }

//     modifier onlyAdmin() {
//         require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not the Admin");
//         _;
//     }

//     function pause() external onlyAdmin {
//         _pause();
//     }

//     function unpause() external onlyAdmin {
//         _unpause();
//     }

// //5) Ability to mint hero for money 
//     function buy(uint8 _animalType) external{
//         require(IERC20Upgradeable(tokenMHT).balanceOf(_msgSender())>=animalPrices[_animalType],"");

//         IERC20Upgradeable(tokenMHT).safeTransferFrom(_msgSender(), address(this), animalPrices[_animalType]);

//         // Hamster(_address).buyMint(_animalType, _msgSender());
        
//     }

//     // function upgrade(uint256 _tokenID, .....) external {
//     //     uint256 price = 0;//calculate price here
//     //     tokenMHT.safeTransferFrom(_msgSender(), address(this), price);
//     //     Hamster(_address).upgrade(_tokenID);
//     // }

    
//     // 7) Upgrade parameters of hero 
// // 7) Обновление параметров конкретного персонажа заплатив токеном MHT (юзер)
//     // function upgradeSpeed(uint256 _tokenID) public {
//     //     uint8 _level = animals[_tokenID].speed;
//     //     require((_level>=0)&&(_level<4),'level is not in boundaries');
//     //     require((tokenMHT.balanceOf(msg.sender)>=animalSkillUpgradePrices[_convertAnimal(animals[_tokenID].name)][_level]),'not enough money for Speed upgrade');
//     //     animals[_tokenID].speed++;
//     // } 

//     // function upgradeImmunity(uint256 _tokenID) public {
//     //     uint8 _level = animals[_tokenID].immunity;
//     //     require((_level>=0)&&(_level<4),'level is not in boundaries');
//     //     require((tokenMHT.balanceOf(msg.sender)>=animalSkillUpgradePrices[_convertAnimal(animals[_tokenID].name)][_level]),'not enough money for Immunity upgrade');
//     //     animals[_tokenID].immunity++;
//     // } 

//     // function upgradeArmor(uint256 _tokenID) public {
//     //     uint8 _level = 4 - animals[_tokenID].armor;
//     //     require((_level>0)&&(_level<=4),'level is not in boundaries');
//     //     require((tokenMHT.balanceOf(msg.sender)>=animalSkillUpgradePrices[_convertAnimal(animals[_tokenID].name)][_level]),'not enough money for armor upgrade');
//     //     animals[_tokenID].armor--;
//     // } 

//     // function upgradeResponse(uint256 _tokenID) public {
//     //     uint8 _level = uint8(animals[_tokenID].response/500);
//     //     require((_level>0)&&(_level<=4),'level is not in boundaries');
//     //     require((tokenMHT.balanceOf(msg.sender)>=animalSkillUpgradePrices[_convertAnimal(animals[_tokenID].name)][_level]),'not enough money for Response upgrade');
//     //     animals[_tokenID].response -= 500;
//     // }

//    // function buyMint(uint8 _animalType, address _to) external onlyShop{

//     // }
// }