import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/garden_plant.dart';
import '../providers/garden_provider.dart';
import '../providers/disease_history_provider.dart';
import '../models/plant_photo.dart';
import '../models/disease_detection.dart';
import '../utils/app_theme.dart';

class PlantGalleryScreen extends StatefulWidget {
  final GardenPlant plant;

  const PlantGalleryScreen({super.key, required this.plant});

  @override
  State<PlantGalleryScreen> createState() => _PlantGalleryScreenState();
}

class _PlantGalleryScreenState extends State<PlantGalleryScreen> with SingleTickerProviderStateMixin {
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
          title: Text(
            '${widget.plant.name} Gallery',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.neonGradient.colors.first,
            labelColor: isDark ? Colors.white : Colors.black87,
            unselectedLabelColor: isDark ? Colors.white.withOpacity(0.5) : Colors.black54,
            tabs: const [
              Tab(icon: Icon(Icons.grid_view_rounded), text: 'Timeline'),
              Tab(icon: Icon(Icons.compare_arrows_rounded), text: 'Compare'),
              Tab(icon: Icon(Icons.photo_library_rounded), text: 'All'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _TimelineTab(plant: widget.plant),
            _CompareTab(plant: widget.plant),
            _AllPhotosTab(plant: widget.plant),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddPhotoDialog(context),
          backgroundColor: AppTheme.neonGradient.colors.first,
          icon: const Icon(Icons.add_photo_alternate_rounded),
          label: const Text('Add Photo'),
        ),
      ),
    );
  }

  void _showAddPhotoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddPhotoDialog(plant: widget.plant),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  final GardenPlant plant;

  const _TimelineTab({required this.plant});

  @override
  Widget build(BuildContext context) {
    final gardenProvider = context.watch<GardenProvider>();
    final photos = gardenProvider.getPhotosForPlant(plant.id);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (photos.isEmpty) {
      return Center(
        child: _EmptyState(
          icon: Icons.photo_library_outlined,
          title: 'No Photos Yet',
          subtitle: 'Start documenting your plant\'s journey',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return _PhotoTimelineCard(
          photo: photo,
          isFirst: index == 0,
          isLast: index == photos.length - 1,
        ).animate()
          .fadeIn(duration: 300.ms, delay: (index * 100).ms)
          .slideX(begin: -0.3, end: 0);
      },
    );
  }
}

class _CompareTab extends StatelessWidget {
  final GardenPlant plant;

  const _CompareTab({required this.plant});

  @override
  Widget build(BuildContext context) {
    final gardenProvider = context.watch<GardenProvider>();
    final beforeAfterPhotos = gardenProvider.getBeforeAfterPhotos(plant.id);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (beforeAfterPhotos.isEmpty) {
      return Center(
        child: _EmptyState(
          icon: Icons.compare_arrows_rounded,
          title: 'No Comparison Photos',
          subtitle: 'Add photos with disease detection to compare before/after',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: (beforeAfterPhotos.length / 2).ceil(),
      itemBuilder: (context, index) {
        final beforeIndex = index * 2;
        final afterIndex = beforeIndex + 1;

        final beforePhoto = beforeAfterPhotos[beforeIndex];
        final afterPhoto = afterIndex < beforeAfterPhotos.length 
            ? beforeAfterPhotos[afterIndex] 
            : null;

        return _ComparePhotoCard(
          beforePhoto: beforePhoto,
          afterPhoto: afterPhoto,
        ).animate()
          .fadeIn(duration: 300.ms, delay: (index * 100).ms)
          .slideY(begin: 0.3, end: 0);
      },
    );
  }
}

class _AllPhotosTab extends StatelessWidget {
  final GardenPlant plant;

  const _AllPhotosTab({required this.plant});

  @override
  Widget build(BuildContext context) {
    final gardenProvider = context.watch<GardenProvider>();
    final photos = gardenProvider.getPhotosForPlant(plant.id);

    if (photos.isEmpty) {
      return const Center(
        child: _EmptyState(
          icon: Icons.photo_outlined,
          title: 'No Photos',
          subtitle: 'Add photos to build your gallery',
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return _PhotoGridCard(photo: photos[index])
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}

class _PhotoTimelineCard extends StatelessWidget {
  final PlantPhoto photo;
  final bool isFirst;
  final bool isLast;

  const _PhotoTimelineCard({
    required this.photo,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.neonGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonGradient.colors.first.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 20),
              ),
              Container(
                width: 2,
                height: isLast ? 0 : 24,
                color: AppTheme.neonGradient.colors.first.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Photo & Info
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                borderRadius: BorderRadius.circular(20),
                border: isDark 
                    ? AppTheme.glassmorphismDark.border 
                    : AppTheme.glassmorphismLight.border,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.file(
                      photo.image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(photo.timestamp),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        if (photo.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            photo.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                        if (photo.diseaseDetected != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.medical_services_rounded, size: 16, color: Colors.orange),
                                const SizedBox(width: 6),
                                Text(
                                  photo.diseaseDetected!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

class _ComparePhotoCard extends StatelessWidget {
  final PlantPhoto beforePhoto;
  final PlantPhoto? afterPhoto;

  const _ComparePhotoCard({
    required this.beforePhoto,
    this.afterPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(24),
        border: isDark 
            ? AppTheme.glassmorphismDark.border 
            : AppTheme.glassmorphismLight.border,
      ),
      child: Column(
        children: [
          // Before Photo
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'BEFORE',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(beforePhoto.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    beforePhoto.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (beforePhoto.diseaseDetected != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    beforePhoto.diseaseDetected!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (afterPhoto != null) ...[
            Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.neonGradient.colors.first.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // After Photo
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'AFTER',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(afterPhoto!.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      afterPhoto!.image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _PhotoGridCard extends StatelessWidget {
  final PlantPhoto photo;

  const _PhotoGridCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showPhotoDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
          borderRadius: BorderRadius.circular(20),
          border: isDark 
              ? AppTheme.glassmorphismDark.border 
              : AppTheme.glassmorphismLight.border,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                photo.image,
                fit: BoxFit.cover,
              ),
            ),
            if (photo.diseaseDetected != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Text(
                  _formatDate(photo.timestamp),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: Image.file(photo.image),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.neonGradient,
          ),
          child: Icon(icon, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _AddPhotoDialog extends StatefulWidget {
  final GardenPlant plant;

  const _AddPhotoDialog({required this.plant});

  @override
  State<_AddPhotoDialog> createState() => _AddPhotoDialogState();
}

class _AddPhotoDialogState extends State<_AddPhotoDialog> {
  File? _selectedImage;
  final _descriptionController = TextEditingController();
  String? _detectedDisease;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      print('📸 Selected image at path: ${file.path}');
      print('📸 File exists: ${await file.exists()}');
      
      setState(() => _selectedImage = file);
    }
  }

  Future<void> _savePhoto() async {
    if (_selectedImage == null) return;

    try {
      // Check if file exists
      if (!await _selectedImage!.exists()) {
        print('❌ Photo file does not exist at path: ${_selectedImage!.path}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo file not found. Please try again.')),
          );
        }
        return;
      }

      print('✅ Photo file exists at path: ${_selectedImage!.path}');

      final gardenProvider = context.read<GardenProvider>();
      final photo = PlantPhoto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        plantId: widget.plant.id,
        image: _selectedImage!,
        timestamp: DateTime.now(),
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text,
        diseaseDetected: _detectedDisease,
      );

      await gardenProvider.addPhoto(photo);
      
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo added successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error saving photo: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding photo: $e')),
        );
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
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Photo',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _selectedImage != null ? _savePhoto : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGradient.colors.first,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Photo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
