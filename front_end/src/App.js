import React, { useEffect, useState, useCallback } from 'react'
import './App.css';
import { ConnectWallet } from "@thirdweb-dev/react";
import { useAddress } from "@thirdweb-dev/react";
import { ThemeProvider, createTheme } from '@mui/material';
import {Snackbar,
  CircularProgress, 
  Grid, 
  Box, 
  TextField, 
  Typography, 
  Card, 
  Button, 
  Paper,
  Zoom,
  FormControlLabel,
  Switch,
  Modal,
  Fab,

  InputLabel, MenuItem, FormControl, Select,TableContainer,Table,TableHead,TableRow,TableCell,TableBody, Icon, Slide} from "@mui/material";

import ABI from './chain-info/erc20ABI.json'
import PriceFeedABI from './chain-info/pricefeedABI.json'
import smartContracts from './chain-info/smart_contracts.json'
import {ethers} from 'ethers'

import IconButton from '@mui/material/IconButton';
import CloseIcon from '@mui/icons-material/Close';
import UserRecurringBuys from './components/UserRecurringBuys';
import ETHicon from './img/ETH.png'
import WETHicon from './img/wETH.png'
import UNIicon from './img/UNIicon.jpg'

import Particles from "react-particles"
import { loadFull } from "tsparticles";
import particlesOptions from "./particlesConfig.json";
import LinearProgress from '@mui/material/LinearProgress';

import {LineChart,Line, CartesianGrid,XAxis,YAxis,Label,Tooltip} from 'recharts'
import EthDater from 'ethereum-block-by-date'
import MusicNoteIcon from '@mui/icons-material/MusicNote';
import MusicOffIcon from '@mui/icons-material/MusicOff';

import Tenderness from './audio/tenderness.mp3'

import AttachMoneyIcon from '@mui/icons-material/AttachMoney';
import TokenFountain from './components/TokenFountain'


