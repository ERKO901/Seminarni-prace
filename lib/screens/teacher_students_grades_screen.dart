import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/data_models.dart';

class TeacherStudentsGradesScreen extends StatelessWidget {
  final String subjectId;
  final String classId;
  final String? gradeDescription;
  final GradeType gradeType;
  final DateTime gradeDate;

  const TeacherStudentsGradesScreen({
    super.key,
    required this.subjectId,
    required this.classId,
    required this.gradeDescription,
    required this.gradeType,
    required this.gradeDate,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final dataService = DataService();

    final subject = dataService.getSubjectById(subjectId);
    final schoolClass = dataService.getClassById(classId);

    if (subject == null || schoolClass == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Žáci a známky')),
        body: const Center(child: Text('Předmět nebo třída nenalezeny')),
      );
    }

    final allGrades = dataService.getGradesForClassAndSubject(classId, subjectId);
    final filteredGrades = allGrades.where((grade) =>
    grade.description == gradeDescription &&
        grade.type == gradeType &&
        grade.date.day == gradeDate.day &&
        grade.date.month == gradeDate.month &&
        grade.date.year == gradeDate.year
    ).toList();

    final students = dataService.getStudentsForClass(classId);

    return Scaffold(
      appBar: AppBar(
        title: Text('${subject.shortName} - ${schoolClass.name}'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
                    _buildGradeInfoCard(subject, schoolClass, filteredGrades, isDesktop),
                    Expanded(
            child: _buildStudentsList(filteredGrades, students, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeInfoCard(Subject subject, SchoolClass schoolClass, List<Grade> grades, bool isDesktop) {
    final averageGrade = grades.isEmpty ? 0.0 : grades.map((g) => g.value).reduce((a, b) => a + b) / grades.length;
    final gradeDistribution = <int, int>{};
    for (var grade in grades) {
      gradeDistribution[grade.value] = (gradeDistribution[grade.value] ?? 0) + 1;
    }

    return Container(
      margin: EdgeInsets.all(isDesktop ? 12 : 16),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: isDesktop ? 40 : 50,
                    height: isDesktop ? 40 : 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [subject.color, subject.color.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(isDesktop ? 10 : 12),
                    ),
                    child: Center(
                      child: Text(
                        subject.shortName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 12 : 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isDesktop ? 12 : 16),
                  Container(
                    width: isDesktop ? 40 : 50,
                    height: isDesktop ? 40 : 50,
                    decoration: BoxDecoration(
                      color: _getGradeTypeColor(gradeType).withOpacity(0.1),
                      border: Border.all(color: _getGradeTypeColor(gradeType), width: 2),
                      borderRadius: BorderRadius.circular(isDesktop ? 10 : 12),
                    ),
                    child: Icon(
                      _getGradeTypeIcon(gradeType),
                      color: _getGradeTypeColor(gradeType),
                      size: isDesktop ? 18 : 22,
                    ),
                  ),
                  SizedBox(width: isDesktop ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gradeDescription ?? 'Známka bez popisu',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getGradeTypeColor(gradeType).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getGradeTypeText(gradeType),
                                style: TextStyle(
                                  color: _getGradeTypeColor(gradeType),
                                  fontSize: isDesktop ? 10 : 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${gradeDate.day}.${gradeDate.month}.${gradeDate.year}',
                              style: TextStyle(
                                fontSize: isDesktop ? 11 : 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
                            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn('Průměr', averageGrade.toStringAsFixed(2), _getGradeColor(averageGrade.round())),
                  _buildStatColumn('Celkem', grades.length.toString(), Colors.blue),
                  _buildStatColumn('Nejlepší', grades.isEmpty ? '0' : grades.map((g) => g.value).reduce((a, b) => a < b ? a : b).toString(), Colors.green),
                ],
              ),
              const SizedBox(height: 12),
                            if (grades.isNotEmpty) ...[
                Text(
                  'Rozložení známek:',
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [1, 2, 3, 4, 5].map((grade) {
                    final count = gradeDistribution[grade] ?? 0;
                    return Column(
                      children: [
                        Container(
                          width: isDesktop ? 24 : 28,
                          height: isDesktop ? 24 : 28,
                          decoration: BoxDecoration(
                            color: _getGradeColor(grade),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              grade.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 11 : 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: isDesktop ? 10 : 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStudentsList(List<Grade> grades, List<Student> allStudents, bool isDesktop) {
    if (grades.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Žádní žáci s touto známkou', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

        grades.sort((a, b) => a.value.compareTo(b.value));

    return ListView.builder(
      padding: EdgeInsets.all(isDesktop ? 12 : 16),
      itemCount: grades.length,
      itemBuilder: (context, index) {
        final grade = grades[index];
        final student = allStudents.firstWhere((s) => s.id == grade.studentId);

        return _buildStudentGradeCard(student, grade, index + 1, isDesktop);
      },
    );
  }

  Widget _buildStudentGradeCard(Student student, Grade grade, int rank, bool isDesktop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 12 : 16),
        child: Row(
          children: [
                        Container(
              width: isDesktop ? 30 : 35,
              height: isDesktop ? 30 : 35,
              decoration: BoxDecoration(
                color: rank <= 3 ? Colors.amber : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  rank.toString(),
                  style: TextStyle(
                    color: rank <= 3 ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 12 : 13,
                  ),
                ),
              ),
            ),
            SizedBox(width: isDesktop ? 12 : 16),
                        Container(
              width: isDesktop ? 40 : 50,
              height: isDesktop ? 40 : 50,
              decoration: BoxDecoration(
                color: Colors.blue[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${student.firstName[0]}${student.lastName[0]}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 14 : 16,
                  ),
                ),
              ),
            ),
            SizedBox(width: isDesktop ? 12 : 16),
                        Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Váha: ${grade.weight.toInt()}',
                    style: TextStyle(
                      fontSize: isDesktop ? 11 : 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
                        Container(
              width: isDesktop ? 40 : 50,
              height: isDesktop ? 40 : 50,
              decoration: BoxDecoration(
                color: _getGradeColor(grade.value),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  grade.value.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 16 : 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(int grade) {
    switch (grade) {
      case 1: return Colors.green;
      case 2: return Colors.lightGreen;
      case 3: return Colors.orange;
      case 4: return Colors.deepOrange;
      case 5: return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getGradeTypeColor(GradeType type) {
    switch (type) {
      case GradeType.test: return Colors.red;
      case GradeType.homework: return Colors.blue;
      case GradeType.classwork: return Colors.green;
      case GradeType.project: return Colors.purple;
      case GradeType.exam: return Colors.orange;
    }
  }

  IconData _getGradeTypeIcon(GradeType type) {
    switch (type) {
      case GradeType.test: return Icons.quiz;
      case GradeType.homework: return Icons.assignment;
      case GradeType.classwork: return Icons.school;
      case GradeType.project: return Icons.work;
      case GradeType.exam: return Icons.assignment_turned_in;
    }
  }

  String _getGradeTypeText(GradeType type) {
    switch (type) {
      case GradeType.test: return 'Test';
      case GradeType.homework: return 'DÚ';
      case GradeType.classwork: return 'Práce v hodině';
      case GradeType.project: return 'Projekt';
      case GradeType.exam: return 'Zkouška';
    }
  }
}
