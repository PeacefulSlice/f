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
const Hamster = artifacts.require('Hamster');
const Shop = artifacts.require('Shop');

function toBN(number){
    return web3.utils.toBN(number);
}

contract('Hamster', (accounts)=>{
    let admin = accounts[0];
    let user1 = accounts[1];
    const decimals = toBN(10).pow(toBN(18));

    let proxyInstance;
    let masterHamsterCopy;
    let masterShopCopy;
    let hamster;
    let shop;
    let tokenMHT;
    let index;
    let traits;
    let color_and_effects;
    let full_amountTokenMHT;
    let lvl1_bull_price;
    let lvl2_bull_price;
    let bear_price;
    
    



    before(async()=>{
        await TestToken.new(toBN(1000).mul(decimals),"TokenMHT","MHT").then(instance => tokenMHT = instance);
        await Shop.new().then(instance => masterShopCopy = instance);
        await Hamster.new().then(instance => masterHamsterCopy = instance); 
        shop = await Shop.at(masterShopCopy.address);
        hamster = await Hamster.at(masterHamsterCopy.address);
        await shop.initialize.sendTransaction(admin, tokenMHT.address);
        await hamster.initialize.sendTransaction(admin, shop.address);
        


    })

    it('Setting default parameters', async() => {
        await hamster.setDefaultAnimalParameters.sendTransaction({from:admin});
        traits = await hamster.getDefaultParameters.call();
        color_and_effects = await hamster.getDefaultColorAndEffects.call();
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



    it('Minting', async()=>{
        await hamster.createAnimals.sendTransaction(0,1,{from:admin});
        traits = await hamster.getAnimalParameters.call(1);
        color_and_effects = await hamster.getAnimalColorAndEffects.call(1);
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

    // it('limit of max amount works', async() => {
    //     await expectRevert(
    //         hamster.createAnimals.sendTransaction(3,1001,{from:admin}),
    //         "Can't mint that much of animals"
    //     );
    // })

    // it('renew parameters(by admin)', async() => {
    //     await hamster.renewAnimalParameters.sendTransaction(1,1,1,1,3,1500,{from:admin});
    //     traits = await hamster.getAnimalParameters.call(1);
    //     index = 0;
    //     expect(traits[index++]).to.be.eq.BN(1);
    //     expect(traits[index++]).to.be.eq.BN(1);
    //     expect(traits[index++]).to.be.eq.BN(1);
    //     expect(traits[index++]).to.be.eq.BN(3);
    //     expect(traits[index++]).to.be.eq.BN(1500);
        
    // })
    
    it('upgrading by user in shop', async() => {
        await shop.setDefaultUpgradePrices({from:admin});
        // allowwance and transferring tokeMHT
        await hamster.safeTransferFrom.sendTransaction(admin,user1,1);
        full_amountTokenMHT = toBN(1000).mul(decimals);
        await tokenMHT.approve(shop.address, full_amountTokenMHT, {from:admin});
        await tokenMHT.approve(shop.address, full_amountTokenMHT, {from:user1});
        await tokenMHT.transfer.sendTransaction(user1, full_amountTokenMHT);
        expect( await tokenMHT.balanceOf(user1).to.eq.BN(full_amountTokenMHT));
        // Upgrades
        lvl2_bull_price = toBN(150).mul(decimals);
        // Speed
        await shop.upgradeSpecificTrait(1,0,{from:user1});
        traits = await hamster.getAnimalParameters.call(1);
        index = 0;
        expect(traits[index++]).to.be.eq.BN(1);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(1);
        expect(traits[index++]).to.be.eq.BN(3);
        expect(traits[index++]).to.be.eq.BN(1500);
        expect ( await tokenMHT.balanceOf(user1).to.be.eq.BN(full_amountTokenMHT).sub(lvl2_bull_price));
        lvl2_bull_price += lvl2_bull_price;
        // Immunity
        await shop.upgradeSpecificTrait(1,1,{from:user1});
        traits = await hamster.getAnimalParameters.call(1);
        index = 0;
        expect(traits[index++]).to.be.eq.BN(1);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(3);
        expect(traits[index++]).to.be.eq.BN(1500);
        expect ( await tokenMHT.balanceOf(user1).to.be.eq.BN(full_amountTokenMHT).sub(lvl2_bull_price));
        lvl2_bull_price += lvl2_bull_price;
        // Armor
        await shop.upgradeSpecificTrait(1,2,{from:user1});
        traits = await hamster.getAnimalParameters.call(1);
        index = 0;
        expect(traits[index++]).to.be.eq.BN(1);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(1500);
        expect ( await tokenMHT.balanceOf(user1).to.be.eq.BN(full_amountTokenMHT).sub(lvl2_bull_price));
        lvl2_bull_price += lvl2_bull_price;
        // Response
        await shop.upgradeSpecificTrait(1,3,{from:user1});
        traits = await hamster.getAnimalParameters.call(1);
        index = 0;
        expect(traits[index++]).to.be.eq.BN(1);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(1000);
        expect ( await tokenMHT.balanceOf(user1).to.be.eq.BN(full_amountTokenMHT).sub(lvl2_bull_price));
    })

    it('Purchasing new hero and upgrading him', async() => {
        await shop.setDefaultAnimalPrices({from:admin});
        bear_price = toBN(150).mul(decimals);
        lvl1_bull_price = toBN(75).mul(decimals);
        await shop.buyAnimal(2,{from:user1});
        expect (await tokenMHT.balanceOf(user1).to.be.eq.BN(full_amountTokenMHT).sub(lvl2_bull_price).sub(bear_price));
        await shop.upgradeSpecificTrait(2,3,{from:user1});
        traits = await hamster.getAnimalParameters.call(2);
        index = 0;
        expect(traits[index++]).to.be.eq.BN(2);
        expect(traits[index++]).to.be.eq.BN(0);
        expect(traits[index++]).to.be.eq.BN(0);
        expect(traits[index++]).to.be.eq.BN(4);
        expect(traits[index++]).to.be.eq.BN(1500);
        expect (await tokenMHT.balanceOf(user1).to.be.eq.BN(full_amountTokenMHT).sub(lvl2_bull_price).sub(bear_price).sub(lvl1_bull_price));
    })
})