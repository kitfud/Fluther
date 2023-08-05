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
  InputLabel, MenuItem, FormControl, Select,TableContainer,Table,TableHead,TableRow,TableCell,TableBody, Icon} from "@mui/material";

import ABI from './chain-info/erc20ABI.json'
import ERC20Address from './chain-info/smart_contracts.json'
import smartContracts from './chain-info/smart_contracts.json'
import {ethers} from 'ethers'

import IconButton from '@mui/material/IconButton';
import CloseIcon from '@mui/icons-material/Close';
import UserRecurringBuys from './components/UserRecurringBuys';
import WETHicon from './img/wETH.png'
import UNIicon from './img/UNIicon.jpg'

import Particles from "react-particles"
import { loadFull } from "tsparticles";
import particlesOptions from "./particlesConfig.json";
import zIndex from '@mui/material/styles/zIndex';

const theme = createTheme({
  palette: {
    primary: {
      main: '#ec1520',
      //previously yellow #ece115
    },
    secondary: {
      main:'#42fae8'
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
          backgroundColor: 'teal',
        },
      },
      inputProps:{
          style:{color:"red"}  
      }
    },
    MuiFormControl: {
      styleOverrides: {
        root: {
          backgroundColor: 'teal'
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        // Name of the slot
        root: {
          // Some CSS
          borderColor: "green",
          borderRadius: 30,
          position: "relative",
          zIndex: 0,
          raised:true
        },
      },
    },
  }
})

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


  const [wethtoken,setWEth] = useState(null)
  const [unitoken,setUNI] = useState(null)

  const [wethbalance,setWEthBalance] = useState(null)
  const [unibalance,setUniBalance] = useState(null)
  const [processing, setProcessing] = useState(false)
  const [txHash, setTxHash] = useState(null)

  const [openSnackbar,setOpenSnackBar] = useState(false)

  const [unicolor,setUniColor] = useState('black')

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
    if(!dataload){
    updateEthers()
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

        <UserRecurringBuys signer={signer} contract={dollarCostAverageContract} provider={provider} address={address}/>
       
       
        </Grid>      
      </ThemeProvider>
    </>
  );
}

export default App;
