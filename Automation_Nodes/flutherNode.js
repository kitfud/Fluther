//import required dependencies

//const { automationLayerABI, sequencerABI } = require("./flutherNode");
const sequencerABI = [
    {
        "inputs": [],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "previousOwner",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "newOwner",
                "type": "address"
            }
        ],
        "name": "OwnershipTransferred",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "address",
                "name": "account",
                "type": "address"
            }
        ],
        "name": "Paused",
        "type": "event"
    },
    {
        "inputs": [],
        "name": "registerNode",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "index",
                "type": "uint256"
            }
        ],
        "name": "removeNode",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "renounceOwnership",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_blockNumberRange",
                "type": "uint256"
            }
        ],
        "name": "setBlockNumberRange",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "tokenAddress",
                "type": "address"
            }
        ],
        "name": "setDuhAddress",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "newOwner",
                "type": "address"
            }
        ],
        "name": "transferOwnership",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "address",
                "name": "account",
                "type": "address"
            }
        ],
        "name": "Unpaused",
        "type": "event"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_minimumDuh",
                "type": "uint256"
            }
        ],
        "name": "updateMinimumDuh",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getBlockNumber",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getCurrentNode",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getCurrentNodeIndex",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getMinimumDuh",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getTotalNodes",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "hasSufficientTokens",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "owner",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "paused",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    }
]
const automationLayerABI = [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "duh",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "minimumDuh",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "sequencerAddress",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "automationFee",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "oracleAddress",
				"type": "address"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [],
		"name": "AutomationLayer__CallerNotOracle",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "AutomationLayer__InvalidAccountNumber",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "AutomationLayer__NotAccpetingNewAccounts",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "AutomationLayer__NotAllowed",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "AutomationLayer__NotEnoughtTokens",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "AutomationLayer__OriginNotNode",
		"type": "error"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "caller",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "bool",
				"name": "acceptingNewAccounts",
				"type": "bool"
			}
		],
		"name": "AcceptingAccountsSet",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "accountNumber",
				"type": "uint256"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "automatedContract",
				"type": "address"
			}
		],
		"name": "AccountCancelled",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "automatedContract",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "AccountCreated",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "caller",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "automationFee",
				"type": "uint256"
			}
		],
		"name": "AutomationFeeSet",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "caller",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "node",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "bool",
				"name": "isNodeRegistered",
				"type": "bool"
			}
		],
		"name": "NodeSet",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "caller",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "oracle",
				"type": "address"
			}
		],
		"name": "OracleAddressSet",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "previousOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnershipTransferred",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "Paused",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "caller",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "sequencer",
				"type": "address"
			}
		],
		"name": "SequencerAddressSet",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "accountNumber",
				"type": "uint256"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "automatedContract",
				"type": "address"
			}
		],
		"name": "TransactionSuccess",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "Unpaused",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "Withdrawn",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "accountNumber",
				"type": "uint256"
			}
		],
		"name": "cancelAccount",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "accountNumber",
				"type": "uint256"
			}
		],
		"name": "checkSimpleAutomation",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "contractAddress",
				"type": "address"
			}
		],
		"name": "createAccount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAcceptingNewAccounts",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "accountNumber",
				"type": "uint256"
			}
		],
		"name": "getAccount",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "user",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "automatedContract",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "enum IAutomationLayer.Status",
						"name": "status",
						"type": "uint8"
					}
				],
				"internalType": "struct IAutomationLayer.Account",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAutomationFee",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getDuh",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "node",
				"type": "address"
			}
		],
		"name": "getIsNodeRegistered",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getMinimumDug",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getNextAccountNumber",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getOracleAddress",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getSequencerAddress",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "pause",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "paused",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "renounceOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bool",
				"name": "acceptingNewAccounts",
				"type": "bool"
			}
		],
		"name": "setAcceptingNewAccounts",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "automationFee",
				"type": "uint256"
			}
		],
		"name": "setAutomationFee",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "node",
				"type": "address"
			},
			{
				"internalType": "bool",
				"name": "isNodeRegistered",
				"type": "bool"
			}
		],
		"name": "setNode",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "oracleAddress",
				"type": "address"
			}
		],
		"name": "setOracleAddress",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sequencerAddress",
				"type": "address"
			}
		],
		"name": "setSequencerAddress",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "accountNumber",
				"type": "uint256"
			}
		],
		"name": "simpleAutomation",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "transferOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "unpause",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "withdraw",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]


//console.log(automationLayerABI, sequencerABI)
const { Contract, ethers } = require("ethers");
require("dotenv").config();


const providers = [
  process.env.POLYGON_WSS,
  process.env.POLYGON_WSS2,
  process.env.POLYGON_WSS3,
  process.env.POLYGON_WSS4,
];
const randomProvider = Math.floor(Math.random() * providers.length);

const provider = new ethers.providers.WebSocketProvider(
  providers[randomProvider]
);

const automationLayerContractAddress =
  "0x1f33ba65023CbFA03Cbac4e803a4E9b6C7480890";
const sequencerAddress = "0x173f7b303cabb652dbcd9cc847a4fec41ffb67b0";

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
 const getOwner = await sequencerContract.owner()

  const getCurrentNode = await sequencerContract.getCurrentNode();
  

  console.log(getCurrentNode);
  console.log(wallet.address);
  
  if (getCurrentNode == wallet.address) {
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
  
  } else {
    console.log("Not Current Node");
  }
  await timer(60000);
  init();
};
init();
