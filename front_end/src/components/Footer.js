import React from 'react'
import { Box,Typography,Button,TextField } from '@mui/material'

const Footer = () => {
  return (
    <>
     <Box
        sx={{
          display:"flex",
          flexDirection:"row",
          alignItems:"center",
          justifyContent:"flex-start",
          backgroundColor:"black",
          opacity:"80%",
          width:"100%",
          height:"200px",
          zIndex:5,
          positon: "absolute",
          bottom: 0,
        }}
      >
        <Box 
          sx={{
            display:"flex",
            flexDirection:"row-reverse",
            justifyContent:"space-around",
            alignItems:"center",
            width:"50%",
            background:"",
            marginLeft:"10%"
          }}
        >
          <Button variant="contained">
            Sign up
          </Button>
          <TextField
            id="filled-basic"
            label="Email address"
            variant="filled"
            
            sx={{
              backgroundColor:"",
            }} 
          />
          
          
          <Typography color="white">
            <h1>
              Float with fluther
            </h1>
            <p>
              Sign up with your email to recieve news and updates.
            </p>
          </Typography>
        </Box>
      </Box>
    </>
  )
}

export default Footer