// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** @author @EWCunha.
 *  @title Security smart contract.
 */

/// -----------------------------------------------------------------------
/// Imports
/// -----------------------------------------------------------------------

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// -----------------------------------------------------------------------
/// Contract
/// -----------------------------------------------------------------------

contract Security is Ownable, Pausable, ReentrancyGuard {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    /// @dev error for when function caller is not allowed.
    error Security__NotAllowed();

    /// @dev error for when the token approval fails.
    error Security__TokenApprovalFailed();

    /// @dev error for when ERC20 token transfer fails
    error Security__TokenTransferFailed();

    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    /* solhint-disable */

    mapping(address /* caller */ => bool /* isAllowed */) internal s_allowed;

    /* solhint-enable */

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    /** @dev event for when a permission is set to given caller address.
     *  @param allowed: address to set the permission.
     *  @param caller: address of the funciton caller.
     *  @param isAllowed: true if the permission is allowed, false otherwise.
     */
    event CallerPermissionSet(
        address indexed allowed,
        address indexed caller,
        bool isAllowed
    );

    /// -----------------------------------------------------------------------
    /// Modifiers (or functions as modifiers)
    /// -----------------------------------------------------------------------

    /// @dev Uses the nonReentrant modifier. This way reduces smart contract size.
    function __nonReentrant() internal nonReentrant {}

    /// @dev Uses the whenNotPaused modifier. This way reduces smart contract size.
    function __whenNotPaused() internal view whenNotPaused {}

<<<<<<< HEAD
<<<<<<< HEAD
    /// @dev Uses the onlyOwner modifier. This way reduces smart contract size.
    function __onlyOwner() internal view onlyOwner {}
=======
    // /// @dev Uses the onlyOwner modifier. This way reduces smart contract size.
    // function __onlyOwner() internal view onlyOwner {}
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028
=======
    // /// @dev Uses the onlyOwner modifier. This way reduces smart contract size.
    // function __onlyOwner() internal view onlyOwner {}
>>>>>>> dd81a9a1b1d5c6e876efecc1801ee01b7f2a1028

    /// @dev Only allowed addresses can call function.
    function __onlyAllowed() internal view {
        if (!s_allowed[msg.sender]) {
            revert Security__NotAllowed();
        }
    }

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    /** @notice constructor logic.
     *  @param allowed: address which permission will be set to true.
     */
    constructor(address allowed) {
        s_allowed[allowed] = true;
    }

    /// -----------------------------------------------------------------------
    /// External state-change functions
    /// -----------------------------------------------------------------------

    /** @notice sets permission to given caller address.
     *  @dev added nonReentrant and whenNotPaused third party modifiers. Only allowed callers can call
     *  this function.
     *  @param caller: address of the caller.
     *  @param isAllowed: true if the caller is allowed to call functions, false otherwise.
     */
    function setAllowed(address caller, bool isAllowed) external {
        __nonReentrant();
        __whenNotPaused();
        __onlyAllowed();

        s_allowed[caller] = isAllowed;

        emit CallerPermissionSet(caller, msg.sender, isAllowed);
    }

    /** @notice Pauses the smart contract so that any function won't work.
     *  @dev Only allowed callers can call this function. Calls third party pause internal function.
     */
    function pause() external {
        __nonReentrant();
        __onlyAllowed();

        _pause();
    }

    /** @notice Unpauses the smart contract so that every function will work.
     *  @dev Only allowed callers can call this function. Calls third party unpause internal function.
     */
    function unpause() external {
        __nonReentrant();
        __onlyAllowed();

        _unpause();
    }

    /// -----------------------------------------------------------------------
    /// Internal state-change functions
    /// -----------------------------------------------------------------------

    /** @dev Performs transfer of ERC20 tokens using transferFrom function. The way this function does the
     *  transfers is safer because it works when the ERC20 transferFrom returns or does not return any value.
     *  @dev It reverts if the transfer was not successful (i.e. reverted) or if returned value is false.
     *  @param token: ERC20 token smart contract address to transfer.
     *  @param from: address from which tokens will be transferred.
     *  @param to: address to which tokens will be transferred.
     *  @param value: amount of ERC20 tokens to transfer.
     *  @return boolean: true if the transfer was successful, false otherwise.
     */
    function __transferERC20(
        address token,
        address from,
        address to,
        uint256 value,
        bool revert_
    ) internal returns (bool) {
        bool success;
        bytes memory data;
        if (from != address(this)) {
            (success, data) = token.call(
                abi.encodeWithSelector(
                    IERC20(token).transferFrom.selector,
                    from,
                    to,
                    value
                )
            );
        } else {
            (success, data) = token.call(
                abi.encodeWithSelector(
                    IERC20(token).transfer.selector,
                    to,
                    value
                )
            );
        }

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            if (revert_) {
                revert Security__TokenTransferFailed();
            } else {
                return false;
            }
        }

        return true;
    }

    /** @dev Approves the specific amount as allowance to the given address of the given token
     *  @dev It reverts if the approve is not sucessfull (i.e. reverted) or if returned value is false.
     *  @param token: ERC20 token smart contract address to approve.
     *  @param to: address to which tokens will be approved.
     *  @param amount: amount to be approved.
     */
    function __approveERC20(
        address token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20(token).approve.selector, to, amount)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert Security__TokenApprovalFailed();
        }
    }

    /// -----------------------------------------------------------------------
    /// External view functions
    /// -----------------------------------------------------------------------

    /** @notice reads the allowed storage mapping.
     *  @param caller: address of the caller.
     *  @return boolean: true if the caller is allowed to call functions, false otherwise.
     */
    function getAllowed(address caller) external view returns (bool) {
        return s_allowed[caller];
    }
}
