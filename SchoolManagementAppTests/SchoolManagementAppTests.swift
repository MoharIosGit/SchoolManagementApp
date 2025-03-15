//
//  SchoolManagementAppTests.swift
//  SchoolManagementAppTests
//
//  Created by Mohar on 15/03/25.
//


import XCTest
@testable import SchoolManagementApp

class SchoolManagementTests: XCTestCase {

    var schoolData: SchoolData!
    
    override func setUpWithError() throws {
        schoolData = SchoolData()
        schoolData.students = []
        schoolData.teachers = []
    }
    
    override func tearDownWithError() throws {
        schoolData = nil
    }
    
    // MARK: - Test Adding Students
    func testAddStudent() {
        let studentName = "John Doe"
        let studentGrade = "Grade 10"
        
        schoolData.addStudent(name: studentName, grade: studentGrade)
        
        XCTAssertEqual(schoolData.students.count, 1)
        XCTAssertEqual(schoolData.students.first?.name, studentName)
        XCTAssertEqual(schoolData.students.first?.grade, studentGrade)
    }
    
    // MARK: - Test Adding Teachers
    func testAddTeacher() {
        let teacherName = "Ms. Smith"
        let teacherSubject = "Mathematics"
        
        schoolData.addTeacher(name: teacherName, subject: teacherSubject)
        
        XCTAssertEqual(schoolData.teachers.count, 1)
        XCTAssertEqual(schoolData.teachers.first?.name, teacherName)
        XCTAssertEqual(schoolData.teachers.first?.subject, teacherSubject)
    }
    
    // MARK: - Test Saving and Loading Data
    func testSaveAndLoadData() {
        schoolData.addStudent(name: "Alice", grade: "Grade 9")
        schoolData.addTeacher(name: "Mr. Brown", subject: "Science")
        
        schoolData.saveData()
        
        let newSchoolData = SchoolData()
        newSchoolData.loadData()
        
        XCTAssertEqual(newSchoolData.students.count, 1)
        XCTAssertEqual(newSchoolData.teachers.count, 1)
    }
    
    // MARK: - Test Marking Student Attendance
    func testMarkStudentAttendance() {
        let studentName = "Jake"
        let studentGrade = "Grade 8"
        schoolData.addStudent(name: studentName, grade: studentGrade)
        
        let studentID = schoolData.students.first!.id
        let testDate = "2025-03-15"
        
        schoolData.markStudentAttendance(id: studentID, date: testDate, isPresent: true)
        
        XCTAssertEqual(schoolData.students.first?.attendance[testDate], true)
    }
    
    // MARK: - Test Marking Teacher Attendance
    func testMarkTeacherAttendance() {
        let teacherName = "Dr. Wilson"
        let teacherSubject = "History"
        schoolData.addTeacher(name: teacherName, subject: teacherSubject)
        
        let teacherID = schoolData.teachers.first!.id
        let testDate = "2025-03-15"
        
        schoolData.markTeacherAttendance(id: teacherID, date: testDate, isPresent: false)
        
        XCTAssertEqual(schoolData.teachers.first?.attendance[testDate], false)
    }
    
    // MARK: - Test Attendance Count for Dashboard
    func testTotalStudentAttendance() {
        schoolData.addStudent(name: "Lily", grade: "Grade 11")
        schoolData.addStudent(name: "Mark", grade: "Grade 12")
        
        let date = "2025-03-15"
        schoolData.markStudentAttendance(id: schoolData.students[0].id, date: date, isPresent: true)
        schoolData.markStudentAttendance(id: schoolData.students[1].id, date: date, isPresent: false)
        
        let totalAttendance = schoolData.students.reduce(0) { $0 + ($1.attendance[date] ?? false ? 1 : 0) }
        
        XCTAssertEqual(totalAttendance, 1)
    }
    
    func testTotalTeacherAttendance() {
        schoolData.addTeacher(name: "Prof. Adams", subject: "Physics")
        schoolData.addTeacher(name: "Ms. Emily", subject: "English")
        
        let date = "2025-03-15"
        schoolData.markTeacherAttendance(id: schoolData.teachers[0].id, date: date, isPresent: true)
        schoolData.markTeacherAttendance(id: schoolData.teachers[1].id, date: date, isPresent: true)
        
        let totalAttendance = schoolData.teachers.reduce(0) { $0 + ($1.attendance[date] ?? false ? 1 : 0) }
        
        XCTAssertEqual(totalAttendance, 2)
    }
    
}



