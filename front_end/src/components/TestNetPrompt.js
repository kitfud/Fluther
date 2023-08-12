import React from 'react'
import { useSDK,switchNetwork} from "@thirdweb-dev/react";
import { Button,Box } from '@mui/material';

const TestNetPrompt = () => {

const sdk = useSDK();

const switchNetwork = (event)=>{
    sdk.SwitchNetwork(11155111);
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