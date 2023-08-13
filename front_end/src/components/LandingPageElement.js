import React from 'react'
import { Box, Card, Typography } from "@mui/material"

const LandingPageElement = () => {
  return (
    <>
      <Box
        sx={{
          height:"100vh",
          width:"100%",
          display:"flex",
          flexDirection:"column",
          justifyContent:"",
          alignItems:"center",
        }}
      >
        <Card
          sx={{
            height:"50%",
            width:"50%",
            backgroundColor:"white",
            display:"flex",
            flexDirection:"column",
            alignItems:"center",
            justifyContent:"center",
            border:2,
          }}
        >
          <Typography color="black">
            <h1><center>Welcome to fluther!</center></h1>
            <h2><center>fluther is a decentralized dollar cost averaging application.</center></h2>
            <ul>
              <li>Stay in control of your money.</li>
              <li>De-risk from market fluctuations.</li>
              <li>Invest with automated purchases.</li>
              <li>Live your life.</li>
            </ul>
            <h2><center>Click the 'Connect Wallet' button to begin.</center></h2>
          </Typography>
        </Card>
      </Box>
    </>
  )
}

export default LandingPageElement