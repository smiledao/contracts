// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/Governor.sol";
import "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorTimelockControl.sol";
import "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotes.sol";

contract Deployer is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        address[] memory timelockProposers = new address[](0);
        address[] memory timelockExecuters = new address[](0);

        vm.startBroadcast(deployerPrivateKey);

        TimelockController timelock = new TimelockController(2 days, timelockProposers, timelockExecuters, deployer);

        // TODO: Replace with ERC721Votes
        Governor governor = new Governor(IVotes(address(0)), timelock);

        // Grant roles to governor
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));
        timelock.grantRole(timelock.CANCELLER_ROLE(), address(governor));

        // Renounce admin role so that Timelock is the only admin
        timelock.renounceRole(timelock.TIMELOCK_ADMIN_ROLE(), deployer);
    }
}
