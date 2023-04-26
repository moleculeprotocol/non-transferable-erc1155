// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { MyToken } from "../contracts/MyToken.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();

        MyToken token = new MyToken();

        console.log("Token deployed at: %s", address(token));

        vm.stopBroadcast();
    }
}
