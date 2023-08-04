// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** @author @EWCunha
 *  @title ERC20 DUH token smart contract
 */

/// -----------------------------------------------------------------------
/// Imports
/// -----------------------------------------------------------------------

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Security} from "./Security.sol";

/// -----------------------------------------------------------------------
/// Contract
/// -----------------------------------------------------------------------

contract Duh is ERC20, Security {
    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor() ERC20("Duh token", "DUH") Security(msg.sender) {}

    /// -----------------------------------------------------------------------
    /// External state-change functions
    /// -----------------------------------------------------------------------

    function mint(address to, uint256 amount) external {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();

        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();

        _burn(from, amount);
    }
}
