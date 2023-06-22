// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/OxAuth.sol";

contract OxAuthTest is Test {
    OxAuth public oxAuth;
    event ApproveRequest(
        address indexed requester,
        address indexed to,
        string indexed data
    );

    event AccessGrant(
        address indexed approver,
        address indexed thirdParty,
        string indexed data
    );

    event GrantRevoke(
        address indexed approver,
        address indexed requester,
        string data
    );

    function setUp() public {
        oxAuth = new OxAuth();
    }

    function testReqApprove() public {
        vm.prank(address(1));
        vm.expectEmit();
        emit ApproveRequest(address(2), address(1), "kyc");
        oxAuth.requestApproveFromDataProvider(address(2), "kyc");
    }

    function testEmitGrantAccess() public {
        vm.prank(address(2));
        oxAuth.requestApproveFromDataProvider(address(1), "name");
        vm.expectEmit();
        emit AccessGrant(address(1), address(2), "name");
        vm.prank(address(1));
        oxAuth.grantAccessToRequester(address(2), "name");
    }

    function testAcessData() public {
        vm.prank(address(2));
        oxAuth.requestApproveFromDataProvider(address(1), "name");
        vm.prank(address(1));
        oxAuth.grantAccessToRequester(address(2), "name");
        bool approveState = oxAuth.approveCondition(
            address(2),
            address(1),
            "name"
        );
        assertEq(approveState, true);
    }

    function testNotAcessData() public {
        vm.prank(address(2));
        oxAuth.requestApproveFromDataProvider(address(1), "name");
        vm.prank(address(1));
        oxAuth.grantAccessToRequester(address(2), "name");
        bool approveState = oxAuth.approveCondition(
            address(3),
            address(1),
            "name"
        );
        assertEq(approveState, false);
    }

    function testRevokeAccess() public {
        vm.prank(address(2));
        oxAuth.requestApproveFromDataProvider(address(1), "name");
        vm.prank(address(1));
        oxAuth.grantAccessToRequester(address(2), "name");
        vm.prank(address(1));
        oxAuth.revokeGrantToRequester(address(2), "name");
        bool approveState = oxAuth.approveCondition(
            address(2),
            address(1),
            "name"
        );
        assertEq(approveState, false);
    }

    function testFail() public {
        vm.prank(address(2));
        oxAuth.requestApproveFromDataProvider(address(1), "name");
        vm.prank(address(3));
        oxAuth.grantAccessToRequester(address(2), "name");
    }

    function testRevokeEvent() public {
        vm.prank(address(2));
        oxAuth.requestApproveFromDataProvider(address(1), "name");
        vm.prank(address(1));
        oxAuth.grantAccessToRequester(address(2), "name");
        vm.prank(address(1));
        vm.expectEmit();
        emit GrantRevoke(address(1), address(2), "name");
        oxAuth.revokeGrantToRequester(address(2), "name");
    }
}
