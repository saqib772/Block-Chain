require('dotenv').config();

const Web3 = require('web3');
const apikey = process.env['apikey'];
const network = 'goerli';

const nodeUrl = `https://eth.getblock.io/${network}/${apikey}`;
const web3 = new Web3(nodeUrl);

//generate a new account
const account = web3.eth.accounts.create();
// console.log(account.address);

//now fetch the privatekey to accountfrom variable
const privatekey = process.env['privatekey'];
const accountfrom = web3.eth.accounts.privateKeyToAccount(privatekey);
// console.log(accountfrom);

//function to sign the transaction
const createSignedTransaction = async (rawtx) => {   
    rawtx.gas = await web3.eth.estimateGas(rawtx);
    return await web3.eth.accounts.signTransaction(rawtx, privatekey);
};

const sendTransaction = async (signedtx) => {
    return await web3.eth.sendSignedTransaction(signedtx.rawTransaction);
};

const amount = "0.01";
const rawtx = {
    to: account.address,
    value: web3.utils.toWei(amount, "ether")
};

createSignedTransaction(rawtx)
.then(signedtx => sendTransaction(signedtx))
.then(receipt => {
    console.log("Transaction receipt: ", receipt);
})
.catch(error => {
    console.error("Error: ", error);
});
