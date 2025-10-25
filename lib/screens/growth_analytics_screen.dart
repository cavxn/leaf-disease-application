import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/growth_measurement.dart';
import '../models/garden_plant.dart';
import '../providers/growth_provider.dart';
import '../providers/garden_provider.dart';
import '../utils/app_theme.dart';
import 'dart:math';

class GrowthAnalyticsScreen extends StatefulWidget {
  const GrowthAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<GrowthAnalyticsScreen> createState() => _GrowthAnalyticsScreenState();
}

class _GrowthAnalyticsScreenState extends State<GrowthAnalyticsScreen> with TickerProviderStateMixin {
  String? _selectedPlantId;
  String _selectedDimension = 'height';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Charts', icon: Icon(Icons.show_chart)),
            Tab(text: 'Compare', icon: Icon(Icons.compare)),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildChartsTab(),
            _buildCompareTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plant Selection
          Consumer<GardenProvider>(
            builder: (context, gardenProvider, child) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                  borderRadius: BorderRadius.circular(20),
                  border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Plant',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (gardenProvider.plants.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No plants in your garden yet. Add a plant first to view analytics.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedPlantId,
                        decoration: InputDecoration(
                          labelText: 'Choose a plant',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        ),
                        items: gardenProvider.plants.map((plant) {
                          return DropdownMenuItem<String>(
                            value: plant.id,
                            child: Text(plant.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPlantId = value;
                          });
                        },
                      ),
                  ],
                ),
              );
            },
          ).animate().fadeIn(duration: 600.ms),
          
          const SizedBox(height: 24),
          
          // Growth Statistics
          if (_selectedPlantId != null)
            Consumer<GrowthProvider>(
              builder: (context, growthProvider, child) {
                final stats = growthProvider.getGrowthStats(_selectedPlantId!);
                final plantMeasurements = growthProvider.getMeasurementsForPlant(_selectedPlantId!);
                
                if (plantMeasurements.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                      borderRadius: BorderRadius.circular(20),
                      border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No measurements yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add measurements to see growth analytics!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  children: [
                    // Growth Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Height Growth',
                            '${stats['totalGrowthHeight'].toStringAsFixed(1)} cm',
                            Icons.height,
                            Colors.blue,
                            theme,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Total Width Growth',
                            '${stats['totalGrowthWidth'].toStringAsFixed(1)} cm',
                            Icons.width_wide,
                            Colors.green,
                            theme,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Height Growth Rate',
                            '${stats['averageGrowthRateHeight'].toStringAsFixed(2)} cm/day',
                            Icons.trending_up,
                            Colors.orange,
                            theme,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Width Growth Rate',
                            '${stats['averageGrowthRateWidth'].toStringAsFixed(2)} cm/day',
                            Icons.trending_up,
                            Colors.purple,
                            theme,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Height % Growth',
                            '${stats['totalGrowthPercentageHeight'].toStringAsFixed(1)}%',
                            Icons.percent,
                            Colors.teal,
                            theme,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Measurements',
                            '${stats['measurementCount']}',
                            Icons.analytics,
                            Colors.indigo,
                            theme,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Growth Trend
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                        borderRadius: BorderRadius.circular(20),
                        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Growth Trend',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildTrendIndicator(
                                'Height',
                                growthProvider.getGrowthTrend(_selectedPlantId!, 'height'),
                                theme,
                                isDark,
                              ),
                              const SizedBox(width: 16),
                              _buildTrendIndicator(
                                'Width',
                                growthProvider.getGrowthTrend(_selectedPlantId!, 'width'),
                                theme,
                                isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Growth Milestones
                    _buildMilestonesCard(growthProvider, theme, isDark),
                  ],
                );
              },
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_selectedPlantId != null)
            Consumer<GrowthProvider>(
              builder: (context, growthProvider, child) {
                final plantMeasurements = growthProvider.getMeasurementsForPlant(_selectedPlantId!);
                
                if (plantMeasurements.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                      borderRadius: BorderRadius.circular(20),
                      border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No data to display',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add measurements to see growth charts',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  children: [
                    // Dimension Selector
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                        borderRadius: BorderRadius.circular(20),
                        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDimensionButton('height', 'Height', Icons.height, theme, isDark),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDimensionButton('width', 'Width', Icons.width_wide, theme, isDark),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Simple Chart
                    _buildSimpleChart(plantMeasurements, theme, isDark),
                  ],
                );
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                borderRadius: BorderRadius.circular(20),
                border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.eco,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select a plant',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a plant to view its growth charts',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompareTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
              borderRadius: BorderRadius.circular(20),
              border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.compare_arrows,
                  size: 48,
                  color: AppTheme.neonGradient.colors.first,
                ),
                const SizedBox(height: 16),
                Text(
                  'Plant Comparison',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Compare growth rates between different plants',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Coming Soon!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This feature will allow you to compare growth rates between multiple plants',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator(String dimension, String trend, ThemeData theme, bool isDark) {
    Color color;
    IconData icon;
    String text;
    
    switch (trend) {
      case 'increasing':
        color = Colors.green;
        icon = Icons.trending_up;
        text = 'Growing';
        break;
      case 'decreasing':
        color = Colors.red;
        icon = Icons.trending_down;
        text = 'Declining';
        break;
      case 'stable':
        color = Colors.blue;
        icon = Icons.trending_flat;
        text = 'Stable';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
        text = 'Unknown';
    }
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              dimension,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesCard(GrowthProvider growthProvider, ThemeData theme, bool isDark) {
    final milestones = growthProvider.getGrowthMilestones(_selectedPlantId!);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Growth Milestones',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (milestones.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Keep measuring to unlock growth milestones!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...milestones.map((milestone) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            milestone['message'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            'Achieved on ${_formatDate(milestone['measurement'].timestamp)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildDimensionButton(String dimension, String label, IconData icon, ThemeData theme, bool isDark) {
    final isSelected = _selectedDimension == dimension;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDimension = dimension;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.neonGradient.colors.first.withOpacity(0.2)
              : isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppTheme.neonGradient.colors.first
                : isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.neonGradient.colors.first : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppTheme.neonGradient.colors.first : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart(List<GrowthMeasurement> measurements, ThemeData theme, bool isDark) {
    if (measurements.length < 2) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
        ),
        child: Column(
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Need at least 2 measurements',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add more measurements to see the growth chart',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Simple line chart using basic drawing
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedDimension.toUpperCase()} Growth Over Time',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: SimpleLineChartPainter(
                measurements: measurements,
                dimension: _selectedDimension,
                isDark: isDark,
              ),
              size: const Size(double.infinity, 200),
            ),
          ),
          const SizedBox(height: 16),
          // Chart legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('First', measurements.first, theme, isDark),
              _buildLegendItem('Latest', measurements.last, theme, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, GrowthMeasurement measurement, ThemeData theme, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_selectedDimension == 'height' ? measurement.height : measurement.width}cm',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          _formatDate(measurement.timestamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class SimpleLineChartPainter extends CustomPainter {
  final List<GrowthMeasurement> measurements;
  final String dimension;
  final bool isDark;

  SimpleLineChartPainter({
    required this.measurements,
    required this.dimension,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (measurements.length < 2) return;

    final paint = Paint()
      ..color = isDark ? Colors.white : Colors.black87
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = AppTheme.neonGradient.colors.first
      ..style = PaintingStyle.fill;

    final values = measurements.map((m) => 
      dimension == 'height' ? m.height : m.width
    ).toList();

    final minValue = values.reduce(min);
    final maxValue = values.reduce(max);
    final range = maxValue - minValue;
    
    if (range == 0) return; // All values are the same

    final points = <Offset>[];
    final stepX = size.width / (measurements.length - 1);
    
    for (int i = 0; i < measurements.length; i++) {
      final x = i * stepX;
      final normalizedValue = (values[i] - minValue) / range;
      final y = size.height - (normalizedValue * (size.height - 40)) - 20;
      points.add(Offset(x, y));
    }

    // Draw line
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = 20 + (i * (size.height - 40) / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
