import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => TimetableScreenState();
}

class TimetableScreenState extends State<TimetableScreen> {
  final DataService dataService = DataService();

  final List<String> dayNames = ['Po', 'Út', 'St', 'Čt', 'P'];
  final List<String> fullDayNames = [
    'Pondělí',
    'Úterý',
    'Středa',
    'Čtvrtek',
    'Pátek',
  ];

  final List<Map<String, String>> timeSlots = [
    {'period': '1', 'start': '7:05', 'end': '7:50'},
    {'period': '2', 'start': '8:00', 'end': '8:45'},
    {'period': '3', 'start': '8:55', 'end': '9:40'},
    {'period': '4', 'start': '9:55', 'end': '10:40'},
    {'period': '5', 'start': '10:50', 'end': '11:35'},
    {'period': '6', 'start': '11:45', 'end': '12:30'},
    {'period': '7', 'start': '12:40', 'end': '13:25'},
    {'period': '8', 'start': '13:35', 'end': '14:20'},
  ];

  TimetableEntry? selectedEntry;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentStudent = dataService.getCurrentStudent();

    if (currentStudent == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Rozvrh'),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: Text('Žádný student není přihlášen'),
        ),
      );
    }

    final timetable = dataService.getTimetableForClass(currentStudent.classId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Rozvrh'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showInfoDialog(context),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView( // vertical scroll
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: buildTimetableView(timetable, screenWidth),
          ),
        ),
      ),
    );
  }

  Widget buildTimetableView(List<TimetableEntry> timetable, double screenWidth) {
    final isDesktop = screenWidth > 800;

    // allow grid to be wider than screen on mobile
    final effectiveWidth = isDesktop ? (screenWidth > 1400 ? 1400.0 : screenWidth) : 1200.0;

    final dayColumnWidth = isDesktop ? 70.0 : 50.0;
    final outerMargin = isDesktop ? 16.0 : 12.0;
    final innerPadding = isDesktop ? 20.0 : 12.0;
    final cellMargin = 2.0;

    final totalHorizontalSpace = (outerMargin * 2) +
        (innerPadding * 2) +
        dayColumnWidth +
        (cellMargin * 2 * timeSlots.length);

    final availableWidth = effectiveWidth - totalHorizontalSpace;
    final cellWidth = availableWidth / timeSlots.length;
    final cellHeight = isDesktop ? 85.0 : 70.0;

    return Container(
      margin: EdgeInsets.all(outerMargin),
      child: AppTheme.glass(
        borderRadius: isDesktop ? 20 : 18,
        padding: EdgeInsets.all(innerPadding),
        color: Colors.white.withOpacity(0.08),
        child: SingleChildScrollView(          // <── horizontal scroll
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // total width of the grid, so it can overflow on mobile and be scrollable
              minWidth: effectiveWidth,
            ),
            child: buildTimetableGrid(
              timetable,
              cellWidth,
              cellHeight,
              dayColumnWidth,
              isDesktop,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTimetableGrid(
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
        // header row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: dayColumnWidth,
              height: isDesktop ? 60 : 50,
            ),
            ...List.generate(timeSlots.length, (index) {
              final timeSlot = timeSlots[index];
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
        // day rows
        ...List.generate(5, (dayIndex) {
          final dayOfWeek = dayIndex + 1;
          final isToday = DateTime.now().weekday == dayOfWeek;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // day column
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
                        dayNames[dayIndex],
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
              // period cells
              ...List.generate(timeSlots.length, (periodIndex) {
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

                return buildTimetableCell(
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

  Widget buildTimetableCell(
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

    final subject = dataService.getSubjectById(entry.subjectId);
    final teacher = dataService.getTeacherById(entry.teacherId);

    if (subject == null) {
      return Container(
        width: width,
        height: height,
        margin: const EdgeInsets.all(2),
      );
    }

    final isSelected = selectedEntry?.id == entry.id;

    return GestureDetector(
      onTap: () => showLessonDetail(entry, subject, teacher),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => selectedEntry = entry),
        onExit: (_) => setState(() => selectedEntry = null),
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
                  teacher?.lastName ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isDesktop ? 11 : 9,
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

  void showLessonDetail(
      TimetableEntry entry,
      Subject subject,
      Teacher? teacher,
      ) {
    final startTime =
        '${entry.startTime.hour.toString().padLeft(2, '0')}:${entry.startTime.minute.toString().padLeft(2, '0')}';
    final endTime =
        '${entry.endTime.hour.toString().padLeft(2, '0')}:${entry.endTime.minute.toString().padLeft(2, '0')}';

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
                      '${fullDayNames[entry.dayOfWeek - 1]} | ${entry.period}. hodina',
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDetailRow(Icons.access_time, 'Čas', '$startTime - $endTime'),
              const SizedBox(height: 12),
              buildDetailRow(
                Icons.person_outline,
                'Učitel',
                teacher?.fullName ?? 'Neznámý',
              ),
              const SizedBox(height: 12),
              buildDetailRow(Icons.room_outlined, 'Místnost', entry.room),
              const SizedBox(height: 12),
              buildDetailRow(
                Icons.event_outlined,
                'Den',
                fullDayNames[entry.dayOfWeek - 1],
              ),
            ],
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

  Widget buildDetailRow(IconData icon, String label, String value) {
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

  void showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('O rozvrhu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Zobrazení týdenního rozvrhu hodin.'),
              SizedBox(height: 12),
              Text('Na mobilu můžete rozvrh posouvat vodorovně pro zobrazení všech hodin.'),
              Text('Kliknutím na hodinu zobrazíte detaily.'),
              Text('Aktuální den je zvýrazněn oranžově.'),
              Text('Barvy odpovídají jednotlivým předmětům.'),
            ],
          ),
        );
      },
    );
  }
}
