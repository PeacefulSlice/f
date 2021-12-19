const web3 =  require("web3")
const chai = require('chai');
const { current, inTransaction } = require('@openzeppelin/test-helpers/src/expectEvent');
const BN = web3.utils.BN;
const expect = chai.expect;
chai.use(require('chai-match'));
chai.use(require('bn-chai')(BN));

const TestToken = require.artifacts('TestToken');
const PProxy = require.artifacts('PProxy');
const PProxyAdmin = require.artifacts('PProxyAdmin');
const Hamster = require.artifacts('Hamster');
const Shop = require.artifacts('Shop');

function toBN(number){
    return web3.utils.toBN(number);
}

contract('Hamster', (accounts)=>{
    let admin = accounts[0];
    let user1 = accounts[1];

    let proxyAdmin;
    let proxyInstance;
    let masterRoundCopy;
    let hamster;



    before(async()=>{
        await PProxyAdmin.new().then(instance => proxyAdmin = instance);
        await Hamster.new().then(instance => masterRoundCopy = instance);
        await PProxy.new(masterRoundCopy.address,proxyAdmin.address,web3.utils.hexToBytes('0x'))
            .then(instance => proxyInstance = instance);
        hamster = await Hamster.at(proxyInstance.address);


    })

    it('', async()=>{

    })
})