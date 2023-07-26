import React from 'react'
import {Button,Card,Box,Paper,Table, TableBody,TableCell,TableContainer,TableHead,TableRow } from '@mui/material'

const UserRecurringBuys = () => {

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