// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyV2 {
    // Define the storage slot for the implementation address
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    constructor(address _implem) {
        _setImplementation(_implem);
    }

    function _setImplementation(address newImplementation) internal {
        require(newImplementation != address(0), "ProxyV2: invalid implementation address");

        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    }

    function setImplementation(address newImplementation) public virtual {
        _setImplementation(newImplementation);
    }

    function getImplementation() public view returns (address implem) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        
        assembly {
            implem := sload(slot)
        }
    }

    fallback() external payable {
        address implem = getImplementation();
        require(implem != address(0), "ProxyV2: implementation not set");

        (bool success, bytes memory returnData) = implem.delegatecall(msg.data);

        if (success) {
            assembly {
                return(add(returnData, 0x20), mload(returnData))
            }
        } else {
            if (returnData.length > 0) {
                assembly {
                    revert(add(returnData, 0x20), mload(returnData))
                }
            } else {
                revert("ProxyV2: delegatecall failed");
            }
        }
    }

    receive() external payable {}
}