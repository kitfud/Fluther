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
                justifyContent="center"
              >
                <Typography
                  fontSize="40px"
                >
                  Welcome to fluther!
                </Typography>
              </Box>
        
              <Box
                display="flex"
                justifyContent="center"
              >
                <Typography
                  fontSize="24px"
                >
                  fluther is a decentralized dollar cost averaging application.
                </Typography>
              </Box>

              <Box
                display="flex"
                justifyContent="center"
              >
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
                <Typography
                  fontSize="24px"
                >
                  Click the 'Connect Wallet' button to begin.
                </Typography>
              </Box>
            </CardContent>
          </Grid>
        </Card>
      </Grid>
    </>
  )
}

export default LandingPageElement