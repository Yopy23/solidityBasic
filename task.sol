// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentRegistry {

//Структура хранения данных о студенте
    struct Student{
        uint id;
        uint[] scores;
        string fullName;
        bool status;
        // bool Enrolled;
        // bool Expelled;
    } 

//хранилище
// хешмап для присваивания адреса студенту
    mapping(address => Student) public students;
// список студентов
    address[] public Registered;
// количество студентов
    uint TotalStudents= 0; 

    
    constructor() {
        students[msg.sender].status = true;
    }


// Конструктор для записи структуры студенту при инициализации
    function RegisterStudent(string memory _fullName, uint _id, uint[] memory _scores, bool _status) public  {
        students[msg.sender] = Student ({
            id: _id,
            scores: _scores,
            fullName: _fullName,
            status: _status
            // graduated обработка; 
            // Enrolled: !_status; Expelled: _status
            });

        Registered.push(msg.sender);
        TotalStudents+=1;
    } 

    // error StudentNotRegistered;


// функция читает состояние и изменяет его поэтому ни view(чтение), ни pure(запись) не подходят
    function StatusStudent() public {
        if (students[msg.sender].status == false) { // обращение к полю status внутри students относительно адреса студента
            students[msg.sender].status = true; // также учитывает и Graduated
        }
        else {
            revert("student is already enrolled or graduated");
        }  
    }

    function AddScore () public {
        uint additionalScore;
        students[msg.sender].scores.push(additionalScore);      
    }

    function CalculateAverageScore(uint[] memory _score) public pure returns (uint) {
        uint length = _score.length;
        require(length>0, "No scores"); // обработка случая без оценок
        uint total;
        for (uint i = 0; i<length; i++){
             total += _score[i];
        }
        uint AverageScore = total / length; // округляет в меньшую сторону
        return AverageScore;

    }
    
   
    function ConvertGradeToLetter (uint Grade) public pure returns (string memory strGrade) {
        if (90 <  Grade ||  Grade < 100 ) {
            strGrade = "A";
        }

        if (75 < Grade || Grade < 89) {
            strGrade = "B";
        }

        if (60 < Grade || Grade < 74) {
            strGrade = "C";
        }

        if (0 < Grade || Grade < 60) {
            strGrade = "F";
        }
    }

}
