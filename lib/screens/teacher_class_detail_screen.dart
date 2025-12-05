import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/data_models.dart';

class TeacherClassDetailScreen extends StatefulWidget {
  final String classId;

  const TeacherClassDetailScreen({super.key, required this.classId});

  @override
  State<TeacherClassDetailScreen> createState() => _TeacherClassDetailScreenState();
}

class _TeacherClassDetailScreenState extends State<TeacherClassDetailScreen> {
  final DataService _dataService = DataService();
  String? selectedSubjectId;
  Set<String> expandedGrades = {};

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    final schoolClass = _dataService.getClassById(widget.classId);
    final currentTeacher = _dataService.getCurrentTeacher();

    if (schoolClass == null || currentTeacher == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Třída')),
        body: const Center(child: Text('Třída nenalezena')),
      );
    }

    final teacherSubjects = _dataService.getSubjectsForTeacher(currentTeacher.id);
    final students = _dataService.getStudentsForClass(widget.classId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Třída ${schoolClass.name}'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
                    _buildClassHeader(schoolClass, students, teacherSubjects, isDesktop),
                    Expanded(
            child: _buildGradesView(teacherSubjects, students, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildClassHeader(SchoolClass schoolClass, List<Student> students, List<Subject> subjects, bool isDesktop) {
    return Container(
      margin: EdgeInsets.all(isDesktop ? 12 : 16),
      child: Card(
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
                          'Třída ${schoolClass.name}',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${students.length} žáků • ${schoolClass.year}. ročník',
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
              const SizedBox(height: 16),
                            Row(
                children: [
                  Text(
                    'Předmět: ',
                    style: TextStyle(
                      fontSize: isDesktop ? 13 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedSubjectId,
                      hint: const Text('Všechny předměty'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Všechny předměty'),
                        ),
                        ...subjects.map((subject) => DropdownMenuItem<String>(
                          value: subject.id,
                          child: Text(subject.name),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedSubjectId = value;
                          expandedGrades.clear();
                        });
                      },
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

  Widget _buildGradesView(List<Subject> subjects, List<Student> students, bool isDesktop) {
    final filteredSubjects = selectedSubjectId == null
        ? subjects
        : subjects.where((s) => s.id == selectedSubjectId).toList();

    if (filteredSubjects.isEmpty) {
      return const Center(
        child: Text('Žádné předměty k zobrazení'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isDesktop ? 12 : 16),
      itemCount: filteredSubjects.length,
      itemBuilder: (context, index) {
        final subject = filteredSubjects[index];
        return _buildSubjectSection(subject, students, isDesktop);
      },
    );
  }

  Widget _buildSubjectSection(Subject subject, List<Student> students, bool isDesktop) {
    final subjectGrades = _dataService.getGradesForClassAndSubject(widget.classId, subject.id);

        Map<int, List<Grade>> gradesByValue = {};
    for (var grade in subjectGrades) {
      if (gradesByValue[grade.value] == null) {
        gradesByValue[grade.value] = [];
      }
      gradesByValue[grade.value]!.add(grade);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                    Container(
            padding: EdgeInsets.all(isDesktop ? 16 : 20),
            decoration: BoxDecoration(
              color: subject.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: isDesktop ? 40 : 48,
                  height: isDesktop ? 40 : 48,
                  decoration: BoxDecoration(
                    color: subject.color,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${subjectGrades.length} známek',
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
          ),
                    if (subjectGrades.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: Text(
                  'Žádné známky pro tento předmět',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...gradesByValue.entries.map((entry) {
              final gradeValue = entry.key;
              final gradesWithValue = entry.value;
              final isExpanded = expandedGrades.contains('${subject.id}_$gradeValue');

              return _buildGradeGroup(subject, gradeValue, gradesWithValue, students, isExpanded, isDesktop);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildGradeGroup(Subject subject, int gradeValue, List<Grade> grades, List<Student> students, bool isExpanded, bool isDesktop) {
    return Column(
      children: [
                InkWell(
          onTap: () {
            setState(() {
              final key = '${subject.id}_$gradeValue';
              if (isExpanded) {
                expandedGrades.remove(key);
              } else {
                expandedGrades.add(key);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 12 : 16),
            child: Row(
              children: [
                Container(
                  width: isDesktop ? 32 : 40,
                  height: isDesktop ? 32 : 40,
                  decoration: BoxDecoration(
                    color: _getGradeColor(gradeValue),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      gradeValue.toString(),
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
                  child: Text(
                    'Známka $gradeValue (${grades.length} žáků)',
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: isDesktop ? 20 : 24,
                  ),
                ),
              ],
            ),
          ),
        ),
                AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            ),
            child: Column(
              children: grades.map((grade) {
                final student = students.firstWhere((s) => s.id == grade.studentId);
                return _buildStudentGradeItem(student, grade, isDesktop);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentGradeItem(Student student, Grade grade, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 12 : 16,
        vertical: isDesktop ? 8 : 12,
      ),
      child: Row(
        children: [
                    Container(
            width: isDesktop ? 32 : 40,
            height: isDesktop ? 32 : 40,
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
                  fontSize: isDesktop ? 11 : 13,
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
                    fontSize: isDesktop ? 13 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (grade.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    grade.description!,
                    style: TextStyle(
                      fontSize: isDesktop ? 11 : 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _getGradeTypeText(grade.type),
                      style: TextStyle(
                        fontSize: isDesktop ? 10 : 11,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ' • ${_formatDate(grade.date)}',
                      style: TextStyle(
                        fontSize: isDesktop ? 10 : 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
                    Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 6 : 8,
              vertical: isDesktop ? 2 : 4,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Váha: ${grade.weight.toInt()}',
              style: TextStyle(
                fontSize: isDesktop ? 9 : 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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

  String _getGradeTypeText(GradeType type) {
    switch (type) {
      case GradeType.test: return 'Test';
      case GradeType.homework: return 'DÚ';
      case GradeType.classwork: return 'Práce v hodině';
      case GradeType.project: return 'Projekt';
      case GradeType.exam: return 'Zkouška';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
