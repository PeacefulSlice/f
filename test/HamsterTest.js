const web3 =  require("web3")
const chai = require('chai');
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
    
    let proxyAdmin;
    let proxyInstance;
    let masterRoundCopy;
    let hamster;
    let tokenMHT;
    let first_hamster;
    



    before(async()=>{
        await TestToken.new(toBN(1000).mul(decimals),"TokenMHT","MHT").then(instance => tokenMHT = instance);
        // await PProxyAdmin.new().then(instance => proxyAdmin = instance);
        hamster = await Hamster.new().then(instance => masterRoundCopy = instance);
        // await PProxy.new(masterRoundCopy.address,proxyAdmin.address,web3.utils.hexToBytes('0x'))
        //     .then(instance => proxyInstance = instance);
        // hamster = await Hamster.at(proxyInstance.address);
        await hamster.initialize.sendTransaction(admin);
        


    })

    it('minting', async()=>{
        await hamster._mint(0,user1);
        console.log(" = = ", await hamster.tokenURI(1));


    })
})