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
    Divider,
    Link
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

const addTokenMetaMask = async ()=>{
const tokenAddress = '0x87FF5ccd14Dc002903E5B274C0E569c7a215e5A1';
const tokenSymbol = 'WETH';
const tokenDecimals = 18;
const tokenImage = 'https://raw.githubusercontent.com/dappradar/tokens/main/ethereum/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2/logo.png';
try {
  // 'wasAdded' is a boolean. Like any RPC method, an error can be thrown.
  const wasAdded = await window.ethereum.request({
    method: 'wallet_watchAsset',
    params: {
      type: 'ERC20',
      options: {
        address: tokenAddress, // The address of the token.
        symbol: tokenSymbol, // A ticker symbol or shorthand, up to 5 characters.
        decimals: tokenDecimals, // The number of decimals in the token.
        image: tokenImage, // A string URL of the token logo.
      },
    },
  });

  if (wasAdded) {
    console.log('Thanks for your interest!');
  } else {
    console.log('Your loss!');
  }
} catch (error) {
  console.log(error);
}
}


  return (
<Grid
container
spacing={0}
direction="column"
alignItems="center"
justify="center"


>

 <Card
    variant="outlined"
    sx={{ 
      display: 'inline-block',
      position:'absolute',
      backgroundColor:theme.palette.secondary.main,
      borderRadius:1,
      width:'550px',
      height:'370px',
      right:'15%'
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
       
     <Divider sx={{marginBottom:'10px'}}/>


<Box
              display="flex"
              alignItems="center"
              justifyContent="center"
            >
<Card 
display="flex"

sx={{width:'95%',borderRadius:0}}>

<Typography 
fontSize={18}
display="flex"
alignItems="left"
component={'h1'}
>
  Name: Fluther Test WETH
</Typography>
<Typography 
fontSize={18}
display="flex"
alignItems="left"
component={'h1'}
>
  Symbol: WETH
</Typography>

<Typography 
fontSize={18}
display="flex"
alignItems="left"
component={'h1'}
>
  Decimals: 18
</Typography>

<Typography 
fontSize={18}
display="flex"
alignItems="left"
component={'h1'}
>
  Address: <Link target="_blank" href="https://sepolia.etherscan.io/address/0x87FF5ccd14Dc002903E5B274C0E569c7a215e5A1#code"> 0x87FF5ccd14Dc002903E5B274C0E569c7a215e5A1 </Link>
</Typography>
</Card>
 </Box>

    
    <Box
    display="flex"
    alignItems="center"
    justifyContent="center"
    component="div"
    marginTop="20px"
    >
    <Button onClick={addTokenMetaMask} variant="contained" color="success">Add Token To MetaMask</Button>

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