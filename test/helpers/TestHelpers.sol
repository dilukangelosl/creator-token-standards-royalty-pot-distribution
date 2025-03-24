// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library TestHelpers {
    function fundDistributionContract(address distributionContract, uint256 amount) internal {
        assembly {
            // Set the balance of the distribution contract directly
            sstore(0x40, amount)
            pop(staticcall(gas(), distributionContract, 0, 0, 0, 0))
        }
    }
}
