import 'package:flutter/material.dart';


class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String classId;
  final String email;
  final DateTime birthDate;
  final String parentEmail;
  final String parentPhone;
  final String address;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.classId,
    required this.email,
    required this.birthDate,
    required this.parentEmail,
    required this.parentPhone,
    required this.address,
  });

  String get fullName => '$firstName $lastName';
}

class Teacher {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final List<String> subjectIds;
  final List<String> classIds;
  final String title;

  Teacher({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.subjectIds,
    required this.classIds,
    required this.title,
  });

  String get fullName => '$title $firstName $lastName';
}

class SchoolClass {
  final String id;
  final String name;
  final String teacherId;
  final List<String> studentIds;
  final int year;

  SchoolClass({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.studentIds,
    required this.year,
  });
}

class Subject {
  final String id;
  final String name;
  final String shortName;
  final Color color;

  Subject({
    required this.id,
    required this.name,
    required this.shortName,
    required this.color,
  });
}


class TimetableEntry {
  final String id;
  final String subjectId;
  final String teacherId;
  final String classId;
  final String room;
  final int dayOfWeek;
  final int period;
  final DateTime startTime;
  final DateTime endTime;

  TimetableEntry({
    required this.id,
    required this.subjectId,
    required this.teacherId,
    required this.classId,
    required this.room,
    required this.dayOfWeek,
    required this.period,
    required this.startTime,
    required this.endTime,
  });
}

class Grade {
  final String id;
  final String studentId;
  final String subjectId;
  final String teacherId;
  final int value;   final String? description;
  final DateTime date;
  final GradeType type;
  final double weight;

  Grade({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.teacherId,
    required this.value,
    this.description,
    required this.date,
    required this.type,
    required this.weight,
  });
}

enum GradeType {
  test,
  homework,
  classwork,
  project,
  exam,
}

class Attendance {
  final String id;
  final String studentId;
  final String subjectId;
  final DateTime date;
  final int period;
  final AttendanceType type;
  final String? note;
  final bool excused;

  Attendance({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.date,
    required this.period,
    required this.type,
    this.note,
    required this.excused,
  });
}

enum AttendanceType {
  present,
  absent,
  late,
  excused,
}

class Assignment {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String teacherId;
  final List<String> classIds;
  final DateTime dueDate;
  final DateTime assignedDate;
  final AssignmentType type;
  final List<String> attachments;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.teacherId,
    required this.classIds,
    required this.dueDate,
    required this.assignedDate,
    required this.type,
    required this.attachments,
  });
}

enum AssignmentType {
  homework,
  project,
  reading,
  research,
  presentation,
}

class Message {
  final String id;
  final String fromId;
  final List<String> toIds;
  final String subject;
  final String content;
  final DateTime sentDate;
  final bool isRead;
  final MessageType type;
  final String? parentMessageId;

  Message({
    required this.id,
    required this.fromId,
    required this.toIds,
    required this.subject,
    required this.content,
    required this.sentDate,
    required this.isRead,
    required this.type,
    this.parentMessageId,
  });
}

enum MessageType {
  personal,
  announcement,
  reminder,
  urgent,
}

class SchoolEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final EventType type;
  final List<String> targetClassIds;
  final String organizerId;

  SchoolEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.type,
    required this.targetClassIds,
    required this.organizerId,
  });
}

enum EventType {
  exam,
  trip,
  meeting,
  ceremony,
  sports,
  cultural,
  holiday,
}


class Document {
  final String id;
  final String title;
  final String description;
  final String fileName;
  final String fileType;
  final DateTime uploadDate;
  final String uploaderId;
  final List<String> targetClassIds;
  final DocumentCategory category;

  Document({
    required this.id,
    required this.title,
    required this.description,
    required this.fileName,
    required this.fileType,
    required this.uploadDate,
    required this.uploaderId,
    required this.targetClassIds,
    required this.category,
  });
}

enum DocumentCategory {
  syllabus,
  material,
  form,
  announcement,
  policy,
}
