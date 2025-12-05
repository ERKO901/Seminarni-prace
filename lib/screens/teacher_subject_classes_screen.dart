import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/data_models.dart';
import 'teacher_grade_types_screen.dart';

class TeacherSubjectClassesScreen extends StatelessWidget {
  final String subjectId;

  const TeacherSubjectClassesScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final dataService = DataService();

    final subject = dataService.getSubjectById(subjectId);
    final currentTeacher = dataService.getCurrentTeacher();

    if (subject == null || currentTeacher == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Třídy')),
        body: const Center(child: Text('Předmět nenalezen')),
      );
    }

    final teacherClasses = dataService.getClassesForTeacher(currentTeacher.id);
    final classesWithGrades = teacherClasses.where((cls) {
      final grades = dataService.getGradesForClassAndSubject(cls.id, subject.id);
      return grades.isNotEmpty;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${subject.name} - Výběr třídy'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
                    _buildSubjectInfoCard(subject, classesWithGrades, isDesktop),
                    Expanded(
            child: _buildClassesList(context, classesWithGrades, subject, dataService, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectInfoCard(Subject subject, List<SchoolClass> classes, bool isDesktop) {
    final totalGrades = classes.fold<int>(0, (sum, cls) {
      final grades = DataService().getGradesForClassAndSubject(cls.id, subject.id);
      return sum + grades.length;
    });

    return Container(
      margin: EdgeInsets.all(isDesktop ? 12 : 16),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 16 : 20),
          child: Row(
            children: [
              Container(
                width: isDesktop ? 60 : 70,
                height: isDesktop ? 60 : 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [subject.color, subject.color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isDesktop ? 15 : 18),
                ),
                child: Center(
                  child: Text(
                    subject.shortName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 16 : 20,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isDesktop ? 16 : 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vyberte třídu pro zobrazení známek',
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${classes.length} tříd • $totalGrades známek celkem',
                      style: TextStyle(
                        fontSize: isDesktop ? 11 : 12,
                        color: subject.color,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildClassesList(BuildContext context, List<SchoolClass> classes, Subject subject, DataService dataService, bool isDesktop) {
    if (classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.class_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Žádné třídy s známkami z ${subject.name}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isDesktop ? 12 : 16),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final schoolClass = classes[index];
        final students = dataService.getStudentsForClass(schoolClass.id);
        final grades = dataService.getGradesForClassAndSubject(schoolClass.id, subject.id);

        return _buildClassCard(context, schoolClass, students, grades, subject, isDesktop);
      },
    );
  }

  Widget _buildClassCard(BuildContext context, SchoolClass schoolClass, List<Student> students, List<Grade> grades, Subject subject, bool isDesktop) {
    final averageGrade = grades.isEmpty ? 0.0 : grades.map((g) => g.value).reduce((a, b) => a + b) / grades.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TeacherGradeTypesScreen(
                subjectId: subject.id,
                classId: schoolClass.id,
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
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 15),
                ),
                child: Center(
                  child: Text(
                    schoolClass.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 14 : 16,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isDesktop ? 16 : 20),
                            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Třída ${schoolClass.name}',
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
                          'Průměr: ',
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
                            averageGrade.toStringAsFixed(1),
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
}
