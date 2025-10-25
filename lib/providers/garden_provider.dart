import 'package:flutter/material.dart';
import 'dart:io';
import '../models/garden_plant.dart';
import '../models/plant_photo.dart';
import '../services/database_service.dart';

class GardenProvider extends ChangeNotifier {
  List<GardenPlant> _plants = [];
  List<PlantPhoto> _photos = [];
  final DatabaseService _db = DatabaseService.instance;
  bool _isLoading = false;

  List<GardenPlant> get plants => _plants;
  List<PlantPhoto> get photos => _photos;
  bool get isLoading => _isLoading;

  GardenProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _plants = await _db.getAllPlants();
      _photos = await _db.getAllPhotos();
    } catch (e) {
      print('Error loading data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPlant(GardenPlant plant) async {
    try {
      await _db.insertPlant(plant);
      _plants = await _db.getAllPlants();
      notifyListeners();
    } catch (e) {
      print('Error adding plant: $e');
    }
  }

  Future<void> updatePlant(GardenPlant updatedPlant) async {
    try {
      await _db.updatePlant(updatedPlant);
      if (updatedPlant.healthHistory.isNotEmpty) {
        await _db.saveHealthHistory(updatedPlant.id, updatedPlant.healthHistory);
      }
      _plants = await _db.getAllPlants();
      notifyListeners();
    } catch (e) {
      print('Error updating plant: $e');
    }
  }

  Future<void> deletePlant(String plantId) async {
    try {
      await _db.deletePlant(plantId);
      _plants = await _db.getAllPlants();
      _photos = await _db.getAllPhotos();
      notifyListeners();
    } catch (e) {
      print('Error deleting plant: $e');
    }
  }

  GardenPlant? getPlantById(String id) {
    try {
      return _plants.firstWhere((plant) => plant.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addHealthHistory(String plantId, String entry) async {
    final plant = getPlantById(plantId);
    if (plant != null) {
      final updatedHistory = [...plant.healthHistory, entry];
      await updatePlant(plant.copyWith(healthHistory: updatedHistory));
    }
  }

  Future<void> updatePlantStatus(String plantId, String status) async {
    final plant = getPlantById(plantId);
    if (plant != null) {
      await updatePlant(plant.copyWith(status: status));
    }
  }

  // Photo Management
  Future<void> addPhoto(PlantPhoto photo) async {
    try {
      await _db.insertPhoto(photo);
      _photos = await _db.getAllPhotos();
      notifyListeners();
    } catch (e) {
      print('Error adding photo: $e');
      rethrow;
    }
  }

  Future<void> deletePhoto(String photoId) async {
    try {
      await _db.deletePhoto(photoId);
      _photos = await _db.getAllPhotos();
      notifyListeners();
    } catch (e) {
      print('Error deleting photo: $e');
    }
  }

  List<PlantPhoto> getPhotosForPlant(String plantId) {
    return _photos.where((photo) => photo.plantId == plantId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<PlantPhoto> getBeforeAfterPhotos(String plantId) {
    return _photos.where((photo) => 
      photo.plantId == plantId && 
      photo.diseaseDetected != null
    ).toList();
  }

  PlantPhoto? getPhotoById(String photoId) {
    try {
      return _photos.firstWhere((photo) => photo.id == photoId);
    } catch (e) {
      return null;
    }
  }
}

