// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.18;

import "lib/forge-std/src/Script.sol";
import "../src/SmileDao.sol";
import "../src/SmileNFT.sol";
import "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorTimelockControl.sol";
import "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotes.sol";

contract Deployer is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address verifierContract = 0x7082dcF305BE310DE38294E1B339616Ce844b768;
        address deployer = vm.addr(deployerPrivateKey);

        address[] memory timelockProposers = new address[](0);
        address[] memory timelockExecuters = new address[](0);

        vm.startBroadcast(deployerPrivateKey);

        // TODO: Replace with verifier address
        SmileNFT nft = new SmileNFT(verifierContract);
        TimelockController timelock = new TimelockController(2 days, timelockProposers, timelockExecuters, deployer);

        SmileDao smileDao = new SmileDao(IVotes(address(nft)), timelock);

        // Grant roles to governor
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(smileDao));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(smileDao));
        timelock.grantRole(timelock.CANCELLER_ROLE(), address(smileDao));

        // Renounce admin role so that Timelock is the only admin
        timelock.renounceRole(timelock.TIMELOCK_ADMIN_ROLE(), deployer);
    }
}
