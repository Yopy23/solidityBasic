// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeLockedVault {
    // депозит меньше необходимого
    error InsufficientDeposit(uint256 sent, uint256 minRequired); 
    // время блокировки больше джоступного
    error ExceedsMaxLockDuration(uint256 requested, uint256 maxAllowed);
    // блокировка еще активна
    error LockPeriodActive(uint256 currentTime, uint256 unlockTime);
    // нет следств для выворда
    error NoFundsToWithdraw();
    error EthTransferFailed();

    struct LockBox {
        uint256 balance;
        uint256 unlockTimestamp;
    }

    mapping(address => LockBox) public vaults;


    uint MIN_DEPOSIT = 0.01 ether;
    uint MAX_DURATION = 365 days;

    function deposit(uint256 _lockDuration) external payable {

        LockBox storage box = vaults[msg.sender];
        require (msg.value >= MIN_DEPOSIT, InsufficientDeposit(msg.value, MIN_DEPOSIT));
        require (_lockDuration <= MAX_DURATION, ExceedsMaxLockDuration(_lockDuration, MAX_DURATION));

        uint256 newUnlockTimestamp = block.timestamp + _lockDuration;

        if (newUnlockTimestamp > box.unlockTimestamp) {
            box.unlockTimestamp = newUnlockTimestamp;
        }  

        box.balance += msg.value;
    }
    
    receive() external payable {

        LockBox storage box = vaults[msg.sender];
        require (msg.value >= MIN_DEPOSIT, InsufficientDeposit(msg.value, MIN_DEPOSIT));

        box.unlockTimestamp = block.timestamp + 1 days;
    }

    function withdraw() external {
        LockBox storage box = vaults[msg.sender];

        // checks
        require(box.balance > 0, NoFundsToWithdraw());
        require(block.timestamp >= box.unlockTimestamp, LockPeriodActive(block.timestamp, box.unlockTimestamp));

        // effects
        uint256 amountToTransfer = box.balance; 
        box.balance = 0;

        // interactions
        (bool success, ) = payable(msg.sender).call{value: amountToTransfer}("");
        if (!success) {
            revert EthTransferFailed();
        }
    }

    function packDepositData(
        address _user,
        uint256 _amount,
        uint256 _releaseTime
        ) external pure returns (bytes memory) {
        return abi.encode(_user, _amount, _releaseTime );
    }

    function unpackDepositData(bytes memory _data) external pure returns (
        address user,
        uint256 amount,
        uint256 releaseTime
        ) {
        (user, amount, releaseTime) = abi.decode(_data, (address, uint256, uint256));
    } 

}
