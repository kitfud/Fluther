import React, {useEffect, useState} from 'react'
import './App.css';
import { ConnectWallet } from "@thirdweb-dev/react";
import { useAddress } from "@thirdweb-dev/react";
import { ThemeProvider,createTheme } from '@mui/material';
import {Grid,Box, TextField, Typography, Card, Button} from "@mui/material"


function App() {
  const [amount, setAmount] = useState("")
  const [token1,setToken1] = useState("")
  const [token2,setToken2] = useState("")
  const [interval, setInterval] = useState("")

  const [contractParamsSet, setContractParams] = useState(false)
  const [userAddress,setUserAddress] = useState(null)

  const address = useAddress();
  const theme = createTheme({
    palette:{
      mode:"dark"
    }
  })

useEffect(()=>{
if(amount!== "" && token1!== "" & token2!=="" & interval !=="")
{
  setContractParams(true)
}
else{
  setContractParams(false)
}
},[amount,token1,token2,interval])

const submitAgreement =()=>{
let data = {"user":address,"amount":amount,"token1":token1,"token2":token2,"interval":interval}
console.log(JSON.stringify(data))
}

  return (
<>
{/* {address?console.log(address):null} */}

<ThemeProvider theme={theme}>
  <Box sx={{marginBottom:'10px', marginTop:'10px'}} display="flex" alignItems="center" justifyContent="center">
  <ConnectWallet
              dropdownPosition={{
                side: "top",
                align: "center",
              }}/>
  </Box>
  
  <Grid   container
  spacing={0}
  direction="column"
  alignItems="center"
  justify="center"
  style={{ minHeight: '100vh' }}>
  <Card variant="outlined" sx={{ alignSelf:'center',display: 'inline-block', backgroundColor: "gray" }}>
  <Typography color="primary" component="h1" sx={{ fontSize: 20, fontWeight: 600, padding: 2}}>Create Dollar Cost Average:</Typography>

  
<Box display="flex" alignItems="center" justifyContent="center">
<TextField onChange={(e)=> setAmount(e.target.value)} id="filled-basic" label="Amount" variant="filled" ></TextField>
</Box> 

<Box display="flex" alignItems="center" justifyContent="center">
<TextField onChange={(e)=> setToken1(e.target.value)} id="filled-basic" label="Token1" variant="filled" ></TextField>
</Box> 

<Box display="flex" alignItems="center" justifyContent="center">
<TextField onChange={(e)=> setToken2(e.target.value)} id="filled-basic" label="Token2" variant="filled" ></TextField>
</Box> 

<Box display="flex" alignItems="center" justifyContent="center" >
<TextField onChange={(e)=> setInterval(e.target.value)} id="filled-basic" label="Time Interval (sec)" variant="filled" ></TextField>
</Box> 

{ contractParamsSet?
<Box sx={{marginTop:'20px',marginBottom:"20px"}} display="flex" alignItems="center" justifyContent="center">
<Button onClick={submitAgreement} variant="contained" color="warning">Submit Agreement</Button>
</Box>  : <Box sx={{marginTop:'20px',marginBottom:"20px"}}></Box>
}    
  </Card> 
  </Grid>
  
</ThemeProvider>
</>
      
  );
}

export default App;
