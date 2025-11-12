// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyV2 {
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    constructor(address _implem) {
        _setImplementation(_implem);
    }

    function _setImplementation(address newImplementation) internal {
        require(newImplementation != address(0), "ProxyV2: invalid implementation address");

        assembly {
            sstore(IMPLEMENTATION_SLOT, newImplementation)
        }
    }

    function setImplementation(address newImplementation) public virtual {
        _setImplementation(newImplementation);
    }

    function getImplementation() public view returns (address implem) {
        assembly {
            implem := sload(IMPLEMENTATION_SLOT)
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