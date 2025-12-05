import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/data_models.dart';
import 'teacher_subject_classes_screen.dart';

class TeacherSubjectsScreen extends StatelessWidget {
  const TeacherSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final dataService = DataService();

    final currentTeacher = dataService.getCurrentTeacher();
    if (currentTeacher == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Známkování')),
        body: const Center(child: Text('Žádný učitel není přihlášen')),
      );
    }

    final teacherSubjects = dataService.getSubjectsForTeacher(currentTeacher.id);
    final teacherClasses = dataService.getClassesForTeacher(currentTeacher.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Známkování - Výběr předmětu'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
                    _buildTeacherInfoCard(currentTeacher, teacherClasses, isDesktop),
                    Expanded(
            child: _buildSubjectsList(context, teacherSubjects, dataService, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherInfoCard(Teacher teacher, List<SchoolClass> classes, bool isDesktop) {
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
                    width: isDesktop ? 50 : 60,
                    height: isDesktop ? 50 : 60,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(isDesktop ? 25 : 30),
                    ),
                    child: Icon(
                      Icons.person_4,
                      color: Colors.white,
                      size: isDesktop ? 24 : 30,
                    ),
                  ),
                  SizedBox(width: isDesktop ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher.fullName,
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vyberte předmět pro známkování',
                          style: TextStyle(
                            fontSize: isDesktop ? 12 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectsList(BuildContext context, List<Subject> subjects, DataService dataService, bool isDesktop) {
    if (subjects.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Žádné předměty nejsou přiřazeny', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isDesktop ? 12 : 16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final teacherClasses = dataService.getClassesForTeacher(dataService.getCurrentTeacher()!.id);
        final classesWithGrades = teacherClasses.where((cls) {
          final grades = dataService.getGradesForClassAndSubject(cls.id, subject.id);
          return grades.isNotEmpty;
        }).toList();

        return _buildSubjectCard(context, subject, classesWithGrades, isDesktop);
      },
    );
  }

  Widget _buildSubjectCard(BuildContext context, Subject subject, List<SchoolClass> classes, bool isDesktop) {
    final totalGrades = classes.fold<int>(0, (sum, cls) {
      final grades = DataService().getGradesForClassAndSubject(cls.id, subject.id);
      return sum + grades.length;
    });

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TeacherSubjectClassesScreen(subjectId: subject.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
                      '${classes.length} tříd • $totalGrades známek',
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                                        if (classes.isNotEmpty)
                      Text(
                        'Třídy: ${classes.map((c) => c.name).join(', ')}',
                        style: TextStyle(
                          fontSize: isDesktop ? 11 : 12,
                          color: subject.color,
                          fontWeight: FontWeight.w500,
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
}
