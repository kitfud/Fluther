import React from 'react'
import {useState,useEffect} from 'react'
import {Card,
    Typography,
    Box,
    TextField,
    CircularProgress,
    Button,
    Grid,
    Snackbar,
} from '@mui/material'

import IconButton from '@mui/material/IconButton';
import CloseIcon from '@mui/icons-material/Close';

import { ethers } from 'ethers'

const TokenFountain = ({theme,contract,address,signer,provider}) => {

const [amount, setAmount] = useState(null)
const [processing, setProcessing] = useState(false)
const [txHash, setTxHash] = useState(null)
const [openSnackbar,setOpenSnackBar] = useState(false)

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

const handleRequestAmount = async()=>{
setProcessing(true)
let adjustedAmount = ethers.utils.parseEther(amount)
let submitAmount = adjustedAmount.toString()

if(address && contract){
console.log(contract)

try{
 const tx = await contract.connect(signer).mint(address,submitAmount)
 let hash = tx.hash
 setTxHash(hash.toString())
 isTransactionMined(hash.toString())
 }
 catch(err){
   setProcessing(false)
   console.log(err)
 }
}
}


  return (
<Grid
container
spacing={0}
direction="column"
alignItems="center"
justify="center"
style={{ minHeight: '100vh' }}
>

 <Card
    variant="outlined"
    sx={{ 
      alignSelf:'center',
      display: 'inline-block',
      backgroundColor:theme.palette.secondary.main,
      borderRadius:1,
      width:'400px',
      right:'20%'
    }}
    >
    <Typography 
    color= '#5d00d4'
    component="h1"
    sx={{
      fontSize: 15,
      fontWeight: 700,
      padding: 2
    }}
    display="flex"
    alignItems="center"
    justifyContent="center">Get Mock WETH Token For Testing</Typography>
    <Box >
        <TextField
         sx={{
            width: "100%"
          }}
          onChange={(e) => setAmount(e.target.value) }
          label="Request amount (WETH)"
          variant="filled"
        ></TextField>
     
     <Box display="flex"
        alignItems="center"
        justifyContent="center"
        component="div">
{
    !processing?
     <Button
        sx={{marginTop:'5px',marginBottom:'10px'}}
        display='flex'
        variant="contained"
        onClick={handleRequestAmount}>Request Test WETH
        </Button>:<CircularProgress sx={{marginTop:'5px',marginBottom:'10px'}}/>
}
     </Box>
       
        
      
    </Box>

    </Card>
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
    </Grid>
   

  )
}

export default TokenFountain