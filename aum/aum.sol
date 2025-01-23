// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract ScholarshipManagement {  

    // โครงสร้างข้อมูลการจอง
    struct Manage {
        uint256 recipientId;
        address recipient;
        string grantName;
        uint256 grantAmount;
        string grantDate;
        string approver;
        string status;
    }

    Manage[] public scholarships;
    mapping(uint256 => bool) private scholarshipExists;

    event ScholarshipAdded(
        uint256 indexed recipientId,
        address indexed recipient,
        string grantName,
        uint256 grantAmount
    );

    event ScholarshipError(
        address from,
        string reason
    );

    // เพิ่มทุนการศึกษา
    function addScholarship(
        uint256 _recipientId,
        address _recipient, 
        string memory _grantName,
        uint256 _grantAmount,
        string memory _grantDate,
        string memory _approver,
        string memory _status
    ) public {
        // ตรวจสอบว่า Scholarship ID ซ้ำหรือไม่
        if (scholarshipExists[_recipientId]) {
            emit ScholarshipError(msg.sender, "Scholarship ID already exists");
            return;
        }

        // สร้างทุนการศึกษาใหม่
        Manage memory newScholarship = Manage({
            recipientId: _recipientId,
            recipient: _recipient,
            grantName: _grantName,
            grantAmount: _grantAmount,
            grantDate: _grantDate,
            approver: _approver,
            status: _status
        });

        scholarships.push(newScholarship);
        scholarshipExists[_recipientId] = true;

        emit ScholarshipAdded(_recipientId, _recipient, _grantName, _grantAmount);
    }

    // ดึงข้อมูลทุนการศึกษา
    function getScholarship(uint256 _recipientId) public view returns (Manage memory) {
        for (uint256 i = 0; i < scholarships.length; i++) {
            if (scholarships[i].recipientId == _recipientId) {
                return scholarships[i];
            }
        }
        revert("Scholarship not found");
    }

    // จำนวนทุนการศึกษาทั้งหมด
    function getTotalScholarships() public view returns (uint256) {
        return scholarships.length;
    }

    // การจัดการนักเรียน
    mapping(bytes32 => bool) private listStudent;

    event NameAdded(address indexed student, string name, bytes32 proof);
    event RegistrationError(address from, string name, string reason);

    // บันทึกค่าการพิสูจน์
    function recordProof(bytes32 proof) private {
        listStudent[proof] = true;
    }

    // ลงทะเบียนนักเรียน
    function registration(string memory name) public payable {
        bytes32 nameHash = hashing(name);

        // ตรวจสอบว่านักเรียนนี้ลงทะเบียนแล้วหรือยัง
        if (listStudent[nameHash]) {
            emit RegistrationError(msg.sender, name, "This student was added previously");
            payable(msg.sender).transfer(msg.value); // คืนเงินให้ผู้ส่ง
            return;
        }

        // ตรวจสอบค่าธรรมเนียมการลงทะเบียน
        if (msg.value != 0.002 ether) {
            emit RegistrationError(msg.sender, name, "Incorrect amount of Ether. 0.002 ether for registration");
            payable(msg.sender).transfer(msg.value); // คืนเงินให้ผู้ส่ง
            return;
        }

        // บันทึกชื่อ
        recordProof(nameHash);
        emit NameAdded(msg.sender, name, nameHash);
    }

    // ฟังก์ชัน Hashing (SHA256)
    function hashing(string memory name) private pure returns (bytes32) {
        return sha256(bytes(name));
    }

    // ตรวจสอบชื่อนักเรียน
    function checkName(string memory name) public view returns (bool) {
        return listStudent[hashing(name)];
    }
}