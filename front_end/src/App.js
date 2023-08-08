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
<<<<<<< HEAD
  InputLabel, MenuItem, FormControl, Select,TableContainer,Table,TableHead,TableRow,TableCell,TableBody, Icon} from "@mui/material";

import ABI from './chain-info/erc20ABI.json'
import ERC20Address from './chain-info/smart_contracts.json'
import smartContracts from './chain-info/smart_contracts.json'
import {ethers} from 'ethers'

import IconButton from '@mui/material/IconButton';
import CloseIcon from '@mui/icons-material/Close';
import UserRecurringBuys from './components/UserRecurringBuys';
=======
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
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
import WETHicon from './img/wETH.png'
import UNIicon from './img/UNIicon.jpg'

import Particles from "react-particles"
import { loadFull } from "tsparticles";
import particlesOptions from "./particlesConfig.json";
<<<<<<< HEAD
import zIndex from '@mui/material/styles/zIndex';
=======
import LinearProgress from '@mui/material/LinearProgress';

import {LineChart,Line, CartesianGrid,XAxis,YAxis,Label,Tooltip} from 'recharts'
import EthDater from 'ethereum-block-by-date'
import MusicNoteIcon from '@mui/icons-material/MusicNote';
import MusicOffIcon from '@mui/icons-material/MusicOff';

import Tenderness from './audio/tenderness.mp3'

>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028

