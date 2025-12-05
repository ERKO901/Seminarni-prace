import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';
import 'models/user_model.dart';
import 'services/data_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const MagistryApp());
}

class MagistryApp extends StatefulWidget {
  const MagistryApp({super.key});

  @override
  State<MagistryApp> createState() => _MagistryAppState();
}

class _MagistryAppState extends State<MagistryApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.dark;
  UserType? _userType;
  late bool _systemIsDark;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _systemIsDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _systemIsDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
    });
  }

  bool get _effectiveIsDark {
    switch (_themeMode) {
      case ThemeMode.system:
        return _systemIsDark;
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
    }
  }

  void _cycleTheme() {
    setState(() {
      switch (_themeMode) {
        case ThemeMode.system:
          _themeMode = ThemeMode.light;
          break;
        case ThemeMode.light:
          _themeMode = ThemeMode.dark;
          break;
        case ThemeMode.dark:
          _themeMode = ThemeMode.system;
          break;
      }
    });
  }

  void _setUserType(UserType userType) {
    setState(() {
      _userType = userType;
      if (userType == UserType.student) {
        _dataService.setCurrentUser(DemoUsers.studentId, userType);
      } else {
        _dataService.setCurrentUser(DemoUsers.teacherId, userType);
      }
    });
  }

  void _logout() {
    setState(() {
      _userType = null;
      _dataService.setCurrentUser('', UserType.student);
    });
  }

  String get _themeDisplayName {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'Systém';
      case ThemeMode.light:
        return 'Světlý';
      case ThemeMode.dark:
        return 'Tmavý';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magistři',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final gradient = brightness == Brightness.dark
            ? AppTheme.darkBackgroundGradient
            : AppTheme.lightBackgroundGradient;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(gradient: gradient),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 550),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _userType == null
            ? LoginScreen(
          key: const ValueKey('login_screen'),
          onLogin: _setUserType,
        )
            : DashboardScreen(
          key: const ValueKey('dashboard_screen'),
          userType: _userType!,
          onLogout: _logout,
          onThemeToggle: _cycleTheme,
          currentThemeMode: _themeMode,
          effectiveIsDark: _effectiveIsDark,
          themeDisplayName: _themeDisplayName,
        ),
      ),
    );
  }
}
