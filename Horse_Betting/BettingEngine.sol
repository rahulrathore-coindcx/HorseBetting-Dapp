// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./RaceCourse.sol";
import "./Betting.sol";
import "./ERC20.sol";

contract BettingEngine {
    RaceCourse[] races;  // store all raceCourse data
    Betting[] bets; // store all betting data
    uint256 betsInSystem = 0;
    
    uint256 public constant DECIMALS = 2;
    uint256 public constant HUNDRED = 100;

    mapping (uint256 => uint256[]) raceToBet; // mapping for a raceId to all corresponding bets

    function createBet(uint _raceIndex, uint _horseIndex, uint _amount, Betting.BetType _betType, Betting.Arealocation _location, address _tokenAddress) public payable{
        require(msg.value >= _amount,
            "Bet amount must be equal or less than sent amount");
        require(_raceIndex < races.length, "Race does not exist");
        
        // require(races[_raceIndex].endTime > block.timestamp, "Race has already run");
        // require((_horseIndex >= 0 && _horseIndex < races[_raceIndex].horses),
            // "Horse number does not exist in this race");
        //require(_tokenAddress.token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
        betsInSystem++;
        uint newBetId = (betsInSystem);
        raceToBet[newBetId].push(newBetId);
        Betting bet = new Betting(_raceIndex, _tokenAddress, _betType, _location, _amount, _horseIndex);
        bets.push(bet);
    }

    function createRace(uint256 _raceId, uint256 _horseNumbers, uint256 _startTime, uint256 _endTime, Betting.Arealocation _location) public {
        require(_startTime > block.timestamp, "Race must take place in the future");
        RaceCourse raceCourse  = new RaceCourse(_raceId, _location, _startTime, _endTime, _horseNumbers);
        races.push(raceCourse);
    }

    function evaluateRace(uint256 _raceIndex) public payable {
        //require(races[_raceIndex].endTime < block.timestamp, "Race not yet run");
        require(_raceIndex < races.length, "Race does not exist");
        RaceCourse race = races[_raceIndex];
        uint256[] memory winners = getRandom(race.horses);
        race.winners = winners;
        uint256[] memory betsInRace = raceToBet[_raceIndex];
        uint256 lossingAmount = 0;
      
        for (uint256 i=0;i<betsInRace.length;i++) {
            Betting bettingContract = bets[betsInRace[i]];
            for(uint256 j=0;j<winners.length;j++) {
                if (winners[j] == bettingContract.horseIndex) {
                    bettingContract.betResult = Betting.BetResult.Win;
                    race.winBetters[j].push(betsInRace[i]);
                    break;
                }
            }
            if (bettingContract.betResult == Betting.BetResult.NA) {
                bettingContract.betResult = Betting.BetResult.Loss;
                lossingAmount+= bettingContract.amount;
            }
        }
        distribute(_raceIndex,lossingAmount);
    }

    function distribute(uint256 _raceIndex, uint256 _amount) internal returns (bool) {
       uint256[] memory winners = races[_raceIndex].winners;
       uint256[] memory betters = races[_raceIndex].winBetter;
        for (uint256 i=1;i<=winners.length;i++) {
            uint256 distributionAmount = multiply(NthWinnerPercent(i), _amount);
            for(uint256 j=0;j<betters.length;j++) {
                Betting bettingContract = bets[betters[j]];
                uint256 contribution = divide(bettingContract.amount, _amount);
                uint256 bettingReward = multiply(contribution, distributionAmount);
                require(bettingContract.token.transferFrom(address(this), bettingContract.tokenAddress,  bettingContract.amount + bettingReward), "Token transfer failed");
            }
        }
    }

    function getRandom (uint256 _size) internal returns (uint256[] memory) {

        uint256[] memory arr = new uint256[](_size);
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
        
        for (uint256 i = 0; i < _size; i++) {
            // Generate a pseudo-random number using block information and seed
            seed = uint256(keccak256(abi.encodePacked(seed, blockhash(block.number - 1), i)));
            // Store the generated random number in the array
            arr[i] = seed % _size; // Assuming you want random numbers between 0 and size
        }

        return arr;
    }

    function NthWinnerPercent(uint256 n) internal returns (uint256) {
        // a = 50
        // r = 1/2
        // logic is based on GP
        // ar^n-1 = 100/2^n
        uint256 b = power(2,n);
        return divide(HUNDRED,b);
    }

    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        // Perform multiplication with extra precision and then divide
        return (a * b) / (10 ** DECIMALS);
    }

    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        // Multiply by 10^DECIMALS to keep the decimal places in the result
        return (a * (10 ** DECIMALS)) / b;
    }

    function power(uint256 base, uint256 exponent) public pure returns (uint256) {
        uint256 result = 1;
        for (uint256 i = 0; i < exponent; i++) {
            result = result * base;
        }
        return result;
    }
}