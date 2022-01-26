const chai = require('chai');
const {  expectRevert } = require('@openzeppelin/test-helpers');
const web3 =  require("web3")
const { current, inTransaction } = require('@openzeppelin/test-helpers/src/expectEvent');
const BN = web3.utils.BN;
const expect = chai.expect;
chai.use(require('chai-match'));
chai.use(require('bn-chai')(BN));

const TestToken = artifacts.require('TestToken');
const PProxy = artifacts.require('PProxy');
const PProxyAdmin = artifacts.require('PProxyAdmin');
const MarketHeroAnimal = artifacts.require('MarketHeroAnimal');
const MarketHeroShop = artifacts.require('MarketHeroShop');
const MarketHeroURI = artifacts.require('MarketHeroURI');

function toBN(number){
    return web3.utils.toBN(number);
}
module.exports = async function (deployer, network, accounts){
    let admin = accounts[0];
    console.log("Deploy: Admin: "+admin);
    const decimals = toBN(10).pow(toBN(18));
    let marketHeroURI;
    await deployer.deploy(MarketHeroURI, admin)
        .then(function(){
            console.log("MarketHeroURI instance: ", MarketHeroURI.address);
            return MarketHeroURI.at(MarketHeroURI.address);
        }).then(function (instance){
            marketHeroURI = instance; 
        });

    await TestToken.new(toBN(1000).mul(decimals),"TokenMHT","MHT").then(instance => tokenMHT = instance);
    await MarketHeroShop.new().then(instance => masterMarketHeroShopCopy = instance);
    await MarketHeroAnimal.new().then(instance => masterMarketHeroAnimalCopy = instance); 
    shop = await MarketHeroShop.at(masterMarketHeroShopCopy.address);
    animal = await MarketHeroAnimal.at(masterMarketHeroAnimalCopy.address);
    await shop.initialize.sendTransaction(admin, tokenMHT.address);
    await animal.initialize.sendTransaction(admin, shop.address, marketHeroURI.address);       
    
}