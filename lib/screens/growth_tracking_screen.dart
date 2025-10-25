import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/growth_measurement.dart';
import '../models/garden_plant.dart';
import '../providers/growth_provider.dart';
import '../providers/garden_provider.dart';
import '../utils/app_theme.dart';
import 'dart:math';

class GrowthTrackingScreen extends StatefulWidget {
  const GrowthTrackingScreen({Key? key}) : super(key: key);

  @override
  State<GrowthTrackingScreen> createState() => _GrowthTrackingScreenState();
}

class _GrowthTrackingScreenState extends State<GrowthTrackingScreen> {
  String? _selectedPlantId;
  final _heightController = TextEditingController();
  final _widthController = TextEditingController();
  final _leafCountController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _heightController.dispose();
    _widthController.dispose();
    _leafCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addMeasurement() async {
    if (!_formKey.currentState!.validate() || _selectedPlantId == null) {
      return;
    }

    try {
      final measurement = GrowthMeasurement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        plantId: _selectedPlantId!,
        timestamp: DateTime.now(),
        height: double.parse(_heightController.text),
        width: double.parse(_widthController.text),
        leafCount: _leafCountController.text.isNotEmpty 
            ? double.parse(_leafCountController.text) 
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        measurementType: 'manual',
      );

      await context.read<GrowthProvider>().addMeasurement(measurement);
      
      // Clear form
      _heightController.clear();
      _widthController.clear();
      _leafCountController.clear();
      _notesController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Growth measurement added successfully!'),
            backgroundColor: AppTheme.neonGradient.colors.first,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding measurement: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Tracking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                  borderRadius: BorderRadius.circular(20),
                  border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 48,
                      color: AppTheme.neonGradient.colors.first,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Track Plant Growth',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Measure and monitor your plant\'s growth over time',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
              
              const SizedBox(height: 24),
              
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
                                    'No plants in your garden yet. Add a plant first to track its growth.',
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
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
              
              const SizedBox(height: 24),
              
              // Measurement Form
              if (_selectedPlantId != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Growth Measurements',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Height Input
                        TextFormField(
                          controller: _heightController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Height (cm)',
                            hintText: 'Enter plant height',
                            prefixIcon: Icon(Icons.height, color: AppTheme.neonGradient.colors.first),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the height';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Height must be greater than 0';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Width Input
                        TextFormField(
                          controller: _widthController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Width (cm)',
                            hintText: 'Enter plant width',
                            prefixIcon: Icon(Icons.width_wide, color: AppTheme.neonGradient.colors.first),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the width';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Width must be greater than 0';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Leaf Count Input (Optional)
                        TextFormField(
                          controller: _leafCountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Leaf Count (optional)',
                            hintText: 'Enter number of leaves',
                            prefixIcon: Icon(Icons.eco, color: AppTheme.neonGradient.colors.first),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              if (int.parse(value) < 0) {
                                return 'Leaf count cannot be negative';
                              }
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Notes Input
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Notes (optional)',
                            hintText: 'Add any observations about the plant',
                            prefixIcon: Icon(Icons.note, color: AppTheme.neonGradient.colors.first),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addMeasurement,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonGradient.colors.first,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_chart_rounded),
                                const SizedBox(width: 8),
                                Text(
                                  'Add Measurement',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
              
              const SizedBox(height: 24),
              
              // Recent Measurements
              if (_selectedPlantId != null)
                Consumer<GrowthProvider>(
                  builder: (context, growthProvider, child) {
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
                              'Add your first measurement to start tracking growth!',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    
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
                            'Recent Measurements',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...plantMeasurements.take(3).map((measurement) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.neonGradient.colors.first.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.straighten,
                                      color: AppTheme.neonGradient.colors.first,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${measurement.height.toStringAsFixed(1)}cm × ${measurement.width.toStringAsFixed(1)}cm',
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
                                    ),
                                  ),
                                  if (measurement.leafCount != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${measurement.leafCount!.toInt()} leaves',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
            ],
          ),
        ),
      ),
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
