// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/utils/Strings.sol";
import {Script, console} from "forge-std/Script.sol";
import {MinimalSmartAccount} from "../src/MSA.sol";
import {MSAFactory} from "../src/MSAFactory.sol";
import {MSAProxy} from "../src/MSAProxy.sol";

contract Deploy is Script {
    using Strings for uint256;

    /// @dev Included to enable compilation of the script without a $MNEMONIC environment variable.
    string internal constant TEST_MNEMONIC = "test test test test test test test test test test test junk";

    /// @dev Needed for the deterministic deployments.
    bytes32 internal ZERO_SALT;

    /// @dev The address of the transaction broadcaster.
    address internal broadcaster;

    /// @dev Used to derive the broadcaster's address if $ETH_FROM is not defined.
    string internal mnemonic;

    /// @dev Needed for the deterministic deployments.
    bytes32 internal salt;
    
    /// @dev Initializes the transaction broadcaster like this:
    ///
    /// - If $ETH_FROM is defined, use it.
    /// - Otherwise, derive the broadcaster address from $MNEMONIC.
    /// - If $MNEMONIC is not defined, default to a test mnemonic.
    ///
    /// The use case for $ETH_FROM is to specify the broadcaster key and its address via the command line.
    function setUp() public {
        address from = vm.envOr({ name: "ETH_FROM", defaultValue: address(0) });
        salt = vm.envOr({ name: "SALT", defaultValue: ZERO_SALT });

        if (from != address(0)) {
            broadcaster = from;
        } else {
            mnemonic = vm.envOr({ name: "MNEMONIC", defaultValue: TEST_MNEMONIC });
            (broadcaster,) = deriveRememberKey({ mnemonic: mnemonic, index: 0 });
        }
    }

    modifier broadcast() {
        vm.startBroadcast(broadcaster);
        _;
        vm.stopBroadcast();
    }

    function run() broadcast external {
        string memory chainId = block.chainid.toString();

        MinimalSmartAccount _MinimalSmartAccount = new MinimalSmartAccount{salt:salt}();
        MSAFactory _MSAFactory = new MSAFactory{salt:salt}(address(_MinimalSmartAccount));

        console.log("MinimalSmartAccount: ", address(_MinimalSmartAccount));
        console.log("MSAFactory: ", address(_MSAFactory));

        vm.serializeAddress(chainId,"broadcaster", address(broadcaster));
        vm.serializeBytes32(chainId,"salt", salt);
        vm.serializeAddress(chainId,"MinimalSmartAccount", address(_MinimalSmartAccount));
        string memory finalJson = vm.serializeAddress(chainId,"MSAFactory", address(_MSAFactory));

        vm.writeJson(finalJson, string.concat("./script-deploy-data/",chainId,".json"));

    }
}