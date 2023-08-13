import React from 'react'
import { Box, Card, Typography,Grid,CardContent, List, ListItem,ListItemText } from "@mui/material"

const LandingPageElement = () => {
  return (
    <>
   
   <Grid
      container
      justifyContent="center"
      alignItems="center"
    >

    <Card >
        <Grid
      container
      justifyContent="center"
      alignItems="center"
        >
            <CardContent>
            <Box 
            display="flex"
            justifyContent="center">
            <Typography fontSize={'40px'}>Welcome to fluther!</Typography>
            </Box>
        
            <Box
            display="flex"
            justifyContent="center">
            <Typography fontSize={'24px'}>fluther is a decentralized dollar cost averaging application.</Typography>
            </Box>

            <Box  display="flex"
              justifyContent="center">
                <List>
                    <ListItem><ListItemText>Stay in control of your money.</ListItemText></ListItem>
                    <ListItem><ListItemText>De-risk from market fluctuations.</ListItemText></ListItem>
                    <ListItem><ListItemText>Invest with automated purchases.</ListItemText></ListItem>
                    <ListItem><ListItemText>Live your life.</ListItemText></ListItem>
                </List>

            </Box>
            
            <Box
              display="flex"
              justifyContent="center"
            >
        <Typography  fontSize={'24px'}>Click the 'Connect Wallet' button to begin.</Typography>
            </Box>
        </CardContent>
        </Grid>
        </Card>
   
    {/* <Card
    sx={{margin:'auto',flexDirection:'column',alignContent:'center',justifyContent:'center'}}
>
    
       
<Grid direction="column"
  justify="center"
  alignItems="center"
  spacing={0}>


<Typography variant="h1">Welcome to fluther!</Typography>



<Typography variant="h2">fluther is a decentralized dollar cost averaging application.</Typography>
             

           

            <ul>
              <li>Stay in control of your money.</li>
              <li>De-risk from market fluctuations.</li>
              <li>Invest with automated purchases.</li>
              <li>Live your life.</li>
            </ul>
           
    <Typography variant="h2" >Click the 'Connect Wallet' button to begin.</Typography>
          
    </Grid>
        </Card>
       */}
       </Grid>
      
    </>
  )
}

export default LandingPageElement