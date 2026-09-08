// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentRegistry {

    struct Student{
        uint id;
        uint[] scores;
        string fullName;
        bool status;
    }

    mapping(address => Student) public students;

    constructor (string memory _fullName, uint _id, uint _scores, bool _status, address _InitialStudent) {
        _InitialStudent = msg.sender;
        students[_id] = Student ({
        id: _id,
        scores:_scores,
        fullName: _fullName,
        Enrolled: !_status,
        Expelled: _status});
        // graduated обработка
    } 



    address[] Registred = new address[]();
    uint TotalStudents= 0;

    error StudentAllreadyRegistred;
    error StudentNotRegistred;
    
    
    /* function StudentTemplate(string memory _fullName, uint _id, uint _scores, bool _status) public {

        students[_id] = Student ({
        id: _id,
        scores:_scores,
        fullName: _fullName,
        Enrolled: !_status,
        Expelled: _status,
        Graduated: StudentGraduated});
    } */

    /*
    function RegisterStudent(string memory _fullName) public pure returns (bool) {
        if (!_status) {
            
        }

        

    }
    */
    
    

    function AddScore (address studentAddress, uint[] memory _score) public returns (uint[] memory) {
        uint additionalScore;
        //score.push(additionalScore);      
    }

    function CalculateAverageScore(uint[] _score) public view returns (uint) {
        uint length = _score.length;
        uint total;
        for (uint i = 0; i<length; i++){
             total += _score[i];
        }
           
        uint AverageScore = total / length; // округляет в меньшую сторону
        return AverageScore;

    }
    
   
    function ConvertGradeToLetter (uint Grade) public pure returns (string memory strGrade) {
        if (90<Grade<100) {
            strGrade = "A";
        }

        if (75<Grade<89) {
            strGrade = "B";
        }

        if (60<Grade<74) {
            strGrade = "C";
        }

        if (0<Grade<60) {
            strGrade = "F";
        }
    }

}

