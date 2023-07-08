// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script{
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig{
        address PriceFeed;
    }

    constructor() {
        if(block.chainid == 11155111){
            activeNetworkConfig = sepoliaNetworkConfig();
        } else {
            activeNetworkConfig = anvilNetworkConfig();
        }
    }

    function sepoliaNetworkConfig() public pure returns(NetworkConfig memory sepoliaConfig){
        sepoliaConfig = NetworkConfig({
            PriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function anvilNetworkConfig() public returns(NetworkConfig memory anvilConfig){
        if(activeNetworkConfig.PriceFeed != address(0)){
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        anvilConfig = NetworkConfig({
            PriceFeed: address(mockV3Aggregator)
        });
    }

    
}