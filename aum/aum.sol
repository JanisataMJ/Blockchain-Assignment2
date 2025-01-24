// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract ScholarshipManagement {
    // โครงสร้างข้อมูลการจอง
    struct Manage {
        address from;
        string recipientId;
        string recipientName;
        string grantName;
        uint256 grantAmount;
        string grantDate;
        string approver;
        string state;
    }

    Manage[] public scholarships;
    mapping(uint256 => Manage) public addScholarships; // เก็บข้อมูลทุนการศึกษาตาม scholarshipId
    mapping(address => uint256[]) public historyScholarship; // เก็บประวัติทุนการศึกษาของผู้ใช้งาน

    uint256 public nextScholarshipId = 1; // ตัวนับสำหรับ scholarshipId
    address public owner;

    event ScholarshipAdded(
        address indexed from,
        string recipientId,
        string recipientName,
        string grantName,
        uint256 grantAmount,
        string grantDate,
        string approver,
        string state
    );

    event ScholarshipError(address from, string recipientId, string reason);

    constructor() {
        owner = msg.sender; // กำหนด owner ของ contract
    }

    // เพิ่มทุนการศึกษา
    function addScholarship(
        string memory recipientId,
        string memory recipientName,
        string memory grantName,
        uint256 grantAmount,
        string memory grantDate,
        string memory approver,
        string memory state
    ) public payable {
        require(msg.value == 0.000001 ether, "Incorrect payment amount");

        uint256 scholarshipId = nextScholarshipId++;

        // สร้างทุนการศึกษาใหม่
        Manage memory newScholarship = Manage({
            from: msg.sender,
            recipientId: recipientId,
            recipientName: recipientName,
            grantName: grantName,
            grantAmount: grantAmount,
            grantDate: grantDate,
            approver: approver,
            state: state
        });

        scholarships.push(newScholarship);
        addScholarships[scholarshipId] = newScholarship;
        historyScholarship[msg.sender].push(scholarshipId);

        emit ScholarshipAdded(
            msg.sender,
            recipientId,
            recipientName,
            grantName,
            grantAmount,
            grantDate,
            approver,
            state
        );
    }

    // ดึงข้อมูลทุนการศึกษาตาม recipientId
    function getScholarship(string memory recipientId)
        public
        view
        returns (Manage memory)
    {
        for (uint256 i = 0; i < scholarships.length; i++) {
            // เปลี่ยน string i เป็น uint i
            if (
                keccak256(abi.encodePacked(scholarships[i].recipientId)) ==
                keccak256(abi.encodePacked(recipientId))
            ) {
                // ใช้ keccak256 และ abi.encodePacked เพื่อเปรียบเทียบ string
                return scholarships[i];
            }
        }
        revert("Scholarship not found");
    }

    // จำนวนทุนการศึกษาทั้งหมด
    function getTotalScholarships() public view returns (uint256) {
        return scholarships.length;
    }

    // ดึงข้อมูลทุนการศึกษาทั้งหมด
    function getAllScholarships() public view returns (Manage[] memory) {
        return scholarships;
    }
}