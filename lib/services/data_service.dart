import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../models/user_model.dart';

class DataService {
  static final DataService _instance = DataService._internal();

  factory DataService() => _instance;

    DataService._internal() {
    _initializeData();
  }

    String? _currentUserId;
  UserType? _currentUserType;

  void setCurrentUser(String userId, UserType userType) {
    _currentUserId = userId;
    _currentUserType = userType;
  }

  String? get currentUserId => _currentUserId;
  UserType? get currentUserType => _currentUserType;

    late final List<Student> _students;
  late final List<Teacher> _teachers;
  late final List<SchoolClass> _classes;
  late final List<Subject> _subjects;
  late final List<TimetableEntry> _timetable;
  late final List<Grade> _grades;
  late final List<Attendance> _attendance;
  late final List<Assignment> _assignments;
  late final List<Message> _messages;
  late final List<SchoolEvent> _events;
  late final List<Document> _documents;

  void _initializeData() {
    _initializeSubjects();
    _initializeTeachers();
    _initializeClasses();
    _initializeStudents();
    _initializeTimetable();
    _initializeGrades();
    _initializeAttendance();
    _initializeAssignments();
    _initializeMessages();
    _initializeEvents();
    _initializeDocuments();
  }

  void _initializeSubjects() {
    _subjects = [
      Subject(id: '1', name: 'Matematika', shortName: 'MAT', color: Colors.blue),
      Subject(id: '2', name: 'Český jazyk', shortName: 'ČJ', color: Colors.red),
      Subject(id: '3', name: 'Anglický jazyk', shortName: 'AJ', color: Colors.green),
      Subject(id: '4', name: 'Fyzika', shortName: 'FYZ', color: Colors.purple),
      Subject(id: '5', name: 'Chemie', shortName: 'CHE', color: Colors.orange),
      Subject(id: '6', name: 'Biologie', shortName: 'BIO', color: Colors.teal),
      Subject(id: '7', name: 'Dějepis', shortName: 'DEJ', color: Colors.brown),
      Subject(id: '8', name: 'Zeměpis', shortName: 'ZEM', color: Colors.cyan),
      Subject(id: '9', name: 'Informatika', shortName: 'INF', color: Colors.indigo),
      Subject(id: '10', name: 'Tělesná výchova', shortName: 'TV', color: Colors.amber),
    ];
  }

  void _initializeTeachers() {
    _teachers = [
      Teacher(
        id: 'teacher1',
        firstName: 'Jan',
        lastName: 'Novák',
        email: 'j.novak@skola.cz',
        phone: '+420 123 456 789',
        subjectIds: ['1', '4'],
        classIds: ['1a', '2a', '3b', '3c'],
        title: 'Mgr.',
      ),
      Teacher(
        id: 'teacher2',
        firstName: 'Marie',
        lastName: 'Svobodová',
        email: 'm.svobodova@skola.cz',
        phone: '+420 234 567 890',
        subjectIds: ['2', '7'],
        classIds: ['2a', '2b'],
        title: 'PhDr.',
      ),
      Teacher(
        id: 'teacher3',
        firstName: 'Petr',
        lastName: 'Dvořák',
        email: 'p.dvorak@skola.cz',
        phone: '+420 345 678 901',
        subjectIds: ['3'],
        classIds: ['2a', '2b', '3a', '3b'],
        title: 'Mgr.',
      ),
      Teacher(
        id: 'teacher4',
        firstName: 'Eva',
        lastName: 'Procházková',
        email: 'e.prochazkova@skola.cz',
        phone: '+420 456 789 012',
        subjectIds: ['5', '6'],
        classIds: ['2a', '3a', '3b'],
        title: 'RNDr.',
      ),
      Teacher(
        id: 'teacher5',
        firstName: 'Pavel',
        lastName: 'Sportovec',
        email: 'p.sportovec@skola.cz',
        phone: '+420 567 890 123',
        subjectIds: ['10'],         classIds: ['2a', '2b', '3a'],
        title: 'Mgr.',
      ),
      Teacher(
        id: 'teacher6',
        firstName: 'Lucie',
        lastName: 'Kodérová',
        email: 'l.koderova@skola.cz',
        phone: '+420 678 901 234',
        subjectIds: ['9'],         classIds: ['2a', '3b'],
        title: 'Ing.',
      ),
      Teacher(
        id: 'teacher7',
        firstName: 'Martin',
        lastName: 'Zeměpisný',
        email: 'm.zemepisny@skola.cz',
        phone: '+420 789 012 345',
        subjectIds: ['8'],         classIds: ['2a', '3a', '3b'],
        title: 'Mgr.',
      ),
    ];
  }

