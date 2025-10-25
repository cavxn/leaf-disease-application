import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/nutrition_provider.dart';
import '../models/nutrition_schedule.dart';
import '../models/fertilizer_product.dart';
import '../models/fertilization_history.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Initialize sample data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionProvider>().initializeSampleData();
    });
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nutrition & Fertilization',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.neonGradient.colors.first,
          labelColor: isDark ? Colors.white : Colors.black87,
          unselectedLabelColor: isDark ? Colors.white.withOpacity(0.5) : Colors.black54,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Schedules'),
            Tab(text: 'Products'),
            Tab(text: 'History'),
            Tab(text: 'Guides'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SchedulesTab(),
          _ProductsTab(),
          _HistoryTab(),
          _GuidesTab(),
        ],
      ),
    );
  }
}

class _SchedulesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 48, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      'Fertilization Schedules',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Never miss a fertilization cycle',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.3),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () => _showAddScheduleDialog(context, nutritionProvider),
                icon: const Icon(Icons.add_alarm_rounded),
                label: const Text('Add Reminder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

              const SizedBox(height: 24),

              ...nutritionProvider.schedules.asMap().entries.map((entry) {
                final index = entry.key;
                final schedule = entry.value;
                return _ScheduleCard(
                  schedule: schedule,
                  onMarkCompleted: () => nutritionProvider.markScheduleCompleted(schedule.id),
                  onDelete: () => nutritionProvider.deleteSchedule(schedule.id),
                ).animate().fadeIn(delay: (300 + (index * 100)).ms);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAddScheduleDialog(BuildContext context, NutritionProvider nutritionProvider) {
    String? selectedPlant = 'Tomato Plants';
    String? selectedFrequency = 'biweekly';
    String? selectedFertilizer = 'All-Purpose Fertilizer 10-10-10';
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Fertilization Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Plant Name'),
                  value: selectedPlant,
                  items: const [
                    DropdownMenuItem(value: 'Tomato Plants', child: Text('Tomato Plants')),
                    DropdownMenuItem(value: 'Pepper Plants', child: Text('Pepper Plants')),
                    DropdownMenuItem(value: 'Rose Garden', child: Text('Rose Garden')),
                    DropdownMenuItem(value: 'Lettuce', child: Text('Lettuce')),
                    DropdownMenuItem(value: 'Spinach', child: Text('Spinach')),
                  ],
                  onChanged: (value) => setState(() => selectedPlant = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Fertilizer Type'),
                  value: selectedFertilizer,
                  items: nutritionProvider.products.map((product) => 
                    DropdownMenuItem(
                      value: '${product.name} ${product.npkRatio}',
                      child: Text('${product.name} ${product.npkRatio}'),
                    ),
                  ).toList(),
                  onChanged: (value) => setState(() => selectedFertilizer = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  value: selectedFrequency,
                  items: const [
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'biweekly', child: Text('Bi-weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  ],
                  onChanged: (value) => setState(() => selectedFrequency = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Any special instructions...',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedPlant != null && selectedFrequency != null && selectedFertilizer != null) {
                  final schedule = NutritionSchedule(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    plantId: 'plant_${DateTime.now().millisecondsSinceEpoch}',
                    plantName: selectedPlant!,
                    fertilizerType: selectedFertilizer!,
                    frequency: selectedFrequency!,
                    nextApplication: DateTime.now().add(const Duration(days: 1)),
                    notes: notesController.text,
                  );
                  nutritionProvider.addSchedule(schedule);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reminder added successfully!')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final NutritionSchedule schedule;
  final VoidCallback onMarkCompleted;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.onMarkCompleted,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final now = DateTime.now();
    final daysUntil = schedule.nextApplication.difference(now).inDays;
    final isOverdue = daysUntil < 0;
    final isToday = daysUntil == 0;
    final isTomorrow = daysUntil == 1;

    String getNextApplicationText() {
      if (isOverdue) return 'Overdue by ${-daysUntil} days';
      if (isToday) return 'Today';
      if (isTomorrow) return 'Tomorrow';
      if (daysUntil <= 7) return 'In $daysUntil days';
      return 'In ${(daysUntil / 7).ceil()} weeks';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOverdue ? Colors.red.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isOverdue ? Icons.warning_rounded : Icons.calendar_month,
                  color: isOverdue ? Colors.red : Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.plantName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.fertilizerType,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getNextApplicationText(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOverdue ? Colors.red : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (schedule.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        schedule.notes,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white.withOpacity(0.6) : Colors.black38,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'complete') {
                    onMarkCompleted();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Schedule marked as completed!')),
                    );
                  } else if (value == 'delete') {
                    onDelete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Schedule deleted!')),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'complete',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline),
                        SizedBox(width: 8),
                        Text('Mark Complete'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getFrequencyColor(schedule.frequency).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getFrequencyText(schedule.frequency),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getFrequencyColor(schedule.frequency),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              if (isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'OVERDUE',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getFrequencyColor(String frequency) {
    switch (frequency) {
      case 'weekly':
        return Colors.green;
      case 'biweekly':
        return Colors.orange;
      case 'monthly':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getFrequencyText(String frequency) {
    switch (frequency) {
      case 'weekly':
        return 'Weekly';
      case 'biweekly':
        return 'Bi-weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return frequency;
    }
  }
}

class _ProductsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.local_florist_rounded, size: 48, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Product Recommendations',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find the right NPK ratios for your plants',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.3),

              const SizedBox(height: 24),

              ...nutritionProvider.products.asMap().entries.map((entry) {
                final index = entry.key;
                final product = entry.value;
                return _ProductCard(
                  product: product,
                ).animate().fadeIn(delay: (200 + (index * 100)).ms);
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final FertilizerProduct product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(product.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(product.category),
                  color: _getCategoryColor(product.category),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(product.category).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.npkRatio,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: _getCategoryColor(product.category),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.brand,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(product.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  product.category.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getCategoryColor(product.category),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Apply ${product.frequency}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Suitable for: ${product.suitablePlants.join(', ')}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white.withOpacity(0.6) : Colors.black38,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'organic':
        return Colors.green;
      case 'synthetic':
        return Colors.blue;
      case 'liquid':
        return Colors.purple;
      case 'granular':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'organic':
        return Icons.eco_rounded;
      case 'synthetic':
        return Icons.science_rounded;
      case 'liquid':
        return Icons.water_drop_rounded;
      case 'granular':
        return Icons.grain_rounded;
      default:
        return Icons.science_rounded;
    }
  }
}

class _HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.history_rounded, size: 48, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      'Application History',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track all your fertilization applications',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.3),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () => _showAddHistoryDialog(context, nutritionProvider),
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('Log Application'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

              const SizedBox(height: 24),

              ...nutritionProvider.history.asMap().entries.map((entry) {
                final index = entry.key;
                final history = entry.value;
                return _HistoryCard(
                  history: history,
                  onDelete: () => nutritionProvider.deleteHistory(history.id),
                ).animate().fadeIn(delay: (300 + (index * 100)).ms);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAddHistoryDialog(BuildContext context, NutritionProvider nutritionProvider) {
    String? selectedPlant = 'Tomato Plants';
    String? selectedProduct = 'All-Purpose Fertilizer 10-10-10';
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String selectedUnit = 'cups';
    String selectedMethod = 'soil';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Log Fertilization'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Plant Name'),
                  value: selectedPlant,
                  items: const [
                    DropdownMenuItem(value: 'Tomato Plants', child: Text('Tomato Plants')),
                    DropdownMenuItem(value: 'Pepper Plants', child: Text('Pepper Plants')),
                    DropdownMenuItem(value: 'Rose Garden', child: Text('Rose Garden')),
                    DropdownMenuItem(value: 'Lettuce', child: Text('Lettuce')),
                    DropdownMenuItem(value: 'Spinach', child: Text('Spinach')),
                  ],
                  onChanged: (value) => setState(() => selectedPlant = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  value: selectedProduct,
                  items: nutritionProvider.products.map((product) => 
                    DropdownMenuItem(
                      value: '${product.name} ${product.npkRatio}',
                      child: Text('${product.name} ${product.npkRatio}'),
                    ),
                  ).toList(),
                  onChanged: (value) => setState(() => selectedProduct = value),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: amountController,
                        decoration: const InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Unit'),
                      value: selectedUnit,
                      items: const [
                        DropdownMenuItem(value: 'cups', child: Text('cups')),
                        DropdownMenuItem(value: 'ml', child: Text('ml')),
                        DropdownMenuItem(value: 'tbsp', child: Text('tbsp')),
                        DropdownMenuItem(value: 'tsp', child: Text('tsp')),
                      ],
                      onChanged: (value) => setState(() => selectedUnit = value!),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Application Method'),
                  value: selectedMethod,
                  items: const [
                    DropdownMenuItem(value: 'soil', child: Text('Soil Application')),
                    DropdownMenuItem(value: 'foliar', child: Text('Foliar Spray')),
                    DropdownMenuItem(value: 'drip', child: Text('Drip Irrigation')),
                  ],
                  onChanged: (value) => setState(() => selectedMethod = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Any observations or notes...',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedPlant != null && selectedProduct != null && amountController.text.isNotEmpty) {
                  final product = nutritionProvider.products.firstWhere(
                    (p) => '${p.name} ${p.npkRatio}' == selectedProduct,
                    orElse: () => nutritionProvider.products.first,
                  );
                  
                  final history = FertilizationHistory(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    plantId: 'plant_${DateTime.now().millisecondsSinceEpoch}',
                    plantName: selectedPlant!,
                    productName: selectedProduct!,
                    npkRatio: product.npkRatio,
                    amount: double.tryParse(amountController.text) ?? 0.0,
                    unit: selectedUnit,
                    applicationDate: DateTime.now(),
                    notes: notesController.text,
                    applicationMethod: selectedMethod,
                  );
                  
                  nutritionProvider.addHistory(history);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Application logged successfully!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final FertilizationHistory history;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.history,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final now = DateTime.now();
    final daysAgo = now.difference(history.applicationDate).inDays;
    
    String getTimeAgo() {
      if (daysAgo == 0) return 'Today';
      if (daysAgo == 1) return 'Yesterday';
      if (daysAgo < 7) return '$daysAgo days ago';
      if (daysAgo < 30) return '${(daysAgo / 7).ceil()} weeks ago';
      return '${(daysAgo / 30).ceil()} months ago';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getMethodColor(history.applicationMethod).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMethodIcon(history.applicationMethod),
                  color: _getMethodColor(history.applicationMethod),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.productName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${history.plantName} • ${history.amount} ${history.unit}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          getTimeAgo(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getMethodColor(history.applicationMethod).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getMethodText(history.applicationMethod),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getMethodColor(history.applicationMethod),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('History entry deleted!')),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
          if (history.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                history.notes,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'soil':
        return Colors.brown;
      case 'foliar':
        return Colors.green;
      case 'drip':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'soil':
        return Icons.landscape_rounded;
      case 'foliar':
        return Icons.water_drop_rounded;
      case 'drip':
        return Icons.water_rounded;
      default:
        return Icons.check_circle;
    }
  }

  String _getMethodText(String method) {
    switch (method.toLowerCase()) {
      case 'soil':
        return 'Soil';
      case 'foliar':
        return 'Foliar';
      case 'drip':
        return 'Drip';
      default:
        return method;
    }
  }
}

class _GuidesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.book_outlined, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Mixing Guides',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Learn how to mix and apply fertilizers correctly',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.3),

          const SizedBox(height: 24),

          _GuideCard(
            title: 'NPK Ratio Guide',
            description: 'Understanding N-P-K numbers and when to use each',
            icon: Icons.science_rounded,
            onTap: () => _navigateToGuide(context, 'NPK Ratio Guide'),
          ).animate().fadeIn(delay: 200.ms),

          _GuideCard(
            title: 'Mixing Instructions',
            description: 'Step-by-step guide to safely mixing fertilizers',
            icon: Icons.science_rounded,
            onTap: () => _navigateToGuide(context, 'Mixing Instructions'),
          ).animate().fadeIn(delay: 300.ms),

          _GuideCard(
            title: 'Application Methods',
            description: 'Different ways to apply fertilizer effectively',
            icon: Icons.water_drop_rounded,
            onTap: () => _navigateToGuide(context, 'Application Methods'),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  void _navigateToGuide(BuildContext context, String guideTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _GuideDetailScreen(guideTitle: guideTitle),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _GuideCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
              borderRadius: BorderRadius.circular(20),
              border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.purple, size: 32),
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
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideDetailScreen extends StatelessWidget {
  final String guideTitle;

  const _GuideDetailScreen({required this.guideTitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          guideTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _buildGuideContent(context, guideTitle),
        ),
      ),
    );
  }

  Widget _buildGuideContent(BuildContext context, String guideTitle) {
    switch (guideTitle) {
      case 'NPK Ratio Guide':
        return _buildNPKGuide(context);
      case 'Mixing Instructions':
        return _buildMixingGuide(context);
      case 'Application Methods':
        return _buildApplicationGuide(context);
      default:
        return const SizedBox();
    }
  }

  Widget _buildNPKGuide(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          context,
          'What is NPK?',
          'NPK stands for Nitrogen (N), Phosphorus (P), and Potassium (K) - the three primary nutrients plants need for healthy growth.',
          Icons.science_rounded,
          Colors.blue,
        ),
        
        _buildSectionCard(
          context,
          'Nitrogen (N)',
          '• Promotes leafy green growth\n• Essential for photosynthesis\n• Use for: Leafy vegetables, grass, young plants\n• Signs of deficiency: Yellow leaves, stunted growth',
          Icons.eco_rounded,
          Colors.green,
        ),
        
        _buildSectionCard(
          context,
          'Phosphorus (P)',
          '• Supports root development\n• Essential for flowering and fruiting\n• Use for: Root vegetables, flowering plants\n• Signs of deficiency: Purple leaves, poor flowering',
          Icons.local_florist_rounded,
          Colors.purple,
        ),
        
        _buildSectionCard(
          context,
          'Potassium (K)',
          '• Improves disease resistance\n• Enhances fruit quality\n• Use for: Fruit trees, tomatoes, peppers\n• Signs of deficiency: Brown leaf edges, weak stems',
          Icons.apple_rounded,
          Colors.orange,
        ),
        
        _buildSectionCard(
          context,
          'Common NPK Ratios',
          '• 10-10-10: Balanced, general purpose\n• 20-10-10: High nitrogen for leafy growth\n• 5-10-10: Low nitrogen, good for flowering\n• 0-10-10: No nitrogen, for established plants',
          Icons.analytics_rounded,
          Colors.red,
        ),
        
        _buildSectionCard(
          context,
          'When to Use Each',
          '• Spring: High nitrogen (20-10-10) for new growth\n• Summer: Balanced (10-10-10) for maintenance\n• Fall: High phosphorus (5-10-10) for root development\n• Winter: Low or no fertilizer',
          Icons.calendar_today_rounded,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildMixingGuide(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          context,
          'Safety First',
          '• Always wear gloves and eye protection\n• Work in a well-ventilated area\n• Keep fertilizers away from children and pets\n• Never mix different fertilizers unless specified',
          Icons.warning_rounded,
          Colors.red,
        ),
        
        _buildSectionCard(
          context,
          'Step 1: Read the Label',
          '• Check the NPK ratio and application rate\n• Note any special mixing instructions\n• Understand the recommended dilution\n• Check for compatibility with other products',
          Icons.article_rounded,
          Colors.blue,
        ),
        
        _buildSectionCard(
          context,
          'Step 2: Measure Accurately',
          '• Use a dedicated measuring cup or scale\n• Follow the "less is more" principle\n• Start with half the recommended dose\n• Keep a record of what you\'ve applied',
          Icons.straighten_rounded,
          Colors.green,
        ),
        
        _buildSectionCard(
          context,
          'Step 3: Mix Gradually',
          '• Add fertilizer to water, not water to fertilizer\n• Stir continuously while adding\n• Mix until completely dissolved\n• Let the solution sit for 10-15 minutes',
          Icons.science_rounded,
          Colors.purple,
        ),
        
        _buildSectionCard(
          context,
          'Step 4: Test pH',
          '• Check the pH of your solution (6.0-7.0 ideal)\n• Adjust if necessary with pH up/down\n• Test on a small area first\n• Apply during cool parts of the day',
          Icons.science_rounded,
          Colors.orange,
        ),
        
        _buildSectionCard(
          context,
          'Common Mistakes',
          '• Over-fertilizing (causes burn)\n• Mixing incompatible products\n• Applying to dry soil\n• Not watering after application',
          Icons.error_rounded,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildApplicationGuide(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          context,
          'Soil Application',
          '• Most common method\n• Apply around the drip line of plants\n• Water thoroughly after application\n• Best for: Established plants, trees, shrubs',
          Icons.landscape_rounded,
          Colors.brown,
        ),
        
        _buildSectionCard(
          context,
          'Foliar Spraying',
          '• Spray directly on leaves\n• Use early morning or late evening\n• Avoid hot, sunny conditions\n• Best for: Quick nutrient uptake, deficiency correction',
          Icons.water_drop_rounded,
          Colors.blue,
        ),
        
        _buildSectionCard(
          context,
          'Drip Irrigation',
          '• Mix fertilizer with irrigation water\n• Ensures even distribution\n• Reduces waste and runoff\n• Best for: Large gardens, consistent feeding',
          Icons.water_rounded,
          Colors.teal,
        ),
        
        _buildSectionCard(
          context,
          'Side Dressing',
          '• Apply fertilizer in a band alongside plants\n• Keep 2-3 inches away from stems\n• Cover with soil to prevent burning\n• Best for: Row crops, vegetables',
          Icons.agriculture_rounded,
          Colors.green,
        ),
        
        _buildSectionCard(
          context,
          'Broadcasting',
          '• Spread fertilizer evenly over large areas\n• Use a spreader for even distribution\n• Water in immediately after application\n• Best for: Lawns, large garden beds',
          Icons.grid_view_rounded,
          Colors.purple,
        ),
        
        _buildSectionCard(
          context,
          'Application Timing',
          '• Early morning: Best for foliar applications\n• Late afternoon: Good for soil applications\n• Avoid: Hot midday sun, before heavy rain\n• Frequency: Follow package instructions',
          Icons.schedule_rounded,
          Colors.orange,
        ),
        
        _buildSectionCard(
          context,
          'Watering After Application',
          '• Always water after soil applications\n• Helps nutrients reach plant roots\n• Prevents fertilizer burn\n• Use 1-2 inches of water',
          Icons.water_rounded,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
