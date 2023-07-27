import React from 'react'
import { useEffect,useState } from 'react'
import {Button,Card,Box,Paper,Table, TableBody,TableCell,TableContainer,TableHead,TableRow } from '@mui/material'
import { ethers } from 'ethers'
import DollarCost from '../chain-info/smart_contracts.json'

const UserRecurringBuys = ({contract,provider,address}) => {

    // console.log(DollarCost.DollarCostAverage.address.sepolia)
// console.log("address",address)
    const [data, setData] = useState(null)
    const [tabledata,setTableData] = useState(null)

    useEffect(()=>{

    const loggingData = async()=>{
    const data = await logEventData("RecurringBuyCreated",[], provider)
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

    },[provider,address])

    useEffect(()=>{
    if(data){
    // console.log(data)
    filterData(data)
}
    },[data])


    const filterData = (data)=>{
        // console.log(data)
        // console.log("data",data[16][0])

        //takes off records which don't relate to events,setup of contracts and admin
        let userData = []
        data.forEach((element)=>{
            // console.log(typeof(element[0]))
            if(typeof(element[0])!='string'){
                userData.push(element)
            }
        })

        //filter to only records specific to user
        // console.log("address",address)
       let result =[] 
       for(let i = 0; i<userData.length; i++){
       if (userData[i][1]==address){
        result.push(userData[i])
       }
       }
console.log("result",result)
       let tableResult = []
       result.forEach((element)=>{
        // console.log("buy",element.buy)
        console.log("timeIntervalSeconds",element.buy.timeIntervalInSeconds.toNumber())
        // console.log("tokenToBuy",element.buy.tokenToBuy)
        // console.log("token to spend",element.buy.tokenToSpend)
        // console.log(element.recBuyId.toNumber())
        let tdata = {
            "buyId":element.recBuyId.toNumber(),
            "tokenToSpend":element.buy.tokenToSpend,
            "tokenToBuy":element.buy.tokenToBuy,
            "timeInterval":element.buy.timeIntervalInSeconds.toNumber()
        }
        tableResult.push(tdata)
       })
 setTableData(tableResult)
    }


    
    const logEventData = async (eventName, filters = [], provider, setterFunction = undefined) => {

        console.log("eventName",eventName)
        console.log("provider",provider)
        console.log("filters",filters)
        // let filterABI = ["event RecurringBuyCreated ( uint256 recBuyId,address sender, tuple buy)"]
        console.log(DollarCost.DollarCostAverage.abi)
        let filterABI = DollarCost.DollarCostAverage.abi
        let iface = new ethers.utils.Interface(filterABI)

        console.log(iface)

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
          {tabledata?(tabledata.map((row) => {
            return(
            <TableRow
              key={row.buyId}
              sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
            >
          
              <TableCell align="right">{row.buyId}</TableCell>
              <TableCell align="right">{row.tokenToBuy}</TableCell>
              <TableCell align="right">{row.tokenToSpend}</TableCell>
              <TableCell align="right">{row.timeInterval}</TableCell>
              <TableCell><Button variant='contained' color="error">Cancel</Button></TableCell>
            </TableRow>)
          })):null}
        </TableBody>
      </Table>
    </TableContainer>
   
    </Card>
    
    </>
   
  )
}

export default UserRecurringBuys