  void _initializeClasses() {
    _classes = [
      SchoolClass(
        id: '1a',
        name: '1.A',
        teacherId: 'teacher1',
        studentIds: ['student13', 'student14', 'student15', 'student18'],
        year: 7,
      ),
      SchoolClass(
        id: '2a',
        name: '2.A',
        teacherId: 'teacher1',
        studentIds: ['student1', 'student2', 'student3', 'student9', 'student10'],
        year: 8,
      ),
      SchoolClass(
        id: '2b',
        name: '2.B',
        teacherId: 'teacher2',
        studentIds: ['student4', 'student5', 'student6'],
        year: 8,
      ),
      SchoolClass(
        id: '3a',
        name: '3.A',
        teacherId: 'teacher3',
        studentIds: [],
        year: 9,
      ),
      SchoolClass(
        id: '3b',
        name: '3.B',
        teacherId: 'teacher4',
        studentIds: ['student7', 'student8', 'student11', 'student12'],
        year: 9,
      ),
      SchoolClass(
        id: '3c',
        name: '3.C',
        teacherId: 'teacher1',
        studentIds: ['student16', 'student17', 'student19'],
        year: 9,
      ),
    ];
  }

  void _initializeStudents() {
    _students = [
            Student(
        id: 'student13',
        firstName: 'Lucie',
        lastName: 'Nováková',
        classId: '1a',
        email: 'l.novakova@student.skola.cz',
        birthDate: DateTime(2011, 4, 10),
        parentEmail: 'novakova.rodic@email.cz',
        parentPhone: '+420 777 888 999',
        address: 'Parková 15, Praha',
      ),
      Student(
        id: 'student14',
        firstName: 'Jan',
        lastName: 'Dvořák',
        classId: '1a',
        email: 'j.dvorak@student.skola.cz',
        birthDate: DateTime(2011, 7, 22),
        parentEmail: 'dvorak.rodic@email.cz',
        parentPhone: '+420 666 555 444',
        address: 'Lesní 20, Praha',
      ),
      Student(
        id: 'student15',
        firstName: 'Eva',
        lastName: 'Malá',
        classId: '1a',
        email: 'e.mala@student.skola.cz',
        birthDate: DateTime(2011, 12, 5),
        parentEmail: 'mala.rodic@email.cz',
        parentPhone: '+420 333 222 111',
        address: 'Školní 33, Praha',
      ),
      Student(
        id: 'student18',
        firstName: 'Tomáš',
        lastName: 'Veselý',
        classId: '1a',
        email: 't.vesely@student.skola.cz',
        birthDate: DateTime(2011, 9, 18),
        parentEmail: 'vesely.rodic@email.cz',
        parentPhone: '+420 444 333 222',
        address: 'Krátká 8, Praha',
      ),

            Student(
        id: 'student1',
        firstName: 'Tomáš',
        lastName: 'Kolář',
        classId: '2a',
        email: 't.kolar@student.skola.cz',
        birthDate: DateTime(2010, 5, 15),
        parentEmail: 'kolar.rodic@email.cz',
        parentPhone: '+420 601 234 567',
        address: 'Hlavní 123, Praha',
      ),
      Student(
        id: 'student2',
        firstName: 'Anna',
        lastName: 'Horáková',
        classId: '2a',
        email: 'a.horakova@student.skola.cz',
        birthDate: DateTime(2010, 3, 22),
        parentEmail: 'horakova.rodic@email.cz',
        parentPhone: '+420 602 345 678',
        address: 'Školní 456, Praha',
      ),
      Student(
        id: 'student3',
        firstName: 'David',
        lastName: 'Černý',
        classId: '2a',
        email: 'd.cerny@student.skola.cz',
        birthDate: DateTime(2010, 8, 10),
        parentEmail: 'cerny.rodic@email.cz',
        parentPhone: '+420 603 456 789',
        address: 'Nová 789, Praha',
      ),
      Student(
        id: 'student9',
        firstName: 'Eliška',
        lastName: 'Nováková',
        classId: '2a',
        email: 'e.novakova@student.skola.cz',
        birthDate: DateTime(2010, 1, 30),
        parentEmail: 'novakova.rodic@email.cz',
        parentPhone: '+420 609 123 456',
        address: 'Parkova 15, Praha',
      ),
      Student(
        id: 'student10',
        firstName: 'Filip',
        lastName: 'Procházka',
        classId: '2a',
        email: 'f.prochazka@student.skola.cz',
        birthDate: DateTime(2010, 6, 18),
        parentEmail: 'prochazka.rodic@email.cz',
        parentPhone: '+420 610 234 567',
        address: 'Lesní 42, Praha',
      ),

            Student(
        id: 'student4',
        firstName: 'Klára',
        lastName: 'Veselá',
        classId: '2b',
        email: 'k.vesela@student.skola.cz',
        birthDate: DateTime(2010, 12, 3),
        parentEmail: 'vesela.rodic@email.cz',
        parentPhone: '+420 604 567 890',
        address: 'Krásná 321, Praha',
      ),
      Student(
        id: 'student5',
        firstName: 'Martin',
        lastName: 'Svoboda',
        classId: '2b',
        email: 'm.svoboda@student.skola.cz',
        birthDate: DateTime(2010, 7, 18),
        parentEmail: 'svoboda.rodic@email.cz',
        parentPhone: '+420 605 678 901',
        address: 'Dlouhá 654, Praha',
      ),
      Student(
        id: 'student6',
        firstName: 'Jakub',
        lastName: 'Novotný',
        classId: '2b',
        email: 'j.novotny@student.skola.cz',
        birthDate: DateTime(2010, 9, 14),
        parentEmail: 'novotny.rodic@email.cz',
        parentPhone: '+420 606 789 012',
        address: 'Školní 987, Praha',
      ),

            Student(
        id: 'student7',
        firstName: 'Tereza',
        lastName: 'Svobodová',
        classId: '3b',
        email: 't.svobodova@student.skola.cz',
        birthDate: DateTime(2009, 4, 25),
        parentEmail: 'svobodova.rodic@email.cz',
        parentPhone: '+420 607 890 123',
        address: 'Nádražní 654, Praha',
      ),
      Student(
        id: 'student8',
        firstName: 'Michal',
        lastName: 'Dvořák',
        classId: '3b',
        email: 'm.dvorak@student.skola.cz',
        birthDate: DateTime(2009, 11, 8),
        parentEmail: 'dvorak.rodic@email.cz',
        parentPhone: '+420 608 901 234',
        address: 'Krásná 321, Praha',
      ),
      Student(
        id: 'student11',
        firstName: 'Viktorie',
        lastName: 'Kratochvílová',
        classId: '3b',
        email: 'v.kratochvilova@student.skola.cz',
        birthDate: DateTime(2009, 2, 12),
        parentEmail: 'kratochvilova.rodic@email.cz',
        parentPhone: '+420 611 345 678',
        address: 'Zahradní 28, Praha',
      ),
      Student(
        id: 'student12',
        firstName: 'Ondřej',
        lastName: 'Krejčí',
        classId: '3b',
        email: 'o.krejci@student.skola.cz',
        birthDate: DateTime(2009, 9, 5),
        parentEmail: 'krejci.rodic@email.cz',
        parentPhone: '+420 612 456 789',
        address: 'Sportovní 73, Praha',
      ),

            Student(
        id: 'student16',
        firstName: 'Petr',
        lastName: 'Horák',
        classId: '3c',
        email: 'p.horak@student.skola.cz',
        birthDate: DateTime(2009, 3, 15),
        parentEmail: 'horak.rodic@email.cz',
        parentPhone: '+420 999 888 777',
        address: 'Nádražní 44, Praha',
      ),
      Student(
        id: 'student17',
        firstName: 'Michaela',
        lastName: 'Krejčí',
        classId: '3c',
        email: 'm.krejci@student.skola.cz',
        birthDate: DateTime(2009, 6, 21),
        parentEmail: 'krejci.rodic@email.cz',
        parentPhone: '+420 111 222 333',
        address: 'Zahradní 55, Praha',
      ),
      Student(
        id: 'student19',
        firstName: 'Štěpán',
        lastName: 'Pokorný',
        classId: '3c',
        email: 's.pokorny@student.skola.cz',
        birthDate: DateTime(2009, 10, 12),
        parentEmail: 'pokorny.rodic@email.cz',
        parentPhone: '+420 555 666 777',
        address: 'Dlouhá 88, Praha',
      ),
    ];
  }

