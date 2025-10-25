import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/garden_journal_entry.dart';
import '../models/garden_plant.dart';
import '../providers/garden_journal_provider.dart';
import '../providers/garden_provider.dart';
import '../providers/weather_provider.dart';
import '../services/pdf_export_service.dart';
import '../utils/app_theme.dart';

class GardenJournalScreen extends StatefulWidget {
  const GardenJournalScreen({Key? key}) : super(key: key);

  @override
  State<GardenJournalScreen> createState() => _GardenJournalScreenState();
}

class _GardenJournalScreenState extends State<GardenJournalScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  
  String _selectedEntryType = 'daily';
  String _selectedMood = 'good';
  String? _selectedPlantId;
  List<String> _photoPaths = [];
  List<String> _tags = [];
  
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addEntry() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final entry = GardenJournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        title: _titleController.text,
        content: _contentController.text,
        photoPaths: _photoPaths,
        entryType: _selectedEntryType,
        tags: _tags,
        plantId: _selectedPlantId,
        mood: _selectedMood,
        weatherData: context.read<WeatherProvider>().currentWeather != null 
            ? context.read<WeatherProvider>().currentWeather!.toJson().toString()
            : null,
        temperature: context.read<WeatherProvider>().currentWeather?.temperature?.toString(),
        humidity: context.read<WeatherProvider>().currentWeather?.humidity?.toString(),
        weatherCondition: context.read<WeatherProvider>().currentWeather?.condition,
      );

      await context.read<GardenJournalProvider>().addEntry(entry);
      
      // Clear form
      _titleController.clear();
      _contentController.clear();
      _tagsController.clear();
      _photoPaths.clear();
      _tags.clear();
      _selectedPlantId = null;
      _selectedMood = 'good';
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Journal entry added successfully!'),
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
            content: Text('Error adding entry: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      setState(() {
        _photoPaths.addAll(images.map((image) => image.path));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoPaths.removeAt(index);
    });
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garden Journal'),
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
            Tab(text: 'New Entry', icon: Icon(Icons.edit)),
            Tab(text: 'Entries', icon: Icon(Icons.list)),
            Tab(text: 'Stats', icon: Icon(Icons.analytics)),
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
            _buildNewEntryTab(),
            _buildEntriesTab(),
            _buildStatsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewEntryTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                    Icons.book_rounded,
                    size: 48,
                    color: AppTheme.neonGradient.colors.first,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Garden Journal Entry',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Record your garden observations and memories',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
            
            const SizedBox(height: 24),
            
            // Entry Type Selection
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
                    'Entry Type',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEntryTypeButton('daily', 'Daily', Icons.today, theme, isDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEntryTypeButton('weekly', 'Weekly', Icons.date_range, theme, isDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEntryTypeButton('special', 'Special', Icons.star, theme, isDark),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
            
            const SizedBox(height: 24),
            
            // Title Input
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
                    'Entry Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Give your entry a title',
                      prefixIcon: Icon(Icons.title, color: AppTheme.neonGradient.colors.first),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Content',
                      hintText: 'Write about your garden observations...',
                      prefixIcon: Icon(Icons.description, color: AppTheme.neonGradient.colors.first),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some content';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
            
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
                        'Link to Plant (Optional)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (gardenProvider.plants.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
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
                                  'No plants in your garden yet. Add a plant first to link entries.',
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
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('No plant linked'),
                            ),
                            ...gardenProvider.plants.map((plant) {
                              return DropdownMenuItem<String>(
                                value: plant.id,
                                child: Text(plant.name),
                              );
                            }).toList(),
                          ],
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
            ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
            
            const SizedBox(height: 24),
            
            // Mood Selection
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
                    'How are you feeling about your garden?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildMoodButton('great', 'Great', '😊', theme, isDark),
                      _buildMoodButton('good', 'Good', '😌', theme, isDark),
                      _buildMoodButton('okay', 'Okay', '😐', theme, isDark),
                      _buildMoodButton('concerned', 'Concerned', '😟', theme, isDark),
                      _buildMoodButton('worried', 'Worried', '😰', theme, isDark),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 800.ms),
            
            const SizedBox(height: 24),
            
            // Photos Section
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
                    'Photos',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_photoPaths.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_camera,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No photos added yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _photoPaths.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_photoPaths[index]),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removePhoto(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Add Photos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonGradient.colors.first,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),
            
            const SizedBox(height: 24),
            
            // Tags Section
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
                    'Tags',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          onDeleted: () => _removeTag(tag),
                          backgroundColor: AppTheme.neonGradient.colors.first.withOpacity(0.2),
                          deleteIconColor: AppTheme.neonGradient.colors.first,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tagsController,
                          decoration: InputDecoration(
                            labelText: 'Add tag',
                            hintText: 'Enter a tag',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _addTag,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonGradient.colors.first,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 1200.ms),
            
            const SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addEntry,
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
                    const Icon(Icons.save),
                    const SizedBox(width: 8),
                    Text(
                      'Save Journal Entry',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 1400.ms),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryTypeButton(String type, String label, IconData icon, ThemeData theme, bool isDark) {
    final isSelected = _selectedEntryType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEntryType = type;
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
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.neonGradient.colors.first : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? AppTheme.neonGradient.colors.first : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodButton(String mood, String label, String emoji, ThemeData theme, bool isDark) {
    final isSelected = _selectedMood == mood;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = mood;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.neonGradient.colors.first.withOpacity(0.2)
              : isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppTheme.neonGradient.colors.first
                : isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 20),
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

  Widget _buildEntriesTab() {
    return Consumer<GardenJournalProvider>(
      builder: (context, journalProvider, child) {
        if (journalProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (journalProvider.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No journal entries yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start documenting your garden journey!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: journalProvider.entries.length,
          itemBuilder: (context, index) {
            final entry = journalProvider.entries[index];
            return _buildEntryCard(entry);
          },
        );
      },
    );
  }

  Widget _buildEntryCard(GardenJournalEntry entry) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    entry.moodEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGradient.colors.first.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.entryType.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.neonGradient.colors.first,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (entry.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: entry.tags.map((tag) {
                return Chip(
                  label: Text(
                    tag,
                    style: theme.textTheme.bodySmall,
                  ),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
          if (entry.hasPhotos) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.photo,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.photoPaths.length} photo${entry.photoPaths.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Consumer<GardenJournalProvider>(
      builder: (context, journalProvider, child) {
        final stats = journalProvider.getJournalStats();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Entries',
                      '${stats['totalEntries']}',
                      Icons.book,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'This Week',
                      '${stats['entriesThisWeek']}',
                      Icons.calendar_today,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Photos',
                      '${stats['totalPhotos']}',
                      Icons.photo,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'With Weather',
                      '${stats['entriesWithWeather']}',
                      Icons.wb_sunny,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Export Section
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
                      'Export Journal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Export your garden journal as a PDF to share or keep as a record.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _exportAllEntries(journalProvider),
                            icon: const Icon(Icons.download),
                            label: const Text('Export All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonGradient.colors.first,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _exportRecentEntries(journalProvider),
                            icon: const Icon(Icons.schedule),
                            label: const Text('Export Recent'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportAllEntries(GardenJournalProvider journalProvider) async {
    try {
      await PDFExportService.exportJournalToPDF(
        entries: journalProvider.entries,
        title: 'My Garden Journal',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Journal exported successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting journal: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _exportRecentEntries(GardenJournalProvider journalProvider) async {
    try {
      final recentEntries = journalProvider.getRecentEntries();
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      
      await PDFExportService.exportJournalToPDF(
        entries: recentEntries,
        title: 'Recent Garden Journal',
        startDate: weekAgo,
        endDate: DateTime.now(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Recent journal exported successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting recent journal: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
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
}
