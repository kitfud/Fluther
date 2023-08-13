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
            marginLeft:"10%",
            marginTop:"2%",
            marginBottom:"2%",
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
          <Box
            sx={{
              display:"flex",
              flexDirection:"column",
              justifyContent:"center",
              backgroundColor:"",
            }}
          >
            <Typography color="white"
              sx={{
                fontSize:"36px"
              }}
            >          
              Float with fluther
            </Typography>
            <Typography color="white"
              sx={{
                fontSize:"18px"
              }}
            >
              Sign up with your email to recieve news and updates.
            </Typography>
          </Box>
        </Box>
      </Box>
    </>
  )
}

export default Footer