import 'package:flutter/material.dart';
import '../models/growth_measurement.dart';
import '../services/database_service.dart';

class GrowthProvider extends ChangeNotifier {
  List<GrowthMeasurement> _measurements = [];
  final DatabaseService _db = DatabaseService.instance;
  bool _isLoading = false;

  List<GrowthMeasurement> get measurements => _measurements;
  bool get isLoading => _isLoading;

  GrowthProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _measurements = await _db.getAllGrowthMeasurements();
    } catch (e) {
      print('Error loading growth data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMeasurement(GrowthMeasurement measurement) async {
    try {
      await _db.insertGrowthMeasurement(measurement);
      _measurements = await _db.getAllGrowthMeasurements();
      notifyListeners();
    } catch (e) {
      print('Error adding growth measurement: $e');
      rethrow;
    }
  }

  Future<void> updateMeasurement(GrowthMeasurement measurement) async {
    try {
      await _db.updateGrowthMeasurement(measurement);
      _measurements = await _db.getAllGrowthMeasurements();
      notifyListeners();
    } catch (e) {
      print('Error updating growth measurement: $e');
      rethrow;
    }
  }

  Future<void> deleteMeasurement(String measurementId) async {
    try {
      await _db.deleteGrowthMeasurement(measurementId);
      _measurements = await _db.getAllGrowthMeasurements();
      notifyListeners();
    } catch (e) {
      print('Error deleting growth measurement: $e');
      rethrow;
    }
  }

  List<GrowthMeasurement> getMeasurementsForPlant(String plantId) {
    return _measurements
        .where((measurement) => measurement.plantId == plantId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  GrowthMeasurement? getLatestMeasurement(String plantId) {
    final plantMeasurements = getMeasurementsForPlant(plantId);
    return plantMeasurements.isNotEmpty ? plantMeasurements.last : null;
  }

  GrowthMeasurement? getPreviousMeasurement(String plantId, DateTime currentTimestamp) {
    final plantMeasurements = getMeasurementsForPlant(plantId);
    final currentIndex = plantMeasurements.indexWhere(
      (m) => m.timestamp.isAtSameMomentAs(currentTimestamp)
    );
    
    if (currentIndex > 0) {
      return plantMeasurements[currentIndex - 1];
    }
    return null;
  }

  // Calculate growth statistics for a plant
  Map<String, dynamic> getGrowthStats(String plantId) {
    final plantMeasurements = getMeasurementsForPlant(plantId);
    
    if (plantMeasurements.length < 2) {
      return {
        'totalGrowthHeight': 0.0,
        'totalGrowthWidth': 0.0,
        'averageGrowthRateHeight': 0.0,
        'averageGrowthRateWidth': 0.0,
        'totalGrowthPercentageHeight': 0.0,
        'totalGrowthPercentageWidth': 0.0,
        'measurementCount': plantMeasurements.length,
      };
    }

    final first = plantMeasurements.first;
    final last = plantMeasurements.last;
    
    final totalGrowthHeight = last.height - first.height;
    final totalGrowthWidth = last.width - first.width;
    
    final totalDays = last.timestamp.difference(first.timestamp).inDays;
    final averageGrowthRateHeight = totalDays > 0 ? totalGrowthHeight / totalDays : 0.0;
    final averageGrowthRateWidth = totalDays > 0 ? totalGrowthWidth / totalDays : 0.0;
    
    final totalGrowthPercentageHeight = first.height > 0 ? (totalGrowthHeight / first.height) * 100 : 0.0;
    final totalGrowthPercentageWidth = first.width > 0 ? (totalGrowthWidth / first.width) * 100 : 0.0;

    return {
      'totalGrowthHeight': totalGrowthHeight,
      'totalGrowthWidth': totalGrowthWidth,
      'averageGrowthRateHeight': averageGrowthRateHeight,
      'averageGrowthRateWidth': averageGrowthRateWidth,
      'totalGrowthPercentageHeight': totalGrowthPercentageHeight,
      'totalGrowthPercentageWidth': totalGrowthPercentageWidth,
      'measurementCount': plantMeasurements.length,
      'firstMeasurement': first,
      'lastMeasurement': last,
    };
  }

  // Get growth trend (increasing, decreasing, stable)
  String getGrowthTrend(String plantId, String dimension) {
    final plantMeasurements = getMeasurementsForPlant(plantId);
    
    if (plantMeasurements.length < 3) return 'insufficient_data';
    
    final recentMeasurements = plantMeasurements.length > 3 
        ? plantMeasurements.sublist(plantMeasurements.length - 3)
        : plantMeasurements;
    final values = recentMeasurements.map((m) => 
      dimension == 'height' ? m.height : m.width
    ).toList();
    
    // Simple trend analysis
    bool increasing = true;
    bool decreasing = true;
    
    for (int i = 1; i < values.length; i++) {
      if (values[i] <= values[i-1]) increasing = false;
      if (values[i] >= values[i-1]) decreasing = false;
    }
    
    if (increasing) return 'increasing';
    if (decreasing) return 'decreasing';
    return 'stable';
  }

  // Get measurements for chart data
  List<Map<String, dynamic>> getChartData(String plantId, String dimension) {
    final plantMeasurements = getMeasurementsForPlant(plantId);
    
    return plantMeasurements.map((measurement) {
      return {
        'timestamp': measurement.timestamp,
        'value': dimension == 'height' ? measurement.height : measurement.width,
        'measurement': measurement,
      };
    }).toList();
  }

  // Get growth milestones (e.g., 50% growth, 100% growth)
  List<Map<String, dynamic>> getGrowthMilestones(String plantId) {
    final plantMeasurements = getMeasurementsForPlant(plantId);
    if (plantMeasurements.isEmpty) return [];
    
    final firstMeasurement = plantMeasurements.first;
    final milestones = <Map<String, dynamic>>[];
    
    for (final measurement in plantMeasurements) {
      final heightGrowth = ((measurement.height - firstMeasurement.height) / firstMeasurement.height) * 100;
      final widthGrowth = ((measurement.width - firstMeasurement.width) / firstMeasurement.width) * 100;
      
      // Check for milestone achievements
      if (heightGrowth >= 25 && !milestones.any((m) => m['type'] == 'height_25')) {
        milestones.add({
          'type': 'height_25',
          'percentage': 25,
          'dimension': 'height',
          'measurement': measurement,
          'message': 'Plant height increased by 25%!',
        });
      }
      
      if (heightGrowth >= 50 && !milestones.any((m) => m['type'] == 'height_50')) {
        milestones.add({
          'type': 'height_50',
          'percentage': 50,
          'dimension': 'height',
          'measurement': measurement,
          'message': 'Plant height doubled!',
        });
      }
      
      if (widthGrowth >= 25 && !milestones.any((m) => m['type'] == 'width_25')) {
        milestones.add({
          'type': 'width_25',
          'percentage': 25,
          'dimension': 'width',
          'measurement': measurement,
          'message': 'Plant width increased by 25%!',
        });
      }
    }
    
    return milestones;
  }
}
