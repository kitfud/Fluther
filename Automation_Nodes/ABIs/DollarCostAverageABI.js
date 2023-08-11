module.exports = {dollarCostAverageABI : [
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
		"name": "DollarCostAverage__AmountIsZero",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAverage__CallerNotRecurringBuySender",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAverage__InvalidAutomationLayerAddress",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAverage__InvalidDefaultRouterAddress",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAverage__InvalidIndexRange",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAverage__InvalidRecurringBuy",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAverage__InvalidRecurringBuyId",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAverage__InvalidTimeInterval",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAverage__InvalidTokenAddresses",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAverage__NotAcceptingNewRecurringBuys",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "DollarCostAverage__TokenNotEnoughAllowance",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "Security__NotAllowed",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "Security__TokenApprovalFailed",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "Security__TokenTransferFailed",
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
				"name": "acceptingRecurringBuys",
				"type": "bool"
			}
		],
		"name": "AcceptingRecurringBuysSet",
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
				"name": "allowed",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "caller",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "bool",
				"name": "isAllowed",
				"type": "bool"
			}
		],
		"name": "CallerPermissionSet",
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
			},
			{
				"indexed": false,
				"internalType": "uint256[]",
				"name": "amounts",
				"type": "uint256[]"
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
						"internalType": "enum IDollarCostAverage.Status",
						"name": "status",
						"type": "uint8"
					}
				],
				"indexed": false,
				"internalType": "struct IDollarCostAverage.RecurringBuy",
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
				"internalType": "bool",
				"name": "acceptingNewRecurringBuys",
				"type": "bool"
			}
		],
		"name": "setAcceptingNewRecurringBuys",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "caller",
				"type": "address"
			},
			{
				"internalType": "bool",
				"name": "isAllowed",
				"type": "bool"
			}
		],
		"name": "setAllowed",
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
		"inputs": [
			{
				"internalType": "address",
				"name": "caller",
				"type": "address"
			}
		],
		"name": "getAllowed",
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
		"name": "getDefaultRouter",
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
						"internalType": "enum IDollarCostAverage.Status",
						"name": "status",
						"type": "uint8"
					}
				],
				"internalType": "struct IDollarCostAverage.RecurringBuy[]",
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
						"internalType": "enum IDollarCostAverage.Status",
						"name": "status",
						"type": "uint8"
					}
				],
				"internalType": "struct IDollarCostAverage.RecurringBuy",
				"name": "",
				"type": "tuple"
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
		"name": "getValidRangeOfRecurringBuys",
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
						"internalType": "enum IDollarCostAverage.Status",
						"name": "status",
						"type": "uint8"
					}
				],
				"internalType": "struct IDollarCostAverage.RecurringBuy[]",
				"name": "",
				"type": "tuple[]"
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
		"inputs": [
			{
				"internalType": "uint256",
				"name": "recurringBuyId",
				"type": "uint256"
			}
		],
		"name": "isRecurringBuyValid",
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
}