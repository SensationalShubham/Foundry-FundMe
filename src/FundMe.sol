// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe_NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    address private immutable i_owner;
    mapping(address => uint256) s_addressToAmtFunded;
    address[] s_funders;
    AggregatorV3Interface private s_priceFeed;

    uint256 public constant MINIMUM_USD = 10;

    constructor(address PriceFeed) {
        s_priceFeed = AggregatorV3Interface(PriceFeed);
        i_owner = msg.sender;
    }

    modifier onlyOwner() {
        if(msg.sender != i_owner) revert FundMe_NotOwner();
        _;
    }

    function fund() payable public{
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Atleast 5 bucks u need to make it count");
        s_addressToAmtFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public onlyOwner{
        uint256 fundersLength = s_funders.length;
        for (uint i = 0; i < fundersLength; i++) {
            address funder = s_funders[i]; 
            s_addressToAmtFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Txn. Failed");
    }


    // Getters functions

    function getFundBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getVersion() public view returns(uint){
        return s_priceFeed.version();
    } 

    function getAddressToAmountFunded(address fundingAddress) public view returns(uint256){
        return s_addressToAmtFunded[fundingAddress];
    }

    function getFunder(uint256 index) public view returns(address){
        return s_funders[index];
    }
    
    function getOwner() public view returns(address){
        return i_owner;
    }

    function getPriceFeed() public view returns(AggregatorV3Interface){
        return s_priceFeed;
    }
}