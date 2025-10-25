import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_provider.dart';
import '../providers/disease_history_provider.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../models/disease_detection.dart';
import '../widgets/feature_card.dart';
import 'result_screen.dart';
import 'water_reminder_screen.dart';
import 'plant_care_screen.dart';
import 'plant_calendar_screen.dart';
import 'community_screen.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch weather data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchCurrentWeather();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    // Bypass permission checks - assume all permissions are granted
    print('📱 Picking image from ${source == ImageSource.camera ? 'camera' : 'gallery'} (permissions bypassed)');

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _detectDisease() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      print('🔍 Starting disease detection...');
      
      // Validate image file
      if (!await _selectedImage!.exists()) {
        throw Exception('Selected image file does not exist');
      }
      
      // Get prediction and confidence from backend
      final predictionResult = await ApiService.predictDisease(_selectedImage!);
      print('📊 Raw prediction result: $predictionResult');
      
      // predictionResult should be a Map<String, dynamic> with 'prediction' and 'confidence'
      final prediction = predictionResult['prediction'] ?? 'Unknown';
      var confidenceRaw = predictionResult['confidence'];
      
      print('🏷️ Prediction: $prediction');
      print('📈 Raw confidence: $confidenceRaw (type: ${confidenceRaw.runtimeType})');
      
      double? confidence;
      if (confidenceRaw is double) {
        confidence = confidenceRaw;
      } else if (confidenceRaw is int) {
        confidence = confidenceRaw.toDouble();
      } else if (confidenceRaw is String) {
        confidence = double.tryParse(confidenceRaw);
      }
      
      print('🎯 Processed confidence: $confidence');
      
      if (confidence == null) {
        confidence = 0.85; // Default confidence for fallback
        print('⚠️ Using default confidence: $confidence');
      }
      
      // Normalize confidence to 0-1 range if it's in percentage (0-100)
      if (confidence > 1.0) {
        confidence = confidence / 100.0;
        print('🔄 Normalized confidence from percentage: $confidence');
      }

      // Get symptoms, treatments, isHealthy from about page (getDiseaseInfo)
      final diseaseInfo = await ApiService.getDiseaseInfo(prediction);
      final symptoms = List<String>.from(diseaseInfo['symptoms'] ?? []);
      final treatments = List<String>.from(diseaseInfo['treatments'] ?? []);
      final isHealthy = prediction.toLowerCase().contains('healthy');
      
      print('🌿 Disease info loaded - Healthy: $isHealthy');

      // Create detection object
      final detection = DiseaseDetection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        image: _selectedImage!,
        diseaseName: prediction,
        confidence: confidence,
        timestamp: DateTime.now(),
        symptoms: symptoms,
        treatments: treatments,
        isHealthy: isHealthy,
      );
      
      print('✅ Detection object created: ${detection.diseaseName} (${detection.confidence})');

      // Add to history
      context.read<DiseaseHistoryProvider>().addDetection(detection);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(detection: detection),
        ),
      );
    } on ApiException catch (e) {
      print('💥 API Error: ${e.code} - ${e.message}');
      
      String userMessage;
      switch (e.code) {
        case 'FILE_NOT_FOUND':
          userMessage = 'Image file not found. Please try selecting another image.';
          break;
        case 'FILE_TOO_LARGE':
          userMessage = 'Image file is too large. Please select a smaller image (max 10MB).';
          break;
        case 'NETWORK_ERROR':
          userMessage = 'Network connection failed. Please check your internet connection.';
          break;
        case 'TIMEOUT_ERROR':
          userMessage = 'Request timed out. Please try again.';
          break;
        case 'SERVER_ERROR':
          userMessage = 'Server error occurred. Please try again later.';
          break;
        case 'PARSE_ERROR':
          userMessage = 'Invalid response from server. Please try again.';
          break;
        default:
          userMessage = 'Error detecting disease: ${e.message}';
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _detectDisease(),
          ),
        ),
      );
    } catch (e) {
      print('💥 Unexpected error in disease detection: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _detectDisease(),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearImage() {
    setState(() => _selectedImage = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // AppBar with Menu Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.menu_rounded,
                      color: isDark ? Colors.white : Colors.black87,
                      size: 28,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    tooltip: 'Menu',
                  ),
                  Text(
                    'Leaf Detector',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the menu button
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                  borderRadius: BorderRadius.circular(24),
                  border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
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
                        Icons.eco_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Leaf Disease Detector',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI-Powered Plant Health Analysis',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),

              const SizedBox(height: 24),

              // Image Selection Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                  borderRadius: BorderRadius.circular(24),
                  border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Upload Plant Image',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    if (_selectedImage != null) ...[
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.neonGradient.colors.first.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : () => _detectDisease(),
                              icon: _isLoading 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.search_rounded),
                              label: Text(_isLoading ? 'Analyzing...' : 'Detect Disease'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.neonGradient.colors.first,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: _clearImage,
                            icon: const Icon(Icons.clear_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.1),
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 48,
                              color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Select an image to analyze',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_rounded),
                              label: const Text('Camera'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.neonGradient.colors.first,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_rounded),
                              label: const Text('Gallery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.neonGradient.colors[1],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.3),

              const SizedBox(height: 24),

              // Features Section
              Text(
                'Features',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.psychology_rounded,
                      title: 'AI Analysis',
                      subtitle: 'Advanced machine learning for accurate disease detection',
                      color: AppTheme.neonGradient.colors[0],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.speed_rounded,
                      title: 'Fast Results',
                      subtitle: 'Get instant analysis in seconds',
                      color: AppTheme.neonGradient.colors[1],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3),

              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.healing_rounded,
                      title: 'Treatment Tips',
                      subtitle: 'Get personalized treatment recommendations',
                      color: AppTheme.neonGradient.colors[2],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.history_rounded,
                      title: 'History',
                      subtitle: 'Track your plant health over time',
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3),

              const SizedBox(height: 24),

              // Quick Actions Section
              Text(
                'Quick Actions',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.water_drop_rounded,
                      title: 'Water Reminder',
                      subtitle: 'Set watering schedules',
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WaterReminderScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.eco_rounded,
                      title: 'Plant Care',
                      subtitle: 'Get care instructions',
                      color: const Color(0xFF10B981),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlantCareScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3),

              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.calendar_today_rounded,
                      title: 'Plant Calendar',
                      subtitle: 'Track growth milestones',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlantCalendarScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.people_rounded,
                      title: 'Community',
                      subtitle: 'Share with plant lovers',
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CommunityScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideY(begin: 0.3),

              const SizedBox(height: 24),

              // Weather & Environment Section
              Consumer<WeatherProvider>(
                builder: (context, weatherProvider, child) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                      borderRadius: BorderRadius.circular(24),
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
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [const Color(0xFF3B82F6), const Color(0xFF3B82F6).withOpacity(0.7)],
                                ),
                              ),
                              child: const Icon(
                                Icons.wb_sunny_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Weather & Environment',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            if (weatherProvider.isLoading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              IconButton(
                                onPressed: () => weatherProvider.fetchCurrentWeather(),
                                icon: const Icon(Icons.refresh_rounded),
                                iconSize: 20,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (weatherProvider.error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    weatherProvider.error!,
                                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => weatherProvider.fetchCurrentWeather(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ] else if (weatherProvider.hasWeather) ...[
                          // Location and condition
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  weatherProvider.getLocationDisplay(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                                  ),
                                ),
                              ),
                              Text(
                                weatherProvider.getConditionDisplay(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Weather metrics
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.thermostat_rounded,
                                        color: Color(0xFF3B82F6),
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Temperature',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        weatherProvider.getTemperatureDisplay(),
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF3B82F6),
                                        ),
                                      ),
                                      Text(
                                        weatherProvider.getTemperatureStatus(),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
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
                                    children: [
                                      const Icon(
                                        Icons.water_drop_rounded,
                                        color: Color(0xFF10B981),
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Humidity',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        weatherProvider.getHumidityDisplay(),
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF10B981),
                                        ),
                                      ),
                                      Text(
                                        weatherProvider.getHumidityStatus(),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Additional weather info
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.air_rounded,
                                        color: Color(0xFF8B5CF6),
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Wind',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        weatherProvider.getWindSpeedDisplay(),
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF8B5CF6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.compress_rounded,
                                        color: Color(0xFFF59E0B),
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Pressure',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        '${weatherProvider.currentWeather?.pressure ?? 0} hPa',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFF59E0B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Plant care recommendations
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: weatherProvider.isGoodForPlantCare 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: weatherProvider.isGoodForPlantCare 
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.orange.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      weatherProvider.isGoodForPlantCare 
                                        ? Icons.check_circle_rounded 
                                        : Icons.info_rounded,
                                      color: weatherProvider.isGoodForPlantCare 
                                        ? Colors.green 
                                        : Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Plant Care Status',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: weatherProvider.isGoodForPlantCare 
                                          ? Colors.green 
                                          : Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${weatherProvider.weatherQualityScore}%',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  weatherProvider.getPlantCareAdvice(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Loading or no data state
                          Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading weather data...',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ).animate().fadeIn(duration: 600.ms, delay: 1400.ms).slideY(begin: 0.3),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      ],
      ),
      ),
    );
  }
} 