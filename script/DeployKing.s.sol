
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {King} from "../src/King.sol";

contract DeployKing is Script {

    King king;

    function run() external returns(King) {
        vm.startBroadcast();
        king = new King();
        vm.stopBroadcast();

        return king;
    }

}