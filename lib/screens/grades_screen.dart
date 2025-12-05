import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen>
    with TickerProviderStateMixin {
  final DataService _dataService = DataService();
  Set<String> expandedSubjects = {};
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    final currentStudent = _dataService.getCurrentStudent();
    if (currentStudent == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Známky'),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(child: Text('Žádný student není přihlášen')),
      );
    }

    final grades = _dataService.getGradesForStudent(currentStudent.id);
    final subjects = _dataService.subjects;

    Map<Subject, List<Grade>> gradesBySubject = {};
    Map<Subject, double> subjectAverages = {};

    for (var subject in subjects) {
      final subjectGrades =
      grades.where((g) => g.subjectId == subject.id).toList();
      if (subjectGrades.isNotEmpty) {
        gradesBySubject[subject] = subjectGrades;
        subjectAverages[subject] = _calculateWeightedAverage(subjectGrades);
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Známky'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showGradeInfoDialog(context),
          ),
        ],
      ),
      body: isDesktop
          ? _buildDesktopLayout(grades, gradesBySubject, subjectAverages)
          : _buildMobileLayout(grades, gradesBySubject, subjectAverages),
    );
  }

  Widget _buildDesktopLayout(
      List<Grade> grades,
      Map<Subject, List<Grade>> gradesBySubject,
      Map<Subject, double> subjectAverages,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 350,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildOverallSummaryCard(grades, subjectAverages, true),
              const SizedBox(height: 16),
              _buildGradeDistributionCard(grades),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _buildSubjectsList(gradesBySubject, subjectAverages, true),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      List<Grade> grades,
      Map<Subject, List<Grade>> gradesBySubject,
      Map<Subject, double> subjectAverages,
      ) {
    return Column(
      children: [
        _buildOverallSummaryCard(grades, subjectAverages, false),
        Expanded(
          child: _buildSubjectsList(gradesBySubject, subjectAverages, false),
        ),
      ],
    );
  }

  Widget _buildOverallSummaryCard(
      List<Grade> grades,
      Map<Subject, double> subjectAverages,
      bool isDesktop,
      ) {
    if (grades.isEmpty) return const SizedBox.shrink();

    final overallAverage = _calculateOverallAverage(subjectAverages);
    final totalGrades = grades.length;
    final totalSubjects = subjectAverages.length;

    return Container(
      margin: EdgeInsets.all(isDesktop ? 0 : 16),
      width: double.infinity,
      child: AppTheme.glass(
        borderRadius: isDesktop ? 20 : 22,
        padding: EdgeInsets.all(isDesktop ? 16 : 20),
        color: Colors.white.withOpacity(0.10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Celkový přehled',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            isDesktop
                ? Column(
              children: [
                _buildDesktopSummaryRow(
                  'Celkový průměr',
                  overallAverage.toStringAsFixed(2),
                  _getGradeColor(overallAverage.round()),
                ),
                const SizedBox(height: 12),
                _buildDesktopSummaryRow(
                  'Předměty',
                  totalSubjects.toString(),
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildDesktopSummaryRow(
                  'Celkem známek',
                  totalGrades.toString(),
                  Colors.green,
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryColumn(
                  'Celkový průměr',
                  overallAverage.toStringAsFixed(2),
                  _getGradeColor(overallAverage.round()),
                ),
                _buildSummaryColumn(
                  'Předměty',
                  totalSubjects.toString(),
                  Colors.blue,
                ),
                _buildSummaryColumn(
                  'Celkem známek',
                  totalGrades.toString(),
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSummaryRow(String label, String value, Color color) {
    return Row(
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeDistributionCard(List<Grade> grades) {
    final distribution = _getGradeDistribution(grades);

    return AppTheme.glass(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      color: Colors.white.withOpacity(0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rozložení známek',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(5, (index) {
            final grade = index + 1;
            final count = distribution[grade] ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getGradeColor(grade),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        grade.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count známek',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubjectsList(
      Map<Subject, List<Grade>> gradesBySubject,
      Map<Subject, double> subjectAverages,
      bool isDesktop,
      ) {
    if (gradesBySubject.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Žádné známky nejsou k dispozici',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final sortedSubjects = gradesBySubject.keys.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return ListView.builder(
      padding: EdgeInsets.all(isDesktop ? 0 : 16),
      itemCount: sortedSubjects.length,
      itemBuilder: (context, index) {
        final subject = sortedSubjects[index];
        final subjectGrades = gradesBySubject[subject]!;
        final average = subjectAverages[subject]!;
        final isExpanded = expandedSubjects.contains(subject.id);

        return _buildSubjectCard(
          subject,
          subjectGrades,
          average,
          isExpanded,
          isDesktop,
        );
      },
    );
  }

  Widget _buildSubjectCard(
      Subject subject,
      List<Grade> grades,
      double average,
      bool isExpanded,
      bool isDesktop,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppTheme.glass(
        borderRadius: 16,
        color: Colors.white.withOpacity(0.08),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    expandedSubjects.remove(subject.id);
                  } else {
                    expandedSubjects.add(subject.id);
                  }
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.all(isDesktop ? 12 : 16),
                child: Row(
                  children: [
                    Container(
                      width: isDesktop ? 40 : 48,
                      height: isDesktop ? 40 : 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            subject.color,
                            subject.color.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                        BorderRadius.circular(isDesktop ? 10 : 12),
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
                              fontSize: isDesktop ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${grades.length} známek',
                            style: TextStyle(
                              fontSize: isDesktop ? 12 : 14,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: isDesktop ? 40 : 50,
                      height: isDesktop ? 40 : 50,
                      decoration: BoxDecoration(
                        color: _getGradeColor(average.round()),
                        borderRadius:
                        BorderRadius.circular(isDesktop ? 20 : 25),
                      ),
                      child: Center(
                        child: Text(
                          average.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isDesktop ? 12 : 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isDesktop ? 6 : 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                decoration: BoxDecoration(
                  color:
                  Theme.of(context).colorScheme.surface.withOpacity(0.4),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: grades
                      .map((grade) => _buildGradeItem(grade, isDesktop))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeItem(Grade grade, bool isDesktop) {
    final teacher = _dataService.getTeacherById(grade.teacherId);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 12 : 16,
        vertical: isDesktop ? 6 : 8,
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 32 : 40,
            height: isDesktop ? 32 : 40,
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
                  grade.description ?? 'Známka bez popisu',
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
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
                      ' • ',
                      style: TextStyle(
                        fontSize: isDesktop ? 10 : 11,
                        color: Colors.grey[300],
                      ),
                    ),
                    Text(
                      _formatDate(grade.date),
                      style: TextStyle(
                        fontSize: isDesktop ? 10 : 12,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
                if (teacher != null)
                  Text(
                    teacher.fullName,
                    style: TextStyle(
                      fontSize: isDesktop ? 10 : 11,
                      color: Colors.grey[400],
                    ),
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
                fontSize: isDesktop ? 10 : 11,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<int, int> _getGradeDistribution(List<Grade> grades) {
    Map<int, int> distribution = {};
    for (var grade in grades) {
      distribution[grade.value] = (distribution[grade.value] ?? 0) + 1;
    }
    return distribution;
  }

  double _calculateWeightedAverage(List<Grade> grades) {
    if (grades.isEmpty) return 0;

    double totalWeightedGrades = 0;
    double totalWeight = 0;

    for (var grade in grades) {
      totalWeightedGrades += grade.value * grade.weight;
      totalWeight += grade.weight;
    }

    return totalWeight > 0 ? totalWeightedGrades / totalWeight : 0;
  }

  double _calculateOverallAverage(Map<Subject, double> subjectAverages) {
    if (subjectAverages.isEmpty) return 0;
    return subjectAverages.values.reduce((a, b) => a + b) /
        subjectAverages.length;
  }

  Color _getGradeColor(int grade) {
    switch (grade) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getGradeTypeText(GradeType type) {
    switch (type) {
      case GradeType.test:
        return 'Test';
      case GradeType.homework:
        return 'DÚ';
      case GradeType.classwork:
        return 'Práce v hodině';
      case GradeType.project:
        return 'Projekt';
      case GradeType.exam:
        return 'Zkouška';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  void _showGradeInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Hodnocení'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stupnice hodnocení:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1 - Výborný'),
              Text('2 - Chvalitebný'),
              Text('3 - Dobrý'),
              Text('4 - Dostatečný'),
              Text('5 - Nedostatečný'),
              SizedBox(height: 12),
              Text(
                'Váha známek: 1-10',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Vyšší váha = větší vliv na průměr'),
            ],
          ),
        );
      },
    );
  }
}
