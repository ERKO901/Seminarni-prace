import 'package:flutter/material.dart';

enum UserType {
  student,
  teacher,
}

class User {
  final String name;
  final UserType type;
  final String id;

  User({required this.name, required this.type, required this.id});
}

class DashboardModule {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  DashboardModule({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });
}


class DemoUsers {
  static const String studentId = 'student1';
  static const String teacherId = 'teacher1';

  static User getStudentUser() => User(
    id: studentId,
    name: 'Tomáš Kolář',
    type: UserType.student,
  );

  static User getTeacherUser() => User(
    id: teacherId,
    name: 'Mgr. Jan Novák',
    type: UserType.teacher,
  );
}