  void _initializeTimetable() {
        _timetable = [
            TimetableEntry(
        id: 'tt1',
        subjectId: '1',
        teacherId: 'teacher1',
        classId: '2a',
        room: 'U102',
        dayOfWeek: 1,
        period: 1,
        startTime: DateTime(2024, 1, 1, 7, 5),
        endTime: DateTime(2024, 1, 1, 7, 50),
      ),
      TimetableEntry(
        id: 'tt2',
        subjectId: '2',
        teacherId: 'teacher2',
        classId: '2a',
        room: 'U205',
        dayOfWeek: 1,
        period: 2,
        startTime: DateTime(2024, 1, 1, 8, 0),
        endTime: DateTime(2024, 1, 1, 8, 45),
      ),
      TimetableEntry(
        id: 'tt3',
        subjectId: '3',
        teacherId: 'teacher3',
        classId: '2a',
        room: 'U308',
        dayOfWeek: 1,
        period: 3,
        startTime: DateTime(2024, 1, 1, 8, 55),
        endTime: DateTime(2024, 1, 1, 9, 40),
      ),
      TimetableEntry(
        id: 'tt4',
        subjectId: '4',
        teacherId: 'teacher1',
        classId: '2a',
        room: 'U110',
        dayOfWeek: 1,
        period: 4,
        startTime: DateTime(2024, 1, 1, 9, 55),
        endTime: DateTime(2024, 1, 1, 10, 40),
      ),
      TimetableEntry(
        id: 'tt5',
        subjectId: '10',
        teacherId: 'teacher5',
        classId: '2a',
        room: 'Tělocvična',
        dayOfWeek: 1,
        period: 5,
        startTime: DateTime(2024, 1, 1, 10, 50),
        endTime: DateTime(2024, 1, 1, 11, 35),
      ),
      TimetableEntry(
        id: 'tt6',
        subjectId: '7',
        teacherId: 'teacher2',
        classId: '2a',
        room: 'U303',
        dayOfWeek: 1,
        period: 6,
        startTime: DateTime(2024, 1, 1, 11, 45),
        endTime: DateTime(2024, 1, 1, 12, 30),
      ),
      TimetableEntry(
        id: 'tt34',
        subjectId: '9',
        teacherId: 'teacher6',
        classId: '2a',
        room: 'U401',
        dayOfWeek: 1,
        period: 7,
        startTime: DateTime(2024, 1, 1, 12, 40),
        endTime: DateTime(2024, 1, 1, 13, 25),
      ),
      TimetableEntry(
        id: 'tt35',
        subjectId: '6',
        teacherId: 'teacher4',
        classId: '2a',
        room: 'U202',
        dayOfWeek: 1,
        period: 8,
        startTime: DateTime(2024, 1, 1, 13, 35),
        endTime: DateTime(2024, 1, 1, 14, 20),
      ),

            TimetableEntry(
        id: 'tt7',
        subjectId: '5',
        teacherId: 'teacher4',
        classId: '2a',
        room: 'U201',
        dayOfWeek: 2,
        period: 1,
        startTime: DateTime(2024, 1, 1, 7, 5),
        endTime: DateTime(2024, 1, 1, 7, 50),
      ),
      TimetableEntry(
        id: 'tt8',
        subjectId: '1',
        teacherId: 'teacher1',
        classId: '2a',
        room: 'U102',
        dayOfWeek: 2,
        period: 2,
        startTime: DateTime(2024, 1, 1, 8, 0),
        endTime: DateTime(2024, 1, 1, 8, 45),
      ),
      TimetableEntry(
        id: 'tt9',
        subjectId: '7',
        teacherId: 'teacher2',
        classId: '2a',
        room: 'U303',
        dayOfWeek: 2,
        period: 3,
        startTime: DateTime(2024, 1, 1, 8, 55),
        endTime: DateTime(2024, 1, 1, 9, 40),
      ),
      TimetableEntry(
        id: 'tt10',
        subjectId: '2',
        teacherId: 'teacher2',
        classId: '2a',
        room: 'U205',
        dayOfWeek: 2,
        period: 4,
        startTime: DateTime(2024, 1, 1, 9, 55),
        endTime: DateTime(2024, 1, 1, 10, 40),
      ),
      TimetableEntry(
        id: 'tt11',
        subjectId: '9',
        teacherId: 'teacher6',
        classId: '2a',
        room: 'U401',
        dayOfWeek: 2,
        period: 5,
        startTime: DateTime(2024, 1, 1, 10, 50),
        endTime: DateTime(2024, 1, 1, 11, 35),
      ),
      TimetableEntry(
        id: 'tt12',
        subjectId: '3',
        teacherId: 'teacher3',
        classId: '2a',
        room: 'U308',
        dayOfWeek: 2,
        period: 6,
        startTime: DateTime(2024, 1, 1, 11, 45),
        endTime: DateTime(2024, 1, 1, 12, 30),
      ),
      TimetableEntry(
        id: 'tt13',
        subjectId: '8',
        teacherId: 'teacher7',
        classId: '2a',
        room: 'U304',
        dayOfWeek: 2,
        period: 7,
        startTime: DateTime(2024, 1, 1, 12, 40),
        endTime: DateTime(2024, 1, 1, 13, 25),
      ),
      TimetableEntry(
        id: 'tt36',
        subjectId: '4',
        teacherId: 'teacher1',
        classId: '2a',
        room: 'U110',
        dayOfWeek: 2,
        period: 8,
        startTime: DateTime(2024, 1, 1, 13, 35),
        endTime: DateTime(2024, 1, 1, 14, 20),
      ),

            TimetableEntry(
        id: 'tt14',
        subjectId: '3',
        teacherId: 'teacher3',
        classId: '2a',
        room: 'U308',
        dayOfWeek: 3,
        period: 1,
        startTime: DateTime(2024, 1, 1, 7, 5),
        endTime: DateTime(2024, 1, 1, 7, 50),
      ),
      TimetableEntry(
        id: 'tt15',
        subjectId: '6',
        teacherId: 'teacher4',
        classId: '2a',
        room: 'U202',
        dayOfWeek: 3,
        period: 2,
        startTime: DateTime(2024, 1, 1, 8, 0),
        endTime: DateTime(2024, 1, 1, 8, 45),
      ),
      TimetableEntry(
        id: 'tt16',
        subjectId: '1',
        teacherId: 'teacher1',
        classId: '2a',
        room: 'U102',
        dayOfWeek: 3,
        period: 3,
        startTime: DateTime(2024, 1, 1, 8, 55),
        endTime: DateTime(2024, 1, 1, 9, 40),
      ),
      TimetableEntry(
        id: 'tt17',
        subjectId: '8',
        teacherId: 'teacher7',
        classId: '2a',
        room: 'U304',
        dayOfWeek: 3,
        period: 4,
        startTime: DateTime(2024, 1, 1, 9, 55),
        endTime: DateTime(2024, 1, 1, 10, 40),
      ),
      TimetableEntry(
        id: 'tt18',
        subjectId: '2',
        teacherId: 'teacher2',
        classId: '2a',
        room: 'U205',
        dayOfWeek: 3,
        period: 5,
        startTime: DateTime(2024, 1, 1, 10, 50),
        endTime: DateTime(2024, 1, 1, 11, 35),
      ),
      TimetableEntry(
        id: 'tt19',
        subjectId: '4',
        teacherId: 'teacher1',
        classId: '2a',
        room: 'U110',
        dayOfWeek: 3,
        period: 6,
        startTime: DateTime(2024, 1, 1, 11, 45),
        endTime: DateTime(2024, 1, 1, 12, 30),
      ),
      TimetableEntry(
        id: 'tt37',
        subjectId: '5',
        teacherId: 'teacher4',
        classId: '2a',
        room: 'U201',
        dayOfWeek: 3,
        period: 7,
        startTime: DateTime(2024, 1, 1, 12, 40),
        endTime: DateTime(2024, 1, 1, 13, 25),
      ),
      TimetableEntry(
        id: 'tt38',
        subjectId: '7',
        teacherId: 'teacher2',
        classId: '2a',
        room: 'U303',
        dayOfWeek: 3,
        period: 8,
        startTime: DateTime(2024, 1, 1, 13, 35),
        endTime: DateTime(2024, 1, 1, 14, 20),
      ),

            TimetableEntry(
        id: 'tt20',
        subjectId: '2',
        teacherId: 'teacher2',
        classId: '2a',
        room: 'U205',
        dayOfWeek: 4,
        period: 1,
        startTime: DateTime(2024, 1, 1, 7, 5),
        endTime: DateTime(2024, 1, 1, 7, 50),
      ),
      TimetableEntry(
        id: 'tt21',
        subjectId: '4',
        teacherId: 'teacher1',
        classId: '2a',
        room: 'U110',
        dayOfWeek: 4,
        period: 2,
        startTime: DateTime(2024, 1, 1, 8, 0),
        endTime: DateTime(2024, 1, 1, 8, 45),
      ),
      TimetableEntry(
        id: 'tt22',
        subjectId: '3',
        teacherId: 'teacher3',
        classId: '2a',
        room: 'U308',
        dayOfWeek: 4,
        period: 3,
        startTime: DateTime(2024, 1, 1, 8, 55),
        endTime: DateTime(2024, 1, 1, 9, 40),
      ),
      TimetableEntry(
        id: 'tt23',
        subjectId: '1',
        teacherId: 'teacher1',
        classId: '2a',
        room: 'U102',
        dayOfWeek: 4,
        period: 4,
        startTime: DateTime(2024, 1, 1, 9, 55),
        endTime: DateTime(2024, 1, 1, 10, 40),
      ),
      TimetableEntry(
        id: 'tt24',
        subjectId: '10',
        teacherId: 'teacher5',
        classId: '2a',
        room: 'Tělocvična',
        dayOfWeek: 4,
        period: 5,
        startTime: DateTime(2024, 1, 1, 10, 50),
        endTime: DateTime(2024, 1, 1, 11, 35),
      ),
      TimetableEntry(
        id: 'tt25',
        subjectId: '5',
        teacherId: 'teacher4',
        classId: '2a',
        room: 'U201',
        dayOfWeek: 4,
        period: 6,
        startTime: DateTime(2024, 1, 1, 11, 45),
        endTime: DateTime(2024, 1, 1, 12, 30),
      ),
      TimetableEntry(
        id: 'tt26',
        subjectId: '9',
        teacherId: 'teacher6',
        classId: '2a',
        room: 'U401',
        dayOfWeek: 4,
        period: 7,
        startTime: DateTime(2024, 1, 1, 12, 40),
        endTime: DateTime(2024, 1, 1, 13, 25),
      ),
      TimetableEntry(
        id: 'tt39',
        subjectId: '1',
        teacherId: 'teacher1',
        classId: '2a',
        room: 'U102',
        dayOfWeek: 4,
        period: 8,
        startTime: DateTime(2024, 1, 1, 13, 35),
        endTime: DateTime(2024, 1, 1, 14, 20),
      ),

            TimetableEntry(
        id: 'tt27',
        subjectId: '9',
        teacherId: 'teacher6',
        classId: '2a',
        room: 'U401',
        dayOfWeek: 5,
        period: 1,
        startTime: DateTime(2024, 1, 1, 7, 5),
        endTime: DateTime(2024, 1, 1, 7, 50),
      ),
      TimetableEntry(
        id: 'tt28',
        subjectId: '7',
        teacherId: 'teacher2',
        classId: '2a',
        room: 'U303',
        dayOfWeek: 5,
        period: 2,
        startTime: DateTime(2024, 1, 1, 8, 0),
        endTime: DateTime(2024, 1, 1, 8, 45),
      ),
      TimetableEntry(
        id: 'tt29',
        subjectId: '5',
        teacherId: 'teacher4',
        classId: '2a',
        room: 'U201',
        dayOfWeek: 5,
        period: 3,
        startTime: DateTime(2024, 1, 1, 8, 55),
        endTime: DateTime(2024, 1, 1, 9, 40),
      ),
      TimetableEntry(
        id: 'tt30',
        subjectId: '2',
        teacherId: 'teacher2',
        classId: '2a',
        room: 'U205',
        dayOfWeek: 5,
        period: 4,
        startTime: DateTime(2024, 1, 1, 9, 55),
        endTime: DateTime(2024, 1, 1, 10, 40),
      ),
      TimetableEntry(
        id: 'tt31',
        subjectId: '1',
        teacherId: 'teacher1',
        classId: '2a',
        room: 'U102',
        dayOfWeek: 5,
        period: 5,
        startTime: DateTime(2024, 1, 1, 10, 50),
        endTime: DateTime(2024, 1, 1, 11, 35),
      ),
      TimetableEntry(
        id: 'tt32',
        subjectId: '6',
        teacherId: 'teacher4',
        classId: '2a',
        room: 'U202',
        dayOfWeek: 5,
        period: 6,
        startTime: DateTime(2024, 1, 1, 11, 45),
        endTime: DateTime(2024, 1, 1, 12, 30),
      ),
      TimetableEntry(
        id: 'tt33',
        subjectId: '3',
        teacherId: 'teacher3',
        classId: '2a',
        room: 'U308',
        dayOfWeek: 5,
        period: 7,
        startTime: DateTime(2024, 1, 1, 12, 40),
        endTime: DateTime(2024, 1, 1, 13, 25),
      ),
      TimetableEntry(
        id: 'tt40',
        subjectId: '8',
        teacherId: 'teacher7',
        classId: '2a',
        room: 'U304',
        dayOfWeek: 5,
        period: 8,
        startTime: DateTime(2024, 1, 1, 13, 35),
        endTime: DateTime(2024, 1, 1, 14, 20),
      ),
    ];
  }

