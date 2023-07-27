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


    
    const logEventData = async (eventName, filters = [], provider, setterFunction = undefined) => {

        console.log("eventName",eventName)
        console.log("provider",provider)
        console.log("filters",filters)

        const ABI = DollarCost.DollarCostAverage.abi.filter(frag => frag.name && frag.name === eventName)[0]
        // console.log(ABI)
        let ABIStr = `event ${ABI.name}(`
        for (let ii = 0; ii < ABI.inputs.length; ii++) {
            ABIStr += `${ABI.inputs[ii].type} ${ABI.inputs[ii].indexed ? "indexed" : ""} ${ABI.inputs[ii].name}`
            if (ii < ABI.inputs.length - 1) {
                ABIStr += ","
            }
        }
        ABIStr += ")"

        console.log(ABIStr)
    //     let datac = contract.filters.RecurringBuyCreated(null,address)
    //    console.log(datac)
   
        //lines below are old code
        const iface = new ethers.utils.Interface([ABIStr])
        console.log("iface",iface)
        return iface

        // const iface = new ethers.utils.Interface(DollarCost.DollarCostAverage.abi)
        // console.log("iface",iface)
    
        // const topics = iface.encodeFilterTopics(ABI.name, filters)
    
        // const filter = {
        //     address: ethers.utils.getAddress(DollarCost.DollarCostAverage.address.sepolia),
        //     topics,
        //     fromBlock: 0
        // }
    
        // const logs = await provider.getLogs(filter)
        // console.log("logs",logs)

        // const decodedEventsArgs = logs.map(log => {
        //     return iface.parseLog(log).args
        // })
        // const decodedEventsInputs = logs.map(log => {
        //     return iface.parseLog(log).eventFragment.inputs
        // })
        // const blockNumbers = logs.map(log => {
        //     return log.blockNumber
        // })
    
        // let decodedEvents = []
        // for (let ii = 0; ii < decodedEventsInputs.length; ii++) {
        //     const result = decodedEventsInputs[ii].map((input, index) => {
        //         if (input.name === "nextReccuringBuyId" || input.name === "msg.sender" || input.name === "buy") {
        //             return { [input.name]: decodedEventsArgs[ii][index].toNumber() }
        //         } else if (ethers.BigNumber.isBigNumber(decodedEventsArgs[ii][index])) {
        //             return { [input.name]: parseFloat(ethers.utils.formatEther(decodedEventsArgs[ii][index])) }
        //         } else {
        //             return { [input.name]: decodedEventsArgs[ii][index] }
        //         }
        //     })
    
        //     let realRestul = {}
        //     for (let jj = 0; jj < result.length; jj++) {
        //         realRestul = { ...realRestul, ...result[jj] }
        //     }
        //     realRestul["timestamp"] = (await provider.getBlock(blockNumbers[ii])).timestamp
        //     decodedEvents.push(realRestul)
        // }
    
        // if (typeof setterFunction !== "undefined") {
        //     setterFunction(decodedEvents)
        // }
    
        // return decodedEvents
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