const theme = createTheme({
  palette: {
    primary: {
<<<<<<< HEAD
      main: '#ec1520',
      //previously yellow #ece115
    },
    secondary: {
      main:'#42fae8'
=======
      main: '#5d00d4',
      //previously yellow #ece115
    },
    secondary: {
      main:'#a7aeff'
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
      // main: '#15ece1',
    },
  },
  typography: {
    fontFamily: 'BlinkMacSystemFont',
  },

  components: {
    // Name of the component 
<<<<<<< HEAD
    MuiTextField: {
      styleOverrides: {
        root: {
          backgroundColor: 'teal',
=======
    
    MuiTextField: {
      styleOverrides: {
        root: {
          backgroundColor: '#ebecff',
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
        },
      },
      inputProps:{
          style:{color:"red"}  
      }
    },
    MuiFormControl: {
      styleOverrides: {
        root: {
<<<<<<< HEAD
          backgroundColor: 'teal'
=======
          backgroundColor: '#ebecff'
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        // Name of the slot
        root: {
          // Some CSS
<<<<<<< HEAD
          borderColor: "green",
          borderRadius: 30,
          position: "relative",
          zIndex: 0,
          raised:true
=======
          borderColor: "#e842fa",
          borderRadius: 30,
          position: "relative",
          zIndex: 0,
          raised:true,
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
        },
      },
    },
  }
})
<<<<<<< HEAD
=======

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
const audio = new Audio(Tenderness)
audio.load()
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028

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
<<<<<<< HEAD
=======
  const [pricefeedcontract,setPriceFeedContract] = useState(null)
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028


  const [wethtoken,setWEth] = useState(null)
  const [unitoken,setUNI] = useState(null)

<<<<<<< HEAD
=======
  const [ethbalance, setEthBalance] = useState(null)
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
  const [wethbalance,setWEthBalance] = useState(null)
  const [unibalance,setUniBalance] = useState(null)
  const [processing, setProcessing] = useState(false)
  const [txHash, setTxHash] = useState(null)

  const [openSnackbar,setOpenSnackBar] = useState(false)

<<<<<<< HEAD
  const [unicolor,setUniColor] = useState('black')

  const address = useAddress();

=======
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


>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
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
    if(!dataload){
    updateEthers()
<<<<<<< HEAD
    }
  },[])

  useEffect(() => {
    // console.log("token",wethtoken)
  let tokenCheckInterval
  if(wethtoken!==null && address!==null && address !== undefined){
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
      //setting contract to approve spending amount, wEth in this case
      try{
      setErc20Contract(new ethers.Contract(smartContracts.WETHMock.address.sepolia,ABI,provider))
      setDuhContract(new ethers.Contract(smartContracts.Duh.address.sepolia,ABI,provider))
      setWEth(new ethers.Contract(smartContracts.WETHMock.address.sepolia,ABI,provider))
      setUNI(new ethers.Contract(smartContracts.UNIMock.address.sepolia,ABI,provider))
      }
      catch(err){
      console.log(err)
      }
    }
  },[provider])


  useEffect(() => {
    if(amount !== "" && token1 !== "" & token2 !=="" & interval !== "" & intervalAmount !== "") {
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
  },2000)
}
return ()=>clearTimeout(colorChange)
},[unicolor])  

  const updateEthers = async ()=>{
    let tempProvider = await new ethers.providers.Web3Provider(window.ethereum);
    setProvider(tempProvider);

    let tempSigner = await tempProvider.getSigner();
    setSigner(tempSigner);
    setDataLoad(true)

    // console.log(smartContracts.smartContracts.address.sepolia)
    // console.log(smartContracts.smartContracts.abi)

    let dollaAverageAddress = smartContracts.DollarCostAverage.address.sepolia
    let dollaAverageAbi = smartContracts.DollarCostAverage.abi
  
    let tempContract = await new ethers.Contract(dollaAverageAddress,dollaAverageAbi,tempProvider);
    setDollarCostAverageContract(tempContract);
  }

  const checkTokenBalance = async ()=>{

    if(wethtoken!==null && address !==null && address!== undefined){
    // console.log("address",address)
    var user = ethers.utils.getAddress(address)
    var wethbal= (await wethtoken.balanceOf(user)/10**18).toString();
    setWEthBalance(wethbal)
    }
    if(unitoken !==null && address !==null && address!== undefined ){
    var unibal= (await unitoken.balanceOf(user)/10**18).toString();
    setUniBalance(unibal)
    }
    //this is the if statement which controls the color change on amount increase
    if(unitoken !==null && address !==null && address!== undefined ){
    checkTokenIncrease(unibal,wethbal)
      }
  }

  const approveSpending = async()=>{
    // console.log("amount",amount)
    // console.log(erc20contract)
    try{
 

      //first contract object made from token to spend erc20contract
      await erc20contract.connect(signer).approve(smartContracts.DollarCostAverage.address.sepolia,ethers.utils.parseEther(amount))

      //this contract object must be made from the DUH token 
      await duhcontract.connect(signer).approve(smartContracts.AutomationLayer.address.sepolia,ethers.utils.parseEther(amount))
      setSpendingApproved(true)
      setDisabledTextFeild(true)
    }
    catch(err){
      console.log(err)
      setSpendingApproved(false)
    }
  }

  const submitAgreement = async () => {
    let data = {
      "user": address,
      "amount": amount,
      "token1": token1,
      "token2": token2,
      "interval": interval,
      "intervalAmount": intervalAmount,
    }
    // console.log(JSON.stringify(data))

  

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
  // console.log(JSON.stringify(tx))

  let hash = tx.hash
  setTxHash(hash.toString())
  isTransactionMined(hash.toString())
  }
  catch(err){
    setProcessing(false)
    console.log(err)
  }
}

const isTransactionMined = async (transactionHash) => {
  let transactionBlockFound = false

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
         
          setProcessing(false)
          console.log("block number assigned.")
          transactionBlockFound = true
          let stringBlock = tx.blockNumber.toString()
          console.log("COMPLETED BLOCK: " + stringBlock)
          setOpenSnackBar(true)

      }
  }
}

