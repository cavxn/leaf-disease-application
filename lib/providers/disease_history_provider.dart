import 'package:flutter/material.dart';
import '../models/disease_detection.dart';

class DiseaseHistoryProvider extends ChangeNotifier {
  final List<DiseaseDetection> _detections = [];
  final List<DiseaseDetection> _favorites = [];

  List<DiseaseDetection> get detections => _detections;
  List<DiseaseDetection> get favorites => _favorites;

  void addDetection(DiseaseDetection detection) {
    _detections.insert(0, detection);
    notifyListeners();
  }

  void toggleFavorite(DiseaseDetection detection) {
    final index = _favorites.indexWhere((d) => d.id == detection.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(detection);
    }
    notifyListeners();
  }

  void removeDetection(String id) {
    _detections.removeWhere((d) => d.id == id);
    _favorites.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  void clearHistory() {
    _detections.clear();
    _favorites.clear();
    notifyListeners();
  }
} 