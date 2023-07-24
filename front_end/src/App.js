import React, { useEffect, useState } from 'react'
import './App.css';
import { ConnectWallet } from "@thirdweb-dev/react";
import { useAddress } from "@thirdweb-dev/react";
import { ThemeProvider, createTheme } from '@mui/material';
import { Grid, Box, TextField, Typography, Card, Button, InputLabel, MenuItem, FormControl, Select } from "@mui/material";

import ABI from './chain-info/erc20ABI.json'
import ERC20Address from './chain-info/erc20Address.json'
import {ethers} from 'ethers'

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
  //const [dollarCostContract,setDollarCostContract] = useState(null)
  const [disableText, setDisabledTextFeild] = useState(false)


  const [wethtoken,setWEth] = useState(null)
  const [unitoken,setUNI] = useState(null)

  const [wethbalance,setWEthBalance] = useState(null)
  const [unibalance,setUniBalance] = useState(null)

  const address = useAddress();

  //address below is deployment to Polygon mainnet
  const dollarCostAddress = '0x519DdbffEA597980B19F254892dEc703613e8775'

  //address below is for Polygon mainnet
  //const quickSwapRouterAddress = '0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff'

  //address below is for testing on Sepolia testnet
  const quickSwapRouterAddress = ethers.utils.getAddress('0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008')
  const [dataload,setDataLoad] = useState(false)
  useEffect(() => {
    if(!dataload){
    updateEthers()
    }
  },[])

  useEffect(() => {
  if(wethtoken!==null && unitoken!==null){
    try{
    checkTokenBalance()
    }
    catch(err){
      console.log(err)
    }
  }
  
  },[wethtoken,unitoken])

  useEffect(() => {
    if(provider !== null){
      //setting contract to approve spending amount, wEth in this case
      try{
      setErc20Contract(new ethers.Contract(ERC20Address.wEthSepolia,ABI,provider))
      }
      catch(err){
console.log(err)
      }
      try{
      console.log(ERC20Address.wEthSepolia)
      let wethcontr = new ethers.Contract(ERC20Address.wEthSepolia,ABI,provider)
      setWEth(wethcontr)
      }
      catch(err){
        console.log(err)
      }
      try{
      console.log(ERC20Address.UNI)
      let unicontr = new ethers.Contract(ERC20Address.UNI,ABI,provider)
      setUNI(unicontr)
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

    //checkTokenBalance()
    //lines below prepped for direct contract interaction [en future]....
    // let tempContract = await new ethers.Contract(address,abi, tempProvider);
    // setDollarCostContract(tempContract);
  }

  const checkTokenBalance = async ()=>{

    if(wethtoken){
    var user = ethers.utils.getAddress(address)
    var wethbal= (await wethtoken.balanceOf(user)/10**18).toString();
    setWEthBalance(wethbal)
    }
    if(unitoken){
    var unibal= (await unitoken.balanceOf(user)/10**18).toString();
    setUniBalance(unibal)
    }
  }

  const approveSpending = async()=>{
    console.log("amount",amount)
    console.log(erc20contract)
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

  const submitAgreement = () => {
    let data = {
      "user": address,
      "amount": amount,
      "token1": token1,
      "token2": token2,
      "interval": interval,
      "intervalAmount": intervalAmount,
    }
    console.log(JSON.stringify(data))
  }

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
                >
                  {/* WILL FIGURE OUT A BETTER WAY TO DO THIS PART LATER */}
                  <MenuItem value= {ERC20Address.wEthSepolia} >WETH Sepolia</MenuItem>
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
                        <MenuItem value= {ERC20Address.wEthSepolia} >WETH Sepolia</MenuItem>
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
          wethbalance!==null && unibalance !== null?
          <Box sx={{backgroundColor:'white',marginTop:"20px"}}>
          <Typography>wETH:${wethbalance}</Typography>
          <Typography>UNI:${unibalance}</Typography>
          </Box>:null
          }
        </Grid>
        
          
       
        
      </ThemeProvider>
    </>
  );
}

export default App;
