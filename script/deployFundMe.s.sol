// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract deployFundMe is Script{
    HelperConfig helperConfig = new HelperConfig();
    address Pricefeed = helperConfig.activeNetworkConfig();

    function run() public returns(FundMe, HelperConfig){
        vm.startBroadcast();
        FundMe fundMe = new FundMe(Pricefeed);
        vm.stopBroadcast();
        return (fundMe, helperConfig);
    }
}