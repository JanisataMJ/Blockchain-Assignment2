// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract ScholarshipManagement {
    // โครงสร้างข้อมูลทุนการศึกษา
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

    Manage[] public scholarships; // เก็บข้อมูลทุนการศึกษาทั้งหมด
    mapping(uint256 => Manage) public addScholarships; // เก็บข้อมูลทุนการศึกษาตาม scholarshipId
    mapping(address => uint256[]) public historyScholarship; // เก็บประวัติทุนการศึกษาของผู้ใช้งาน
    mapping(string => Manage) private scholarshipsByRecipient; // เก็บข้อมูลทุนตาม recipientId เพื่อการค้นหาที่รวดเร็ว

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
        require(msg.value >= 0.000001 ether, "Incorrect payment amount"); // ตรวจสอบจำนวนเงินที่ส่งมา

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

        // บันทึกข้อมูล
        scholarships.push(newScholarship);
        addScholarships[scholarshipId] = newScholarship;
        historyScholarship[msg.sender].push(scholarshipId);
        scholarshipsByRecipient[recipientId] = newScholarship;

        // Emit event
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
        // ดึงข้อมูลจาก mapping
        Manage memory scholarship = scholarshipsByRecipient[recipientId];
        require(scholarship.from != address(0), "Scholarship not found"); // ตรวจสอบว่าข้อมูลมีอยู่หรือไม่
        return scholarship;
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