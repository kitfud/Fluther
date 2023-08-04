// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract DEXFactoryMock {
    address token1;
    address token2;
    address wNative;

    constructor(address token1_, address token2_, address wNative_) {
        token1 = token1_;
        token2 = token2_;
        wNative = wNative_;
    }

    function getPair(
        address token1_,
        address token2_
    ) external view returns (address) {
        if (
            ((token1_ == token1 || token1_ == token2) &&
                (token2_ == token1 || token2_ == token2)) ||
            (token1_ == wNative || token2_ == wNative)
        ) {
            return msg.sender;
        }

        return address(0);
    }
}