const handleClose = (event, reason) => {
  if (reason === 'clickaway') {
    return;
  }
  window.location.reload(false);
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

  return (
    <>
      {/* {address?console.log(address):null} */}
      <Particles
        id="particles_stuff"
        options={particlesOptions}
        init={particlesInit}
      />
    
      
      <ThemeProvider theme={theme}>
    
        {/*
      HAD TO MOVE CONNECT WALLET BUTTON INSIDE GRID OR YOU WOULDN'T BE ABLE TO CLICK IT WITH TSPARTICLES BACKGROUND FOR SOME REASON.

        CONNECT WALLET BUTTON

        <Box 
          sx={{
            marginBottom:'10px',
            marginTop:'4vh',
            zIndex: 10,
            backgroundColor: "red",
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
        */}

        <Grid container
          spacing={0}
          direction="column"
          alignItems="center"
          justify="center"
          style={{ minHeight: '100vh' }}
        >
          {/* CONNECT WALLET BUTTON */}
        <Box 
          sx={{
            marginBottom:'10px',
            marginTop:'4vh',
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

          {/* MAIN CARD */}
          <Card 
            variant="outlined"
            sx={{ 
              alignSelf:'center',
              display: 'inline-block',
              backgroundColor:theme.palette.secondary.main,
              //opacity: 0.9,
            }}
          >
            <Typography
              color='#8c42fa'
              component="h1"
              sx={{
                fontSize: 20,
                fontWeight: 700,
                padding: 2
              }}
            >
                Create Dollar Cost Average:
            </Typography>

            {/* TOTAL AMOUNT BOX FIELD */}  
            <Box
              display="flex"
              alignItems="center"
              justifyContent="center"
            >
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
                  Tokens you own
                </InputLabel>
                <Select
                  id="filled-basic"
                  label="Token1"
                  variant="filled"
                  onChange={ (e) => setToken1(e.target.value) }
                  value={token1}
                  disabled = {disableText}
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
                      onChange={ (e) => setIntervalAmount(e.target.value) }
                      id="filled-basic"
                      label="Interval spend amount"
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
                        Tokens you want
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
                  color="warning"
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
          </Card> 
          
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
              <TableContainer sx={{borderRadius:2, marginTop:'10px'}} component={Paper}>
              <Table aria-label="coin table">
                <TableHead sx={{backgroundColor:"lightyellow"}}>
                <TableRow>
                  <TableCell align="left" >ICON</TableCell>
                  <TableCell align="left" >COINS</TableCell>
                  <TableCell align="left" >WALLET AMOUNT</TableCell>
                </TableRow>
                </TableHead>
                <TableBody>
                  <TableRow>
                    <TableCell>
                      <Icon sx={{width: "50px", height: "50px", borderRadius: "50%"}}>
                        <img src={WETHicon} height="50px" width="50px"/>
                      </Icon>
                    </TableCell>
                    <TableCell><Typography>WETH</Typography></TableCell>
                    <TableCell><Typography>{wethbalance}</Typography></TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>
                      <Icon sx={{width: "50px", height: "50px", borderRadius: "50%"}}>
                        <img src={UNIicon} width="50px" height="50px"/>
                      </Icon>
                    </TableCell>
                  <TableCell><Typography>UNI</Typography></TableCell>
                  <TableCell><Typography color={unicolor}>{unibalance}</Typography></TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </TableContainer> 
            </Box>
          </>:null
          }
      
=======
    }
    
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
    checkAllowance()
  },[address,wethbalance])

  useEffect(()=>{
    let balanceCheck
    if(signer && erc20contract && address){
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
    // console.log("token",wethtoken)
  let tokenCheckInterval
  if(wethtoken!==null && address!==null && address !== undefined){
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
      //setting contract to approve spending amount, wEth in this case
      try{


//price feed contract object is made below
      setPriceFeedContract(new ethers.Contract(smartContracts.PriceFeed.address.sepolia.ETHUSD,PriceFeedABI.sepolia,provider))  

//core contract objects for dollar cost averaging made below
      setErc20Contract(new ethers.Contract(smartContracts.WETHMock.address.sepolia,ABI,provider))
      setDuhContract(new ethers.Contract(smartContracts.Duh.address.sepolia,ABI,provider))
      setWEth(new ethers.Contract(smartContracts.WETHMock.address.sepolia,ABI,provider))
      setUNI(new ethers.Contract(smartContracts.UNIMock.address.sepolia,ABI,provider))
      }
      catch(err){
      console.log(err)
      }
    }
  },[provider])



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
  },2000)
}
return ()=>clearTimeout(colorChange)
},[unicolor])  

  const updateEthers = async ()=>{
    let tempProvider = await new ethers.providers.Web3Provider(window.ethereum);
    setProvider(tempProvider);

    let tempSigner = await tempProvider.getSigner();
    setSigner(tempSigner);
    setDataLoad(true)

    let dollaAverageAddress = smartContracts.DollarCostAverage.address.sepolia
    let dollaAverageAbi = smartContracts.DollarCostAverage.abi
  
    let tempContract = await new ethers.Contract(dollaAverageAddress,dollaAverageAbi,tempProvider);
    setDollarCostAverageContract(tempContract);
  }

  const checkTokenBalance = async ()=>{

    if(provider !== null && address !== null && address !== undefined){
      const ethbal = await provider.getBalance(address);
      let valueToNumber = parseFloat(ethbal.toString())
      let valueConverted = valueToNumber/10**18
      setEthBalance(valueConverted)
    }

    if(wethtoken!==null && address !==null && address!== undefined){
    // console.log("address",address)
    var user = ethers.utils.getAddress(address)
    var wethbal= (await wethtoken.balanceOf(user)/10**18).toString();
    setWEthBalance(wethbal)
    }
    if(unitoken !==null && address !==null && address!== undefined ){
    var unibal= (await unitoken.balanceOf(user)/10**18).toString();
    setUniBalance(unibal)
    }
    //this is the if statement which controls the color change on amount increase
    if(unitoken !==null && address !==null && address!== undefined ){
    checkTokenIncrease(unibal,wethbal)
      }
  }

  const checkAllowance = async ()=>{
 
 if(address && erc20contract){

    let allowanceAmount = await erc20contract.allowance(address,smartContracts.DollarCostAverage.address.sepolia)
    let convertedAllowance = parseFloat(allowanceAmount.toString())/10**18

    setAllowance(convertedAllowance)
   
    return convertedAllowance
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
    }
    catch(err){
      console.log(err)
      setSpendingApproved(false)
    }
   
  }

  const updateAllowance = ()=>{
    setSpendingApproved(false)
    setDisabledTextFeild(false)
    setDelayRender(true)
  }

  const submitAgreement = async () => {
  
    let data = {
      "user": address,
      "amount": amount,
      "token1": token1,
      "token2": token2,
      "interval": interval,
      "intervalAmount": intervalAmount,
    }
 
  

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
  }
  catch(err){
    setProcessing(false)
    console.log(err)
  }
}

