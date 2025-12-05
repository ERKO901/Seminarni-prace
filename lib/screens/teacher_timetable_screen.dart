import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';

class TeacherTimetableScreen extends StatefulWidget {
  const TeacherTimetableScreen({super.key});

  @override
  State<TeacherTimetableScreen> createState() => _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends State<TeacherTimetableScreen> {
  final DataService _dataService = DataService();

  final List<String> _dayNames = [
    'Po',
    'Út',
    'St',
    'Čt',
    'Pá',
  ];

  final List<String> _fullDayNames = [
    'Pondělí',
    'Úterý',
    'Středa',
    'Čtvrtek',
    'Pátek',
  ];

  final List<Map<String, String>> _timeSlots = [
    {'period': '1', 'start': '7:05', 'end': '7:50'},
    {'period': '2', 'start': '8:00', 'end': '8:45'},
    {'period': '3', 'start': '8:55', 'end': '9:40'},
    {'period': '4', 'start': '9:55', 'end': '10:40'},
    {'period': '5', 'start': '10:50', 'end': '11:35'},
    {'period': '6', 'start': '11:45', 'end': '12:30'},
    {'period': '7', 'start': '12:40', 'end': '13:25'},
    {'period': '8', 'start': '13:35', 'end': '14:20'},
  ];

  TimetableEntry? _selectedEntry;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final currentTeacher = _dataService.getCurrentTeacher();
    if (currentTeacher == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Rozvrh'),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(child: Text('Žádný učitel není přihlášen')),
      );
    }

    final timetable = _dataService.getTimetableForTeacher(currentTeacher.id);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Můj rozvrh'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1400,
            ),
            child: _buildTimetableView(timetable, screenWidth),
          ),
        ),
      ),
    );
  }

  Widget _buildTimetableView(
      List<TimetableEntry> timetable,
      double screenWidth,
      ) {
    final isDesktop = screenWidth > 800;
    final effectiveWidth = screenWidth > 1400 ? 1400.0 : screenWidth;

    final dayColumnWidth = isDesktop ? 70.0 : 50.0;
    final outerMargin = isDesktop ? 16.0 : 12.0;
    final innerPadding = isDesktop ? 20.0 : 12.0;
    final cellMargin = 2.0;

    final totalHorizontalSpace = (outerMargin * 2) +
        (innerPadding * 2) +
        dayColumnWidth +
        (cellMargin * 2 * _timeSlots.length);

    final availableWidth = effectiveWidth - totalHorizontalSpace;
    final cellWidth = availableWidth / _timeSlots.length;
    final cellHeight = isDesktop ? 85.0 : 70.0;

    return Container(
      width: effectiveWidth,
      margin: EdgeInsets.all(outerMargin),
      child: AppTheme.glass(
        borderRadius: isDesktop ? 20 : 18,
        padding: EdgeInsets.all(innerPadding),
        color: Colors.white.withOpacity(0.08),
        child: _buildTimetableGrid(
          timetable,
          cellWidth,
          cellHeight,
          dayColumnWidth,
          isDesktop,
        ),
      ),
    );
  }

  Widget _buildTimetableGrid(
      List<TimetableEntry> timetable,
      double cellWidth,
      double cellHeight,
      double dayColumnWidth,
      bool isDesktop,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
                Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: dayColumnWidth,
              height: isDesktop ? 60 : 50,
            ),
            ...List.generate(_timeSlots.length, (index) {
              final timeSlot = _timeSlots[index];
              return Container(
                width: cellWidth,
                height: isDesktop ? 60 : 50,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timeSlot['period']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 16 : 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeSlot['start']!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: isDesktop ? 10 : 9,
                      ),
                    ),
                    Text(
                      timeSlot['end']!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: isDesktop ? 10 : 9,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
                ...List.generate(5, (dayIndex) {
          final dayOfWeek = dayIndex + 1;
          final isToday = DateTime.now().weekday == dayOfWeek;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                            Container(
                width: dayColumnWidth,
                height: cellHeight,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: isToday
                      ? const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  color: isToday ? null : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _dayNames[dayIndex],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 16 : 14,
                        ),
                      ),
                      if (isToday)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
                            ...List.generate(_timeSlots.length, (periodIndex) {
                final period = periodIndex + 1;
                final entry = timetable.firstWhere(
                      (e) => e.dayOfWeek == dayOfWeek && e.period == period,
                  orElse: () => TimetableEntry(
                    id: 'empty',
                    subjectId: '',
                    teacherId: '',
                    classId: '',
                    room: '',
                    dayOfWeek: dayOfWeek,
                    period: period,
                    startTime: DateTime.now(),
                    endTime: DateTime.now(),
                  ),
                );

                return _buildTimetableCell(
                  entry,
                  cellWidth,
                  cellHeight,
                  isDesktop,
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTimetableCell(
      TimetableEntry entry,
      double width,
      double height,
      bool isDesktop,
      ) {
    if (entry.id == 'empty') {
      return Container(
        width: width,
        height: height,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      );
    }

    final subject = _dataService.getSubjectById(entry.subjectId);
    final schoolClass = _dataService.getClassById(entry.classId);

    if (subject == null) {
      return Container(
        width: width,
        height: height,
        margin: const EdgeInsets.all(2),
      );
    }

    final isSelected = _selectedEntry?.id == entry.id;

    return GestureDetector(
      onTap: () => _showLessonDetail(entry, subject, schoolClass),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _selectedEntry = entry),
        onExit: (_) => setState(() => _selectedEntry = null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: height,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                subject.color,
                subject.color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.white : subject.color.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: subject.color.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 8 : 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  subject.shortName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 15 : 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  schoolClass?.name ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isDesktop ? 11 : 9,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  entry.room,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isDesktop ? 10 : 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLessonDetail(
      TimetableEntry entry,
      Subject subject,
      SchoolClass? schoolClass,
      ) {
    final startTime =
        '${entry.startTime.hour.toString().padLeft(2, '0')}:${entry.startTime.minute.toString().padLeft(2, '0')}';
    final endTime =
        '${entry.endTime.hour.toString().padLeft(2, '0')}:${entry.endTime.minute.toString().padLeft(2, '0')}';

    final students = schoolClass != null
        ? _dataService.getStudentsForClass(schoolClass.id)
        : <Student>[];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [subject.color, subject.color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    subject.shortName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '${_fullDayNames[entry.dayOfWeek - 1]} | ${entry.period}. hodina',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.access_time, 'Čas', '$startTime - $endTime'),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.class_outlined,
                  'Třída',
                  schoolClass?.name ?? 'Neznámá',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.room_outlined, 'Místnost', entry.room),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.event_outlined,
                  'Den',
                  _fullDayNames[entry.dayOfWeek - 1],
                ),
                if (students.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Studenti (${students.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...students.map((student) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16),
                        const SizedBox(width: 8),
                        Text(student.fullName),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zavřít'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('O rozvrhu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Zobrazení vašeho týdenního rozvrhu výuky.'),
              SizedBox(height: 12),
              Text('• Kliknutím na hodinu zobrazíte detaily a seznam žáků'),
              Text('• Aktuální den je zvýrazněn oranžově'),
              Text('• Barvy odpovídají jednotlivým předmětům'),
            ],
          ),
        );
      },
    );
  }
}
