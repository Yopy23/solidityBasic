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

// хешмап для присваивания адреса студенту
    mapping(address => Student) public students;

// Конструктор для записи структуры студенту при инициализации
    constructor (string memory _fullName, uint _id, uint[] _scores, bool _status) {
        students[msg.sender] = Student ({
            id: _id,
            scores: _scores,
            fullName: _fullName,
            status: _status
            // graduated обработка; 
            // Enrolled: !_status; Expelled: _status});

    } 


// хранилище 
    address[] public Registred = new address[]();
    uint TotalStudents= 0; 


    // error StudentNotRegistred;


// функция читает состояние и изменяет его поэтому ни view(чтение), ни pure(запись) не подходят
    function RegisterStudent() public returns (bool) {
        if (students[msg.sender].status == false) { // обращение к полю status внутри students относительно адреса студента
            students[msg.sender].status = true; // также учитывает и Graduated
        }
        else {
            revert("student is already enrolled or graduated");
        }  
    }
    
    

    function AddScore (address studentAddress, uint[] memory _score) public returns (uint[] memory) {
        uint additionalScore;
        //score.push(additionalScore);      
    }

    function CalculateAverageScore(uint[] _score) public view returns (uint) {
        uint length = _score.length;
        require(length>0, "No scores" // обработка случая без оценок
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

/* function StudentTemplate(string memory _fullName, uint _id, uint _scores, bool _status) public {

        students[_id] = Student ({
        id: _id,
        scores:_scores,
        fullName: _fullName,
        Enrolled: !_status,
        Expelled: _status,
        Graduated: StudentGraduated});
    } */


