import React from 'react'
import { useState,useEffect } from 'react';
import { Button,Box } from '@mui/material';
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


  return (<>
  <div>This is a TestNet APP- Connect TO Sepolia Network. </div>
  <div>Edit this prompt is in components file</div>

  <Box><Button variant="contained" 
  onClick={switchNetwork}
  color="success">CLICK TO CHANGE NETWORK</Button></Box>
  </>
    
    
  )
}

export default TestNetPrompt