  void _initializeGrades() {
    _grades = [
            Grade(
        id: 'g1',
        studentId: 'student1',
        subjectId: '1',
        teacherId: 'teacher1',
        value: 2,
        description: 'Písemná práce - kvadratické rovnice',
        date: DateTime.now().subtract(const Duration(days: 5)),
        type: GradeType.test,
        weight: 8.0,
      ),
      Grade(
        id: 'g2',
        studentId: 'student1',
        subjectId: '1',
        teacherId: 'teacher1',
        value: 1,
        description: 'Domácí úkol - funkce',
        date: DateTime.now().subtract(const Duration(days: 12)),
        type: GradeType.homework,
        weight: 3.0,
      ),
      Grade(
        id: 'g3',
        studentId: 'student1',
        subjectId: '1',
        teacherId: 'teacher1',
        value: 3,
        description: 'Ústní zkoušení - geometrie',
        date: DateTime.now().subtract(const Duration(days: 8)),
        type: GradeType.exam,
        weight: 5.0,
      ),

            Grade(
        id: 'g8',
        studentId: 'student1',
        subjectId: '4',
        teacherId: 'teacher1',
        value: 2,
        description: 'Laboratorní práce - mechanika',
        date: DateTime.now().subtract(const Duration(days: 7)),
        type: GradeType.classwork,
        weight: 6.0,
      ),

            Grade(
        id: 'g12',
        studentId: 'student1',
        subjectId: '2',
        teacherId: 'teacher2',
        value: 1,
        description: 'Slohová práce - popis osoby',
        date: DateTime.now().subtract(const Duration(days: 15)),
        type: GradeType.project,
        weight: 7.0,
      ),

            Grade(
        id: 'g16',
        studentId: 'student1',
        subjectId: '3',
        teacherId: 'teacher3',
        value: 1,
        description: 'Vocabulary test - Unit 5',
        date: DateTime.now().subtract(const Duration(days: 4)),
        type: GradeType.test,
        weight: 6.0,
      ),
    ];
  }

