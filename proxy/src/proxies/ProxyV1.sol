// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyV1 {
    uint256 public count = 0;
    address public implem;

    constructor(address _implem) {
        implem = _implem;
    }

    receive() external payable {}

    function implementation() external view returns (address) {
        return implem;
    }

    fallback() external payable {
        (bool success, bytes memory returnData) = implem.delegatecall(msg.data);

        if (!success) {
            if (returnData.length > 0) {
                assembly {
                    let returndata_size := mload(returnData)
                    revert(add(32, returnData), returndata_size)
                }
            } else {
                revert("Delegatecal falied without reason");
            }
        }
        assembly {
            return(add(returnData, 32), mload(returnData))
        }
    }
}