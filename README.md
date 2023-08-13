# Fluther: _A Decentralized Dollar Cost Averaging Solution_

## Summary
Fluther is a decentralized dApp for creating recurring token buys over time (AKA dollar-cost averaging). A user can interface with an intuitive UI to log recurring investments, approve amounts for automated spending, view the investment over time, and cancel recurring investments whenever desired, while only paying only a single transaction fee. 

## dApp Problem Statement
While dollar cost averaging is a functionality that exists on multiple centralized trading exchanges- there is a need for a decentralized method that makes use of native Web3 DEXs. Automating recurring buys has been complicated due to the push rather than pull nature of blockchain transactions. This means that a user that would want to make a recurring buy would manually have to sign transactions with their wallet for each buy. 

Fluther overcomes this automation problem by running automation nodes that submit the transactions on behave of users, but only when the predefined parameters have been met. This creates for the user a seamless, gasless dollar-cost average investing experience, while always maintaining 100% control of their funds.

## Dollar Coast Averaging Definition
Dollar-cost averaging is the practice of spending a fixed quantity of one token for the swap of another over time. The idea with this practice is that over the long term, an investor removes the subjective interpretation of when to buy by abiding by a simple rule set. Specifically, invest a certain amount across intervals within a fixed time period. 

The practice of dollar cost averaging is helpful for reducing the effects of market volatility on investments and gives investors peace of mind through a strict rule set therefore, reducing subjectivity. 

## Fluther?
A fluther is a group of jellyfish. Jellyfish have no centralized brain; instead, they have a distributed nervous system. Their bodies are engineered for simplicity, reliability, and function. 

Groups of jellyfish, moreover, are decentralized in their leadership. Jellyfish float together- flow together- through the ocean and make their way as a unified whole. Jellyfish live life untethered from centralization in all they do. 

The dApp Fluther, aims to present a similiarly decentralized means for 'flowing' through the realm of Web3 financial investment. Like a jellyfish that floats effortlessly through the ocean; a user can set a recurring investment and let the automation layer trigger the investment 'buys' by employing a simple rule set. 

Sit back and let the tokens swaps amass via Fluther. 

## Flutter dApp UX Features
-Web3 Connect Button via ThirdWeb

-Spending Approval View

-Token Amount Display

-Token Investment Visualization

-Display User Agreements Dashboard

-Dollar Cost Average Maker

-Mock WETH Token Distribution (Floating Action Button)

-Music Embellishment (Floating Action Button)

