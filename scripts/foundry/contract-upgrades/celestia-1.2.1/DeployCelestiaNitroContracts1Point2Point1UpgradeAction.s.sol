// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.16;

import 'forge-std/Script.sol';
import { CelestiaNitroContracts1Point2Point1UpgradeAction } from '../../../../contracts/parent-chain/contract-upgrades/CelestiaNitroContracts1Point2Point1UpgradeAction.sol';

/**
 * @title DeployCelestiaNitroContracts1Point2Point1UpgradeActionScript
 * @notice This script deploys OSPs and ChallengeManager templates, and SequencerInbox template.
 *          Not applicable for Arbitrum based chains due to precompile call in SequencerInbox (Foundry simulation breaks).
 */
contract DeployCelestiaNitroContracts1Point2Point1UpgradeActionScript is
  Script
{
  function run() public {
    vm.startBroadcast();

    if (vm.envOr('DEPLOY_BOTH', false)) {
      // if true, also deploy the !IS_FEE_TOKEN_CHAIN action
      // only used to save gas cost when deploying both native and custom fee version

      // finally deploy upgrade action
      new CelestiaNitroContracts1Point2Point1UpgradeAction({
        _newWasmModuleRoot: vm.envBytes32('WASM_MODULE_ROOT'),
        _newSequencerInboxImpl: 0x5e1DD81c7488040c44443DcC2E7dF61730f03296,
        _newChallengeMangerImpl: 0x84EDD049A8a54fB6ED6c239Ad46f5B021F150700,
        _newOsp: 0x69e34BC23faD5259f742542D45E80B3898a30d9a
      });
    }

    // finally deploy upgrade action
    new CelestiaNitroContracts1Point2Point1UpgradeAction({
      _newWasmModuleRoot: vm.envBytes32('WASM_MODULE_ROOT'),
      _newSequencerInboxImpl: 0x48d1687b7f25C699AC6AC6205378eA4790Bad49b,
      _newChallengeMangerImpl: 0x84EDD049A8a54fB6ED6c239Ad46f5B021F150700,
      _newOsp: 0x69e34BC23faD5259f742542D45E80B3898a30d9a
    });

    vm.stopBroadcast();
  }
}
