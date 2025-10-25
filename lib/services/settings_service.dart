import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailto/mailto.dart';

class SettingsService {
  static const String _imageQualityKey = 'image_quality';
  static const String _cacheSizeKey = 'cache_size';
  
  // Image Quality Settings
  static Future<String> getImageQuality() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_imageQualityKey) ?? 'standard';
  }
  
  static Future<void> setImageQuality(String quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_imageQualityKey, quality);
  }
  
  // Cache Management
  static Future<double> getCacheSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/cache');
      
      if (!await cacheDir.exists()) {
        return 0.0;
      }
      
      double totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize / (1024 * 1024); // Convert to MB
    } catch (e) {
      print('Error calculating cache size: $e');
      return 0.0;
    }
  }
  
  static Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/cache');
      
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      
      // Also clear temporary files
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      
      print('✅ Cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing cache: $e');
      throw Exception('Failed to clear cache: $e');
    }
  }
  
  // Export Functions
  static Future<void> exportToPDF() async {
    // TODO: Implement PDF export
    // This would require additional dependencies like pdf package
    print('📄 PDF export functionality - to be implemented');
  }
  
  static Future<void> exportToCSV() async {
    // TODO: Implement CSV export
    // This would export disease detection history
    print('📊 CSV export functionality - to be implemented');
  }
  
  // External Links
  static Future<void> openGitHub() async {
    const url = 'https://github.com/cavxn/leaf-disease-application';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('❌ Could not launch GitHub URL');
    }
  }
  
  static Future<void> openFeedback() async {
    final mailto = Mailto(
      to: ['feedback@leafdiseaseapp.com'],
      subject: 'Leaf Disease App Feedback',
      body: 'Please share your feedback about the app:',
    );
    
    final uri = Uri.parse(mailto.toString());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('❌ Could not launch email client');
    }
  }
  
  // Format cache size for display
  static String formatCacheSize(double sizeInMB) {
    if (sizeInMB < 1) {
      return '${(sizeInMB * 1024).toStringAsFixed(0)} KB';
    } else {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
  }
}
