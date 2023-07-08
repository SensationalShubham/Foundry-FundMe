// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {deployFundMe} from "../../script/deployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract FundMeTest is StdCheats, Test{
    FundMe public fundMe;
    HelperConfig public helperConfig;

    uint256 public constant SEND_VALUE = 0.1 ether; // just a value to make sure we are sending enough!
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    address USER = address(1);

    function setUp() public {
        deployFundMe deployer = new deployFundMe();
        (fundMe, helperConfig) = deployer.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testPriceFeedSetCorrectly() public{
        address retrievePriceFeed = address(fundMe.getPriceFeed());
        address expectedPriceFeed = helperConfig.activeNetworkConfig();
        assertEq(retrievePriceFeed, expectedPriceFeed);
    }

    function testOwner() public{
        address owner = fundMe.getOwner();
        vm.startPrank(msg.sender);
        assertEq(owner, msg.sender);
        // assertEq(owner, address(this));
    }

    function testVersion() public{
        uint version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundMeRevert() public{
        vm.expectRevert();
        fundMe.fund();
    }

    modifier funded() {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();
        _;
    }

    function testAddressToAmtFunded() public funded{
        uint256 fundingAmt = fundMe.getAddressToAmountFunded(USER);
        assertEq(fundingAmt, SEND_VALUE);
    }

    function testGetFunderAddress() public funded{
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.expectRevert();
        fundMe.withdraw();
    }

     function testWithdrawFromASingleFunder() public funded {
        // Arrange
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // vm.txGasPrice(GAS_PRICE);
        // uint256 gasStart = gasleft();
        // // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance // + gasUsed
        );
    }
}