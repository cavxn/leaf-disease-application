import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'plant_calendar_screen.dart';
import 'water_reminder_screen.dart';
import 'ai_chat_screen.dart';
import 'about_screen.dart';
import 'my_garden_screen.dart';
import 'plant_gallery_screen.dart';
import 'community_screen.dart';
import 'nutrition_screen.dart';
import 'growth_tracking_screen.dart';
import 'growth_analytics_screen.dart';
import 'garden_journal_screen.dart';
import '../providers/theme_provider.dart';
import '../providers/garden_provider.dart';
import '../utils/app_theme.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gardenProvider = context.watch<GardenProvider>();

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.neonGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonGradient.colors.first.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Leaf Detector',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              '${gardenProvider.plants.length} plants in garden',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // AI Chat
                _DrawerTile(
                  icon: Icons.smart_toy_rounded,
                  title: 'AI Assistant',
                  subtitle: 'Ask anything about plants',
                  gradient: AppTheme.neonGradient,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AIChatScreen()),
                    );
                  },
                  delay: 100.ms,
                ),

                // Growth Tracking
                _DrawerTile(
                  icon: Icons.straighten_rounded,
                  title: 'Growth Tracking',
                  subtitle: 'Measure height & width',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GrowthTrackingScreen()),
                    );
                  },
                  delay: 200.ms,
                ),

                // Growth Analytics
                _DrawerTile(
                  icon: Icons.analytics_rounded,
                  title: 'Growth Analytics',
                  subtitle: 'Charts & comparisons',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GrowthAnalyticsScreen()),
                    );
                  },
                  delay: 250.ms,
                ),

                // Garden Journal
                _DrawerTile(
                  icon: Icons.book_rounded,
                  title: 'Garden Journal',
                  subtitle: 'Daily entries & memories',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GardenJournalScreen()),
                    );
                  },
                  delay: 300.ms,
                ),

                // Plant Calendar
                _DrawerTile(
                  icon: Icons.calendar_today_rounded,
                  title: 'Plant Calendar',
                  subtitle: 'Track growth milestones',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PlantCalendarScreen()),
                    );
                  },
                  delay: 300.ms,
                ),

                // Photo Gallery (New!)
                _DrawerTile(
                  icon: Icons.photo_library_rounded,
                  title: 'Photo Gallery',
                  subtitle: 'View & compare plant photos',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
                  ),
                  onTap: () => _showGallerySelector(context),
                  delay: 250.ms,
                ),

                // Community
                _DrawerTile(
                  icon: Icons.people_rounded,
                  title: 'Community',
                  subtitle: 'Share & learn from others',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CommunityScreen()),
                    );
                  },
                  delay: 300.ms,
                ),

                // Nutrition & Fertilization
                _DrawerTile(
                  icon: Icons.eco_rounded,
                  title: 'Nutrition & Fertilization',
                  subtitle: 'Schedules, products & guides',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8A56), Color(0xFFFF6B35)],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NutritionScreen()),
                    );
                  },
                  delay: 350.ms,
                ),

                // Water Reminder
                _DrawerTile(
                  icon: Icons.water_drop_rounded,
                  title: 'Water Reminder',
                  subtitle: 'Set watering schedules',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WaterReminderScreen()),
                    );
                  },
                  delay: 400.ms,
                ),

                const SizedBox(height: 16),

                // Divider
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // About
                _DrawerTile(
                  icon: Icons.info_rounded,
                  title: 'About',
                  subtitle: 'Disease information & tips',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                                      onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutScreen()),
                    );
                  },
                  delay: 450.ms,
                ),

                const SizedBox(height: 24),

                // Footer
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 16,
                            color: AppTheme.neonGradient.colors.first,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Made with care for plant lovers',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'v1.0.0',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white.withOpacity(0.5) : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                                 ).animate().fadeIn(duration: 600.ms, delay: 550.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGallerySelector(BuildContext context) {
    final gardenProvider = context.read<GardenProvider>();
    
    if (gardenProvider.plants.isEmpty) {
      Navigator.pop(context);
      // Navigate to Garden screen first
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyGardenScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a plant first to use the photo gallery!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
            borderRadius: BorderRadius.circular(24),
            border: isDark 
                ? AppTheme.glassmorphismDark.border 
                : AppTheme.glassmorphismLight.border,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
                        ),
                      ),
                      child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Select Plant',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: gardenProvider.plants.length,
                  itemBuilder: (context, index) {
                    final plant = gardenProvider.plants[index];
                    final photoCount = gardenProvider.getPhotosForPlant(plant.id).length;
                    
                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const LinearGradient(
                            colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
                          ).colors.first.withOpacity(0.2),
                        ),
                        child: plant.image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(plant.image!, fit: BoxFit.cover),
                              )
                            : const Icon(
                                Icons.eco_rounded,
                                color: Color(0xFFEC4899),
                              ),
                      ),
                      title: Text(
                        plant.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        '$photoCount ${photoCount == 1 ? 'photo' : 'photos'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantGalleryScreen(plant: plant),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;
  final Duration delay;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: gradient,
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.white.withOpacity(0.5) : Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay)
        .slideX(begin: -0.3, end: 0, duration: 400.ms, delay: delay);
  }
}
