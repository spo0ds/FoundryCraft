// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/NTNFT.sol";
import "../src/interfaces/IKYC.sol";
import "../src/OxAuth.sol";
import "../src/KYC.sol";

contract KYCTest is Test, OxAuth {
    NTNFT public nft;
    KYC public kyc;

    function setUp() public {
        nft = new NTNFT();
        kyc = new KYC(address(nft));
    }

    function testsetUserData() public {
        string memory name = "John Doe";
        string memory fatherName = "Michael Doe";
        string memory motherName = "Jane Doe";
        string memory grandFatherName = "Robert Doe";
        string memory phoneNumber = "1234567890";
        string memory dob = "2000-01-01";
        string memory bloodGroup = "A+";
        string memory citizenshipNumber = "1234567890";
        string memory panNumber = "ABCDE1234F";
        string memory location = "Sample Address";
        vm.prank(address(1));
        uint tokenId = nft.mintNft();
        vm.prank(address(1));
        kyc.setUserData(
            name,
            fatherName,
            motherName,
            grandFatherName,
            phoneNumber,
            dob,
            bloodGroup,
            citizenshipNumber,
            panNumber,
            location
        );
        vm.prank(address(1));
        string memory retrievedName = kyc.decryptMyData(address(1), "name");
        vm.prank(address(1));
        string memory retrievedFatherName = kyc.decryptMyData(
            address(1),
            "father_name"
        );
        vm.prank(address(1));
        string memory retrievedMotherName = kyc.decryptMyData(
            address(1),
            "mother_name"
        );
        vm.prank(address(1));
        string memory retrievedGrandFatherName = kyc.decryptMyData(
            address(1),
            "grandFather_name"
        );
        vm.prank(address(1));
        string memory retrievedPhoneNumber = kyc.decryptMyData(
            address(1),
            "phone_number"
        );
        vm.prank(address(1));
        string memory retrievedDob = kyc.decryptMyData(address(1), "dob");
        vm.prank(address(1));
        string memory retrievedBloodGroup = kyc.decryptMyData(
            address(1),
            "blood_group"
        );
        vm.prank(address(1));
        string memory retrievedCitizenshipNumber = kyc.decryptMyData(
            address(1),
            "citizenship_number"
        );
        vm.prank(address(1));
        string memory retrievedPanNumber = kyc.decryptMyData(
            address(1),
            "pan_number"
        );
        vm.prank(address(1));
        string memory retrievedLocation = kyc.decryptMyData(
            address(1),
            "location"
        );

        assertEq(retrievedName, name);
        assertEq(retrievedFatherName, fatherName);
        assertEq(retrievedMotherName, motherName);
        assertEq(retrievedGrandFatherName, grandFatherName);
        assertEq(retrievedPhoneNumber, phoneNumber);
        assertEq(retrievedDob, dob);
        assertEq(retrievedBloodGroup, bloodGroup);
        assertEq(retrievedCitizenshipNumber, citizenshipNumber);
        assertEq(retrievedPanNumber, panNumber);
        assertEq(retrievedLocation, location);

        vm.prank(address(2));

        vm.expectRevert(KYC__AddressHasNotMinted.selector);
        kyc.setUserData(
            name,
            fatherName,
            motherName,
            grandFatherName,
            phoneNumber,
            dob,
            bloodGroup,
            citizenshipNumber,
            panNumber,
            location
        );
    }

    function testDecryptMyData() public {
        string memory name = "John Doe";
        string memory fatherName = "Michael Doe";
        string memory motherName = "Jane Doe";
        string memory grandFatherName = "Robert Doe";
        string memory phoneNumber = "1234567890";
        string memory dob = "2000-01-01";
        string memory bloodGroup = "A+";
        string memory citizenshipNumber = "1234567890";
        string memory panNumber = "ABCDE1234F";
        string memory location = "Sample Address";

        // Prank address(1)
        vm.prank(address(1));

        // Mint NFT
        nft.mintNft();

        // Prank address(1) again
        vm.prank(address(1));

        // Set user data
        kyc.setUserData(
            name,
            fatherName,
            motherName,
            grandFatherName,
            phoneNumber,
            dob,
            bloodGroup,
            citizenshipNumber,
            panNumber,
            location
        );
        // Prank address(1) again
        vm.prank(address(1));

        // Retrieve and assert decrypted name
        string memory retrievedName = kyc.decryptMyData(address(1), "name");
        assertEq(retrievedName, name);

        // Prank address(1) again
        vm.prank(address(1));

        // Expect revert when decrypting non-existent data
        try kyc.decryptMyData(address(1), "xyz") {} catch Error(
            string memory error
        ) {
            assertEq(error, "KYC__DataDoesNotExist");
        }

        vm.prank(address(2));
        try kyc.decryptMyData(address(1), "xyz") {} catch Error(
            string memory error
        ) {
            assertEq(error, "KYC__NotOwner");
        }
    }

    function testupdateKYCDetails() public {
        string memory name = "John Doe";
        string memory fatherName = "Michael Doe";
        string memory motherName = "Jane Doe";
        string memory grandFatherName = "Robert Doe";
        string memory phoneNumber = "1234567890";
        string memory dob = "2000-01-01";
        string memory bloodGroup = "A+";
        string memory citizenshipNumber = "1234567890";
        string memory panNumber = "ABCDE1234F";
        string memory location = "Sample Address";

        // Prank address(1)
        vm.prank(address(1));

        // Mint NFT
        nft.mintNft();

        // Prank address(1) again
        vm.prank(address(1));

        // Set user data
        kyc.setUserData(
            name,
            fatherName,
            motherName,
            grandFatherName,
            phoneNumber,
            dob,
            bloodGroup,
            citizenshipNumber,
            panNumber,
            location
        );

        vm.prank(address(1));
        kyc.updateKYCDetails("name", "Bob");
        vm.prank(address(1));
        string memory decryptedName = kyc.decryptMyData(address(1), "name");
        assertEq(decryptedName, "Bob");

        vm.prank(address(1));
        vm.expectRevert(KYC__FieldDoesNotExist.selector);
        kyc.updateKYCDetails("invalid_field", "xyz");
    }

    function teststoreRsaEncryptedinRetrievable() public {
        string memory kycField = "name";
        string memory data = "0x1234abcd";
        vm.prank(address(1));
        vm.expectRevert(KYC__NotYetApprovedToEncryptWithPublicKey.selector);
        kyc.storeRsaEncryptedinRetrievable(address(1), kycField, data);

        string memory name = "John Doe";
        string memory fatherName = "Michael Doe";
        string memory motherName = "Jane Doe";
        string memory grandFatherName = "Robert Doe";
        string memory phoneNumber = "1234567890";
        string memory dob = "2000-01-01";
        string memory bloodGroup = "A+";
        string memory citizenshipNumber = "1234567890";
        string memory panNumber = "ABCDE1234F";
        string memory location = "Sample Address";

        // Prank address(1)
        vm.prank(address(1));

        // Mint NFT
        nft.mintNft();
        vm.prank(address(2));
        nft.mintNft();
        // Prank address(1) again
        vm.prank(address(1));

        // Set user data
        kyc.setUserData(
            name,
            fatherName,
            motherName,
            grandFatherName,
            phoneNumber,
            dob,
            bloodGroup,
            citizenshipNumber,
            panNumber,
            location
        );

        vm.prank(address(2));
        kyc.requestApproveFromDataProvider(address(1), kycField);
        vm.prank(address(1));
        kyc.grantAccessToRequester(address(2), "name");
        vm.prank(address(1));
        kyc.storeRsaEncryptedinRetrievable(address(2), kycField, "Owner");
        vm.prank(address(2));
        string memory retrievedData = kyc.getRequestedDataFromProvider(
            address(1),
            kycField
        );
        assertEq(retrievedData, "Owner");
    }

    function testgetRequestedDataFromProvider() public {
        string memory kycField = "name";
        vm.prank(address(2));
        nft.mintNft();
        vm.prank(address(2));
        vm.expectRevert(KYC__NotYetApprovedToView.selector);
        kyc.getRequestedDataFromProvider(address(1), kycField);
        vm.prank(address(1));
        nft.mintNft();
        vm.prank(address(1));
        kyc.setUserData(
            "Owner",
            "Bob",
            "Carol",
            "Dave",
            "555-555-1234",
            "01/01/2000",
            "123456789",
            "ABCDE1234F",
            "New York",
            "true"
        );
        vm.prank(address(2));
        kyc.requestApproveFromDataProvider(address(1), kycField);
        vm.prank(address(1));
        kyc.grantAccessToRequester(address(2), kycField);
        vm.prank(address(1));
        kyc.storeRsaEncryptedinRetrievable(address(2), kycField, "owner");
        vm.prank(address(2));
        string memory retrievedData = kyc.getRequestedDataFromProvider(
            address(1),
            kycField
        );
        assertEq(retrievedData, "owner");
    }

    function testGenerateHash() public {
        string memory name = "John Doe";
        string memory fatherName = "Michael Doe";
        string memory motherName = "Jane Doe";
        string memory grandFatherName = "Robert Doe";
        string memory phoneNumber = "1234567890";
        string memory dob = "2000-01-01";
        string memory bloodGroup = "A+";
        string memory citizenshipNumber = "1234567890";
        string memory panNumber = "ABCDE1234F";
        string memory location = "Sample Address";

        // Prank address(1)
        vm.prank(address(1));

        // Mint NFT
        nft.mintNft();
        vm.prank(address(2));
        nft.mintNft();
        // Prank address(1) again
        vm.prank(address(1));

        // Set user data
        kyc.setUserData(
            name,
            fatherName,
            motherName,
            grandFatherName,
            phoneNumber,
            dob,
            bloodGroup,
            citizenshipNumber,
            panNumber,
            location
        );
        vm.prank(address(1));
        // Generate signed message hash
        bytes32 storedHash = kyc.generateHash(address(1));
        vm.prank(address(1));
        // Check if the hash is valid
        bytes32 messageHash = keccak256(
            abi.encodePacked(
                name,
                fatherName,
                motherName,
                grandFatherName,
                phoneNumber,
                dob,
                citizenshipNumber,
                panNumber,
                location
            )
        );
        bytes32 expectedHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        assertEq(storedHash, expectedHash);
    }
}
