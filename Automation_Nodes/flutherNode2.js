//import required dependencies

const { automationLayerABI } = require("./ABIs/automationLayerABI");
const {sequencerABI} = require("./ABIs/nodeSequencerABI")

const { Contract, ethers } = require("ethers");
require("dotenv").config();


const providers = [
  process.env.SEPOLIA_WSS
];
const randomProvider = Math.floor(Math.random() * providers.length);

const provider = new ethers.providers.WebSocketProvider(
  providers[randomProvider]
);

const automationLayerContractAddress =
  "0xa7A8d5FECc527dE4e1108F2CaDa27862aAeC5f03";
const sequencerAddress = "0x851A7C0A34262da85AEeEbe8dFdb24C4Fef49835";

console.log(provider.connection.url);

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
  /*
  estimateGas = await
              sequencerContract.estimateGas.registerNode()
  
  const tx = {
    maxFeePerGas: (await provider.getGasPrice()) * 2,
    maxPriorityFeePerGas: 50000000000,
    gasLimit: estimateGas *2,
    nonce: await provider.getTransactionCount(wallet.address, "pending"),
  };

  const registerNode = await sequencerContract.registerNode(tx)
  const receipt = await registerNode.wait();
  console.log(
    ` Transaction https://polygonscan.com/tx/${receipt.transactionHash} mined, status success`
  );
  await timer(60000);
*/
  const totalAccountsindex = await automationLayerContract.getNextAccountNumber();
  console.log("totalAccountsindex", totalAccountsindex.toString());

//const getCurrentNode = await sequencerContract.getCurrentNode();
  

 // console.log(getCurrentNode);
  //console.log(wallet.address);
  
 // if (getCurrentNode == wallet.address) {
    let account = -1;
    while (account < totalAccountsindex - 1) {
      account = account + 1;

      console.log("account", account);
      let checkSimpleAutomation;
      try {
        checkSimpleAutomation = await automationLayerContract.checkSimpleAutomation(account);
      } catch (error) {
        console.log("cannot checkSimpleAutomation", account);
        checkSimpleAutomation = false;
      }
      console.log("checkSimpleAutomation", checkSimpleAutomation);
      if (checkSimpleAutomation == true) {
   
          let estimateGas;
          try {
            estimateGas = await
              automationLayerContract.estimateGas.simpleAutomation(account)
            ;
          } catch (error) {
            estimateGas == 0;
            console.log("simpleAutomation Fails", account);
          }
  if (estimateGas > 0){
          

          const tx = {
            maxFeePerGas: (await provider.getGasPrice()) * 2,
            maxPriorityFeePerGas: 50000000000,
            gasLimit: estimateGas *2,
            nonce: await provider.getTransactionCount(wallet.address, "pending"),
          };

          //Liquidate eligible vault
          const simpleAutomation = await automationLayerContract.simpleAutomation(account, tx);
          console.log("simpleAutomation", simpleAutomation);
          const receipt = await simpleAutomation.wait();

          if (receipt && receipt.blockNumber && receipt.status === 1) {
            // 0 - failed, 1 - success
            console.log(
              ` Transaction https://polygonscan.com/tx/${receipt.transactionHash} mined, status success`
            );
          } else if (receipt && receipt.blockNumber && receipt.status === 0) {
            console.log(
              ` Transaction https://polygonscan.com/tx/${receipt.transactionHash} mined, status failed`
            );
          } else {
            console.log(
              ` Transaction https://polygonscan.com/tx/${receipt.transactionHash} not mined`
            );
          }
        }
      }
    }
  /*
  } else {
    console.log("Not Current Node");
  }
  */
  await timer(60000);
  init();
};
init();
