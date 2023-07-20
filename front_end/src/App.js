import React, { useEffect, useState } from 'react'
import './App.css';
import { ConnectWallet } from "@thirdweb-dev/react";
import { useAddress } from "@thirdweb-dev/react";
import { ThemeProvider, createTheme } from '@mui/material';
import { Grid, Box, TextField, Typography, Card, Button, InputLabel, MenuItem, FormControl, Select } from "@mui/material";

const theme = createTheme({
  palette: {
    primary: {
      main: '#ece115',
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
    }
  }
})

function App() {
  const [amount, setAmount] = useState("")
  const [token1,setToken1] = useState("")
  const [token2,setToken2] = useState("")
  const [interval, setInterval] = useState("")

  const [contractParamsSet, setContractParams] = useState(false)
  const [userAddress,setUserAddress] = useState(null)

  const address = useAddress();
  

  useEffect( () => {
    if(amount!== "" && token1!== "" & token2!=="" & interval !=="") {
      setContractParams(true)
    }
    else {
      setContractParams(false)
    }
  },[amount,token1,token2,interval])

  const submitAgreement = () => {
    let data = {
      "user": address,
      "amount": amount,
      "token1": token1,
      "token2": token2,
      "interval": interval
    }
    console.log(JSON.stringify(data))
  }

  return (
    <>
      {/* {address?console.log(address):null} */}

      <ThemeProvider theme={theme}>

        {/* CONNECT WALLET BUTTON */}
        <Box sx={{marginBottom:'10px', marginTop:'4vh'}} display="flex" alignItems="center" justifyContent="center">
          <ConnectWallet
            dropdownPosition={{
              side: "top",
              align: "center",
            }}
          />
        </Box>
        
        <Grid   container
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
              backgroundColor:theme.palette.secondary.main
            }}
          >
            <Typography color="#1f25e2" component="h1" sx={{
               fontSize: 20,
               fontWeight: 700,
               padding: 2
              }}>
                Create Dollar Cost Average:
            </Typography>

            {/* AMOUNT BOX FIELD */}  
            <Box display="flex" alignItems="center" justifyContent="center">
              <TextField
                onChange={ (e) => setAmount(e.target.value) }
                id="filled-basic"
                label="Amount"
                variant="filled"
              >
              </TextField>
            </Box>

            {/* TOKEN 1 BOX FIELD */}
            <Box display="flex" alignItems="center" justifyContent="center">
              <TextField
                onChange={ (e) => setToken1(e.target.value) }
                id="filled-basic"
                label="Token1"
                variant="filled"
              >
              </TextField>
            </Box>

            {/* TOKEN 2 BOX FIELD */}
            <Box display="flex" alignItems="center" justifyContent="center">
              <TextField
                onChange={ (e) => setToken2(e.target.value) }
                id="filled-basic"
                label="Token2"
                variant="filled"
              >
              </TextField>
            </Box> 

            {/* TIME INTERVAL BOX FIELD */}
            <Box display="flex" alignItems="center" justifyContent="center" >
              <FormControl fullWidth>
                <InputLabel id="demo-simple-select-label">
                  Hours
                </InputLabel>
                <Select
                  id="filled-basic"
                  label="Time frequency"
                  variant="filled"
                  onChange={ (e) => setInterval(e.target.value) }
                >
                  {/* WILL FIGURE OUT A BETTER WAY TO DO THIS PART LATER */}
                  <MenuItem value={1}>1</MenuItem>
                  <MenuItem value={2}>2</MenuItem>
                  <MenuItem value={3}>3</MenuItem>
                  <MenuItem value={4}>4</MenuItem>
                  <MenuItem value={5}>5</MenuItem>
                  <MenuItem value={6}>6</MenuItem>
                  <MenuItem value={7}>7</MenuItem>
                  <MenuItem value={8}>8</MenuItem>
                  <MenuItem value={9}>9</MenuItem>
                  <MenuItem value={10}>10</MenuItem>
                  <MenuItem value={11}>11</MenuItem>
                  <MenuItem value={12}>12</MenuItem>
                  <MenuItem value={13}>13</MenuItem>
                  <MenuItem value={14}>14</MenuItem>
                  <MenuItem value={15}>15</MenuItem>
                  <MenuItem value={16}>16</MenuItem>
                  <MenuItem value={17}>17</MenuItem>
                  <MenuItem value={18}>18</MenuItem>
                  <MenuItem value={19}>19</MenuItem>
                  <MenuItem value={20}>20</MenuItem>
                  <MenuItem value={21}>21</MenuItem>
                  <MenuItem value={22}>22</MenuItem>
                  <MenuItem value={23}>23</MenuItem>
                  <MenuItem value={24}>24</MenuItem>
                </Select>

              </FormControl>
              {/* 
              <TextField onChange={(e)=> setInterval(e.target.value)} id="filled-basic" label="Time Interval (sec)" variant="filled" >
              </TextField>
            */}
            </Box> 

            {/* "SUBMIT AGREEMENT" BUTTON LOGIC
                  IF USER SUBMITTED ALL INFO
                    SHOW SUBMIT AGREEMENT BUTTON
            */}
            { contractParamsSet
              ?
              <Box sx={{marginTop:'20px',marginBottom:"20px"}} display="flex" alignItems="center" justifyContent="center">
                <Button onClick={submitAgreement} variant="contained" color="warning">
                  Submit Agreement
                </Button>
              </Box>
              :
              <Box sx={{marginTop:'20px',marginBottom:"20px"}}>
              </Box>
            }    

          </Card> 
        </Grid>
      
      </ThemeProvider>
    </>
  );
}

export default App;