const isTransactionMined = async (transactionHash) => {
  let transactionBlockFound = false

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
         
          setProcessing(false)
          console.log("block number assigned.")
          transactionBlockFound = true
          let stringBlock = tx.blockNumber.toString()
          console.log("COMPLETED BLOCK: " + stringBlock)
          setOpenSnackBar(true)

      }
  }
}

const handleClose = (event, reason) => {
  if (reason === 'clickaway') {
    return;
  }
  window.location.reload(false);
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
  console.log(thresholdETHtransaction)
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
  console.log("Icon click")
  // handleModalOpen()
  const dater = new EthDater(
    provider // Ethers provider, required.
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
    console.log(typeof(convertDate))
    dataFrame["date"] = convertDate.getMonth() + "/"+ convertDate.getDate()
    dataFrame["amount"] = tokenQuantityBlocks[blocks.indexOf(element)]
    tokenChangeData.push(dataFrame)
    if(counter==9){
      console.log("TOKEN CHANGE",tokenChangeData)
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
  console.log(blocks)
  getTokenQuantityPerBlock(unitoken,blocks)
}
},[blocks])

function getTokenQuantityPerBlock(token,blocks){
let items = []
let counter = 0
blocks.forEach((item)=>{
  token.balanceOf(address,{blockTag:item.block}).then((res)=>{
    console.log(`index: ${blocks.indexOf(item)}:`,parseFloat(res.toString())/10**18)
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
  console.log("blocks",blocks)
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
      {/* {address?console.log(address):null} */}
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

      <Modal
        open={open}
        onClose={handleClose}
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
          {/* CONNECT WALLET BUTTON */}
          <Slide direction="down" in={true} mountOnEnter>
            <Box 
              sx={{
                marginBottom:'10px',
                marginTop:'4vh',
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
              alignSelf:'center',
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
      
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
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
<<<<<<< HEAD

        <UserRecurringBuys signer={signer} contract={dollarCostAverageContract} provider={provider} address={address}/>
       
=======
        <Box >
        <FormControlLabel 
        sx={{color:'#e000f8'}}
        control={<Switch checked={checked} onChange={handleChange} />}
        label="Display User Agreements"
      />
        </Box>
     
      <Zoom in={checked}>
      <Box>
      <UserRecurringBuys signer={signer} contract={dollarCostAverageContract} provider={provider} address={address}/> 
      </Box>
       </Zoom>
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
       
        </Grid>      
      </ThemeProvider>
    </>
  );
}

export default App;
