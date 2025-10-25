import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/garden_provider.dart';
import '../models/garden_plant.dart';
import 'plant_detail_screen.dart';
import '../utils/app_theme.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gardenProvider = context.watch<GardenProvider>();

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.neonGradient,
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
                          'My Garden',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '${gardenProvider.plants.length} plants',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAddPlantDialog(context),
                    icon: const Icon(Icons.add_circle_rounded),
                    iconSize: 36,
                    color: AppTheme.neonGradient.colors.first,
                  ),
                ],
              ),
            ),

            // Plants Grid
            Expanded(
              child: gardenProvider.plants.isEmpty
                  ? _buildEmptyState(context, theme, isDark)
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: gardenProvider.plants.length,
                        itemBuilder: (context, index) {
                          final plant = gardenProvider.plants[index];
                          return _buildPlantCard(context, plant, theme, isDark)
                              .animate()
                              .fadeIn(duration: 300.ms, delay: (index * 100).ms)
                              .slideY(begin: 0.3);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.neonGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonGradient.colors.first.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.eco_outlined,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Plants Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start building your garden\nby adding your first plant!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddPlantDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Plant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonGradient.colors.first,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(
    BuildContext context,
    GardenPlant plant,
    ThemeData theme,
    bool isDark,
  ) {
    final statusColors = {
      'healthy': Colors.green,
      'treating': Colors.orange,
      'recovering': Colors.blue,
      'watch': Colors.yellow.shade700,
    };

    final statusIcons = {
      'healthy': Icons.check_circle_rounded,
      'treating': Icons.medical_services_rounded,
      'recovering': Icons.health_and_safety_rounded,
      'watch': Icons.visibility_rounded,
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailScreen(plant: plant),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Plant Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  color: AppTheme.neonGradient.colors.first.withOpacity(0.1),
                ),
                child: plant.image != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.file(
                          plant.image!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.eco_rounded,
                          size: 60,
                          color: AppTheme.neonGradient.colors.first,
                        ),
                      ),
              ),
            ),
            // Plant Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plant.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: statusColors[plant.status]?.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            statusIcons[plant.status],
                            size: 16,
                            color: statusColors[plant.status],
                          ),
                        ),
                      ],
                    ),
                    if (plant.scientificName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        plant.scientificName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${DateTime.now().difference(plant.dateAdded).inDays}d ago',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPlantDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddPlantDialog(),
    );
  }
}

class _AddPlantDialog extends StatefulWidget {
  const _AddPlantDialog();

  @override
  State<_AddPlantDialog> createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends State<_AddPlantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scientificNameController = TextEditingController();
  final _notesController = TextEditingController();
  File? _selectedImage;
  String _selectedStatus = 'healthy';

  @override
  void dispose() {
    _nameController.dispose();
    _scientificNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _savePlant() async {
    if (_formKey.currentState!.validate()) {
      final gardenProvider = context.read<GardenProvider>();
      
      final plant = GardenPlant(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        scientificName: _scientificNameController.text.isEmpty 
            ? null 
            : _scientificNameController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        dateAdded: DateTime.now(),
        image: _selectedImage,
        status: _selectedStatus,
      );

      await gardenProvider.addPlant(plant);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
          borderRadius: BorderRadius.circular(24),
          border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add New Plant',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Image Picker
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt_rounded),
                            title: const Text('Camera'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library_rounded),
                            title: const Text('Gallery'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.neonGradient.colors.first.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(_selectedImage!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_photo_alternate_rounded, size: 48),
                              const SizedBox(height: 8),
                              Text('Add Photo', style: theme.textTheme.bodyMedium),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Plant Name *',
                    prefixIcon: const Icon(Icons.eco_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                // Scientific Name Field
                TextFormField(
                  controller: _scientificNameController,
                  decoration: InputDecoration(
                    labelText: 'Scientific Name',
                    prefixIcon: const Icon(Icons.science_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Status Field
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    prefixIcon: const Icon(Icons.health_and_safety_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'healthy', child: Text('Healthy')),
                    DropdownMenuItem(value: 'treating', child: Text('Treating')),
                    DropdownMenuItem(value: 'recovering', child: Text('Recovering')),
                    DropdownMenuItem(value: 'watch', child: Text('Watch')),
                  ],
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
                const SizedBox(height: 16),

                // Notes Field
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    prefixIcon: const Icon(Icons.notes_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                ElevatedButton(
                  onPressed: _savePlant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonGradient.colors.first,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add Plant'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
