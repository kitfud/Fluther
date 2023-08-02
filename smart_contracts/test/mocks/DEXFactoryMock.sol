// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract DEXFactoryMock {
    function getPair(
        address /* token1 */,
        address /* token2 */
    ) external view returns (address) {
        return msg.sender;
    }
}
