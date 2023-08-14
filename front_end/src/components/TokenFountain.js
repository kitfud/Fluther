import React from 'react'
import { useState,useEffect } from 'react'
import {
  Card,
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
  const [amountError,setAmountError] = useState(false)

  const handleTokenRequestCheck= (e)=>{

    const reg = new RegExp(/^[0-9]+([.][0-9]+)?$/);
    const emptyString = new RegExp(/^$/);
  
    //check to make sure only number passes and also not empty strings
  
    if(reg.test(e.target.value) || emptyString.test(e.target.value)){ 
      setAmountError(false)
      setAmount(e.target.value)
    }
    else{
      setAmount("")
      setAmountError(true)
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
      <Button
        color="secondary"
        size="small"
        onClick={handleClose}
      >
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
      try{
        await tx.blockNumber
      }
       catch(error){
        tx = await provider.getTransactionReceipt(transactionHash)
      }
      finally{
        console.log("proceeding")
      }
  
      if(tx && tx.blockNumber){
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
    }
    catch (error) {
      console.log(error);
    }
  }

  const addUNITokenMetaMask = async ()=>{
    const tokenAddress = '0x6e4c13eD298b5Fcac70dc0F672f75aAeCca52768';
    const tokenSymbol = 'UNI';
    const tokenDecimals = 18;
    const tokenImage = 'https://img.freepik.com/premium-vector/uniswap-uni-token-symbol-cryptocurrency-logo-coin-icon-isolated-white-background-vector-illustration_337410-888.jpg?w=2000';
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
      }
      else {
      console.log('Your loss!');
      }
    }
    catch (error) {
      console.log(error);
    }
  }

  return (
    <>
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
            height:'550px',
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
            justifyContent="center"
          >
            Get Mock WETH Token For Testing
          </Typography>
          <Box>
            <TextField
              sx={{
                width: "100%"
              }}
              error = {amountError}
              helperText={amountError?'only number or decimal values':''}
              onChange={(e) => handleTokenRequestCheck(e) }
              label="Request amount (WETH)"
              variant="filled"
            />
            <Box
              display="flex"
              alignItems="center"
              justifyContent="center"
              component="div"
            >
              {
                !processing
                ?
                  !amountError
                  ?
                    <Button
                      sx={{
                        marginTop:'5px',
                        marginBottom:'10px'
                      }}
                      display='flex'
                      variant="contained"
                      onClick={handleRequestAmount}>Request Test WETH
                    </Button>
                  :
                    null
                :
                  <CircularProgress
                    sx={{
                      marginTop:'5px',
                      marginBottom:'10px'
                    }}
                  />
              }
            </Box>
       
            <Divider sx={{marginBottom:'10px'}}/>
            {
              window.ethereum.isMetaMask
              ?
                <>
                  <Box
                    display="flex"
                    alignItems="center"
                    justifyContent="center"
                  >
                    <Card 
                      display="flex"
                      sx={{
                        width:'95%',
                        borderRadius:0
                      }}
                    >
                      <Typography 
                        fontSize={18}
                        display="flex"
                        alignItems="left"
                        component={'h1'}
                      >
                        Name: fluther Test WETH
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
                        Address:
                        <Link
                          target="_blank"
                          href="https://sepolia.etherscan.io/address/0x87FF5ccd14Dc002903E5B274C0E569c7a215e5A1#code"
                        >
                          0x87FF5ccd14Dc002903E5B274C0E569c7a215e5A1
                        </Link>
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
                    <Button
                      onClick={addTokenMetaMask}
                      variant="contained"
                      color="success"
                    >
                      Add WETH Token To MetaMask
                    </Button>
                  </Box>
                </>
              :
                null
            }
          </Box>

          <Divider sx={{marginBottom:'10px',marginTop:'10px'}}/>
          {
            window.ethereum.isMetaMask
            ?
              <>
                <Box
                  display="flex"
                  alignItems="center"
                  justifyContent="center"
                >
                  <Card 
                    display="flex"
                    sx={{
                      width:'95%',
                      borderRadius:0
                    }}
                  >
                    <Typography 
                      fontSize={18}
                      display="flex"
                      alignItems="left"
                      component={'h1'}
                    >
                      Name: fluther Test UNI
                    </Typography>
                    <Typography 
                      fontSize={18}
                      display="flex"
                      alignItems="left"
                      component={'h1'}
                    >
                      Symbol: UNI
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
                      Address:
                      <Link
                        target="_blank"
                        href="https://sepolia.etherscan.io/address/0x6e4c13eD298b5Fcac70dc0F672f75aAeCca52768#code"
                      >
                          0x6e4c13eD298b5Fcac70dc0F672f75aAeCca52768
                      </Link>
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
                  <Button
                    onClick={addUNITokenMetaMask}
                    variant="contained"
                    color="warning"
                  >
                    Add UNI Token To MetaMask
                  </Button>
                </Box>
              </>
            :
              null
          }
        </Card>
        <Snackbar
          anchorOrigin={{
            vertical: 'bottom',
            horizontal: 'center'
          }}
          open={openSnackbar}
          autoHideDuration={3000}
          onClose={handleClose}
          message=""
          action={action}
          sx={{
            backgroundColor:"white"
          }}
        >
          <a target="_blank" href={`https://sepolia.etherscan.io/tx/${txHash}`}>
            <Typography color="black">
              Success! Click for Transaction:${txHash} on Etherscan
            </Typography>
          </a>
        </Snackbar>
      </Grid>
    </>
  )
}

export default TokenFountain