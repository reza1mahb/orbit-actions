// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.16;

import 'forge-std/Script.sol';
import { IReader4844 } from 'lib/nitro-contracts/src/libraries/IReader4844.sol';
import { CelestiaNitroContracts1Point2Point1UpgradeAction } from '../../../../contracts/parent-chain/contract-upgrades/CelestiaNitroContracts1Point2Point1UpgradeAction.sol';

import { ArbitrumChecker } from 'lib/nitro-contracts/src/libraries/ArbitrumChecker.sol';

import { OneStepProver0 } from 'lib/nitro-contracts/src/osp/OneStepProver0.sol';
import { OneStepProverMemory } from 'lib/nitro-contracts/src/osp/OneStepProverMemory.sol';
import { OneStepProverMath } from 'lib/nitro-contracts/src/osp/OneStepProverMath.sol';
import { OneStepProverHostIo } from 'lib/nitro-contracts/src/osp/OneStepProverHostIo.sol';
import { OneStepProofEntry } from 'lib/nitro-contracts/src/osp/OneStepProofEntry.sol';
import { ChallengeManager } from 'lib/nitro-contracts/src/challenge/ChallengeManager.sol';
import { SequencerInbox } from 'lib/nitro-contracts/src/bridge/SequencerInbox.sol';

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

    // deploy OSP templates
    address osp0 = address(new OneStepProver0());
    address ospMemory = address(new OneStepProverMemory());
    address ospMath = address(new OneStepProverMath());
    address ospHostIo = address(new OneStepProverHostIo());
    address osp = address(
      new OneStepProofEntry(osp0, ospMemory, ospMath, ospHostIo)
    );

    // deploy new challenge manager templates
    address challengeManager = address(new ChallengeManager());

    if (vm.envOr('DEPLOY_BOTH', false)) {
      // if true, also deploy the !IS_FEE_TOKEN_CHAIN action
      // only used to save gas cost when deploying both native and custom fee version

      // deploy sequencer inbox template
      address seqInbox2 = address(
        new SequencerInbox(
          vm.envUint('MAX_DATA_SIZE'),
          reader4844Address,
          !vm.envBool('IS_FEE_TOKEN_CHAIN')
        )
      );

      // finally deploy upgrade action
      new CelestiaNitroContracts1Point2Point1UpgradeAction({
        _newWasmModuleRoot: vm.envBytes32('WASM_MODULE_ROOT'),
        _newSequencerInboxImpl: seqInbox2,
        _newChallengeMangerImpl: challengeManager,
        _newOsp: osp
      });
    }

    // deploy sequencer inbox template
    address seqInbox = address(
      new SequencerInbox(
        vm.envUint('MAX_DATA_SIZE'),
        reader4844Address,
        vm.envBool('IS_FEE_TOKEN_CHAIN')
      )
    );

    // finally deploy upgrade action
    new CelestiaNitroContracts1Point2Point1UpgradeAction({
      _newWasmModuleRoot: vm.envBytes32('WASM_MODULE_ROOT'),
      _newSequencerInboxImpl: seqInbox,
      _newChallengeMangerImpl: challengeManager,
      _newOsp: osp
    });

    vm.stopBroadcast();
  }
}
