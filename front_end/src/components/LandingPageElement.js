import React from 'react'
import { Box, Card, Typography,Grid,CardContent, List, ListItem, ListItemText, ListItemIcon } from "@mui/material"
import CircleIcon from '@mui/icons-material/Circle';

const LandingPageElement = () => {
  return (
    <>
      <Grid
        container
        justifyContent="center"
        alignItems="center"
      >
        <Card
          sx={{
            raised:true,
            border:2,
            borderColor:"white",
            backgroundColor:"black",
            opacity:"75%",
            zIndex:0,
          }}
        >
          <Grid
            container
            justifyContent="center"
            alignItems="center"
            sx={{
              m:1,
              p:1,
              zIndex:1,
            }}
          >
            <CardContent>
              <Box 
                display="flex"
                justifyContent="center"
              >
                <Typography
                  fontSize="40px"
                  color="white"
                >
                  Welcome to fluther!
                </Typography>
              </Box>
        
              <Box
                display="flex"
                flexWrap="wrap"
                justifyContent="flex-start"
              >
                <Typography
                  fontSize="24px"
                  color="white"
                >
                  fluther is a decentralized dollar cost averaging application.
                </Typography>
              </Box>

              <Box sx={{m:1, p:1}}>
                <List>
                  <ListItem>
                    <ListItemIcon>
                      <CircleIcon sx={{color:"white", fontSize:"10px"}}/>
                    </ListItemIcon>
                    <ListItemText
                      primaryTypographyProps={{
                        fontSize: "20px"
                      }}
                      sx={{
                        color:"white",
                      }}
                    >
                      Stay in control of your money.
                    </ListItemText>
                  </ListItem>
                  <ListItem>
                    <ListItemIcon>
                      <CircleIcon
                        sx={{
                          color:"white",
                          fontSize:"10px"
                        }}
                      />
                    </ListItemIcon>
                    <ListItemText 
                      primaryTypographyProps={{
                        fontSize: "20px"
                      }}
                      sx={{
                        color:"white"
                      }}
                    >
                      De-risk from market fluctuations.
                    </ListItemText>
                  </ListItem>
                  <ListItem>
                    <ListItemIcon>
                      <CircleIcon
                        sx={{
                          color:"white",
                          fontSize:"10px"
                        }}
                      />
                    </ListItemIcon>
                    <ListItemText
                      primaryTypographyProps={{
                        fontSize: "20px"
                      }}
                      sx={{
                        color:"white"
                      }}
                    >
                      Invest with automated purchases.
                    </ListItemText>
                  </ListItem>
                  <ListItem>
                    <ListItemIcon>
                      <CircleIcon
                        sx={{
                          color:"white",
                          fontSize:"10px"
                        }}
                      />
                    </ListItemIcon>
                    <ListItemText
                      primaryTypographyProps={{
                        fontSize: "20px"
                      }}
                      sx={{
                        color:"white"
                      }}
                    >
                      Live your life.
                    </ListItemText>
                  </ListItem>
                </List>
              </Box>
              <Box
                display="flex"
                justifyContent="center"
              >
                <Typography
                  fontSize="24px"
                  color="white"
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