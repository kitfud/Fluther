<<<<<<< HEAD
<<<<<<< HEAD
import React, { isValidElement } from 'react'
import { useEffect,useState } from 'react'
import {Typography,Snackbar,CircularProgress,Button,Card,Box,Paper,Table, TableBody,TableCell,TableContainer,TableHead,TableRow } from '@mui/material'
import { ethers } from 'ethers'
import DollarCost from '../chain-info/smart_contracts.json'
=======
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
import React from 'react'
import { useEffect,useState } from 'react'
import {Typography,Snackbar,CircularProgress,Button,Card,Box,Paper,Table, TableBody,TableCell,TableContainer,TableHead,TableRow, Slide } from '@mui/material'
import { ethers } from 'ethers'
<<<<<<< HEAD
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028

import IconButton from '@mui/material/IconButton';
import CloseIcon from '@mui/icons-material/Close';

import smartContracts from '../chain-info/smart_contracts.json'

const UserRecurringBuys = ({setUpdateAgreements,updateAgreements,processingApp,
  setCancelOccur,balance,signer,contract,provider,address}) => {

<<<<<<< HEAD
<<<<<<< HEAD
    // console.log(DollarCost.DollarCostAverage.address.sepolia)
// console.log("address",address)
const [data, setData] = useState(null)
=======

>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======

>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
const [tabledata,setTableData] = useState(null)
const [processing, setProcessing] = useState(false)

  const [openSnackbar,setOpenSnackBar] = useState(false)
  const [txHash, setTxHash] = useState(null)
<<<<<<< HEAD
<<<<<<< HEAD
  const [canceledIds,setCanceledIds] = useState(null)
 
=======
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028

 
  const [buyIds,setBuyIds] = useState(null)
  const [buyIdStructs,setBuyIdStructs] = useState(null)
<<<<<<< HEAD
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028

  const [currentDataLength, setCurrentDataLength] = useState(null)

  const [cancelUpdateAgreements, setCancelUpdateAgreements] = useState(false)


  const handleClose = (event, reason) => {
    if (reason === 'clickaway') {
      return;
    }
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
    window.location.reload(false);
=======
    window.location.reload()
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
    window.location.reload()
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
    // window.location.reload()
>>>>>>> 918fa301e141e082cb1d287fc05f2dee672b6d1f
    setOpenSnackBar(false);
    
  };

  useEffect(()=>{
    let checkAgreements

    if(updateAgreements){
      checkAgreements= setInterval(()=>{
        console.log("checking for updates")
        logUserData()
      },1000)
    }
    if(!updateAgreements){
      clearInterval(checkAgreements)
    }
    return ()=>clearInterval(checkAgreements)

  },[updateAgreements])

  useEffect(()=>{
    let checkCancelAgreements

    if(cancelUpdateAgreements){
      checkCancelAgreements= setInterval(()=>{
        console.log("checking for updates")
        logUserData()
      },1000)
    }
    if(!cancelUpdateAgreements){
      clearInterval(checkCancelAgreements)
    }
    return ()=>clearInterval(checkCancelAgreements)

  },[cancelUpdateAgreements])




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
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD

    const loggingData = async()=>{
    const data = await logEventData("RecurringBuyCreated",[], provider)
    console.log("data",data)
    setData(data)
    }

    if(provider!=null){
    try{
    loggingData()  
    }
    catch(err){
        console.log(err)
    }
    }

    },[provider,address])

    useEffect(()=>{
    if(data != undefined){
    console.log("data",data)
    filterData(data)
}
    },[data])



    const filterData = (data)=>{
        // console.log(data)
        // console.log("data",data[16][0])

        //takes off records which don't relate to events,setup of contracts and admin
        let userData = []
        let cancelledContracts = []

        data.forEach((element)=>{
            //the cancel event array is length 2 and the admin stuff does not start witha  string when
            //llooking at data
            if(typeof(element[0])!='string'& element.length==3){
                userData.push(element)
            }
           
        })

        
            data.forEach((element)=>{
                //event structure for canclled events in length 2 and only take sender from address
                if(typeof(element[0])!='string'& element.length==2 &element.sender==address){
                //filter and convert big number to javascript integer
                    cancelledContracts.push(element.recBuyId.toNumber())
                }
               
            })
           
       

        //console.log("cancelled",cancelledContracts)
        setCanceledIds(cancelledContracts)
        //filter to only records specific to user
        console.log("userData",userData.buy)
       let result =[] 
       for(let i = 0; i<userData.length; i++){
       if (userData[i][1]==address&& userData[i].buy){
        result.push(userData[i])
       }
       }
console.log("result",result)
       let tableResult = []
       result.forEach((element)=>{
        // console.log("buy",element.buy)
        // console.log("timeIntervalSeconds",element.buy.timeIntervalInSeconds.toNumber())
      
        console.log("tokenToBuy",element.buy.tokenToBuy)
        console.log("token to spend",element.buy.tokenToSpend)
        // console.log(element.recBuyId.toNumber())
        
        // console.log("amount",ethers.utils.formatEther(element.buy[1]))
       
        let tdata = {
            "buyId":element.recBuyId.toNumber(),
            "tokenToSpend":element.buy.tokenToSpend,
            "tokenToBuy":element.buy.tokenToBuy,
            "timeInterval":element.buy.timeIntervalInSeconds.toNumber(),
            "amount":ethers.utils.formatEther(element.buy[1])
        }
        tableResult.push(tdata)
    
       })
    //    console.log("tableresult",tableResult)
    setTableData(tableResult)
    }


    
    const logEventData = async (eventName, filters = [], provider, setterFunction = undefined) => {

        // console.log("eventName",eventName)
        // console.log("provider",provider)
        // console.log("filters",filters)
        // let filterABI = ["event RecurringBuyCreated ( uint256 recBuyId,address sender, tuple buy)"]
        // console.log(DollarCost.DollarCostAverage.abi)
        let filterABI = DollarCost.DollarCostAverage.abi
        let iface = new ethers.utils.Interface(filterABI)

        // console.log(iface)

        let dollarCostAddress = DollarCost.DollarCostAverage.address.sepolia
        // console.log(dollarCostAddress)
        let filter = {
            address: dollarCostAddress,
            fromBlock:0,     
        }
        let logPromise = provider.getLogs(filter)
        logPromise.then(function(logs){
            let events = logs.map((log)=>{
                return iface.parseLog(log).args
            })
            setData(events)
            
        }).catch(function(err){
            console.log(err);
        });

=======
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
    if(provider!=null){
=======
    if(contract){
   
>>>>>>> 918fa301e141e082cb1d287fc05f2dee672b6d1f
    try{
    logUserData()  
    }
    catch(err){
    console.log(err)
    }
    }
    },[provider,address,balance,contract,processingApp])



    useEffect(()=>{
    if(buyIdStructs){
     
    filterData(buyIdStructs)
}
    },[buyIdStructs])



    const filterData = ()=>{
   
      let tableResult = []
      if(buyIdStructs.length==0 && cancelUpdateAgreements){
        setCancelUpdateAgreements(false)
        setTableData(tableResult)
      }
     
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
          if(buyIdStructs.length>currentDataLength && updateAgreements){
            setUpdateAgreements(false)
          }
          else if(buyIdStructs.length<currentDataLength && cancelUpdateAgreements){
            setCancelUpdateAgreements(false)
          }
       
          setCurrentDataLength(buyIdStructs.length)
         
        }
      })

    }

    const logUserData = async () => {

     if(contract && address){
      
      let userData = await contract.getRecurringBuysFromUser(address)
  
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
     
          setBuyIdStructs(userBuyStructsRefined)
        }
      })
     }
