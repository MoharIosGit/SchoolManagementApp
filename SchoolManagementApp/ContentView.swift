//
//  ContentView.swift
//  SchoolManagementApp
//
//  Created by Mohar on 15/03/25.
//

import SwiftUI

// MARK: - Models
struct Student: Identifiable, Codable {
    let id: UUID
    var name: String
    var grade: String
    var attendance: [String: Bool] // Dictionary of Date -> Present/Absent
}

struct Teacher: Identifiable, Codable {
    let id: UUID
    var name: String
    var subject: String
    var attendance: [String: Bool] // Dictionary of Date -> Present/Absent
}

// MARK: - Data Persistence (UserDefaults)
class SchoolData: ObservableObject {
    @Published var students: [Student] = []
    @Published var teachers: [Teacher] = []
    
    init() {
        loadData()
    }
    
    func saveData() {
        let encoder = JSONEncoder()
        if let encodedStudents = try? encoder.encode(students),
           let encodedTeachers = try? encoder.encode(teachers) {
            UserDefaults.standard.set(encodedStudents, forKey: "students")
            UserDefaults.standard.set(encodedTeachers, forKey: "teachers")
        }
    }
    
    func loadData() {
        let decoder = JSONDecoder()
        if let savedStudents = UserDefaults.standard.data(forKey: "students"),
           let decodedStudents = try? decoder.decode([Student].self, from: savedStudents) {
            self.students = decodedStudents
        }
        
        if let savedTeachers = UserDefaults.standard.data(forKey: "teachers"),
           let decodedTeachers = try? decoder.decode([Teacher].self, from: savedTeachers) {
            self.teachers = decodedTeachers
        }
    }
    
    func addStudent(name: String, grade: String) {
        let newStudent = Student(id: UUID(), name: name, grade: grade, attendance: [:])
        students.append(newStudent)
        saveData()
    }
    
    func addTeacher(name: String, subject: String) {
        let newTeacher = Teacher(id: UUID(), name: name, subject: subject, attendance: [:])
        teachers.append(newTeacher)
        saveData()
    }
    
    func markStudentAttendance(id: UUID, date: String, isPresent: Bool) {
        if let index = students.firstIndex(where: { $0.id == id }) {
            students[index].attendance[date] = isPresent
            saveData()
        }
    }
    
    func markTeacherAttendance(id: UUID, date: String, isPresent: Bool) {
        if let index = teachers.firstIndex(where: { $0.id == id }) {
            teachers[index].attendance[date] = isPresent
            saveData()
        }
    }
    
    func deleteStudent(at offsets: IndexSet) {
        students.remove(atOffsets: offsets)
        saveData()
    }
    
    func deleteTeacher(at offsets: IndexSet) {
        teachers.remove(atOffsets: offsets)
        saveData()
    }
}

// MARK: - Attendance View
struct AttendanceView: View {
    @EnvironmentObject var schoolData: SchoolData
    @State private var selectedDate = Date()
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding()
                
                List {
                    Section(header: Text("Students Attendance")) {
                        ForEach(schoolData.students) { student in
                            HStack {
                                Text(student.name)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { student.attendance[formattedDate] ?? false },
                                    set: { newValue in schoolData.markStudentAttendance(id: student.id, date: formattedDate, isPresent: newValue) }
                                ))
                            }
                        }
                    }
                    
                    Section(header: Text("Teachers Attendance")) {
                        ForEach(schoolData.teachers) { teacher in
                            HStack {
                                Text(teacher.name)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { teacher.attendance[formattedDate] ?? false },
                                    set: { newValue in schoolData.markTeacherAttendance(id: teacher.id, date: formattedDate, isPresent: newValue) }
                                ))
                            }
                        }
                    }
                }
                .navigationTitle("Attendance")
            }
        }
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var schoolData: SchoolData
    
    var totalStudents: Int { schoolData.students.count }
    var totalTeachers: Int { schoolData.teachers.count }
    
    var totalStudentAttendance: Int {
        schoolData.students.reduce(0) { $0 + $1.attendance.values.filter { $0 }.count }
    }
    
    var totalTeacherAttendance: Int {
        schoolData.teachers.reduce(0) { $0 + $1.attendance.values.filter { $0 }.count }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("📚 School Dashboard").font(.largeTitle).bold().padding()
                
                HStack {
                    VStack {
                        Text("👨‍🎓 Students")
                        Text("\(totalStudents)")
                            .font(.largeTitle)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                    
                    VStack {
                        Text("👨‍🏫 Teachers")
                        Text("\(totalTeachers)")
                            .font(.largeTitle)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(10)
                }
                .padding()
                
                HStack {
                    VStack {
                        Text("📝 Student Attendance")
                        Text("\(totalStudentAttendance)")
                            .font(.largeTitle)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(10)
                    
                    VStack {
                        Text("📝 Teacher Attendance")
                        Text("\(totalTeacherAttendance)")
                            .font(.largeTitle)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Dashboard")
        }
    }
}

// MARK: - Main App View
struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            
            AttendanceView()
                .tabItem {
                    Label("Attendance", systemImage: "checkmark.circle.fill")
                }
            
            StudentListView()
                .tabItem {
                    Label("Students", systemImage: "person.2.fill")
                }
            
            TeacherListView()
                .tabItem {
                    Label("Teachers", systemImage: "person.crop.rectangle.fill")
                }
        }
        .environmentObject(SchoolData())
    }
}

// MARK: - Student List View
struct StudentListView: View {
    @EnvironmentObject var schoolData: SchoolData
    @State private var name = ""
    @State private var grade = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Add Student")) {
                        TextField("Name", text: $name)
                        TextField("Grade", text: $grade)
                        Button("Add") {
                            schoolData.addStudent(name: name, grade: grade)
                            name = ""
                            grade = ""
                        }
                    }
                    
                    Section(header: Text("Student List")) {
                        List {
                            ForEach(schoolData.students) { student in
                                VStack(alignment: .leading) {
                                    Text(student.name).font(.headline)
                                    Text("Grade: \(student.grade)").font(.subheadline)
                                }
                            }
                            .onDelete(perform: schoolData.deleteStudent)
                        }
                    }
                }
            }
            .navigationTitle("Students")
        }
    }
}


// MARK: - Teacher List View
struct TeacherListView: View {
    @EnvironmentObject var schoolData: SchoolData
    @State private var name = ""
    @State private var subject = ""

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Add Teacher")) {
                        TextField("Name", text: $name)
                        TextField("Subject", text: $subject)
                        Button("Add") {
                            schoolData.addTeacher(name: name, subject: subject)
                            name = ""
                            subject = ""
                        }
                    }

                    Section(header: Text("Teacher List")) {
                        List {
                            ForEach(schoolData.teachers) { teacher in
                                VStack(alignment: .leading) {
                                    Text(teacher.name).font(.headline)
                                    Text("Subject: \(teacher.subject)").font(.subheadline)
                                }
                            }
                            .onDelete(perform: schoolData.deleteTeacher)
                        }
                    }
                }
            }
            .navigationTitle("Teachers")
        }
    }
}

// MARK: - App Entry Point
@main
struct SchoolManagementApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SchoolData())
        }
    }
}


#Preview {
    ContentView()
}
