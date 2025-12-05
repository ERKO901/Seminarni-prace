import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final Function(UserType) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final cardWidth = isDesktop ? 420.0 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardWidth),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 0 : 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(isDesktop),
                        SizedBox(height: isDesktop ? 24 : 36),
                        _buildLoginOptions(isDesktop),
                        SizedBox(height: isDesktop ? 28 : 44),
                        _buildDemoLabel(isDesktop),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDesktop) {
    return Column(
      children: [
        AppTheme.glass(
          borderRadius: isDesktop ? 32 : 40,
          padding: EdgeInsets.all(isDesktop ? 26 : 32),
          color: Colors.white.withOpacity(0.10),
          child: const Icon(
            Icons.school_outlined,
            size: 56,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isDesktop ? 18 : 24),
        Text(
          'Magistři',
          style: TextStyle(
            fontSize: isDesktop ? 30 : 38,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(0, 6),
                blurRadius: 16,
              ),
            ],
          ),
        ),
        SizedBox(height: isDesktop ? 6 : 10),
        Text(
          'Demo školního systému',
          style: TextStyle(
            fontSize: isDesktop ? 14 : 16,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginOptions(bool isDesktop) {
    return Column(
      children: [
        Text(
          'Vyberte typ účtu',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: isDesktop ? 26 : 32),
        _buildLoginOption(
          title: 'Žák',
          subtitle: 'Přihlásit se jako žák',
          icon: Icons.person_outline,
          isDesktop: isDesktop,
          onTap: () => widget.onLogin(UserType.student),
        ),
        SizedBox(height: isDesktop ? 14 : 18),
        _buildLoginOption(
          title: 'Učitel',
          subtitle: 'Přihlásit se jako učitel',
          icon: Icons.person_4_outlined,
          isDesktop: isDesktop,
          onTap: () => widget.onLogin(UserType.teacher),
        ),
      ],
    );
  }

  Widget _buildDemoLabel(bool isDesktop) {
    return Text(
      'Demo verze - žádná data nejsou skutečná',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: isDesktop ? 11 : 12,
        color: Colors.white.withOpacity(0.65),
      ),
    );
  }

  Widget _buildLoginOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDesktop,
  }) {
    final double radius = isDesktop ? 22 : 24;

    return AppTheme.glass(
      borderRadius: radius,
      padding: EdgeInsets.all(isDesktop ? 16 : 20),
      color: Colors.white.withOpacity(0.10),
      border: BorderSide(color: Colors.white.withOpacity(0.28)),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: isDesktop ? 44 : 52,
            height: isDesktop ? 44 : 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isDesktop ? 14 : 16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF42A5F5),
                  Color(0xFF7E57C2),
                ],
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isDesktop ? 22 : 26,
            ),
          ),
          SizedBox(width: isDesktop ? 14 : 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: isDesktop ? 18 : 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isDesktop ? 4 : 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: isDesktop ? 12 : 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withOpacity(0.8),
            size: isDesktop ? 16 : 18,
          ),
        ],
      ),
    );
  }
}
