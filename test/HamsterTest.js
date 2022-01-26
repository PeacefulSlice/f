const chai = require('chai');
const {  expectRevert } = require('@openzeppelin/test-helpers');
const web3 =  require("web3")
// const { current, inTransaction } = require('@openzeppelin/test-helpers/src/expectEvent');
const BN = web3.utils.BN;
const expect = chai.expect;
chai.use(require('chai-match'));
chai.use(require('bn-chai')(BN));

const TestToken = artifacts.require('TestToken');
const MarketHeroAnimal = artifacts.require('MarketHeroAnimal');
const MarketHeroShop = artifacts.require('MarketHeroShop');
const MarketHeroURI = artifacts.require('MarketHeroURI');

function toBN(number){
    return web3.utils.toBN(number);
}


contract('MarketHero', (accounts)=>{
    
    let admin = accounts[0];
    let user1 = accounts[1];
    const decimals = toBN(10).pow(toBN(18));

    // let proxyInstance;
    let masterMarketHeroAnimalCopy;
    let masterMarketHeroShopCopy;
    let animal;
    let shop;
    let tokenMHT;
    let index;
    let traits;
    let color_and_effects;
    let full_amountTokenMHT;
    let marketHeroURI;
    let user1_balance;
    let bear_price;
    let lvl1_bear_price;
    let lvl2_bull_price;
    
    
    



    before(async()=>{
        await MarketHeroURI.deployed().then(instance => marketHeroURI = instance);
        await TestToken.new(toBN(1000).mul(decimals),"TokenMHT","MHT").then(instance => tokenMHT = instance);
        await MarketHeroShop.new().then(instance => masterMarketHeroShopCopy = instance);
        await MarketHeroAnimal.new().then(instance => masterMarketHeroAnimalCopy = instance); 
        shop = await MarketHeroShop.at(masterMarketHeroShopCopy.address);
        animal = await MarketHeroAnimal.at(masterMarketHeroAnimalCopy.address);
        await shop.initialize.sendTransaction(admin, tokenMHT.address);
        await animal.initialize.sendTransaction(admin, shop.address, marketHeroURI.address);
        await shop.setMarketHeroAnimalContract(animal.address);
    })

    it('Setting default parameters', async() => {
        
        traits = await animal.getDefaultParameters.call();
        
        index = 0;
        expect(traits[index++]).to.be.eq.BN(0);
        expect(traits[index++]).to.be.eq.BN(0);
        expect(traits[index++]).to.be.eq.BN(0);
        expect(traits[index++]).to.be.eq.BN(4);
        expect(traits[index++]).to.be.eq.BN(2000);
        
    })



    it('Minting', async()=>{
        await animal.createAnimals.sendTransaction(0,1,{from:admin});
        traits = await animal.getAnimalParameters.call(1);
        color_and_effects = await animal.getAnimalColorAndEffects.call(1);
        index = 0;
        expect(traits[index++]).to.be.eq.BN(0);
        expect(traits[index++]).to.be.eq.BN(0);
        expect(traits[index++]).to.be.eq.BN(0);
        expect(traits[index++]).to.be.eq.BN(4);
        expect(traits[index++]).to.be.eq.BN(2000);
        index = 0;
        expect(color_and_effects[index++]).to.be.eq.BN(0);
        expect(color_and_effects[index++]).to.be.eq.BN(0);
        expect(color_and_effects[index++]).to.be.eq.BN(0);
        expect(color_and_effects[index++]).to.be.eq.BN(0);
        expect(color_and_effects[index++]).to.be.eq.BN(0);
        expect(color_and_effects[index++]).to.be.eq.BN(0);
        expect(color_and_effects[index++]).to.be.eq.BN(0);
        expect(color_and_effects[index++]).to.be.eq.BN(0);
    })



    it('renew parameters(by admin)', async() => {
        await animal.renewAnimalParameters.sendTransaction(1,1,1,1,3,1500,{from:admin});
        traits = await animal.getAnimalParameters.call(1);
        index = 0;
        expect(traits[index++]).to.be.eq.BN(1);
        expect(traits[index++]).to.be.eq.BN(1);
        expect(traits[index++]).to.be.eq.BN(1);
        expect(traits[index++]).to.be.eq.BN(3);
        expect(traits[index++]).to.be.eq.BN(1500);
        
    })
    
    it('upgrading by user in shop', async() => {
        // allowance and transferring tokeMHT
        await animal.safeTransferFrom.sendTransaction(admin,user1,1);
        full_amountTokenMHT = toBN(1000).mul(decimals);
        await tokenMHT.approve(shop.address, full_amountTokenMHT, {from:admin});
        await tokenMHT.transfer.sendTransaction(user1, full_amountTokenMHT);
        await tokenMHT.approve(shop.address, full_amountTokenMHT, {from:user1});
        expect( await tokenMHT.balanceOf(user1)).to.be.eq.BN(full_amountTokenMHT);
        // Upgrades
        lvl2_bull_price = toBN(150).mul(decimals);
        // Speed
        await shop.upgradeSpecificTrait(1,0,{from:user1});
        traits = await animal.getAnimalParameters.call(1);
        index = 0;
        expect(traits[index++]).to.be.eq.BN(1);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(1);
        expect(traits[index++]).to.be.eq.BN(3);
        expect(traits[index++]).to.be.eq.BN(1500);
        expect ( await tokenMHT.balanceOf(user1)).to.be.eq.BN(full_amountTokenMHT.sub(lvl2_bull_price));
        // Immunity
        await shop.upgradeSpecificTrait(1,1,{from:user1});
        traits = await animal.getAnimalParameters.call(1);
        index = 0;
        expect(traits[index++]).to.be.eq.BN(1);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(3);
        expect(traits[index++]).to.be.eq.BN(1500);
        expect ( await tokenMHT.balanceOf(user1)).to.be.eq.BN(full_amountTokenMHT.sub(lvl2_bull_price).sub(lvl2_bull_price));
        // Armor
        await shop.upgradeSpecificTrait(1,2,{from:user1});
        traits = await animal.getAnimalParameters.call(1);
        index = 0;
        expect(traits[index++]).to.be.eq.BN(1);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(1500);
        expect ( await tokenMHT.balanceOf(user1)).to.be.eq.BN(full_amountTokenMHT.sub(lvl2_bull_price).sub(lvl2_bull_price).sub(lvl2_bull_price));
        // Response
        await shop.upgradeSpecificTrait(1,3,{from:user1});
        traits = await animal.getAnimalParameters.call(1);
        index = 0;
        expect(traits[index++]).to.be.eq.BN(1);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(1000);
        expect ( await tokenMHT.balanceOf(user1)).to.be.eq.BN(full_amountTokenMHT.sub(lvl2_bull_price).sub(lvl2_bull_price).sub(lvl2_bull_price).sub(lvl2_bull_price));
        
    })

    it('Purchasing new hero and upgrading its', async() => {

        user1_balance = full_amountTokenMHT.sub(lvl2_bull_price).sub(lvl2_bull_price).sub(lvl2_bull_price).sub(lvl2_bull_price)
        bear_price = toBN(150).mul(decimals);
        lvl1_bear_price = toBN(75).mul(decimals);
        await shop.buyAnimal(2,{from:user1});
        expect (await tokenMHT.balanceOf(user1)).to.be.eq.BN(user1_balance.sub(bear_price));
        await shop.upgradeSpecificTrait(2,3,{from:user1});
        traits = await animal.getAnimalParameters.call(2);
        index = 0;
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(0);
        expect(traits[index++]).to.be.eq.BN(0);
        expect(traits[index++]).to.be.eq.BN(4);
        expect(traits[index++]).to.be.eq.BN(1500);
        expect (await tokenMHT.balanceOf(user1)).to.be.eq.BN((user1_balance.sub(lvl1_bear_price)).sub(bear_price));
    })
        // it('limit of max amount works', async() => {
        //     await expectRevert(
        //         await animal.createAnimals.sendTransaction(3,1001,{from:admin}),
        //         "Can't mint that much of animals"
        //     );
        // })
})