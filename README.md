# Fluther: _A Decentralized Dollar Cost Averaging Solution_

## Summary
Fluther is a decentralized dApp for creating dollar cost average investments. A user can interface with an intuitive UI to log recurring investments, approve amounts for automated spending, view the investment gains and cancel recurring investments whenever desired.  

## dApp Problem Statement
While dollar cost averaging is a functionality which exists on multiple centralized trading exchanges- there is a need for a decentralized method which makes use of native Web3 DEXs. By harnessing the power of automation [developed by BlockHead finance], Fluther empowers users create recurring investments for a token exchange of their choice. 

## Dollar Coast Averaging Definition
Dollar cost averging is the practice of spending a fixed quantity of one token for the swap of another over time. The idea with this practice is that over the long term an investor removes the subjective interpretation of when to buy by abiding by a simple rule set. Specifically, invest a certain amount across intervals within a fixed time period. 

The practice of dollar cost averaging is helpful for reducing the effects of market volitility on investments and gives investors peace of mind through a strict rule set therefore, reducing subjectivity. 

## Fluther?
A fluther is a group of jellyfish. Jellyfish have no centralized brain; instead they have a distrubted nervous system. Their bodies are engineered for simplicity, reliability and function. 

Groups of jellyfish, moreoever, are decentralized in their leadership. Jellyfish float together- flow together- through the ocean and make their way as a unified whole. Jellyfish live life untehtered from centralization in all they do. 

The dApp Fluther, aims to present a similiarly decentralized means for 'flowing' through the relm of Web3 financial investment. Like a jellyfish which floats effortlessly through the ocean; a user can set a recurring investment and let the automation layer trigger the investment 'buys' through employing a simple rule set. 

Sit back and let the tokens swaps amass via Fluther. 

## Flutter dApp UX Features
-Web3 Connect Button via ThirdWeb

-Spending Approval View

-Token Amount Display

-Token Investment Visualization

-Display User Agreements Dashboard

-Dollar Cost Average Maker

-Mock WETH Token Distribution (Floating Action Button)

-Music Embelishment (Floating Action Button)

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

    -AutomationLayer.sol Describe

    -NodeSequencer.sol Describe

## Fluther Protocol Fee Break Down
- Describe the fee break down in fees;for customer vs. automation node operator

## Automation via Running Nodes

- Describe Node.js script and incentive for running a node  

## Automation Layer & Further Development

- Outline vision for integation with BlockHead Finance Automation protocol. 
- Describe functions which act as interface for automation layer once launched on mainnet. 

## Web3 Integrations
-<strong>Infura</strong>:
The Fluther dApp makes full use of the Infura API for defining a provider object. This is for making calls to the blockchain to recieve the most up date information on token amounts, dollar cost average contract deployments + cancellations as well as getting confirmation transactions on chain for the distribution of test token. 

-<strong>MetaMask SDK</strong>:
Fluther dApp incorperates the MetaMask SDK via the dApp logo being detected on connection with wallet. Furthermore, integration comes from how MetaMask injects itself into the browser via window.ethereum; as described in the SDK, Fluther's test token distrubtion (Floating Action Button) can auto add test tokens to a user's MetaMask without the manual insertion of a token info which can be prone to error. 

-<strong>Ethers.js</strong>:
Ethers.js is used as a utility library for converting amounts between on chain values and those consumed on the front end. Furthermore, to keep the 'signer' object dynamic (per app usage)- a provider object from Ethers.js Web3 is created to write state changes to the blockchain. 

-<strong>ThirdWeb</strong>:
As a nod to Web3 builders, Fluther as appropraited the Web3 connect button to allow users to connect with multiple wallets aside from MetaMask. The user's blockchain address is parsed from this element and used throughtout the dApp. 

-<strong>Hardhat</strong>:

-<strong>Foundry</strong>:

-<strong>Remix</strong>:

-<strong>Chainlink Price Feed</strong>: To ensure that dollar cost average agreement investment amounts meet a cetain threshold (at least $20 USD per investment); a Chainlink price feed is used to pull dynamic pricing for the swap value, USD/ETH. This value is then employed on the front end for form validation. 

## Team
- [@kitfud](https://github.com/kitfud)
- [@EWCunha](https://github.com/EWCunha)
- [@GZRdev](https://github.com/GZRdev)
- [@DopaMIM](https://github.com/DopaMIM)

