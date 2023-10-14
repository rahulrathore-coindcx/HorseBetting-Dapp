// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ERC20Token {
    mapping(address => uint256) public balanceOf;

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    // function transferTokensAndEther(address to, uint256 amount) external payable returns (bool) {
    //     // Transfer tokens
    //     require(balanceOf[msg.sender] >= amount, "Insufficient balance");
    //     balanceOf[msg.sender] -= amount;
    //     balanceOf[to] += amount;

    //     // Transfer Ether
    //     require(msg.value >= amount, "Insufficient Ether sent");
    //     (bool, success, ) = to.call{value: amount}("");
    //     require(success, "Transfer failed");

    //     return true;
    // }
}
