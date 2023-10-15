// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./Betting.sol";

contract RaceCourse {
    address public owner;
    uint256 public raceId;
    Betting.Arealocation public location;
    uint256 public startTime;
    uint256 public endTime;
    address[] public participants;
    uint256[] public winners;
    uint256[] public winBetters;
    uint256 public horses;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(uint256 _raceId, Betting.Arealocation _location, uint256 _startTime, uint256 _endTime, uint256 _horse) {
        owner = msg.sender;
        raceId = _raceId;
        location = _location;
        startTime = _startTime;
        endTime = _endTime;
        horses = _horse;
    }

    function getHorses() public view returns (uint256) {
        return horses;
    }

    function setWinners(uint256[] memory _winners) public {
    winners = _winners;
    }

    function getWinners() public view returns (uint256[] memory) {
     return winners;
    }

    function setWinBetter(uint256 _winBetter) public {
       winBetters.push(_winBetter);
    }

    function getWinBetters() public view returns (uint256[] memory) {
     return winBetters;
    }
    
}
