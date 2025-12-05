import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import 'grades_screen.dart';
import 'teacher_classes_screen.dart';
import 'timetable_screen.dart';
import 'teacher_timetable_screen.dart';

class DashboardScreen extends StatelessWidget {
  final UserType userType;
  final VoidCallback onLogout;
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;
  final bool effectiveIsDark;
  final String themeDisplayName;

  const DashboardScreen({
    super.key,
    required this.userType,
    required this.onLogout,
    required this.onThemeToggle,
    required this.currentThemeMode,
    required this.effectiveIsDark,
    required this.themeDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDesktop),
            Expanded(
              child: _buildDashboardGrid(context, isDesktop),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    final dataService = DataService();
    String userName = '';

    if (userType == UserType.student) {
      final student = dataService.getCurrentStudent();
      userName = student?.fullName ?? 'Žák';
    } else {
      final teacher = dataService.getCurrentTeacher();
      userName = teacher?.fullName ?? 'Učitel';
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(isDesktop ? 12 : 16),
      child: AppTheme.glass(
        borderRadius: isDesktop ? 24 : 26,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 16 : 20,
          vertical: isDesktop ? 10 : 12,
        ),
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => _showMenuDialog(context),
              icon: Icon(
                Icons.menu_rounded,
                size: isDesktop ? 22 : 26,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Přehled',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: isDesktop ? 18 : 20,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 10 : 14,
                vertical: isDesktop ? 4 : 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isDesktop ? 18 : 22),
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    userType == UserType.student
                        ? Icons.person_outline
                        : Icons.person_4_outlined,
                    size: isDesktop ? 18 : 20,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  SizedBox(width: isDesktop ? 6 : 8),
                  Text(
                    '$userName • ${userType == UserType.student ? 'žák' : 'učitel'}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: isDesktop ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isDesktop ? 8 : 10),
            Tooltip(
              message: 'Režim: $themeDisplayName',
              child: IconButton(
                onPressed: onThemeToggle,
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getThemeIcon(),
                      size: isDesktop ? 22 : 24,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    if (currentThemeMode == ThemeMode.system)
                      Container(
                        margin: const EdgeInsets.only(left: 3),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getThemeIcon() {
    switch (currentThemeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
    }
  }

  Widget _buildDashboardGrid(BuildContext context, bool isDesktop) {
    final modules = _getModules(context);
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    double childAspectRatio;
    double maxWidth;

    if (screenWidth > 1200) {
      crossAxisCount = 6;
      childAspectRatio = 1.0;
      maxWidth = 1200;
    } else if (screenWidth > 800) {
      crossAxisCount = 5;
      childAspectRatio = 1.0;
      maxWidth = 1000;
    } else if (screenWidth > 600) {
      crossAxisCount = 4;
      childAspectRatio = 0.95;
      maxWidth = double.infinity;
    } else {
      crossAxisCount = 3;
      childAspectRatio = 0.9;
      maxWidth = double.infinity;
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.all(isDesktop ? 12 : 16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: isDesktop ? 10 : 12,
            mainAxisSpacing: isDesktop ? 10 : 12,
          ),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final module = modules[index];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 420 + index * 40),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 26 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: _buildModuleCard(context, module, isDesktop),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModuleCard(
      BuildContext context, DashboardModule module, bool isDesktop) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double radius = isDesktop ? 18 : 22;

    return AppTheme.glass(
      borderRadius: radius,
      color: isDark
          ? Colors.white.withOpacity(0.06)
          : Colors.white.withOpacity(0.9),
      padding: EdgeInsets.all(isDesktop ? 12 : 16),
      border: BorderSide(
        color: module.color.withOpacity(0.5),
        width: 1.1,
      ),
      onTap: module.onTap ?? () => _showComingSoonDialog(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isDesktop ? 40 : 50,
            height: isDesktop ? 40 : 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  module.color,
                  module.color.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isDesktop ? 10 : 12),
              boxShadow: [
                BoxShadow(
                  color: module.color.withOpacity(0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              module.icon,
              color: Colors.white,
              size: isDesktop ? 20 : 24,
            ),
          ),
          SizedBox(height: isDesktop ? 10 : 12),
          Text(
            module.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: isDesktop ? 11 : 13,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<DashboardModule> _getModules(BuildContext context) {
    if (userType == UserType.student) {
      return [
        DashboardModule(
          title: 'Komens',
          icon: Icons.chat_bubble_outline,
          color: const Color(0xFF64B5F6),
        ),
        DashboardModule(
          title: 'Absence',
          icon: Icons.event_busy_outlined,
          color: const Color(0xFFE91E63),
        ),
        DashboardModule(
          title: 'Plán akcí',
          icon: Icons.event_outlined,
          color: const Color(0xFFFF9800),
        ),
        DashboardModule(
          title: 'Známky',
          icon: Icons.grade_outlined,
          color: const Color(0xFF2196F3),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const GradesScreen()),
          ),
        ),
        DashboardModule(
          title: 'Rozvrh',
          icon: Icons.table_chart_outlined,
          color: const Color(0xFFFF9800),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const TimetableScreen()),
          ),
        ),
        DashboardModule(
          title: 'Suplování',
          icon: Icons.swap_horiz_outlined,
          color: const Color(0xFFFF7043),
        ),
        DashboardModule(
          title: 'Předměty',
          icon: Icons.menu_book_outlined,
          color: const Color(0xFF4CAF50),
        ),
        DashboardModule(
          title: 'Výuka',
          icon: Icons.school_outlined,
          color: const Color(0xFF9C27B0),
        ),
        DashboardModule(
          title: 'Domácí úkoly',
          icon: Icons.assignment_outlined,
          color: const Color(0xFF00BCD4),
        ),
        DashboardModule(
          title: 'GDPR',
          icon: Icons.security_outlined,
          color: const Color(0xFF795548),
        ),
        DashboardModule(
          title: 'Infokanál',
          icon: Icons.info_outline,
          color: const Color(0xFF009688),
        ),
        DashboardModule(
          title: 'Dokumenty',
          icon: Icons.description_outlined,
          color: const Color(0xFF673AB7),
        ),
        DashboardModule(
          title: 'Ankety',
          icon: Icons.poll_outlined,
          color: const Color(0xFF8BC34A),
        ),
        DashboardModule(
          title: 'Výukové zdroje',
          icon: Icons.library_books_outlined,
          color: const Color(0xFF3F51B5),
        ),
      ];
    } else {
      return [
        DashboardModule(
          title: 'Třídní kniha',
          icon: Icons.book_outlined,
          color: const Color(0xFF2196F3),
        ),
        DashboardModule(
          title: 'Rozvrh',
          icon: Icons.table_chart_outlined,
          color: const Color(0xFFFF9800),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const TeacherTimetableScreen()),
          ),
        ),
        DashboardModule(
          title: 'Známkování',
          icon: Icons.grade_outlined,
          color: const Color(0xFF4CAF50),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TeacherSubjectsScreen(),
            ),
          ),
        ),
        DashboardModule(
          title: 'Docházka',
          icon: Icons.how_to_reg_outlined,
          color: const Color(0xFFE91E63),
        ),
        DashboardModule(
          title: 'Žáci',
          icon: Icons.people_outline,
          color: const Color(0xFF9C27B0),
        ),
        DashboardModule(
          title: 'Úkoly',
          icon: Icons.assignment_outlined,
          color: const Color(0xFF00BCD4),
        ),
        DashboardModule(
          title: 'Komunikace',
          icon: Icons.chat_outlined,
          color: const Color(0xFF64B5F6),
        ),
        DashboardModule(
          title: 'Materiály',
          icon: Icons.folder_outlined,
          color: const Color(0xFF795548),
        ),
        DashboardModule(
          title: 'Statistiky',
          icon: Icons.analytics_outlined,
          color: const Color(0xFF009688),
        ),
      ];
    }
  }

  void _showMenuDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Menu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Nastavení'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showComingSoonDialog(context);
                },
              ),
              ListTile(
                leading: Icon(_getThemeIcon()),
                title: Text('Vzhled: $themeDisplayName'),
                subtitle: Text(_getThemeSubtitle()),
                onTap: () {
                  Navigator.of(context).pop();
                  onThemeToggle();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Odhlásit se'),
                onTap: () {
                  Navigator.of(context).pop();
                  onLogout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getThemeSubtitle() {
    switch (currentThemeMode) {
      case ThemeMode.system:
        return 'Automaticky dle systému';
      case ThemeMode.light:
        return 'Vždy světlý režim';
      case ThemeMode.dark:
        return 'Vždy tmavý režim';
    }
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Připravujeme'),
          content: Text(
            'Tato funkce bude dostupná v plné verzi aplikace.',
          ),
        );
      },
    );
  }
}
