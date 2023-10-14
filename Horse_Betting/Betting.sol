// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract Betting {
    uint256 public raceId;
    uint256 public amount;
    uint256 public horseIndex;
    address tokenAddress;
    enum Arealocation {Amercia, EPAC}
    Arealocation public location;
    enum BetType { Win, Place, Show}
    enum BetResult { Win, Loss, Cancel, NA}
    BetResult public betResult;
    mapping(address => BetType) public userBets;

    ERC20Token public token;

    constructor(uint256 _raceId, address _tokenAddress, BetType _betType, Arealocation _location, uint256 _amount, uint256 _horseIndex) {
        raceId = _raceId;
        horseIndex = _horseIndex;
        location = _location;
        betResult = BetResult.NA;
        userBets[msg.sender] = _betType;
        amount = _amount;
        tokenAddress = _tokenAddress;
        token = ERC20Token(_tokenAddress);
    }
}
