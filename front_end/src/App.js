import logo from './jellies_01.jpg';
import './App.css';
import { ConnectWallet } from "@thirdweb-dev/react";
import { useAddress } from "@thirdweb-dev/react";

import { ThemeProvider,createTheme } from '@mui/material';
import {  Box, TextField, Typography, Card, Button} from "@mui/material"


function App() {

  const address = useAddress();
  const theme = createTheme({
    palette:{
      mode:"dark"
    }
  })

  return (


<>
{console.log(address)}
<ThemeProvider theme={theme}>
  <Box>
  <ConnectWallet
              dropdownPosition={{
                side: "bottom",
                align: "center",
              }}/>
  </Box>


      
  <Card variant="outlined" sx={{ display: 'inline-block', backgroundColor: "gray" }}>
  <Typography color="primary" component="h1" sx={{ fontSize: 20, fontWeight: 600, padding: 2}}>Create Dollar Cost Average:</Typography>

  
<Box display="flex" alignItems="center" justifyContent="center">
<TextField id="filled-basic" label="Amount" variant="filled" ></TextField>
</Box> 

<Box display="flex" alignItems="center" justifyContent="center">
<TextField id="filled-basic" label="Token1" variant="filled" ></TextField>
</Box> 

<Box display="flex" alignItems="center" justifyContent="center">
<TextField id="filled-basic" label="Token2" variant="filled" ></TextField>
</Box> 

<Box display="flex" alignItems="center" justifyContent="center" >
<TextField id="filled-basic" label="Time Interval (sec)" variant="filled" ></TextField>
</Box> 

<Box sx={{marginTop:'20px'}} display="flex" alignItems="center" justifyContent="center">
<Button variant="contained" color="warning">Submit Agreement</Button>
</Box>

          
  </Card> 
</ThemeProvider>
</>
      
  );
}

export default App;