<<<<<<< HEAD
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
    }

    const handleCancel = async (id)=>{
        if(signer){
        try{
        setProcessing(true)
        let tx = await contract.connect(signer).cancelRecurringPayment(id)
        let hash = tx.hash
        setCancelUpdateAgreements(true)
        setTxHash(hash.toString())
        isTransactionMined(hash.toString())
        
        }
        catch(err){
        setCancelUpdateAgreements(false)
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
                setCancelOccur(true)
                logUserData()
      
            }
        }
      }
    
<<<<<<< HEAD
<<<<<<< HEAD
 const removeCancelledContracts = (tableData) =>{
    // console.log('tableData',tableData)
    // console.log("cancelled",canceledIds)
    let refinedData = tableData.filter(element=>!canceledIds.includes(element.buyId))
    // console.log("refined",refinedData)
    return refinedData
 }
=======

>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======

>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028

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
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
    <Card sx={{marginTop:'20px',padding:'40px'}}>
        <Box>
        <div>Current Dollar Cost Average Contracts</div>
        </Box>
        <TableContainer component={Paper}>
      <Table sx={{ minWidth: 650 }} aria-label="Current Dollar Cost Average">
        <TableHead sx={{backgroundColor:"lightyellow"}}>
=======
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
    !updateAgreements?
    !cancelUpdateAgreements?
