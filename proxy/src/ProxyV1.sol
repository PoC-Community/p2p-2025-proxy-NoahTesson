// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyV1 {
    address public implem;

    constructor(address _implem) {
        implem = _implem;
    }

    receive() external payable {}

    function implementation() external view returns (address) {
        return implem;
    }
}