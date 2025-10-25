import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/garden_plant.dart';
import '../providers/garden_provider.dart';
import 'plant_gallery_screen.dart';
import '../utils/app_theme.dart';

class PlantDetailScreen extends StatefulWidget {
  final GardenPlant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late GardenPlant _plant;

  @override
  void initState() {
    super.initState();
    _plant = widget.plant;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final statusColors = {
      'healthy': Colors.green,
      'treating': Colors.orange,
      'recovering': Colors.blue,
      'watch': Colors.yellow.shade700,
    };

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.photo_library_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlantGalleryScreen(plant: _plant),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => _showEditDialog(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Plant Image
              Container(
                height: 300,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _plant.image != null
                      ? Image.file(_plant.image!, fit: BoxFit.cover)
                      : Container(
                          color: AppTheme.neonGradient.colors.first.withOpacity(0.2),
                          child: Center(
                            child: Icon(
                              Icons.eco_rounded,
                              size: 100,
                              color: AppTheme.neonGradient.colors.first,
                            ),
                          ),
                        ),
                ),
              ).animate().fadeIn(duration: 400.ms),

              // Plant Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _plant.name,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (_plant.scientificName != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _plant.scientificName!,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: statusColors[_plant.status]?.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColors[_plant.status]!,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            _plant.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColors[_plant.status],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Date Added
                    _InfoCard(
                      icon: Icons.calendar_today_rounded,
                      title: 'Date Added',
                      value: _formatDate(_plant.dateAdded),
                      color: const Color(0xFF3B82F6),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                    // Notes
                    if (_plant.notes != null) ...[
                      const SizedBox(height: 16),
                      _InfoCard(
                        icon: Icons.notes_rounded,
                        title: 'Notes',
                        value: _plant.notes!,
                        color: const Color(0xFF8B5CF6),
                        isMultiLine: true,
                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                    ],

                    const SizedBox(height: 24),

                    // Health History
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF10B981),
                                const Color(0xFF10B981).withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: const Icon(Icons.history_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Health History',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_plant.healthHistory.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          'No health history yet.\nTap the button below to add an entry.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                          ),
                        ),
                      )
                    else
                      ..._plant.healthHistory.asMap().entries.map((entry) {
                        final index = entry.key;
                        final history = entry.value;
                        return _HistoryCard(
                          text: history,
                          timestamp: DateTime.now().subtract(Duration(days: index)),
                        ).animate().fadeIn(duration: 300.ms, delay: (index * 100).ms);
                      }).toList(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddHistoryDialog(context),
          backgroundColor: AppTheme.neonGradient.colors.first,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Entry'),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditDialog(BuildContext context) {
    final gardenProvider = context.read<GardenProvider>();
    final nameController = TextEditingController(text: _plant.name);
    final scientificNameController = TextEditingController(text: _plant.scientificName ?? '');
    final notesController = TextEditingController(text: _plant.notes ?? '');
    String selectedStatus = _plant.status;

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Edit Plant',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Plant Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: scientificNameController,
                      decoration: InputDecoration(
                        labelText: 'Scientific Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'healthy', child: Text('Healthy')),
                        DropdownMenuItem(value: 'treating', child: Text('Treating')),
                        DropdownMenuItem(value: 'recovering', child: Text('Recovering')),
                        DropdownMenuItem(value: 'watch', child: Text('Watch')),
                      ],
                      onChanged: (value) => setDialogState(() => selectedStatus = value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final updatedPlant = _plant.copyWith(
                          name: nameController.text,
                          scientificName: scientificNameController.text.isEmpty 
                              ? null 
                              : scientificNameController.text,
                          notes: notesController.text.isEmpty ? null : notesController.text,
                          status: selectedStatus,
                        );
                        gardenProvider.updatePlant(updatedPlant).then((_) {
                          if (mounted) {
                            setState(() => _plant = updatedPlant);
                            Navigator.pop(context);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonGradient.colors.first,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddHistoryDialog(BuildContext context) {
    final gardenProvider = context.read<GardenProvider>();
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Health History Entry',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter notes about this plant...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (controller.text.isNotEmpty) {
                      await gardenProvider.addHealthHistory(_plant.id, controller.text);
                      if (mounted) {
                        setState(() {
                          _plant = GardenPlant(
                            id: _plant.id,
                            name: _plant.name,
                            scientificName: _plant.scientificName,
                            notes: _plant.notes,
                            dateAdded: _plant.dateAdded,
                            image: _plant.image,
                            status: _plant.status,
                            healthHistory: [..._plant.healthHistory, controller.text],
                          );
                        });
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonGradient.colors.first,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add Entry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isMultiLine;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String text;
  final DateTime timestamp;

  const _HistoryCard({required this.text, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: isDark ? Colors.white.withOpacity(0.5) : Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                _formatTimestamp(timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white.withOpacity(0.5) : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