>>>>>>> 918fa301e141e082cb1d287fc05f2dee672b6d1f
    <Slide direction="right" in={true} mountOnEnter>
    <Card sx={{marginTop:'20px', marginBottom: "20px", padding:'0px', border:2, borderColor:"#e842fa"}}>
        <Box>

        </Box>
        <TableContainer component={Paper}>
      <Table sx={{ minWidth: 650, }} aria-label="Current Dollar Cost Average">
        <TableHead sx={{backgroundColor:"#a7aeff"}}>
<<<<<<< HEAD
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
          <TableRow>
            <TableCell>buyId</TableCell>
            <TableCell align="right">Token To Spend</TableCell>
            <TableCell align="right">Token To Buy</TableCell>
            <TableCell align="right">Amount</TableCell>
            <TableCell align="right">Interval&nbsp;</TableCell>
            <TableCell align="right"></TableCell>
          </TableRow>
        </TableHead>
<<<<<<< HEAD
<<<<<<< HEAD
        <TableBody>
          {tabledata?(removeCancelledContracts(tabledata).map((row) => {
            // let swap = {"tokenToBuy":"UNI","tokenToSpend":"WETH"}
            // console.log("row",row)
            let swap = translateToken(row)
            let time = translateTime(row)
=======
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
        <TableBody sx={{backgroundColor: "#ebecff"}}>
          {tabledata?(tabledata.map((row) => {
       
            let swap = translateToken(row)
            let time = translateTime(row)
            let index = tabledata.indexOf(row)
<<<<<<< HEAD
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
            
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
<<<<<<< HEAD
<<<<<<< HEAD
              <TableCell><Button onClick={()=>handleCancel(row.buyId)} variant='contained' color="error">Cancel</Button></TableCell>
            </TableRow>)
          })):<div></div>}
=======
              <TableCell><Button onClick={()=>handleCancel(buyIds[index])} variant='contained' color="error">Cancel</Button></TableCell>
            </TableRow>)
          })):null}
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
              <TableCell><Button onClick={()=>handleCancel(buyIds[index])} variant='contained' color="error">Cancel</Button></TableCell>
            </TableRow>)
          })):null}
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
        </TableBody>
      </Table>
    </TableContainer>
<<<<<<< HEAD



<<<<<<< HEAD
<<<<<<< HEAD
    </Card>:<Box display="flex"
=======
    </Card></Slide>:<Box display="flex"
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
    </Card></Slide>:<Box display="flex"
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
                alignItems="center"
                justifyContent="center" 
                sx={{marginTop:'20px'}}> <CircularProgress/></Box>
=======
    </Card></Slide>:
        <Box display="flex"
        alignItems="center"
        justifyContent="center" 
        sx={{marginTop:'20px',marginBottom:'10px'}}> <CircularProgress sx={{color:"white"}}/></Box>:
    <Box display="flex"
        alignItems="center"
        justifyContent="center" 
        sx={{marginTop:'20px',marginBottom:'10px'}}> <CircularProgress sx={{color:"white"}}/></Box>:
        <Box display="flex"
              alignItems="center"
              justifyContent="center" 
              sx={{marginTop:'20px',marginBottom:'10px'}}> <CircularProgress sx={{color:"white"}}/></Box>
>>>>>>> 918fa301e141e082cb1d287fc05f2dee672b6d1f
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