import React from 'react'
import { useEffect,useState } from 'react'
import {Button,Card,Box,Paper,Table, TableBody,TableCell,TableContainer,TableHead,TableRow } from '@mui/material'
import { ethers } from 'ethers'
import DollarCost from '../chain-info/smart_contracts.json'

const UserRecurringBuys = ({contract,provider,address}) => {

    // console.log(DollarCost.DollarCostAverage.address.sepolia)
// console.log("address",address)
    const [data, setData] = useState(null)

    useEffect(()=>{

    const loggingData = async()=>{
    console.log("provider",provider)
    const data = await logEventData("RecurringBuyCreated",[], provider)
    console.log(data)
    setData(data)
    }

    if(provider){
    try{
    loggingData()  
    }
    catch(err){
        console.log(err)
    }
    }
    },[provider])

    useEffect(()=>{
if(data){
    console.log(data)
}
    },[data])


    
    const logEventData = async (eventName, filters = [], provider, setterFunction = undefined) => {

        console.log("eventName",eventName)
        console.log("provider",provider)
        console.log("filters",filters)
        let filterABI = ["event RecurringBuyCreated(uint256 indexed recBuyId,address indexed sender,tuple buy)"]
        let iface = new ethers.utils.Interface(filterABI)

        let dollarCostAddress = DollarCost.DollarCostAverage.address.sepolia
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

    }
    
    function createData(buyId, tokenToSpend, tokenToBuy, timeInterval) {
        return {buyId, tokenToSpend, tokenToBuy,timeInterval};
      }
    
    
    const rows = [
        createData('test0', 'testWETH', 'testUNI', 'test300'),
      ];

  return (
    <>
    <Card sx={{marginTop:'20px',padding:'40px'}}>
        <Box>
        <div>Current Dollar Cost Average Contracts</div>
        </Box>
        <TableContainer component={Paper}>
      <Table sx={{ minWidth: 650 }} aria-label="Current Dollar Cost Average">
        <TableHead>
          <TableRow>
            <TableCell>buyId</TableCell>
            <TableCell align="right">Token To Spend</TableCell>
            <TableCell align="right">Token To Buy</TableCell>
            <TableCell align="right">Interval&nbsp; (sec)</TableCell>
            
          </TableRow>
        </TableHead>
        <TableBody>
          {rows.map((row) => (
            <TableRow
              key={row.buyId}
              sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
            >
          
              <TableCell align="right">{row.buyId}</TableCell>
              <TableCell align="right">{row.tokenToBuy}</TableCell>
              <TableCell align="right">{row.tokenToSpend}</TableCell>
              <TableCell align="right">{row.timeInterval}</TableCell>
              <TableCell><Button variant='contained' color="error">Cancel</Button></TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </TableContainer>
   
    </Card>
    
    </>
   
  )
}

export default UserRecurringBuys