const theme = createTheme({
  palette: {
    primary: {
      main: '#5d00d4',
      //previously yellow #ece115
    },
    secondary: {
      main:'#a7aeff'
      // main: '#15ece1',
    },
  },
  typography: {
    fontFamily: 'BlinkMacSystemFont',
  },

  components: {
    // Name of the component 
    
    MuiTextField: {
      styleOverrides: {
        root: {
          backgroundColor: '#ebecff',
        },
      },
      inputProps:{
          style:{color:"red"}  
      }
    },
    MuiFormControl: {
      styleOverrides: {
        root: {
          backgroundColor: '#ebecff'
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        // Name of the slot
        root: {
          // Some CSS
          borderColor: "#e842fa",
          borderRadius: 30,
          position: "relative",
          zIndex: 0,
          raised:true,
        },
      },
    },

  }
})

const modalStyle = {
  position: 'absolute',
  top: '50%',
  left: '50%',
  transform: 'translate(-50%, -50%)',
  width: 400,
  bgcolor: 'background.paper',
  border: '2px solid #000',
  boxShadow: 24,
  p: 4,
};

const fountainModalStyle = {
  position: 'absolute',
  top: '10%',
  right: '0%',
  width: 400,
};
const audio = new Audio(Tenderness)
audio.load()

function App() {
  const [amount, setAmount] = useState("")
  const [token1,setToken1] = useState("")
  const [token2,setToken2] = useState("")
  const [interval, setI] = useState("")
  const [intervalAmount, setIntervalAmount] = useState("")

  const [erc20contract, setErc20Contract]= useState(null)
  const [contractParamsSet, setContractParams] = useState(false)
  const [provider, setProvider] = useState(null)
  const [signer, setSigner] = useState(null)
  const [spendingApproved, setSpendingApproved] = useState(false)
  const [dollarCostAverageContract,setDollarCostAverageContract] = useState(null)
  const [disableText, setDisabledTextFeild] = useState(false)
  const [duhcontract, setDuhContract] = useState(null)
  const [pricefeedcontract,setPriceFeedContract] = useState(null)


  const [wethtoken,setWEth] = useState(null)
  const [unitoken,setUNI] = useState(null)

  const [ethbalance, setEthBalance] = useState(null)
  const [wethbalance,setWEthBalance] = useState(null)
  const [unibalance,setUniBalance] = useState(null)
  const [processing, setProcessing] = useState(false)
  const [txHash, setTxHash] = useState(null)

  const [openSnackbar,setOpenSnackBar] = useState(false)

const [unicolor,setUniColor] = useState('black')
const [allowance, setAllowance] = useState(null)

const [delayRender, setDelayRender] = useState(false)
const [previousAllowance, setPreviousAllowance] = useState(null)
const [exchangeprice, setExchangePrice] = useState(null)

const [thresholdETHtransaction, setThresholdETHTransaction] = useState(null)
const [amountError, setAmountError] = useState(false)

const [checked, setChecked] = useState(false);

const [open, setOpen] = useState(false);
const [dater,setDater] = useState(null)

const handleModalOpen = () => setOpen(true);
const handleModalClose = () => setOpen(false);

const [tokenChangeData, setTokenChangeData] = useState([])

const [music, setMusic] = useState(false)

const [openFountain,setOpenFountain] = useState(false)
const [cancelOccur,setCancelOccur] = useState(false)
const [infuraProvider, setInfuraProvider] = useState(null)

const [updateAgreements,setUpdateAgreements] = useState(false)

const handleCloseFountain = ()=>{
  setOpenFountain(false)
}

const handleOpenFountain = ()=>{
  setOpenFountain(true)
}



const renderChart = ( 
  <LineChart width={400} height={400} data={tokenChangeData}  margin={{ top: 5, right: 20, bottom: 5, left: 0 }}>
    <Line type="monotone" dataKey="amount" stroke="#8884d8" />
    <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
    <XAxis dataKey="date" />
    <YAxis >
      <Label  style={{
             textAnchor: "left",
             fontSize: "100%",
             fill: "black"
         }}
      angle={270} 
      />
    </YAxis>
    <Tooltip/>
  </LineChart>
  )


const handleChange = () => {
  setChecked((prev) => !prev);
};

const address = useAddress();



  //address below is deployment to Polygon mainnet
  //const dollarCostAddress = '0x519DdbffEA597980B19F254892dEc703613e8775'

  //address below is for Polygon mainnet
  //const quickSwapRouterAddress = '0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff'

  //address below is for testing on Sepolia testnet
  const quickSwapRouterAddress = '0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008'
  const [dataload,setDataLoad] = useState(false)

  const particlesInit = useCallback(main => {
    loadFull(main);
  },[])

  
  useEffect(() => {
    console.log("UPDATING ETHERS")
    updateEthers()
  },[])

  useEffect(()=>{
if(pricefeedcontract){
getCurrentExchangePrice()
}
  },[pricefeedcontract])


useEffect(()=>{
if(exchangeprice){
  let decimalsRemovedRate= exchangeprice.toNumber()/10**8
  setThresholdETHTransaction(20/decimalsRemovedRate)
}
  },[exchangeprice])


const getCurrentExchangePrice = async()=>{
  let result = await pricefeedcontract.getLatestData()
  setExchangePrice(result)
}



  useEffect(()=>{
  
 if(provider !=null){
    checkAllowance()
 }
  },[address,wethbalance])

  useEffect(()=>{
    let balanceCheck
    if(signer !=null && erc20contract && address){
    
    balanceCheck= setInterval(()=>{checkAllowance()},1000)
    }
    return ()=>clearInterval(balanceCheck)
  },[signer,erc20contract,allowance])

  useEffect(()=>{
    if(allowance && typeof(allowance)=="number"){

      if(delayRender==true){
        if(previousAllowance==allowance){
          setDelayRender(false)
        }
        if(previousAllowance!=allowance){
         setDelayRender(false)
        }
      }
     
     if(allowance>=100){
      setSpendingApproved(true)
      setDisabledTextFeild(true)
     }
     else{
      setSpendingApproved(false)
      setDisabledTextFeild(false)
     }
     setPreviousAllowance(allowance)
    }
  },[allowance])

  useEffect(() => {
    console.log("token",wethtoken)
    console.log("address",address)
  let tokenCheckInterval
  if(wethtoken&& provider && address!==null && address !== undefined){
    try{
    checkTokenBalance()
    tokenCheckInterval = setInterval(()=>{
      checkTokenBalance()
    },1000)
    }
    catch(err){
      console.log(err)
    }
  }
  return ()=>clearInterval(tokenCheckInterval)
  },[wethtoken,address])



  useEffect(() => {
    if(provider !== null){
    
  
     

if(infuraProvider){
//price feed contract object is made below
try{
      setPriceFeedContract(new ethers.Contract(smartContracts.PriceFeed.address.sepolia.ETHUSD,PriceFeedABI.sepolia,infuraProvider))  
      setErc20Contract(new ethers.Contract(smartContracts.WETHMock.address.sepolia,ABI,infuraProvider))
      setDuhContract(new ethers.Contract(smartContracts.Duh.address.sepolia,ABI,infuraProvider))
      setWEth(new ethers.Contract(smartContracts.WETHMock.address.sepolia,ABI,infuraProvider))
      setUNI(new ethers.Contract(smartContracts.UNIMock.address.sepolia,ABI,infuraProvider))
}
catch(err){
  console.log(err)
}
}else{
      

      setPriceFeedContract(new ethers.Contract(smartContracts.PriceFeed.address.sepolia.ETHUSD,PriceFeedABI.sepolia,provider))  
      setErc20Contract(new ethers.Contract(smartContracts.WETHMock.address.sepolia,ABI,provider))
      setDuhContract(new ethers.Contract(smartContracts.Duh.address.sepolia,ABI,provider))
      setWEth(new ethers.Contract(smartContracts.WETHMock.address.sepolia,ABI,provider))
      setUNI(new ethers.Contract(smartContracts.UNIMock.address.sepolia,ABI,provider))
      }
    }
    
  },[provider,infuraProvider])



  useEffect(() => {
    if(token1 !== "" & token2 !=="" & interval !== "" & intervalAmount !== "") {
      setContractParams(true)
    }
    else {
      setContractParams(false)
    }
  },[amount,token1,token2,interval, intervalAmount])


let currentWETH = 0
let currentUNI = 0
const checkTokenIncrease = (incomingUNI,incomingWETH) =>{
 
    if(incomingUNI>currentUNI && currentUNI != 0){
      console.log("INCREASE DETECTED")
      setUniColor("green")
    }
    currentUNI = incomingUNI
    currentWETH = incomingWETH
  }

useEffect(()=>{
let colorChange
if(unicolor=="green"){
  colorChange = setTimeout(()=>{
    setUniColor("black")
    checkAllowance()
  },2000)
}
return ()=>clearTimeout(colorChange)
},[unicolor])  

  const updateEthers = async ()=>{
    let tempProvider = await new ethers.providers.Web3Provider(window.ethereum);
    setProvider(tempProvider);

    const network = process.env.REACT_APP_ETHEREUM_NETWORK;
    const key = process.env.REACT_APP_INFURA_API_KEY
    let infuraTempProvider;
    
    try{
    infuraTempProvider = new ethers.providers.InfuraProvider(
      network,
      key
    )
    }
  catch(err){
  console.log(err)
  setInfuraProvider(null)
}
if (infuraTempProvider){
  setInfuraProvider(infuraProvider)
}
    
    // const Metaprovider = new ethers.providers.Web3Provider(window.ethereum);
    const tempSigner =tempProvider.getSigner();
    // const tempSigner = new ethers.Wallet(process.env.REACT_APP_SIGNER_PRIVATE_KEY, tempProvider);
 
    
    setSigner(tempSigner);
    setDataLoad(true)
  

    let dollaAverageAddress = smartContracts.DollarCostAverage.address.sepolia
    let dollaAverageAbi = smartContracts.DollarCostAverage.abi
  
    let tempContract = new ethers.Contract(dollaAverageAddress,dollaAverageAbi,tempProvider);
    setDollarCostAverageContract(tempContract);
    
  }

  const checkTokenBalance = async ()=>{

   
  if(provider!== null && address !== null && address !== undefined){
  if(infuraProvider !=null){
    console.log("Checking with INFURA PROVIDER")
      const ethbal = await infuraProvider.getBalance(address);
      let valueToNumber = parseFloat(ethbal.toString())
      let valueConverted = valueToNumber/10**18
      setEthBalance(valueConverted)
  }
  else{
    if(provider){
    const ethbal = await provider.getBalance(address);
    let valueToNumber = parseFloat(ethbal.toString())
    let valueConverted = valueToNumber/10**18
    setEthBalance(valueConverted)
    }
  }
    }

    if(provider!=null  && address!== undefined){
    // console.log("address",signer.address)
   
    var wethbal= (await wethtoken.balanceOf(address)/10**18).toString();
   
    setWEthBalance(wethbal)
    }

    
    if(provider !=null && address!== undefined ){
    var unibal= (await unitoken.balanceOf(address)/10**18).toString();
    setUniBalance(unibal)
    }
   
    //this is the if statement which controls the color change on amount increase
    if(provider !=null&& address!== undefined){
    checkTokenIncrease(unibal,wethbal)
      }
  }

  const checkAllowance = async ()=>{
 
 if(address && erc20contract && provider!=null){

 
    let allowanceAmount = await erc20contract.allowance(address,smartContracts.DollarCostAverage.address.sepolia)
    let convertedAllowance = parseFloat(allowanceAmount.toString())/10**18
   
    setAllowance(convertedAllowance)
   
 }
    
  }

  const approveSpending = async()=>{
    console.log(amount)
    if(delayRender==true){
      if(amount==allowance){
        setDelayRender(false)
      }
    }
    if(parseInt(amount)<100){
      console.log(amount)
      alert("need to approve amount 100 or more")
      return
    }
  
    try{
      //first contract object made from token to spend erc20contract
      await erc20contract.connect(signer).approve(smartContracts.DollarCostAverage.address.sepolia,ethers.utils.parseEther(amount))
      setSpendingApproved(true)
      setDisabledTextFeild(true) 
      
      setDelayRender(true)
    }
    catch(err){
      console.log(err)
      setSpendingApproved(false)

      setDelayRender(false)
      setDisabledTextFeild(false)
    }
   
  }

  const updateAllowance = ()=>{
    setSpendingApproved(false)
    setDisabledTextFeild(false)
    setDelayRender(true)
  }

  const submitAgreement = async () => {
  
const input = intervalAmount;
const amountInterval = ethers.utils.parseUnits(input)

  try{
  setProcessing(true)

  console.log("dollarCostDetails",
  {'signer':signer,
  "amountInterval":amountInterval,
  "token1":token1,
  "token2":token2,
  "interval":interval,
  "quickSwapAddress":quickSwapRouterAddress
})

  let tx = await dollarCostAverageContract.connect(signer).createRecurringBuy(amountInterval,token1,token2,interval,'0x0000000000000000000000000000000000000000',quickSwapRouterAddress)
  let hash = tx.hash
  setTxHash(hash.toString())
  isTransactionMined(hash.toString())
  setUpdateAgreements(true)
  }
  catch(err){
    setProcessing(false)
    console.log(err)
  }
}

const isTransactionMined = async (transactionHash) => {
  let transactionBlockFound = false
  if(infuraProvider){

  while (transactionBlockFound === false) {
      let tx = await infuraProvider.getTransactionReceipt(transactionHash)
      console.log("transaction status check....")
      try {
          await tx.blockNumber
      }
      catch (error) {
          tx = await infuraProvider.getTransactionReceipt(transactionHash)
      }
      finally {
          console.log("proceeding")
      }


      if (tx && tx.blockNumber) {
        
          console.log("block number assigned.")
          transactionBlockFound = true
          let stringBlock = tx.blockNumber.toString()
          console.log("COMPLETED BLOCK: " + stringBlock)
          
          
            setProcessing(false)
            setOpenSnackBar(true)
         
          

      }
  }
}
  else{
    while (transactionBlockFound === false) {
      let tx = await provider.getTransactionReceipt(transactionHash)
      console.log("transaction status check....")
      try {
          await tx.blockNumber
      }
      catch (error) {
          tx = await provider.getTransactionReceipt(transactionHash)
      }
      finally {
          console.log("proceeding")
      }


      if (tx && tx.blockNumber) {
        
          console.log("block number assigned.")
          transactionBlockFound = true
          let stringBlock = tx.blockNumber.toString()
          console.log("COMPLETED BLOCK: " + stringBlock)
          
          
            setProcessing(false)
            setOpenSnackBar(true)
         
          

      }
  }
  }
}

const handleClose = (event, reason) => {
  if (reason === 'clickaway') {
    return;
  }
  // window.location.reload(false);
  setOpenSnackBar(false);
};

const action = (
  <React.Fragment>
    <Button color="secondary" size="small" onClick={handleClose}>
      UNDO
    </Button>
    <IconButton
      size="small"
      aria-label="close"
      color="inherit"
      onClick={handleClose}
    >
      <CloseIcon fontSize="small" />
    </IconButton>
  </React.Fragment>
);

const handleIntervalSpendCheck= (e)=>{

const reg = new RegExp(/^[0-9]+([.][0-9]+)?$/);
const emptyString = new RegExp(/^$/);

//check to make sure only number passes and also not empty strings

if(reg.test(e.target.value) || emptyString.test(e.target.value)){

  if(parseFloat(e.target.value)>=thresholdETHtransaction){
  setAmountError(false)
  setIntervalAmount(e.target.value)
  }
  else{
    setIntervalAmount("")
    setAmountError(true)
  }
}
else{
  setIntervalAmount("")
  setAmountError(true)
}
}

const handleIconClick = ()=>{
  
  // handleModalOpen()
  const dater = new EthDater(
  infuraProvider // Ethers provider, required.
);
setDater(dater)

}

const [blocks,setBlocks] = useState(null)
const [tokenQuantityBlocks,setTokenQuantityBlocks] = useState(null)

useEffect(()=>{
  if(tokenQuantityBlocks!=null){
  let tokenChangeData = []
  let counter = 0
  blocks.forEach((element)=>{
    counter++
    let dataFrame = {}
    let convertDate = new Date(element.date)
    
    dataFrame["date"] = convertDate.getMonth() + "/"+ convertDate.getDate()
    dataFrame["amount"] = tokenQuantityBlocks[blocks.indexOf(element)]
    tokenChangeData.push(dataFrame)
    if(counter==9){

      setTokenChangeData(tokenChangeData)
      handleModalOpen(true)
    }
  })
  // console.log("blocks",blocks)
  // console.log("tokenQuantity",tokenQuantityBlocks)
  }
},[tokenQuantityBlocks])


useEffect(()=>{
if(dater){
getBlockForDates()
}
},[dater])
useEffect(()=>{
if(blocks){
  getTokenQuantityPerBlock(unitoken,blocks)
}
},[blocks])

function getTokenQuantityPerBlock(token,blocks){
let items = []
let counter = 0
blocks.forEach((item)=>{
  token.balanceOf(address,{blockTag:item.block}).then((res)=>{
   
    items[blocks.indexOf(item)]=parseFloat(res.toString())/10**18
    counter++
    if(counter == 9){
      // console.log("items",items)
      setTokenQuantityBlocks(items)
    }
  })
})



}

async function getBlockForDates (){
  let present = getPreviousDaysDate(0)
  let back = getPreviousDaysDate(8)

  let blocks = await dater.getEvery(
    'days', // Period, required. Valid value: years, quarters, months, weeks, days, hours, minutes
    back, // Start date, required. Any valid moment.js value: string, milliseconds, Date() object, moment() object.
    present, // End date, required. Any valid moment.js value: string, milliseconds, Date() object, moment() object.
    1, // Duration, optional, integer. By default 1.
    true, // Block after, optional. Search for the nearest block before or after the given date. By default true.
    false // Refresh boundaries, optional. Recheck the latest block before request. By default false.
    );
  setBlocks(blocks)

}

function getPreviousDaysDate(dayBack){
  const now = new Date()
  return new Date(now.getTime() - dayBack * 24 * 60 * 60 * 1000).toJSON();
}

function handleReturn(event){
  setDelayRender(false)
  setSpendingApproved(true)
}



const handleMusic =(event)=>{
  
  if(!music){
    setMusic(true)
    audio.play()
  }
  else{
    setMusic(false)
    audio.pause()
  }
}



  return (
    <>

      <Particles
        id="particles_stuff"
        options={particlesOptions}
        init={particlesInit}
      />
    
      
      <ThemeProvider theme={theme}>

{
  music?
      (<Fab onClick={handleMusic} sx={{position:'fixed', marginLeft:'3%',marginTop:'1%'}} color="primary" aria-label="add">
        <MusicNoteIcon />
      </Fab>):
      <Fab onClick={handleMusic} sx={{position:'fixed', marginLeft:'3%',marginTop:'1%'}} color="primary" aria-label="add">
      <MusicOffIcon />
      </Fab>
  }


<Box className="tooltip" sx={{position:'fixed', right:'3%', marginTop:'1%'}}>
<span className="tooltiptextBank" > Click For Test WETH Faucet</span>
<Fab onClick={handleOpenFountain} color = "primary" >
    <AttachMoneyIcon/>
</Fab>
</Box>

<Modal
  open={openFountain}
  onClose = {handleCloseFountain}
 
>
  <Box  sx={fountainModalStyle}>
  <TokenFountain infuraProvider={infuraProvider?infuraProvider:provider} 
  signer={signer} 
  address={address} 
  contract={erc20contract} 
  theme={theme}/>
  </Box>


</Modal>


      <Modal
        open={open}
        onClose={handleModalClose}
        aria-labelledby="modal-modal-title"
        aria-describedby="modal-modal-description"
      >
        <Box  sx={modalStyle}>
        <Typography position="absolute" top="20px"sx={{positon:'absolute',top:'20px'}}>UNI</Typography>
        {renderChart}
        <Typography sx={{position:'relative',left:'50px'}}>Date</Typography>
        </Box>
      </Modal>
    

        <Grid container
          spacing={0}
          direction="column"
          alignItems="center"
          justify="center"
          style={{ minHeight: '100vh' }}
        >
          <Slide direction="down" in={true} mountOnEnter>
            <Box
              sx={{
                zIndex: 5,
                marginTop:'2vh',
              }}
            >
              <Typography fontSize="100px" color="#a939c4" fontFamily="Cherry Bomb One">
                fluther
              </Typography>
            </Box>
          </Slide>

          {/* CONNECT WALLET BUTTON */}
          <Slide direction="down" in={true} mountOnEnter>
            <Box 
              sx={{
                marginBottom:'10px',
                marginTop:'2vh',
                zIndex: 10,
              }}
              display="flex"
              alignItems="center"
              justifyContent="center"
            >
              <ConnectWallet 
                dropdownPosition={{
                  side: "top",
                  align: "center",
                }}
              />
            </Box>
        </Slide>

          {/* MAIN CARD */}
          <Slide direction="left" in={true} mountOnEnter>
          <Card 
            variant="outlined"
            sx={{ 
              
              display: 'inline-block',
              backgroundColor:theme.palette.secondary.main,
              //opacity: 0.9,
            }}
          >
            <Box width='100%'
            display="flex"
            alignItems="center"
            justifyContent="center"
            >
            <Typography
              color='#bf00e8'
              component="h1"
            
              sx={{
                fontSize: 20,
                fontWeight: 700,
                padding: 2
              }}
            >
                Create Dollar Cost Average
            </Typography>
            </Box>
           

              {!spendingApproved?
            <Box
              alignItems="center"
              justifyContent="center">
                {
                allowance>=100?
                <Box component="div" display="block">
                <Button variant="contained" onClick={handleReturn} >Return To Dollar Cost Average Maker</Button>
                </Box>:null
                }
               <Box    alignItems="center"
              justifyContent="center" display="flex">
               <Typography padding={'2px'}  color='#bf00e8'
              component="h1"
            
              sx={{
                fontSize: 10,
                fontWeight: 700,
                padding: 2
              }}>Current Spending Limit:{allowance}</Typography>
               </Box>
           
            </Box>:null
}

            {/* TOTAL AMOUNT BOX FIELD */}  
            <Box
              display="flex"
              alignItems="center"
              justifyContent="center"
            >
              { !spendingApproved
              ?
                <TextField
                  sx={{
                    width: "80%"
                  }}
                  onChange={ (e) => setAmount(e.target.value) }
                  id="filled-basic"
                  label="Total amount"
                  variant="filled"
                  disabled = {disableText}
                >
                </TextField>
              :
              (
              <>
                <Box sx={{marginBottom:'20px'}} component="div">
                  { delayRender
                    ?  
                      <Box sx={{ width: '100%' }}>
                        <LinearProgress/>
                        <Box backgroundColor="lightBlue">
                          <Typography>Allowance Approved. Values Will Update Shortly.</Typography>
                        </Box> 
                      </Box>
                    :
                      <Button onClick={updateAllowance} variant="contained" color="warning">Update {allowance} Spending Limit</Button>
                  }
                </Box>
              </>)
              }
            </Box>

            {/* TOKEN 1 BOX FIELD */}
            <Box 
         
              display="flex"
              alignItems="center"
              justifyContent="center"
            >
        
              <FormControl
                variant="filled"
                sx={{
                  width: "80%",
                  display: "flex",
                  flexDirection: "row",
                  justifyContent: "space-around",
                  alignItems:"center",
                }}
                
              >
                <InputLabel>
                  Token to Spend
                </InputLabel>
                <Select
                  id="filled-basic"
                  label="Token1"
                  variant="filled"
                  onChange={ (e) => setToken1(e.target.value) }
                  value={token1}
                  sx={{
                    width:"100%"
                  }}
                >
           
                  <MenuItem value={smartContracts.WETHMock.address.sepolia}>
                    <Icon sx={{height:"25px", width:"25px", borderRadius: "50%",}}><img src={WETHicon} height="25px" width="25px"/></Icon>
                      wETH Sepolia
                  </MenuItem>
                </Select>
              </FormControl>
            </Box>

            {/*
               -WE NEED USERS SPENDING APPROVAL
               -SHOW APPROVAL BUTTON UNTIL USER GIVES APPROVAL
            */}
            {
              !spendingApproved
              ?
              (
                <>
                  <Box 
                    sx={{
                      marginTop:'20px',
                      marginBottom:"20px"
                    }} 
                    display="flex"
                    alignItems="center"
                    justifyContent="center"
                  >
                    <Button
                      onClick={approveSpending}
                      variant="contained"
                      color="success"
                    >
                      Approve Spending Amount
                    </Button>
                  </Box>
                </>
              )
              :
              null
            }

            {/* TIME INTERVAL FORMCONTROL FIELD */}
            {
              spendingApproved
              ?
              (
                <>
                  {/* INTERVAL AMOUNT BOX FIELD */}  
                  
                  <Box 
                    display="flex"
                    alignItems="center"
                    justifyContent="center"
                  >
                    <TextField
                      onChange={ (e) => handleIntervalSpendCheck(e) }
                      error = {amountError}
                      helperText={amountError?'spending does not meet threshold amount':''}
                      id="filled-basic"
                      label="Amount to Spend"
                      variant="filled"
                      sx={{
                        width: "80%"
                      }}
                    >
                    </TextField>
                  </Box>
                  {/* TOKEN 2 BOX FIELD */}
                  <Box 
                    display="flex"
                    alignItems="center"
                    justifyContent="center"
                  >
                    <FormControl
                      variant="filled"
                      sx={{
                        width: "80%"
                      }}
                    >
                      <InputLabel>
                        Tokens To Buy
                      </InputLabel>
                      <Select
                        id="filled-basic"
                        label="Token1"
                        variant="filled"
                        onChange={ (e) => setToken2(e.target.value) }
                        value={token2}
                      >
            
                        <MenuItem value= {smartContracts.UNIMock.address.sepolia} >
                        <Icon sx={{height:"25px", width:"25px", borderRadius: "50%",}}><img src={UNIicon} height="25px" width="25px"/></Icon>
                          UNI
                        </MenuItem>
                      </Select>
                    </FormControl>
                  </Box>
                  <Box
                    display="flex"
                    alignItems="center"
                    justifyContent="center">
                  </Box>
                  <Box
                    display="flex"
                    alignItems="center"
                    justifyContent="center"
                  >
                    <FormControl
                      variant="filled"
                      sx={{
                        width: "80%"
                      }}
                    >
                      <InputLabel>
                        Time Interval
                      </InputLabel>
                      <Select
                        id="filled-basic"
                        label="Interval"
                        variant="filled"
                        onChange={ (e) => setI(e.target.value) }
                        value={interval}
                      >
                        {/* WILL FIGURE OUT A BETTER WAY TO DO THIS PART LATER */}
                        <MenuItem value={300}>5 Minutes</MenuItem>
                        <MenuItem value={86400}>Daily</MenuItem>
                        <MenuItem value={604800}>Weekly</MenuItem>
                        <MenuItem value={2419200}>Monthly</MenuItem>
                      </Select>
                    </FormControl>
                  </Box> 
                </>
              )
              :<Box></Box>
            }

            {/* "SUBMIT AGREEMENT" BUTTON LOGIC
                  IF USER SUBMITTED ALL INFO
                    SHOW SUBMIT AGREEMENT BUTTON
            */}
            { 
              contractParamsSet & spendingApproved
              ?
              
                !processing?
              <Box 
                sx={{
                  marginTop:'20px',
                  marginBottom:"20px"
                }}
                display="flex"
                alignItems="center"
                justifyContent="center"
              >
              
                <Button
                  onClick={submitAgreement}
                  variant="contained"
                  color="success"
                >
                  Submit Agreement
                </Button>
              </Box>: <Box 
                sx={{
                  marginTop:'20px',
                  marginBottom:"20px"
                }}
                display="flex"
                alignItems="center"
                justifyContent="center"
              ><CircularProgress/> 
              </Box>
              
              :
              <Box
                sx={{
                  marginTop:'20px',
                  marginBottom:"20px"
                }}>
              </Box>
            }    
          </Card></Slide>
          
          {
          wethbalance!==null && address !== null?
          <>
            <Box 
              sx={{
                //WALLET AMOUNT section
                display:"flex",
                flexDirection:"column",
                justifyContent:"center",
                zIndex:1,
              
              }}
            >
              <Slide direction="right" in={true} mountOnEnter>
                <TableContainer sx={{border: 2,borderColor: "#e842fa",borderRadius:5, marginTop:'10px',}} component={Paper}>
                  <Table aria-label="coin table">
                    <TableHead sx={{backgroundColor:"#a7aeff",}}>
                    <TableRow>
                      <TableCell align="left" ><Typography fontWeight="700" color="#bf00e8">ICON</Typography></TableCell>
                      <TableCell align="left" ><Typography fontWeight="700" color="#bf00e8">COINS</Typography></TableCell>
                      <TableCell align="left" ><Typography fontWeight="700" color="#bf00e8">WALLET AMOUNT</Typography></TableCell>
                    </TableRow>
                    </TableHead>
                    <TableBody sx={{backgroundColor: "#ebecff"}}>
                      <TableRow>
                        <TableCell>
                          <Icon  sx={{width: "50px", height: "50px", borderRadius: "50%"}}>
                            <img  src={ETHicon} height="50px" width="50px"/>
                          </Icon>
                        </TableCell>
                        <TableCell><Typography fontWeight="600">ETH</Typography></TableCell>
                        <TableCell><Typography fontWeight="600">{ethbalance}</Typography></TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell>
                          <Icon sx={{width: "50px", height: "50px", borderRadius: "50%"}}>
                            <img src={WETHicon} height="50px" width="50px"/>
                          </Icon>
                        </TableCell>
                        <TableCell><Typography fontWeight="600">WETH</Typography></TableCell>
                        <TableCell><Typography fontWeight="600">{wethbalance}</Typography></TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell>
                        <Box className="tooltip">
                         <Icon onClick = {handleIconClick} sx={{width: "50px", height: "50px", borderRadius: "50%"}}>
                            <img className='highlight' src={UNIicon} width="50px" height="50px"/>
                          </Icon>
                          
                    <span className="tooltiptext">Click For Data</span>
                          </Box>
                       
                        
                         
                        </TableCell>
                      <TableCell><Typography fontWeight="600">UNI</Typography></TableCell>
                      <TableCell><Typography fontWeight="600" color={unicolor}>{unibalance}</Typography></TableCell>
                      </TableRow>
                    </TableBody>
                  </Table>
                </TableContainer>
              </Slide> 
            </Box>
          </>:null
          }
      
      <Snackbar
        anchorOrigin={{vertical: 'bottom', horizontal: 'center'}}
        open={openSnackbar}
        autoHideDuration={3000}
        onClose={handleClose}
        message=""
        action={action}
        sx={{backgroundColor:"white"}}
      >
        <a target="_blank" href={`https://sepolia.etherscan.io/tx/${txHash}`}>
          <Typography color="black">Success! Click for Transaction:${txHash} on Etherscan</Typography>
        </a>
        </Snackbar>
        <Box >
        <FormControlLabel 
        sx={{color:'white'}}
        control={<Switch checked={checked} onChange={handleChange} />}
        label="Display User Agreements"
      />
        </Box>
     
      <Zoom in={checked}>
      <Box>
      <UserRecurringBuys 
      setUpdateAgreements={setUpdateAgreements}
      updateAgreements={updateAgreements}
      processingApp={processing} setCancelOccur={setCancelOccur} cancelOccur = {cancelOccur} balance={ethbalance} signer={signer} contract={dollarCostAverageContract} provider={infuraProvider?infuraProvider:provider} address={address}/> 
      </Box>
       </Zoom>
       
        </Grid>      
      </ThemeProvider>
    </>
  );
}

export default App;
