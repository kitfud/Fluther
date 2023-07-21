//import required dependencies
const {dollarCostAverageABI, automationLayerABI, nodeSequencerABI} = require('.')
console.log(dollarCostAverageABI)



const { Contract, ethers } = require("ethers");
require("dotenv").config();
console.log(ethers.version)

const providers = [
  process.env.POLYGON_WSS,
  process.env.POLYGON_WSS2,
  process.env.POLYGON_WSS3,
  process.env.POLYGON_WSS4,
];
const randomProvider = Math.floor(Math.random() * providers.length);
console.log(randomProvider)
/*
const provider = new ethers.providers.WebSocketProvider(
  providers[randomProvider]
);
*/
const provider = new ethers.providers.JsonRpcProvider()

//const provider = "wss://polygon-mainnet.s.chainbase.online/v1/2JCGtG0pwQA9HgcPdPy3G6rh7xB"

const automationLayerContractAddress =
  "0xe8a12A7b1d803E2285d65Db1c3443CCC42ead896";
const sequencerAddress = "0x1712bFADd06B94Bc8dFb30F4d81AcF0919f7Db0B";


const wallet = new ethers.Wallet(process.env.TEST_ACCOUNT);
const signer = wallet.connect(provider);

//var contract = new ethers.Contract(contractAddress, abi, signer);

const timer = (ms) => new Promise((res) => setTimeout(res, ms));

const init = async () => {
  //search each vault to detemine if it is near liquidation and contains a minimum balance to make it worthwhile

  var automationLayerContract = new ethers.Contract(
    automationLayerContractAddress,
    automationLayerABI,
    signer
  );

  const sequencerContract = new ethers.Contract(
    sequencerAddress,
    sequencerABI,
    signer
  );

  const totalAccountsindex = await automationLayerContract.totalAccounts();
  console.log("totalAccountsindex", totalAccountsindex.toString());

  const getCurrentNode = await sequencerContract.getCurrentNode();
  console.log(getCurrentNode);
  console.log(wallet.address);

  if (getCurrentNode == wallet.address) {
    let account = -1;
    while (account < totalAccountsindex - 1) {
      account = account + 1;

      console.log("account", account);
      let checkTrigger;
      try {
        checkTrigger = await automationLayerContract.checkTrigger(account);
      } catch (error) {
        console.log("cannot checkTrigger", account);
        checkTrigger = false;
      }
      console.log("checkTrigger", checkTrigger);
      if (checkTrigger == true) {
        let isCanceled = await automationLayerContract.isAccountCanceled(
          account
        );

        if (isCanceled == false) {
          let estimateGas;
          try {
            estimateGas = await
              automationLayerContract.estimateGas.trigger(account)
            ;
          } catch (error) {
            estimateGas == 0;
            console.log("Trigger Fails", account);
          }
  if (estimateGas > 0){
          

          const tx = {
            maxFeePerGas: (await provider.getGasPrice()) * 2,
            maxPriorityFeePerGas: 50000000000,
            gasLimit: estimateGas *2,
            nonce: await provider.getTransactionCount(wallet.address, "pending"),
          };

          //Liquidate eligible vault
          const trigger = await automationLayerContract.trigger(account, tx);
          console.log("trigger", trigger);
          const receipt = await trigger.wait();

          if (receipt && receipt.blockNumber && receipt.status === 1) {
            // 0 - failed, 1 - success
            console.log(
              `Sell Transaction https://polygonscan.com/tx/${receipt.transactionHash} mined, status success`
            );
          } else if (receipt && receipt.blockNumber && receipt.status === 0) {
            console.log(
              `Sell Transaction https://polygonscan.com/tx/${receipt.transactionHash} mined, status failed`
            );
          } else {
            console.log(
              `Sell Transaction https://polygonscan.com/tx/${receipt.transactionHash} not mined`
            );
          }
        }
      }
    }
  }
  } else {
    console.log("Not Current Node");
  }
  await timer(60000);
  init();
};
init();
