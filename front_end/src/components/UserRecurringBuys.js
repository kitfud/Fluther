import React from 'react'
import { useEffect,useState } from 'react'
import {Typography,Snackbar,CircularProgress,Button,Card,Box,Paper,Table, TableBody,TableCell,TableContainer,TableHead,TableRow, Slide } from '@mui/material'
import { ethers } from 'ethers'

import IconButton from '@mui/material/IconButton';
import CloseIcon from '@mui/icons-material/Close';

import smartContracts from '../chain-info/smart_contracts.json'

const UserRecurringBuys = ({signer,contract,provider,address}) => {


const [tabledata,setTableData] = useState(null)
const [processing, setProcessing] = useState(false)

  const [openSnackbar,setOpenSnackBar] = useState(false)
  const [txHash, setTxHash] = useState(null)

 
  const [buyIds,setBuyIds] = useState(null)
  const [buyIdStructs,setBuyIdStructs] = useState(null)


  const handleClose = (event, reason) => {
    if (reason === 'clickaway') {
      return;
    }
    window.location.reload()
    setOpenSnackBar(false);
    
  };



  const action = (
    <React.Fragment>
      <Button color="secondary" size="small" onClick={handleClose}>
        UNDO
      </Button>
      <IconButton
        size="small"
        aria-label="close"
        color="inherit"
        onClick={handleClose}
      >
        <CloseIcon fontSize="small" />
      </IconButton>
    </React.Fragment>
  );

    useEffect(()=>{
    if(provider!=null){
    try{
    logUserData()  
    }
    catch(err){
    console.log(err)
    }
    }
    },[provider,address])

    useEffect(()=>{
    if(buyIdStructs){
    filterData(buyIdStructs)
}
    },[buyIdStructs])



    const filterData = ()=>{
   
      let tableResult = []
     
      let counter = 0
      buyIdStructs.forEach((element)=>{
        counter++
       let tdata = {
            "buyId":buyIds[buyIdStructs.indexOf(element)].toNumber(),
            "tokenToSpend":element.tokenToSpend,
            "tokenToBuy":element.tokenToBuy,
            "timeInterval":element.timeIntervalInSeconds.toNumber(),
            "amount":ethers.utils.formatEther(element.amountToSpend)
        }
        tableResult.push(tdata)
        if(counter == buyIdStructs.length){
          setTableData(tableResult)
        }
      })

    }



    const logUserData = async () => {
     if(address){
      
      let userData = await contract.getRecurringBuysFromUser(address)
      // console.log(userData)
      let userBuyIds = userData[0]
      let userBuyStructs= userData[1]

      let userBuyIdsRefined = []
      let userBuyStructsRefined = []

      let counterIds = 0
      userBuyIds.forEach((el)=>{
        counterIds++
        if(userBuyIds.indexOf(el) !=0){
          userBuyIdsRefined.push(el)
        }
        if(counterIds==userBuyIds.length){
          setBuyIds(userBuyIdsRefined)
        }
      })


      let counterStructs = 0
      userBuyStructs.forEach((el)=>{
        counterStructs++
        if(userBuyStructs.indexOf(el) !=0){
          userBuyStructsRefined.push(el)
        }
        if(counterStructs==userBuyIds.length){
          // console.log(userBuyIdsRefined)
          setBuyIdStructs(userBuyStructsRefined)
        }
      })
     }
    }

    const handleCancel = async (id)=>{
        if(signer){
        try{
        setProcessing(true)
        let tx = await contract.connect(signer).cancelRecurringPayment(id)
        let hash = tx.hash
        setTxHash(hash.toString())
        isTransactionMined(hash.toString())

        }
        catch(err){
        setProcessing(false)
        console.log(err)
        }
        }
    }

    const isTransactionMined = async (transactionHash) => {
        let transactionBlockFound = false
      
        while (transactionBlockFound === false) {
            let tx = await provider.getTransactionReceipt(transactionHash)
            console.log("transaction status check....")
            try {
                await tx.blockNumber
            }
            catch (error) {
                tx = await provider.getTransactionReceipt(transactionHash)
            }
            finally {
                console.log("proceeding")
            }
      
      
            if (tx && tx.blockNumber) {
               
                setProcessing(false)
                console.log("block number assigned.")
                transactionBlockFound = true
                let stringBlock = tx.blockNumber.toString()
                console.log("COMPLETED BLOCK: " + stringBlock)
                // setReloadPage(true)
                setOpenSnackBar(true)
      
            }
        }
      }
    


 const translateToken = (row)=>{
    let translatedData = {}
    if(row.tokenToBuy == smartContracts.UNIMock.address.sepolia){
        translatedData["tokenToBuy"] ="UNI"
    }
    else if (row.tokenToBuy == smartContracts.WETHMock.address.sepolia){
        translatedData["tokenToBuy"]="WETH"        
    }

    if(row.tokenToSpend == smartContracts.UNIMock.address.sepolia){
        translatedData["tokenToSpend"] ="UNI"
    }
    else if (row.tokenToSpend == smartContracts.WETHMock.address.sepolia){
        translatedData["tokenToSpend"]="WETH"        
    }

    return translatedData

 }

 const translateTime=(row)=>{
    let returnData = {}
    if(row.timeInterval==300){
        returnData["timeInterval"] = "5 Minutes"
    }
    else if (row.timeInterval==86400){
        returnData["timeInterval"] = "Daily"
    } 
    else if (row.timeInterval==604800){
        returnData["timeInterval"] = "Weekly"
    } 
    else if (row.timeInterval==2419200){
        returnData["timeInterval"] = "Monthly" 
    }
    return returnData
 }

  return (
    <>
   {
    !processing?
    <Slide direction="right" in={true} mountOnEnter>
    <Card sx={{marginTop:'20px', marginBottom: "20px", padding:'0px', border:2, borderColor:"#e842fa"}}>
        <Box>

        </Box>
        <TableContainer component={Paper}>
      <Table sx={{ minWidth: 650, }} aria-label="Current Dollar Cost Average">
        <TableHead sx={{backgroundColor:"#a7aeff"}}>
          <TableRow>
            <TableCell>buyId</TableCell>
            <TableCell align="right">Token To Spend</TableCell>
            <TableCell align="right">Token To Buy</TableCell>
            <TableCell align="right">Amount</TableCell>
            <TableCell align="right">Interval&nbsp;</TableCell>
            <TableCell align="right"></TableCell>
          </TableRow>
        </TableHead>
        <TableBody sx={{backgroundColor: "#ebecff"}}>
          {tabledata?(tabledata.map((row) => {
       
            let swap = translateToken(row)
            let time = translateTime(row)
            let index = tabledata.indexOf(row)
            
            return(
            <TableRow
              key={row.buyId}
              sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
            >
          
              <TableCell align="right">{row.buyId}</TableCell>
              <TableCell align="right">{swap.tokenToSpend}</TableCell>
              <TableCell align="right">{swap.tokenToBuy}</TableCell>
              <TableCell align="right">{row.amount}</TableCell>
              <TableCell align="right">{time.timeInterval}</TableCell>
              <TableCell><Button onClick={()=>handleCancel(buyIds[index])} variant='contained' color="error">Cancel</Button></TableCell>
            </TableRow>)
          })):null}
        </TableBody>
      </Table>
    </TableContainer>



    </Card></Slide>:<Box display="flex"
                alignItems="center"
                justifyContent="center" 
                sx={{marginTop:'20px'}}> <CircularProgress/></Box>
}
        <Snackbar
        anchorOrigin={{vertical: 'bottom', horizontal: 'center'}}
        open={openSnackbar}
        autoHideDuration={3000}
        onClose={handleClose}
        message=""
        action={action}
        sx={{backgroundColor:"white"}}
      >
        <a target="_blank" href={`https://sepolia.etherscan.io/tx/${txHash}`}>
          <Typography color="black">Success!Dollar Cost Agreement Canceled:${txHash} on Etherscan</Typography>
        </a>
        </Snackbar>
    </>
   
  )
}

export default UserRecurringBuys