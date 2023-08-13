import React from 'react'
import { useState,useEffect } from 'react';
import { Button, Box, Typography, Card } from '@mui/material';
import {ethers} from 'ethers'

const TestNetPrompt = () => {


const switchNetwork = (event)=>{
try{
  changeChainID()
}
catch(err){
console.log("REQUEST REJECTED")
return
}
}



const changeChainID = async ()=>{

    try {
        await window.ethereum.request({
            method: "wallet_switchEthereumChain",
            params: [{
                chainId: "0xaa36a7"
            }]
        });
      console.log("You have succefully switched to Sepolia Test network")
      } catch (switchError) {
        // This error code indicates that the chain has not been added to MetaMask.
        if (switchError.code === 4902) {
         console.log("This network is not available in your metamask, please add it")
        }
        //error indicates that user rejected transaction
        else if(switchError.code === 4001){
         console.log("USER REJECTED CONNECTION")
         window.location.reload()
        }
        console.log("Failed to switch to the network" + switchError.code)
      }
}


  return (
    <>
      <Box height="100vh"
        sx={{
          zIndex:1,
          display:"flex",
          flexDirection:"column",
          alignItems:"center",
          backgroundColor:"",
          width:"50%",
        }}
      >
        <Card
          sx={{
            display:"flex",
            flexDirection:"column",
            justifyContent:"center",
            alignItems:"center",
            zIndex:2,
            backgroundColor:"white",
            height:"40%",
            width:"100%",
            border:2,
          }}
        >
          <Typography>
            <h1><center>fluther is an app built using the Sepolia test network.</center></h1>
            <h2><center>Your wallet is not currently connected to the Sepolia test network.</center></h2>
            <h2><center>Please click the button below to connect to Sepolia.</center></h2>
          </Typography>
          <Button
            variant="contained" 
            onClick={switchNetwork}
            color="success"
          >
            Connect to Sepolia testnet
          </Button>
        </Card>
      </Box>
    </>
  )
}

export default TestNetPrompt