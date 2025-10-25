import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/disease_history_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Futuristic App Bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.neonGradient,
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Customize your experience',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: -0.3, duration: 600.ms, curve: Curves.easeOutCubic),

              // Settings Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Theme Settings
                    _SettingsSection(
                      title: 'Appearance',
                      icon: Icons.palette_rounded,
                      children: [
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return Column(
                              children: [
                                _FuturisticSettingsTile(
                                  icon: Icons.brightness_auto_rounded,
                                  title: 'System',
                                  subtitle: 'Follow system theme',
                                  trailing: _FuturisticRadio<ThemeMode>(
                                    value: ThemeMode.system,
                                    groupValue: themeProvider.themeMode,
                                    onChanged: (value) {
                                      if (value != null) {
                                        themeProvider.setThemeMode(value);
                                      }
                                    },
                                  ),
                                ),
                                _FuturisticSettingsTile(
                                  icon: Icons.light_mode_rounded,
                                  title: 'Light',
                                  subtitle: 'Light theme',
                                  trailing: _FuturisticRadio<ThemeMode>(
                                    value: ThemeMode.light,
                                    groupValue: themeProvider.themeMode,
                                    onChanged: (value) {
                                      if (value != null) {
                                        themeProvider.setThemeMode(value);
                                      }
                                    },
                                  ),
                                ),
                                _FuturisticSettingsTile(
                                  icon: Icons.dark_mode_rounded,
                                  title: 'Dark',
                                  subtitle: 'Dark theme',
                                  trailing: _FuturisticRadio<ThemeMode>(
                                    value: ThemeMode.dark,
                                    groupValue: themeProvider.themeMode,
                                    onChanged: (value) {
                                      if (value != null) {
                                        themeProvider.setThemeMode(value);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Data Management
                    _SettingsSection(
                      title: 'Data Management',
                      icon: Icons.storage_rounded,
                      children: [
                        _FuturisticSettingsTile(
                          icon: Icons.delete_forever_rounded,
                          title: 'Clear History',
                          subtitle: 'Delete all detection history',
                          onTap: () => _showFuturisticClearHistoryDialog(context),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Notifications
                    _SettingsSection(
                      title: 'Notifications',
                      icon: Icons.notifications_rounded,
                      children: [
                        _FuturisticSwitchTile(
                          icon: Icons.eco_rounded,
                          title: 'Disease Reminders',
                          subtitle: 'Get tips and reminders for plant care',
                          value: true,
                          onChanged: (val) {
                            // TODO: Save notification setting
                          },
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Image Quality
                    _SettingsSection(
                      title: 'Image Quality',
                      icon: Icons.high_quality_rounded,
                      children: [
                        _FuturisticDropdownTile(
                          icon: Icons.camera_alt_rounded,
                          title: 'Scan Mode',
                          subtitle: 'Choose image quality for detection',
                          value: 'standard',
                          items: const [
                            DropdownMenuItem(value: 'standard', child: Text('Standard')),
                            DropdownMenuItem(value: 'high', child: Text('High Resolution')),
                          ],
                          onChanged: (val) {
                            // TODO: Save image quality setting
                          },
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Storage
                    _SettingsSection(
                      title: 'Storage',
                      icon: Icons.sd_storage_rounded,
                      children: [
                        _FuturisticSettingsTile(
                          icon: Icons.cleaning_services_rounded,
                          title: 'Clear Cache',
                          subtitle: 'Free up storage space',
                          trailing: Text(
                            '12.3 MB',
                            style: TextStyle(
                              color: AppTheme.neonGradient.colors.first,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            // TODO: Clear cache logic
                          },
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Export Data
                    _SettingsSection(
                      title: 'Export Data',
                      icon: Icons.file_download_rounded,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _FuturisticButton(
                                icon: Icons.picture_as_pdf_rounded,
                                label: 'Export PDF',
                                onPressed: () {
                                  // TODO: Export as PDF
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _FuturisticButton(
                                icon: Icons.table_chart_rounded,
                                label: 'Export CSV',
                                onPressed: () {
                                  // TODO: Export as CSV
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 1200.ms).slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // About
                    _SettingsSection(
                      title: 'About',
                      icon: Icons.info_rounded,
                      children: [
                        _FuturisticSettingsTile(
                          icon: Icons.app_settings_alt_rounded,
                          title: 'App Version',
                          subtitle: '1.0.0',
                        ),
                        _FuturisticSettingsTile(
                          icon: Icons.privacy_tip_rounded,
                          title: 'Privacy Policy',
                          subtitle: 'Read our privacy policy',
                          onTap: () {
                            // TODO: Navigate to privacy policy
                          },
                        ),
                        _FuturisticSettingsTile(
                          icon: Icons.description_rounded,
                          title: 'Terms of Service',
                          subtitle: 'Read our terms of service',
                          onTap: () {
                            // TODO: Navigate to terms of service
                          },
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 1400.ms).slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Developer Info
                    _SettingsSection(
                      title: 'Developer & Credits',
                      icon: Icons.person_rounded,
                      children: [
                        _FuturisticSettingsTile(
                          icon: Icons.code_rounded,
                          title: 'Created by Cavin and Bharath',
                          subtitle: 'github.com/Bharath-123',
                          onTap: () {
                            // TODO: Open GitHub
                          },
                        ),
                        _FuturisticSettingsTile(
                          icon: Icons.favorite_rounded,
                          title: 'Acknowledgements',
                          subtitle: 'Thanks to open source & contributors',
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 1600.ms).slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Feedback
                    _SettingsSection(
                      title: 'Feedback & Support',
                      icon: Icons.feedback_rounded,
                      children: [
                        _FuturisticButton(
                          icon: Icons.bug_report_rounded,
                          label: 'Send Feedback / Report Issue',
                          onPressed: () {
                            // TODO: Open feedback form or email
                          },
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 1800.ms).slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Reset App
                    _SettingsSection(
                      title: 'Reset App',
                      icon: Icons.restore_rounded,
                      children: [
                        _FuturisticButton(
                          icon: Icons.restore_rounded,
                          label: 'Restore to Default Settings',
                          onPressed: () => _showFuturisticResetAppDialog(context),
                          isDestructive: true,
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 2000.ms).slideY(begin: 0.3),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFuturisticClearHistoryDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.neonGradient,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Clear History',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete all detection history? This action cannot be undone.',
          style: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.neonGradient.colors.first),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DiseaseHistoryProvider>().clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('History cleared'),
                  backgroundColor: AppTheme.neonGradient.colors.first,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonGradient.colors.first,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showFuturisticResetAppDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Colors.red, Colors.red.shade700]),
              ),
              child: const Icon(
                Icons.restore_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Reset App',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to reset the app to default settings? This will clear all data and preferences.',
          style: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.neonGradient.colors.first),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Reset app logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('App reset to default settings'),
                  backgroundColor: AppTheme.neonGradient.colors.first,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.neonGradient,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _FuturisticSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _FuturisticSettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.neonGradient,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FuturisticRadio<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  const _FuturisticRadio({
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppTheme.neonGradient.colors.first : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: isSelected
            ? Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.neonGradient,
                ),
              )
            : null,
      ),
    );
  }
}

class _FuturisticSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FuturisticSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.neonGradient,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.neonGradient.colors.first,
              activeTrackColor: AppTheme.neonGradient.colors.first.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _FuturisticDropdownTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _FuturisticDropdownTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.neonGradient,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            DropdownButton<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              dropdownColor: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              underline: Container(),
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: AppTheme.neonGradient.colors.first,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FuturisticButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;

  const _FuturisticButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive 
          ? Colors.red 
          : AppTheme.neonGradient.colors.first,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
        shadowColor: isDestructive 
          ? Colors.red.withOpacity(0.3)
          : AppTheme.neonGradient.colors.first.withOpacity(0.3),
      ),
    );
  }
} 