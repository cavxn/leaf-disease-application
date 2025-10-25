import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/disease_history_provider.dart';
import '../models/disease_detection.dart';
import '../utils/app_theme.dart';
import 'result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.neonGradient,
                            ),
                            child: const Icon(
                              Icons.history_rounded,
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
                                  'Detection History',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Track your plant health journey',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          labelColor: isDark ? Colors.white : Colors.black87,
                          unselectedLabelColor: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                          indicatorColor: AppTheme.neonGradient.colors.first,
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                          tabs: const [
                            Tab(text: 'All'),
                            Tab(text: 'Favorites'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: -0.3, duration: 600.ms, curve: Curves.easeOutCubic),

                // History List
                Expanded(
                  child: TabBarView(
                    children: [
                      _HistoryList(detections: context.watch<DiseaseHistoryProvider>().detections),
                      _HistoryList(detections: context.watch<DiseaseHistoryProvider>().favorites),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<DiseaseDetection> detections;

  const _HistoryList({required this.detections});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (detections.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.neonGradient,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No detections yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start by detecting a disease to see it here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: detections.length,
      itemBuilder: (context, index) {
        final detection = detections[index];
        final isHealthy = detection.isHealthy;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
            borderRadius: BorderRadius.circular(20),
            border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
            boxShadow: [
              BoxShadow(
                color: isHealthy 
                  ? const Color(0xFF10B981).withOpacity(0.2)
                  : AppTheme.neonGradient.colors[2].withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(detection: detection),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isHealthy 
                            ? const Color(0xFF10B981).withOpacity(0.3)
                            : AppTheme.neonGradient.colors[2].withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          detection.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isHealthy 
                                    ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF10B981)])
                                    : AppTheme.neonGradient,
                                ),
                                child: Icon(
                                  isHealthy ? Icons.eco_rounded : Icons.warning_amber_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  detection.diseaseName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Confidence: ${(detection.confidence * 100).round()}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: isHealthy 
                                ? const Color(0xFF10B981)
                                : AppTheme.neonGradient.colors[2],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Detected on ${_formatDate(detection.timestamp)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Arrow
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms).slideX(begin: 0.3);
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 