## Running the dApp locally
To run the dApp locally,an Infura API key is needed. Follow [these instructions](https://www.infura.io/) to create your own API key with Infura. After downloading this repository, create a `.env` file in the `front_end` folder. Copy and paste your created API token in the file with the variable names as follows, replacing in <INFURA_API_KEY> and <PRIVATE_KEY> with your own details:

`REACT_APP_ETHEREUM_NETWORK = "sepolia"`  
`REACT_APP_INFURA_API_KEY = "<INFURA_API_KEY>"`  
`REACT_APP_SIGNER_PRIVATE_KEY = "<PRIVATE-KEY> "`  

Details on how to access a MetaMask private key can be found [here](https://support.metamask.io/hc/en-us/articles/360015289632-How-to-export-an-account-s-private-key)

<strong>Once the .env file is created:</strong>

CD into the `front_end` folder, and run:
```
npm install
npm start
```

## Live Deployment
TBD->Click Link to Be Deployed [HERE]

## Smart Contract Patterns

    -DollarCostAverage.sol Describe

## Fluther Protocol Fee Breakdown
- The Fluther protocol charges a 0.5% fee for each recurring buy. This fee is split 50/50 with the protocol and the front end (currently operated by the Fluther team) that a user uses to set up the recurring buy. These fees are subject to change to optimize for both protocol sustainability and user growth.

## Run your own Fluther frontend
- Frontend developers are incentivized to build their own UX on top of the Fluther protocol. Each time a new recurring buy is created through the Fluther protocol one of the parameters is the wallet address of the interface. This address is stored as a state variable associated with the recurring buy and will receive a share of all fees with each swap.
  
## Automation via FlutherNode

- A user who has set up a Fluther recurring buy only needs to submit a single transaction. The initial transaction outlines the parameters for each recurring buy including the tokens to be swapped, the amount to swap, and how much time must pass between swaps. All subsequent transactions are automated with flutherNode.js located in the Automation_Nodes folder.  The following steps outline how to run a fluther node:
  1. cd into the Automation_Nodes folder, and from your command line install ethers 5.6.1 (some newer versions do not work properly)
    ```
    npm install ethers@5.6.1 --save

    ```
  2. Update global .env file with Infura websocket for appropriate chain (SEPOLIA_WSS), and signer private key (TEST_ACCOUNT)
  3. Optionally install pm2 globally. 
    ```
    npm install pm2 -g

    ```
  4. exit out of the automation nodes folder and start the node with pm2. 
    ```
    pm2 start Automation_Nodes/flutherNode.js

    ```
   
troubleshooting flutherNode.js
Make sure the dollarCostAverageContractAddress is the correct contract address for the chain you are automating.
        
## Automation Layer & Further Development

It is the goal of the Fluther team to eventually fully decentralize the Fluther protocol.  To do this we have incorporated the following plans for future development:
1. Decentralize the front end. We have incentivized anybody to be able to build a front end on top of the Fluther protocol, this not only expands the reach of the FLuther protocol beyond what would be possible with a centralized frontend but will also create a fully censorship-resistant UX.
2. Decentralize the protocol. As the protocol grows Fluther will likely release a token to govern the protocol.
3. Decentralize the Automation. Currently, Fluther automation Nodes are run by the Fluther team. In the future, we intend to integrate automation with the decentralized Blockhead Finance Automation Layer, which incentivizes node operators to automate transactions on behalf of the protocol.

## Web3 Integrations
-<strong>Infura</strong>:

Infura is an integral part of the Fluther protocol. Not only do we rely on Infura as an RPC provider to operate the Fluther user interface (to recieve the most up date information on token amounts, dollar cost average contract deployments + cancellations as well as getting confirmation transactions on chain for the distribution of test token), but also, the Fluther Automation Node must integrate with the Infura websockets to check the status of each account every minute or so.


-<strong>MetaMask SDK</strong>:
Fluther dApp incorporates the MetaMask SDK via the dApp logo being detected on connection with the wallet. Furthermore, integration comes from how MetaMask injects itself into the browser via window.ethereum; as described in the SDK, Fluther's test token distribution (Floating Action Button) can auto-add test tokens to a user's MetaMask without the manual insertion of token info which can be prone to error. 

-<strong>Ethers.js</strong>:
Ethers.js is used as a utility library for converting amounts between on-chain values and those consumed on the front end. Furthermore, to keep the 'signer' object dynamic (per app usage)- a provider object from Ethers.js Web3 is created to write state changes to the blockchain. 

-<strong>ThirdWeb</strong>:
As a nod to Web3 builders, Fluther as appropriated the Web3 connect button to allow users to connect with multiple wallets aside from MetaMask. The user's blockchain address is parsed from this element and used throughout the dApp. 

-<strong>Hardhat</strong>:

-<strong>Foundry</strong>:

-<strong>Remix</strong>:

-<strong>Chainlink Price Feed</strong>: To ensure that dollar cost average agreement investment amounts meet a cetain threshold (at least $20 USD per investment); a Chainlink price feed is used to pull dynamic pricing for the swap value, USD/ETH. This value is then employed on the front end for form validation. 

## Team
- [@kitfud](https://github.com/kitfud)
- [@EWCunha](https://github.com/EWCunha)
- [@GZRdev](https://github.com/GZRdev)
- [@DopaMIM](https://github.com/DopaMIM)

