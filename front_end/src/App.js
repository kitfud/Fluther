import React, { useEffect, useState } from 'react'
import './App.css';
import { ConnectWallet } from "@thirdweb-dev/react";
import { useAddress } from "@thirdweb-dev/react";
import { ThemeProvider, createTheme } from '@mui/material';
import {Snackbar,CircularProgress, Grid, Box, TextField, Typography, Card, Button, InputLabel, MenuItem, FormControl, Select } from "@mui/material";

import ABI from './chain-info/erc20ABI.json'
import ERC20Address from './chain-info/erc20Address.json'
import DollarCostAverage from './chain-info/smart_contracts.json'
import {ethers} from 'ethers'

import IconButton from '@mui/material/IconButton';
import CloseIcon from '@mui/icons-material/Close';
import UserRecurringBuys from './components/UserRecurringBuys';

const theme = createTheme({
  palette: {
    primary: {
      main: '#af0079',
      //previously yellow #ece115
    },
    secondary: {
      main: '#15ece1',
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


  const [wethtoken,setWEth] = useState(null)
  const [unitoken,setUNI] = useState(null)

  const [wethbalance,setWEthBalance] = useState(null)
  const [unibalance,setUniBalance] = useState(null)
  const [processing, setProcessing] = useState(false)
  const [txHash, setTxHash] = useState(null)

  const [openSnackbar,setOpenSnackBar] = useState(false)

  const address = useAddress();

  //address below is deployment to Polygon mainnet
  const dollarCostAddress = '0x519DdbffEA597980B19F254892dEc703613e8775'

  //address below is for Polygon mainnet
  //const quickSwapRouterAddress = '0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff'

  //address below is for testing on Sepolia testnet
  const quickSwapRouterAddress = '0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008'
  const [dataload,setDataLoad] = useState(false)
  useEffect(() => {
    if(!dataload){
    updateEthers()
    }
  },[])

  useEffect(() => {
    // console.log("token",wethtoken)
  if(wethtoken!==null && address!==null && address !== undefined){
    try{
    checkTokenBalance()
    }
    catch(err){
      console.log(err)
    }
  }
  
  },[wethtoken,address])



  useEffect(() => {
    if(provider !== null){
      //setting contract to approve spending amount, wEth in this case
      try{
      setErc20Contract(new ethers.Contract(ERC20Address.wEthSepolia,ABI,provider))
      setWEth(new ethers.Contract(ERC20Address.wEthSepolia,ABI,provider))
      setUNI(new ethers.Contract(ERC20Address.UNI,ABI,provider))
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


  const updateEthers = async ()=>{
    let tempProvider = await new ethers.providers.Web3Provider(window.ethereum);
    setProvider(tempProvider);

    let tempSigner = await tempProvider.getSigner();
    setSigner(tempSigner);
    setDataLoad(true)

    // console.log(DollarCostAverage.DollarCostAverage.address.sepolia)
    // console.log(DollarCostAverage.DollarCostAverage.abi)

    let dollaAverageAddress = DollarCostAverage.DollarCostAverage.address.sepolia
    let dollaAverageAbi = DollarCostAverage.DollarCostAverage.abi
  
    //lines below prepped for direct contract interaction [en future]....
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
  }

  const approveSpending = async()=>{
    // console.log("amount",amount)
    // console.log(erc20contract)
    try{
      await erc20contract.connect(signer).approve(quickSwapRouterAddress,parseInt(amount))
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
    console.log(JSON.stringify(data))

  try{
  setProcessing(true)
  let tx = await dollarCostAverageContract.connect(signer).createRecurringBuy(amount,token1,token2,interval,'0x0000000000000000000000000000000000000000',quickSwapRouterAddress)
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

      <ThemeProvider theme={theme}>

        {/* CONNECT WALLET BUTTON */}
        <Box 
          sx={{
            marginBottom:'10px',
            marginTop:'4vh'
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
        
        <Grid container
          spacing={0}
          direction="column"
          alignItems="center"
          justify="center"
          style={{ minHeight: '100vh' }}
        >

          {/* MAIN CARD */}
          <Card 
            variant="outlined"
            sx={{ 
              alignSelf:'center',
              display: 'inline-block',
              backgroundColor:theme.palette.secondary.main,
              opacity: 0.9,
            }}
          >
            <Typography
              color="#af0079"
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
                  width: "80%"
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
                >
                  {/* WILL FIGURE OUT A BETTER WAY TO DO THIS PART LATER */}
                  <MenuItem   value= {ERC20Address.wEthSepolia} >WETH Sepolia</MenuItem>
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
                      label="Interval purchase amount"
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
                        {/* WILL FIGURE OUT A BETTER WAY TO DO THIS PART LATER */}
            
                        <MenuItem value= {ERC20Address.UNI} >UNI</MenuItem>
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
              :
              null
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
          <Box
            sx={{
              backgroundColor:'#15ece1',
              marginTop:"20px",
              display:"flex",
              justifyContent:"center",
              border: "8px solid #15ece1",
              borderRadius: 2,
              width:"20%",
            }}
          >
            <Box
              sx={{
                //COINS section
                minWidth:"40%",
                display:"flex",
                flexDirection:"column",
                justifyContent:"center",

            
              }}
            >
              
              <Typography sx={{backgroundColor:"#af0079", display:"flex", justifyContent:"center"}}>COINS</Typography>
              <Typography sx={{backgroundColor:"darkgrey", borderTop: "3px solid #999999", display: "flex", justifyContent:"center",}}>wETH</Typography>
              <Typography sx={{backgroundColor:"darkgrey", borderTop: "3px solid #999999", display: "flex", justifyContent:"center",}}>UNI</Typography>
            </Box>

            <Box 
              sx={{
                //WALLET AMOUNT section
                minWidth:"60%",
                display:"flex",
                flexDirection:"column",
                justifyContent:"center",
              
              }}
            >
              <Typography sx={{backgroundColor:"#af0079", display:"flex", justifyContent:"center", borderLeft:"5px solid #960369"}}>WALLET AMOUNT</Typography>
              <Typography sx={{backgroundColor:"darkgrey", display:"flex", justifyContent:"center", borderTop: "3px solid #999999", borderLeft: "5px solid #999999"}}>{wethbalance}</Typography>
              <Typography sx={{backgroundColor:"darkgrey", display:"flex", justifyContent:"center", borderTop: "3px solid #999999", borderLeft: "5px solid #999999"}}>{unibalance}</Typography>
            </Box>
          
          </Box>:null
          }
      
      <Snackbar
        anchorOrigin={{vertical: 'bottom', horizontal: 'center'}}
        open={openSnackbar}
        autoHideDuration={6000}
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
