// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentRegistry {

//Структура хранения данных о студенте
    struct Student{
        uint id;
        uint[] scores;
        string fullName;
        Status status;
        bool exists;
    } 

// Перечисление статуса
    enum Status {Enrolled, Graduated, Expelled}

//хранилище
// хешмап для присваивания адреса студенту
    mapping(address => Student) public students;
// список студентов
    address[] private studentAddress;// Registered;
// количество студентов
    uint totalStudentsCount; 

    
    /*constructor() {
        students[msg.sender].status = true;
    } */

    function registerStudent(string memory _fullName) external {
        if (students[msg.sender].exists = false) { // если студент не зарегистрирован
        uint[] memory _scores;
            students[msg.sender] = Student ({ // регистрируем
                id: totalStudentsCount,
                fullName: _fullName,
                scores: _scores,
                status : Status.Enrolled,
                exists: true
                });

            studentAddress.push(msg.sender); // записываем в address[] private StudentAddress;
            totalStudentsCount ++; // выдаем id
    }
        else {
            require(students[msg.sender].exists = true, "Student already registered"); // по fullname
        }
    }

    function AddScore (address _studentAddress, uint _score) external {
        if (students[_studentAddress].exists = true && _score <= 100) 
            students[_studentAddress].scores.push(_score);

    }

    function CalculateAverageScore(address _studentAddress) external view returns (uint) { //вводится адрес
        uint Length = students[_studentAddress].scores.length;
        require(students[_studentAddress].exists == false);
        require(Length > 0, "0"); //случай без оценок
        uint total;
        for (uint i = 0; i<Length; i++){ // цикл для подсчета оценки
             total += students[_studentAddress].scores[i];
        }
        uint AverageScore = total / Length; // округляет в меньшую сторону
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

    function getStudent (address _studentAddress) external view returns (uint, uint[] memory, string memory, Status ) {
        Student memory st = students[_studentAddress];
        return (st.id, st.scores, st.fullName, st.status);
    }

}

