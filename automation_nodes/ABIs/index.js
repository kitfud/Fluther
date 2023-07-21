module.export = { 
    automationLayerABI : [
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
		"inputs": [],
		"name": "pause",
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
		"name": "Paused",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "renounceOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
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
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "withdraw",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
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
],
dollarCOstAverageABI : [
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "recurringBuyId",
				"type": "uint256"
			}
		],
		"name": "cancelRecurringPayment",
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
			},
			{
				"internalType": "address",
				"name": "token1",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "token2",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "timeIntervalSeconds",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "paymentInterface",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "dexRouter",
				"type": "address"
			}
		],
		"name": "createRecurringBuy",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "defaultRouter",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "automationLayerAddress",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_wrapNative",
				"type": "address"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [],
		"name": "DollarCostAveraging__AmountIsZero",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAveraging__CallerNotRecurringBuySender",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAveraging__InvalidIndexRange",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAveraging__InvalidRecurringBuy",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAveraging__InvalidRecurringBuyId",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAveraging__InvalidTimeInterval",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAveraging__InvalidTokenAddresses",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAveraging__NotAcceptingNewRecurringBuys",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAveraging__TokenTransferFailed",
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
				"indexed": true,
				"internalType": "address",
				"name": "automationLayerAddress",
				"type": "address"
			}
		],
		"name": "AutomationLayerSet",
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
				"name": "defaultRouter",
				"type": "address"
			}
		],
		"name": "DefaultRouterSet",
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
		"inputs": [],
		"name": "pause",
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
		"name": "Paused",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "recBuyId",
				"type": "uint256"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "sender",
				"type": "address"
			}
		],
		"name": "PaymentTransferred",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "recBuyId",
				"type": "uint256"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "sender",
				"type": "address"
			}
		],
		"name": "RecurringBuyCancelled",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "recBuyId",
				"type": "uint256"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"components": [
					{
						"internalType": "address",
						"name": "sender",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "amountToSpend",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "tokenToSpend",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "tokenToBuy",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "timeIntervalInSeconds",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "paymentInterface",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "dexRouter",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "paymentDue",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "accountNumber",
						"type": "uint256"
					},
					{
						"internalType": "enum IDollarCostAveraging.Status",
						"name": "status",
						"type": "uint8"
					}
				],
				"indexed": false,
				"internalType": "struct IDollarCostAveraging.RecurringBuy",
				"name": "buy",
				"type": "tuple"
			}
		],
		"name": "RecurringBuyCreated",
		"type": "event"
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
				"internalType": "address",
				"name": "automationLayerAddress",
				"type": "address"
			}
		],
		"name": "setAutomationLayer",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "defaultRouter",
				"type": "address"
			}
		],
		"name": "setDefaultRouter",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "recurringBuyId",
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
				"internalType": "uint256",
				"name": "recurringBuyId",
				"type": "uint256"
			}
		],
		"name": "transferFunds",
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
				"name": "recurringBuyId",
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
		"inputs": [],
		"name": "getAcceptingNewRecurringBuys",
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
		"name": "getAutomationLayer",
		"outputs": [
			{
				"internalType": "contract IAutomationLayer",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getCurrentBlockTimestamp",
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
		"name": "getNextRecurringBuyId",
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
		"inputs": [
			{
				"internalType": "uint256",
				"name": "startRecBuyId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "endRecBuyId",
				"type": "uint256"
			}
		],
		"name": "getRangeOfRecurringBuys",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "sender",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "amountToSpend",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "tokenToSpend",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "tokenToBuy",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "timeIntervalInSeconds",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "paymentInterface",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "dexRouter",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "paymentDue",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "accountNumber",
						"type": "uint256"
					},
					{
						"internalType": "enum IDollarCostAveraging.Status",
						"name": "status",
						"type": "uint8"
					}
				],
				"internalType": "struct IDollarCostAveraging.RecurringBuy[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "recurringBuyId",
				"type": "uint256"
			}
		],
		"name": "getRecurringBuy",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "sender",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "amountToSpend",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "tokenToSpend",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "tokenToBuy",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "timeIntervalInSeconds",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "paymentInterface",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "dexRouter",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "paymentDue",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "accountNumber",
						"type": "uint256"
					},
					{
						"internalType": "enum IDollarCostAveraging.Status",
						"name": "status",
						"type": "uint8"
					}
				],
				"internalType": "struct IDollarCostAveraging.RecurringBuy",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getWrapNative",
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
],
nodeSequencerABI: [
    {
      inputs: [],
      stateMutability: "nonpayable",
      type: "constructor",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "address",
          name: "previousOwner",
          type: "address",
        },
        {
          indexed: true,
          internalType: "address",
          name: "newOwner",
          type: "address",
        },
      ],
      name: "OwnershipTransferred",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "address",
          name: "account",
          type: "address",
        },
      ],
      name: "Paused",
      type: "event",
    },
    {
      inputs: [],
      name: "registerNode",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "uint256",
          name: "index",
          type: "uint256",
        },
      ],
      name: "removeNode",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [],
      name: "renounceOwnership",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "uint256",
          name: "_blockNumberRange",
          type: "uint256",
        },
      ],
      name: "setBlockNumberRange",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "tokenAddress",
          type: "address",
        },
      ],
      name: "setDuhAddress",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "newOwner",
          type: "address",
        },
      ],
      name: "transferOwnership",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "address",
          name: "account",
          type: "address",
        },
      ],
      name: "Unpaused",
      type: "event",
    },
    {
      inputs: [
        {
          internalType: "uint256",
          name: "_minimumDuh",
          type: "uint256",
        },
      ],
      name: "updateMinimumDuh",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [],
      name: "getBlockNumber",
      outputs: [
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "getCurrentNode",
      outputs: [
        {
          internalType: "address",
          name: "",
          type: "address",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "getCurrentNodeIndex",
      outputs: [
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "getMinimumDuh",
      outputs: [
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "getTotalNodes",
      outputs: [
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "hasSufficientTokens",
      outputs: [
        {
          internalType: "bool",
          name: "",
          type: "bool",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "owner",
      outputs: [
        {
          internalType: "address",
          name: "",
          type: "address",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "paused",
      outputs: [
        {
          internalType: "bool",
          name: "",
          type: "bool",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
  ],
};
