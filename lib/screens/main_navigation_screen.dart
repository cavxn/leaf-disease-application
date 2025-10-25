import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home_screen.dart';
import 'camera_screen.dart';
import 'result_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'permission_screen.dart';
import 'plant_care_screen.dart';
import 'plant_calendar_screen.dart';
import 'my_garden_screen.dart';
import 'main_drawer.dart';
import '../widgets/ai_fab.dart';
import '../utils/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool _permissionsGranted = true; // Always consider permissions as granted

  static final List<Widget> _pages = <Widget>[
    HomeScreen(),
    MyGardenScreen(),
    PlantCareScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recheck permissions when returning to this screen
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Always consider permissions as granted
    setState(() {
      _permissionsGranted = true;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Bypass permission check - always show main app
    // if (!_permissionsGranted) {
    //   return PermissionScreen(
    //     onPermissionsGranted: () {
    //       // Callback when permissions are granted
    //       _checkPermissions();
    //     },
    //   );
    // }
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      drawer: const MainDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
        ),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
          borderRadius: BorderRadius.circular(25),
          border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppTheme.neonGradient.colors.first,
            unselectedItemColor: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
            iconSize: 24,
            items: [
              _buildNavItem(Icons.eco_rounded, 'Detect', 0),
              _buildNavItem(Icons.local_florist_rounded, 'Garden', 1),
              _buildNavItem(Icons.spa_rounded, 'Care', 2),
              _buildNavItem(Icons.history_rounded, 'History', 3),
              _buildNavItem(Icons.settings_rounded, 'Settings', 4),
            ],
          ),
        ),
      ).animate().slideY(begin: 0.3, duration: 800.ms, curve: Curves.easeOutCubic),
      floatingActionButton: const AIFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected ? AppTheme.neonGradient : null,
          color: isSelected ? null : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: isSelected ? 26 : 24,
        ),
      ),
      label: label,
    );
  }
}

class _DetectionResultsScreenPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.neonGradient,
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Detection Results',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'View your plant disease detection results here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }
} 