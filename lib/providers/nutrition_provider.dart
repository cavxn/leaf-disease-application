import 'package:flutter/foundation.dart';
import '../models/nutrition_schedule.dart';
import '../models/fertilizer_product.dart';
import '../models/fertilization_history.dart';

class NutritionProvider extends ChangeNotifier {
  final List<NutritionSchedule> _schedules = [];
  final List<FertilizerProduct> _products = [];
  final List<FertilizationHistory> _history = [];

  // Getters
  List<NutritionSchedule> get schedules => _schedules;
  List<FertilizerProduct> get products => _products;
  List<FertilizationHistory> get history => _history;

  // Initialize with sample data
  void initializeSampleData() {
    _initializeSampleProducts();
    _initializeSampleSchedules();
    _initializeSampleHistory();
  }

  void _initializeSampleProducts() {
    _products.clear();
    _products.addAll([
      FertilizerProduct(
        id: '1',
        name: 'All-Purpose Fertilizer',
        npkRatio: '10-10-10',
        description: 'Balanced nutrition for general use on most plants',
        category: 'synthetic',
        suitablePlants: ['tomato', 'pepper', 'rose', 'general'],
        applicationMethod: 'soil',
        frequency: 'biweekly',
        price: 12.99,
        brand: 'Garden Pro',
        imageUrl: '',
      ),
      FertilizerProduct(
        id: '2',
        name: 'High Nitrogen Fertilizer',
        npkRatio: '20-10-10',
        description: 'Best for leafy vegetables and plants that need more nitrogen',
        category: 'synthetic',
        suitablePlants: ['lettuce', 'spinach', 'kale', 'leafy greens'],
        applicationMethod: 'soil',
        frequency: 'weekly',
        price: 15.99,
        brand: 'Leaf Boost',
        imageUrl: '',
      ),
      FertilizerProduct(
        id: '3',
        name: 'Bloom Booster',
        npkRatio: '5-10-10',
        description: 'Enhances flowering and fruiting in plants',
        category: 'synthetic',
        suitablePlants: ['rose', 'tomato', 'pepper', 'flowering plants'],
        applicationMethod: 'soil',
        frequency: 'biweekly',
        price: 18.99,
        brand: 'Flower Power',
        imageUrl: '',
      ),
      FertilizerProduct(
        id: '4',
        name: 'Organic Compost',
        npkRatio: '5-5-5',
        description: 'Slow-release natural nutrients from organic matter',
        category: 'organic',
        suitablePlants: ['all plants'],
        applicationMethod: 'soil',
        frequency: 'monthly',
        price: 8.99,
        brand: 'Nature\'s Best',
        imageUrl: '',
      ),
    ]);
  }

  void _initializeSampleSchedules() {
    _schedules.clear();
    final now = DateTime.now();
    _schedules.addAll([
      NutritionSchedule(
        id: '1',
        plantId: 'plant1',
        plantName: 'Tomato Plants',
        fertilizerType: 'All-Purpose Fertilizer 10-10-10',
        frequency: 'biweekly',
        nextApplication: now.add(const Duration(days: 1)),
        notes: 'Apply in the morning for best absorption',
      ),
      NutritionSchedule(
        id: '2',
        plantId: 'plant2',
        plantName: 'Rose Garden',
        fertilizerType: 'Bloom Booster 5-10-10',
        frequency: 'monthly',
        nextApplication: now.add(const Duration(days: 7)),
        notes: 'Focus on root zone application',
      ),
      NutritionSchedule(
        id: '3',
        plantId: 'plant3',
        plantName: 'Pepper Plants',
        fertilizerType: 'High Nitrogen 20-10-10',
        frequency: 'weekly',
        nextApplication: now.add(const Duration(days: 3)),
        notes: 'Dilute to half strength for young plants',
      ),
    ]);
  }

  void _initializeSampleHistory() {
    _history.clear();
    final now = DateTime.now();
    _history.addAll([
      FertilizationHistory(
        id: '1',
        plantId: 'plant1',
        plantName: 'Tomato Plants',
        productName: 'All-Purpose Fertilizer 10-10-10',
        npkRatio: '10-10-10',
        amount: 2.0,
        unit: 'cups',
        applicationDate: now.subtract(const Duration(days: 3)),
        notes: 'Applied evenly around base',
        applicationMethod: 'soil',
      ),
      FertilizationHistory(
        id: '2',
        plantId: 'plant2',
        plantName: 'Rose Garden',
        productName: 'Bloom Booster 5-10-10',
        npkRatio: '5-10-10',
        amount: 1.5,
        unit: 'cups',
        applicationDate: now.subtract(const Duration(days: 7)),
        notes: 'Focused on root zone',
        applicationMethod: 'soil',
      ),
      FertilizationHistory(
        id: '3',
        plantId: 'plant3',
        plantName: 'Pepper Plants',
        productName: 'High Nitrogen 20-10-10',
        npkRatio: '20-10-10',
        amount: 1.0,
        unit: 'cups',
        applicationDate: now.subtract(const Duration(days: 14)),
        notes: 'Diluted to half strength',
        applicationMethod: 'soil',
      ),
    ]);
  }

  // Schedule management
  void addSchedule(NutritionSchedule schedule) {
    _schedules.add(schedule);
    notifyListeners();
  }

  void updateSchedule(NutritionSchedule schedule) {
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _schedules[index] = schedule;
      notifyListeners();
    }
  }

  void deleteSchedule(String scheduleId) {
    _schedules.removeWhere((s) => s.id == scheduleId);
    notifyListeners();
  }

  void markScheduleCompleted(String scheduleId) {
    final schedule = _schedules.firstWhere((s) => s.id == scheduleId);
    final updatedSchedule = schedule.copyWith(
      nextApplication: _calculateNextApplication(schedule),
    );
    updateSchedule(updatedSchedule);
  }

  DateTime _calculateNextApplication(NutritionSchedule schedule) {
    final now = DateTime.now();
    switch (schedule.frequency) {
      case 'weekly':
        return now.add(const Duration(days: 7));
      case 'biweekly':
        return now.add(const Duration(days: 14));
      case 'monthly':
        return now.add(const Duration(days: 30));
      default:
        return now.add(const Duration(days: 14));
    }
  }

  // History management
  void addHistory(FertilizationHistory history) {
    _history.add(history);
    notifyListeners();
  }

  void deleteHistory(String historyId) {
    _history.removeWhere((h) => h.id == historyId);
    notifyListeners();
  }

  // Product management
  void addProduct(FertilizerProduct product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(FertilizerProduct product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  // Get products by category
  List<FertilizerProduct> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  // Get products suitable for a plant
  List<FertilizerProduct> getProductsForPlant(String plantName) {
    return _products.where((p) => 
      p.suitablePlants.contains(plantName.toLowerCase()) || 
      p.suitablePlants.contains('all plants')
    ).toList();
  }

  // Get upcoming schedules
  List<NutritionSchedule> getUpcomingSchedules({int days = 7}) {
    final cutoff = DateTime.now().add(Duration(days: days));
    return _schedules.where((s) => 
      s.isActive && s.nextApplication.isBefore(cutoff)
    ).toList()..sort((a, b) => a.nextApplication.compareTo(b.nextApplication));
  }

  // Get history for a specific plant
  List<FertilizationHistory> getHistoryForPlant(String plantId) {
    return _history.where((h) => h.plantId == plantId).toList()
      ..sort((a, b) => b.applicationDate.compareTo(a.applicationDate));
  }
}
