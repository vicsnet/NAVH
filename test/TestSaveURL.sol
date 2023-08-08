// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SaveURL.sol";

contract TestSaveURL {
SaveURL deployURL;

function deployAddress() public{
    deployURL = new SaveURL(1, 3, 100, 300);
}

function testCreateAccount() public{
    deployAddress();
    deployURL.CreateAccount();
}
function testBuyPremiumSpace() public{
    testCreateAccount();
}
}