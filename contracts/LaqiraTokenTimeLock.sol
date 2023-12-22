// SPDX-License-Identifier: MIT
// LaqiraTimeLockWallet, Developed by Laqira Protocol team

import "./Ownable.sol";

pragma solidity ^0.8.0;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract LaqiraTokenTimeLock is Ownable {
    uint256 public creationTime;
    
    // Number of tokens which is released after each period.
    uint256 private _periodicReleaseNum;
    
    // Seconds of 6 month is 15552000, release period is usually 6 month and all the tokens will be released in 8 periods(8 * 6 month = 4 yaers).
    uint256 public immutable period;
    
    // Number of tokens that has been withdrawn already.
    uint256 private _withdrawnTokens;
    
    IBEP20 private immutable _token;
    
    constructor(address _owner, IBEP20 token_, uint256 _period, uint256 periodicReleaseNum_) {
        _transferOwnership(_owner);
        _token = token_;
        creationTime = block.timestamp;
        period = _period;
        _periodicReleaseNum = periodicReleaseNum_;
    }
    
    function withdraw(uint256 _amount, address beneficiary_) public onlyOwner {
        require(availableTokens() >= _amount);
        token().transfer(beneficiary_, _amount);
        _withdrawnTokens += _amount;
    }
    
    function token() public view returns (IBEP20) {
        return _token;
    }
    
    function periodicReleaseNum() public view returns (uint256) {
        return _periodicReleaseNum;
    }
    
    function withdrawnTokens() public view returns (uint256) {
        return _withdrawnTokens;
    }
    
    function availableTokens() public view returns (uint256) {
        uint256 passedTime = block.timestamp - creationTime;
        uint256 balance = timeLockWalletBalance();
        uint256 available = ((passedTime / period) * _periodicReleaseNum) - _withdrawnTokens;
        if (available > balance)
            available = balance;
        return available;
    }
    
    function lockedTokens() public view returns (uint256) {
        uint256 balance = timeLockWalletBalance();
        return balance - availableTokens();
    }

    function timeLockWalletBalance() public view returns (uint256) {
        uint256 balance = token().balanceOf(address(this));
        return balance;
    }
}
