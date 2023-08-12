//import required dependencies

const { automationLayerABI } = require("./ABIs/automationLayerABI");
<<<<<<< HEAD
const { sequencerABI } = require("./ABIs/nodeSequencerABI")
const { dollarCostAverageABI } = require("./ABIs/flutherNode4ABI.js")
=======
const {sequencerABI} = require("./ABIs/nodeSequencerABI")
const {dollarCostAverageABI} = require("./ABIs/flutherNode4ABI.js")
>>>>>>> 056901f7367c7206390fe5850b20458cb8adb7f8
const { Contract, ethers } = require("ethers");
require("dotenv").config();



const providers = [
  process.env.SEPOLIA_WSS
];
const randomProvider = Math.floor(Math.random() * providers.length);

const provider = new ethers.providers.WebSocketProvider(
  providers[randomProvider]
);
dollarCostAverageContractAddress = "0xf0EF015fDeFB728840a7407521b1a9806aff0ef2" //0x324B97C7881517BD64D05888431c72877a70df26"
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
<<<<<<< HEAD
  var dollarCostAverageContract = new ethers.Contract(dollarCostAverageContractAddress, dollarCostAverageABI, signer)
=======
var dollarCostAverageContract = new ethers.Contract(dollarCostAverageContractAddress, dollarCostAverageABI, signer)
>>>>>>> 056901f7367c7206390fe5850b20458cb8adb7f8
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

  const getNextRecurringBuyId = await dollarCostAverageContract.getNextRecurringBuyId()
  console.log(getNextRecurringBuyId.toString())


<<<<<<< HEAD
  let account = -1;
  while (account < getNextRecurringBuyId - 1) {
    account = account + 1;

    console.log("account", account);
    let checkSimpleAutomation;
    try {
      checkSimpleAutomation = await dollarCostAverageContract.checkTrigger(account);
    } catch (error) {
      console.log("cannot checkSimpleAutomation", account);
      checkSimpleAutomation = false;
    }
    console.log("checkSimpleAutomation", checkSimpleAutomation);
    if (checkSimpleAutomation == true) {

      let estimateGas;
      try {
        estimateGas = await
          dollarCostAverageContract.estimateGas.trigger(account)
          ;
      } catch (error) {
        estimateGas == 0;
        console.log("simpleAutomation Fails", account);
      }

      const maxFeePerGas = (await provider.getGasPrice()) * 2
      if (estimateGas > 0) {


        const tx = {
          maxFeePerGas: maxFeePerGas,
          maxPriorityFeePerGas: maxFeePerGas,
          gasLimit: estimateGas * 2,
          nonce: await provider.getTransactionCount(wallet.address, "pending"),
        };


        const simpleAutomation = await dollarCostAverageContract.trigger(account, tx);
        console.log("simpleAutomation", account);
        const receipt = await simpleAutomation.wait();

        if (receipt && receipt.blockNumber && receipt.status === 1) {
          // 0 - failed, 1 - success
          console.log(
            ` Transaction https://sepolia.etherscan.io/tx/${receipt.transactionHash} mined, status success`
          );
        } else if (receipt && receipt.blockNumber && receipt.status === 0) {
          console.log(
            ` Transaction https://sepolia.etherscan.io/tx/${receipt.transactionHash} mined, status failed`
          );
        } else {
          console.log(
            ` Transaction https://sepolia.etherscan.io/tx/${receipt.transactionHash} not mined`
          );
        }
      }
    }
  }
=======
    let account = -1;
    while (account < getNextRecurringBuyId - 1) {
      account = account + 1;

      console.log("account", account);
      let checkSimpleAutomation;
      try {
        checkSimpleAutomation = await dollarCostAverageContract.checkTrigger(account);
      } catch (error) {
        console.log("cannot checkSimpleAutomation", account);
        checkSimpleAutomation = false;
      }
      console.log("checkSimpleAutomation", checkSimpleAutomation);
      if (checkSimpleAutomation == true) {
   
          let estimateGas;
          try {
            estimateGas = await
            dollarCostAverageContract.estimateGas.trigger(account)
            ;
          } catch (error) {
            estimateGas == 0;
            console.log("simpleAutomation Fails", account);
          }

         const maxFeePerGas = (await provider.getGasPrice()) * 2
  if (estimateGas > 0){
          

          const tx = {
            maxFeePerGas: maxFeePerGas,
            maxPriorityFeePerGas: maxFeePerGas,
            gasLimit: estimateGas *2,
            nonce: await provider.getTransactionCount(wallet.address, "pending"),
          };

 
          const simpleAutomation = await dollarCostAverageContract.trigger(account, tx);
          console.log("simpleAutomation", account);
          const receipt = await simpleAutomation.wait();

          if (receipt && receipt.blockNumber && receipt.status === 1) {
            // 0 - failed, 1 - success
            console.log(
              ` Transaction https://sepolia.etherscan.io/tx/${receipt.transactionHash} mined, status success`
            );
          } else if (receipt && receipt.blockNumber && receipt.status === 0) {
            console.log(
              ` Transaction https://sepolia.etherscan.io/tx/${receipt.transactionHash} mined, status failed`
            );
          } else {
            console.log(
              ` Transaction https://sepolia.etherscan.io/tx/${receipt.transactionHash} not mined`
            );
          }
        }
      }
    }
>>>>>>> 056901f7367c7206390fe5850b20458cb8adb7f8

  await timer(60000);
  init();
};
init();