  void _initializeAttendance() {
    _attendance = [];
  }

  void _initializeAssignments() {
    _assignments = [];
  }

  void _initializeMessages() {
    _messages = [];
  }

  void _initializeEvents() {
    _events = [];
  }

  void _initializeDocuments() {
    _documents = [];
  }

    List<Subject> get subjects => _subjects;
  List<TimetableEntry> get timetable => _timetable;

    List<TimetableEntry> getTimetableForClass(String classId) {
    return _timetable.where((entry) => entry.classId == classId).toList()
      ..sort((a, b) {
        if (a.dayOfWeek != b.dayOfWeek) {
          return a.dayOfWeek.compareTo(b.dayOfWeek);
        }
        return a.period.compareTo(b.period);
      });
  }

    List<TimetableEntry> getTimetableForTeacher(String teacherId) {
    return _timetable.where((entry) => entry.teacherId == teacherId).toList()
      ..sort((a, b) {
        if (a.dayOfWeek != b.dayOfWeek) {
          return a.dayOfWeek.compareTo(b.dayOfWeek);
        }
        return a.period.compareTo(b.period);
      });
  }

    List<Student> get students => List.unmodifiable(_students);
  List<Teacher> get teachers => List.unmodifiable(_teachers);
  List<SchoolClass> get classes => List.unmodifiable(_classes);
  List<Grade> get grades => List.unmodifiable(_grades);

