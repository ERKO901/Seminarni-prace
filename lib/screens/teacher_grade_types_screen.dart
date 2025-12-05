import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/data_models.dart';
import 'teacher_students_grades_screen.dart';

class TeacherGradeTypesScreen extends StatelessWidget {
  final String subjectId;
  final String classId;

  const TeacherGradeTypesScreen({
    super.key,
    required this.subjectId,
    required this.classId,
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
        appBar: AppBar(title: const Text('Známky')),
        body: const Center(child: Text('Předmět nebo třída nenalezeny')),
      );
    }

    final grades = dataService.getGradesForClassAndSubject(classId, subjectId);

        Map<String, List<Grade>> gradeGroups = {};
    for (var grade in grades) {
      final key = '${grade.description ?? "Bez popisu"}_${grade.type.name}_${grade.date.day}/${grade.date.month}/${grade.date.year}';
      if (gradeGroups[key] == null) {
        gradeGroups[key] = [];
      }
      gradeGroups[key]!.add(grade);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${subject.name} - ${schoolClass.name}'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
                    _buildInfoCard(subject, schoolClass, grades, isDesktop),
                    Expanded(
            child: _buildGradeTypesList(context, gradeGroups, subject, schoolClass, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Subject subject, SchoolClass schoolClass, List<Grade> grades, bool isDesktop) {
    final averageGrade = grades.isEmpty ? 0.0 : grades.map((g) => g.value).reduce((a, b) => a + b) / grades.length;
    final students = DataService().getStudentsForClass(classId);

    return Container(
      margin: EdgeInsets.all(isDesktop ? 12 : 16),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 16 : 20),
          child: Row(
            children: [
              Container(
                width: isDesktop ? 50 : 60,
                height: isDesktop ? 50 : 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [subject.color, subject.color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 15),
                ),
                child: Center(
                  child: Text(
                    subject.shortName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 14 : 16,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isDesktop ? 12 : 16),
              Container(
                width: isDesktop ? 40 : 50,
                height: isDesktop ? 40 : 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isDesktop ? 10 : 12),
                ),
                child: Center(
                  child: Text(
                    schoolClass.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 12 : 14,
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
                      '${subject.name} - ${schoolClass.name}',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${students.length} žáků • ${grades.length} známek',
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Průměr třídy: ',
                          style: TextStyle(
                            fontSize: isDesktop ? 11 : 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getGradeColor(averageGrade.round()),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            averageGrade.toStringAsFixed(2),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isDesktop ? 10 : 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeTypesList(BuildContext context, Map<String, List<Grade>> gradeGroups, Subject subject, SchoolClass schoolClass, bool isDesktop) {
    if (gradeGroups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grade_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Žádné známky k zobrazení', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    final sortedEntries = gradeGroups.entries.toList()
      ..sort((a, b) => b.value.first.date.compareTo(a.value.first.date)); 
    return ListView.builder(
      padding: EdgeInsets.all(isDesktop ? 12 : 16),
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final grades = entry.value;
        final sampleGrade = grades.first;

        return _buildGradeTypeCard(context, sampleGrade, grades.length, subject, schoolClass, isDesktop);
      },
    );
  }

  Widget _buildGradeTypeCard(BuildContext context, Grade sampleGrade, int count, Subject subject, SchoolClass schoolClass, bool isDesktop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TeacherStudentsGradesScreen(
                subjectId: subject.id,
                classId: schoolClass.id,
                gradeDescription: sampleGrade.description,
                gradeType: sampleGrade.type,
                gradeDate: sampleGrade.date,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 16 : 20),
          child: Row(
            children: [
                            Container(
                width: isDesktop ? 50 : 60,
                height: isDesktop ? 50 : 60,
                decoration: BoxDecoration(
                  color: _getGradeTypeColor(sampleGrade.type).withOpacity(0.1),
                  border: Border.all(color: _getGradeTypeColor(sampleGrade.type), width: 2),
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 15),
                ),
                child: Icon(
                  _getGradeTypeIcon(sampleGrade.type),
                  color: _getGradeTypeColor(sampleGrade.type),
                  size: isDesktop ? 24 : 30,
                ),
              ),
              SizedBox(width: isDesktop ? 16 : 20),
                            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sampleGrade.description ?? 'Známka bez popisu',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getGradeTypeColor(sampleGrade.type).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _getGradeTypeText(sampleGrade.type),
                            style: TextStyle(
                              color: _getGradeTypeColor(sampleGrade.type),
                              fontSize: isDesktop ? 11 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${sampleGrade.date.day}.${sampleGrade.date.month}.${sampleGrade.date.year}',
                          style: TextStyle(
                            fontSize: isDesktop ? 11 : 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count žáků • Váha: ${sampleGrade.weight.toInt()}',
                      style: TextStyle(
                        fontSize: isDesktop ? 11 : 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
                            Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: isDesktop ? 16 : 20,
              ),
            ],
          ),
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
