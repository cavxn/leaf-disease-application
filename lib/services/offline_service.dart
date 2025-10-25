import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class OfflineService {
  static const String _cacheKey = 'cached_predictions';
  static const int _maxCacheSize = 100; // Maximum number of cached predictions
  
  // Cache a prediction result
  static Future<void> cachePrediction({
    required String imagePath,
    required Map<String, dynamic> prediction,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString(_cacheKey) ?? '{}';
      final cache = json.decode(cacheData) as Map<String, dynamic>;
      
      // Generate hash for image path
      final imageHash = _generateImageHash(imagePath);
      
      // Add to cache
      cache[imageHash] = {
        'imagePath': imagePath,
        'prediction': prediction,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Limit cache size
      if (cache.length > _maxCacheSize) {
        _cleanOldCacheEntries(cache);
      }
      
      // Save back to preferences
      await prefs.setString(_cacheKey, json.encode(cache));
      print('✅ Cached prediction for image: $imagePath');
    } catch (e) {
      print('❌ Error caching prediction: $e');
    }
  }
  
  // Get cached prediction if available
  static Future<Map<String, dynamic>?> getCachedPrediction(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString(_cacheKey) ?? '{}';
      final cache = json.decode(cacheData) as Map<String, dynamic>;
      
      final imageHash = _generateImageHash(imagePath);
      final cached = cache[imageHash];
      
      if (cached != null) {
        // Check if image file still exists
        final file = File(cached['imagePath']);
        if (await file.exists()) {
          print('✅ Found cached prediction for: $imagePath');
          return Map<String, dynamic>.from(cached['prediction']);
        } else {
          // Remove stale cache entry
          cache.remove(imageHash);
          await prefs.setString(_cacheKey, json.encode(cache));
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting cached prediction: $e');
      return null;
    }
  }
  
  // Check if we have internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Get all cached predictions for history
  static Future<List<Map<String, dynamic>>> getAllCachedPredictions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString(_cacheKey) ?? '{}';
      final cache = json.decode(cacheData) as Map<String, dynamic>;
      
      final predictions = <Map<String, dynamic>>[];
      
      for (final entry in cache.values) {
        final prediction = Map<String, dynamic>.from(entry);
        final file = File(prediction['imagePath']);
        
        if (await file.exists()) {
          predictions.add(prediction);
        }
      }
      
      // Sort by timestamp (newest first)
      predictions.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
      
      return predictions;
    } catch (e) {
      print('❌ Error getting cached predictions: $e');
      return [];
    }
  }
  
  // Clear all cached predictions
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      print('✅ Cleared all cached predictions');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }
  
  // Get cache size in MB
  static Future<double> getCacheSize() async {
    try {
      final predictions = await getAllCachedPredictions();
      double totalSize = 0;
      
      for (final prediction in predictions) {
        final file = File(prediction['imagePath']);
        if (await file.exists()) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize / (1024 * 1024); // Convert to MB
    } catch (e) {
      print('❌ Error calculating cache size: $e');
      return 0.0;
    }
  }
  
  // Generate hash for image path
  static String _generateImageHash(String imagePath) {
    final bytes = utf8.encode(imagePath);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
  
  // Clean old cache entries
  static void _cleanOldCacheEntries(Map<String, dynamic> cache) {
    final entries = cache.entries.toList();
    entries.sort((a, b) {
      final timestampA = a.value['timestamp'] as int;
      final timestampB = b.value['timestamp'] as int;
      return timestampA.compareTo(timestampB);
    });
    
    // Remove oldest entries
    final toRemove = entries.length - _maxCacheSize;
    for (int i = 0; i < toRemove; i++) {
      cache.remove(entries[i].key);
    }
  }
}
