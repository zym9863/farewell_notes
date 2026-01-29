import 'dart:ui';

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'capsule_list_screen.dart';
import 'targets_screen.dart';

/// 主页面 - 底部导航
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [CapsuleListScreen(), TargetsScreen()];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: WidgetStatePropertyAll(
                  theme.textTheme.labelLarge,
                ),
                indicatorColor: isDark
                    ? AppTheme.primaryDark.withOpacity(0.18)
                    : AppTheme.primaryLight.withOpacity(0.16),
                backgroundColor: theme.colorScheme.surface.withOpacity(
                  isDark ? 0.7 : 0.9,
                ),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                height: 76,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      Icons.mail_outline,
                      color: _currentIndex == 0
                          ? (isDark
                              ? AppTheme.primaryDark
                              : AppTheme.primaryLight)
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    selectedIcon: Icon(
                      Icons.mail,
                      color: isDark
                          ? AppTheme.primaryDark
                          : AppTheme.primaryLight,
                    ),
                    label: '时空胶囊',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.person_outline,
                      color: _currentIndex == 1
                          ? (isDark
                              ? AppTheme.primaryDark
                              : AppTheme.primaryLight)
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    selectedIcon: Icon(
                      Icons.person,
                      color: isDark
                          ? AppTheme.primaryDark
                          : AppTheme.primaryLight,
                    ),
                    label: '告别对象',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
