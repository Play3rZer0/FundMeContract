//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

//contract that implements owner
contract Ownable {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner Is Authorized Withdrawal");
        _;
    }

}

contract SafetyVault is Ownable {

//events to log deposit and withdrawals
    event Deposit(address indexed, uint);
    event Withdraw(address indexed, uint);
    event WithdrawAll(address indexed, uint);

//A mapping of users to their account balance on the contract
    mapping(address => uint) public balances;

//The main deposit function for funding the contract
    function deposit() public payable {
        require(msg.value > 0, "Invalid Amount");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

//Checks individual balance of the user
    function checkBalance() public view returns(uint) {
        return balances[msg.sender];
    }

//Checks the total balance of the contract
    function checkTotalBalance() public view returns(uint) {
        return address(this).balance;
    }

//Each depositor can withdraw their funds at anytime
    function withdraw() public payable {
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal Failed");
        emit Withdraw(msg.sender, msg.value);
    }

//Only the owner can withdraw all the funds
    function withdrawAll() public payable onlyOwner {
        uint amount = checkTotalBalance();
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal Failed");
        emit WithdrawAll(msg.sender, msg.value);
    }

//When funds are sent to the contract without using a function
    receive() external payable {
        deposit();
    }

}