    Student? getCurrentStudent() {
    if (_currentUserType == UserType.student && _currentUserId != null) {
      return _students.firstWhere((s) => s.id == _currentUserId);
    }
    return null;
  }

  Teacher? getCurrentTeacher() {
    if (_currentUserType == UserType.teacher && _currentUserId != null) {
      return _teachers.firstWhere((t) => t.id == _currentUserId);
    }
    return null;
  }

  List<Grade> getGradesForStudent(String studentId) {
    return _grades.where((g) => g.studentId == studentId).toList();
  }

  Subject? getSubjectById(String id) {
    return _subjects.firstWhere((s) => s.id == id);
  }

  Teacher? getTeacherById(String id) {
    try {
      return _teachers.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  SchoolClass? getClassById(String id) {
    try {
      return _classes.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<SchoolClass> getClassesForTeacher(String teacherId) {
    return _classes.where((c) => c.teacherId == teacherId).toList();
  }

  List<Student> getStudentsForClass(String classId) {
    return _students.where((s) => s.classId == classId).toList();
  }

  List<Subject> getSubjectsForTeacher(String teacherId) {
    final teacher = getTeacherById(teacherId);
    if (teacher == null) return [];
    return _subjects.where((s) => teacher.subjectIds.contains(s.id)).toList();
  }

  List<Grade> getGradesForClassAndSubject(String classId, String subjectId) {
    final classStudents = getStudentsForClass(classId);
    final studentIds = classStudents.map((s) => s.id).toList();
    return _grades
        .where(
            (g) => studentIds.contains(g.studentId) && g.subjectId == subjectId)
        .toList();
  }
}
