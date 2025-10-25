import 'package:flutter/material.dart';
import '../models/plant_care_event.dart';
import '../models/plant.dart';

class PlantCareProvider extends ChangeNotifier {
  List<PlantCareEvent> _events = [];
  List<Plant> _plants = [];

  List<PlantCareEvent> get events => _events;
  List<Plant> get plants => _plants;

  void addEvent(PlantCareEvent event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(PlantCareEvent event) {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      notifyListeners();
    }
  }

  void deleteEvent(String eventId) {
    _events.removeWhere((event) => event.id == eventId);
    notifyListeners();
  }

  void toggleEventCompletion(String eventId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = _events[index];
      _events[index] = event.copyWith(isCompleted: !event.isCompleted);
      notifyListeners();
    }
  }

  List<PlantCareEvent> getEventsForDate(DateTime date) {
    return _events.where((event) =>
        event.date.year == date.year &&
        event.date.month == date.month &&
        event.date.day == date.day).toList();
  }

  List<PlantCareEvent> getUpcomingEvents({int days = 7}) {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    
    return _events.where((event) =>
        event.date.isAfter(now) &&
        event.date.isBefore(futureDate) &&
        !event.isCompleted).toList();
  }

  List<PlantCareEvent> getOverdueEvents() {
    final now = DateTime.now();
    return _events.where((event) =>
        event.date.isBefore(now) &&
        !event.isCompleted).toList();
  }

  void addPlant(Plant plant) {
    _plants.add(plant);
    notifyListeners();
  }

  void updatePlant(Plant plant) {
    final index = _plants.indexWhere((p) => p.id == plant.id);
    if (index != -1) {
      _plants[index] = plant;
      notifyListeners();
    }
  }

  void deletePlant(String plantId) {
    _plants.removeWhere((plant) => plant.id == plantId);
    notifyListeners();
  }

  Plant? getPlantById(String id) {
    try {
      return _plants.firstWhere((plant) => plant.id == id);
    } catch (e) {
      return null;
    }
  }

  List<PlantCareEvent> getEventsForPlant(String plantId) {
    return _events.where((event) => event.plantId == plantId).toList();
  }

  // Initialize with plant database matching disease detection classes
  void initializeSampleData() {
    if (_plants.isEmpty) {
      _plants = [
        // 🍎 FRUIT TREES & ORCHARDS
        Plant(
          id: '1',
          name: 'Apple',
          scientificName: 'Malus domestica',
          image: '🍎',
          careLevel: 'Medium',
          wateringFrequency: 'Weekly',
          lightRequirement: 'Full sun',
          temperature: '15-25°C',
          humidity: '40-60%',
          fertilizing: 'Spring and fall',
          repotting: 'Not applicable (outdoor tree)',
          tips: [
            'Prune in late winter for best fruit production',
            'Plant in well-draining soil',
            'Requires cross-pollination for fruit',
            'Watch for apple scab and cedar apple rust',
            'Harvest when fruit easily separates from branch',
          ],
        ),
        Plant(
          id: '2',
          name: 'Blueberry',
          scientificName: 'Vaccinium spp.',
          image: '🫐',
          careLevel: 'Medium',
          wateringFrequency: 'Twice weekly',
          lightRequirement: 'Full sun to partial shade',
          temperature: '15-25°C',
          humidity: '50-70%',
          fertilizing: 'Spring with acidic fertilizer',
          repotting: 'Not applicable (outdoor shrub)',
          tips: [
            'Requires acidic soil (pH 4.5-5.5)',
            'Plant multiple varieties for better pollination',
            'Mulch with pine needles or oak leaves',
            'Prune old canes after fruiting',
            'Protect from birds with netting',
          ],
        ),
        Plant(
          id: '3',
          name: 'Cherry',
          scientificName: 'Prunus avium',
          image: '🍒',
          careLevel: 'Medium',
          wateringFrequency: 'Weekly',
          lightRequirement: 'Full sun',
          temperature: '10-25°C',
          humidity: '40-60%',
          fertilizing: 'Early spring',
          repotting: 'Not applicable (outdoor tree)',
          tips: [
            'Prune in late summer to avoid disease',
            'Plant in well-draining soil',
            'Requires chilling hours for fruit set',
            'Watch for powdery mildew',
            'Harvest when fruit is fully colored',
          ],
        ),
        Plant(
          id: '4',
          name: 'Orange',
          scientificName: 'Citrus sinensis',
          image: '🍊',
          careLevel: 'Medium',
          wateringFrequency: 'Weekly',
          lightRequirement: 'Full sun',
          temperature: '15-30°C',
          humidity: '50-70%',
          fertilizing: 'Monthly in growing season',
          repotting: 'Every 2-3 years',
          tips: [
            'Protect from frost in winter',
            'Use citrus-specific fertilizer',
            'Watch for citrus greening disease',
            'Prune to maintain shape',
            'Harvest when fully orange',
          ],
        ),
        Plant(
          id: '5',
          name: 'Peach',
          scientificName: 'Prunus persica',
          image: '🍑',
          careLevel: 'Medium',
          wateringFrequency: 'Weekly',
          lightRequirement: 'Full sun',
          temperature: '15-25°C',
          humidity: '40-60%',
          fertilizing: 'Early spring',
          repotting: 'Not applicable (outdoor tree)',
          tips: [
            'Prune in late winter',
            'Thin fruit for better quality',
            'Watch for bacterial spot',
            'Plant in well-draining soil',
            'Harvest when fruit gives slightly to pressure',
          ],
        ),
        Plant(
          id: '6',
          name: 'Raspberry',
          scientificName: 'Rubus idaeus',
          image: '🫐',
          careLevel: 'Easy',
          wateringFrequency: 'Twice weekly',
          lightRequirement: 'Full sun',
          temperature: '15-25°C',
          humidity: '50-70%',
          fertilizing: 'Spring',
          repotting: 'Not applicable (outdoor plant)',
          tips: [
            'Prune old canes after fruiting',
            'Support with trellis or stakes',
            'Mulch to retain moisture',
            'Plant in rows for easy harvesting',
            'Remove suckers to control spread',
          ],
        ),
        Plant(
          id: '7',
          name: 'Strawberry',
          scientificName: 'Fragaria × ananassa',
          image: '🍓',
          careLevel: 'Easy',
          wateringFrequency: 'Every 2-3 days',
          lightRequirement: 'Full sun',
          temperature: '15-25°C',
          humidity: '50-70%',
          fertilizing: 'Spring and after fruiting',
          repotting: 'Not applicable (outdoor plant)',
          tips: [
            'Plant in well-draining soil',
            'Remove runners to focus energy on fruit',
            'Mulch with straw to keep fruit clean',
            'Replace plants every 3-4 years',
            'Pinch first-year flowers for better establishment',
          ],
        ),

        // 🌽 VEGETABLES & CROPS
        Plant(
          id: '8',
          name: 'Corn (Maize)',
          scientificName: 'Zea mays',
          image: '🌽',
          careLevel: 'Easy',
          wateringFrequency: 'Every 2-3 days',
          lightRequirement: 'Full sun',
          temperature: '20-30°C',
          humidity: '50-70%',
          fertilizing: 'High nitrogen fertilizer',
          repotting: 'Not applicable (outdoor crop)',
          tips: [
            'Plant in blocks for better pollination',
            'Water deeply and consistently',
            'Watch for rust and leaf blight',
            'Harvest when kernels are milky',
            'Plant succession crops for extended harvest',
          ],
        ),
        Plant(
          id: '9',
          name: 'Bell Pepper',
          scientificName: 'Capsicum annuum',
          image: '🫑',
          careLevel: 'Medium',
          wateringFrequency: 'Every 2-3 days',
          lightRequirement: 'Full sun',
          temperature: '20-30°C',
          humidity: '50-70%',
          fertilizing: 'Balanced fertilizer monthly',
          repotting: 'Not applicable (outdoor plant)',
          tips: [
            'Start seeds indoors 8-10 weeks before last frost',
            'Transplant when soil is warm',
            'Support with stakes or cages',
            'Watch for bacterial spot',
            'Harvest when peppers reach desired size',
          ],
        ),
        Plant(
          id: '10',
          name: 'Potato',
          scientificName: 'Solanum tuberosum',
          image: '🥔',
          careLevel: 'Easy',
          wateringFrequency: 'Weekly',
          lightRequirement: 'Full sun',
          temperature: '15-25°C',
          humidity: '50-70%',
          fertilizing: 'Low nitrogen, high potassium',
          repotting: 'Not applicable (outdoor crop)',
          tips: [
            'Plant seed potatoes in spring',
            'Hill soil around plants as they grow',
            'Watch for early and late blight',
            'Harvest when foliage dies back',
            'Store in cool, dark place',
          ],
        ),
        Plant(
          id: '11',
          name: 'Soybean',
          scientificName: 'Glycine max',
          image: '🫘',
          careLevel: 'Easy',
          wateringFrequency: 'Weekly',
          lightRequirement: 'Full sun',
          temperature: '20-30°C',
          humidity: '50-70%',
          fertilizing: 'Nitrogen-fixing, minimal fertilizer',
          repotting: 'Not applicable (outdoor crop)',
          tips: [
            'Plant after soil warms in spring',
            'Space plants 2-3 inches apart',
            'Rotate crops to prevent disease',
            'Harvest when pods are dry and brown',
            'Excellent for soil improvement',
          ],
        ),
        Plant(
          id: '12',
          name: 'Squash',
          scientificName: 'Cucurbita spp.',
          image: '🎃',
          careLevel: 'Easy',
          wateringFrequency: 'Every 2-3 days',
          lightRequirement: 'Full sun',
          temperature: '20-30°C',
          humidity: '50-70%',
          fertilizing: 'Balanced fertilizer monthly',
          repotting: 'Not applicable (outdoor plant)',
          tips: [
            'Plant in hills with 3-4 seeds each',
            'Water at base to avoid powdery mildew',
            'Harvest when skin is hard',
            'Store in cool, dry place',
            'Great for fall decorations',
          ],
        ),
        Plant(
          id: '13',
          name: 'Tomato',
          scientificName: 'Solanum lycopersicum',
          image: '🍅',
          careLevel: 'Medium',
          wateringFrequency: 'Every 2-3 days',
          lightRequirement: 'Full sun',
          temperature: '20-30°C',
          humidity: '50-70%',
          fertilizing: 'Balanced fertilizer every 2-3 weeks',
          repotting: 'Not applicable (outdoor plant)',
          tips: [
            'Support with stakes or cages',
            'Water at soil level to prevent disease',
            'Watch for blight and mosaic virus',
            'Prune suckers for better air circulation',
            'Harvest when fully colored',
          ],
        ),

        // 🍇 VINE CROPS
        Plant(
          id: '14',
          name: 'Grape',
          scientificName: 'Vitis vinifera',
          image: '🍇',
          careLevel: 'Medium',
          wateringFrequency: 'Weekly',
          lightRequirement: 'Full sun',
          temperature: '15-25°C',
          humidity: '50-70%',
          fertilizing: 'Spring with balanced fertilizer',
          repotting: 'Not applicable (outdoor vine)',
          tips: [
            'Train on trellis or arbor',
            'Prune heavily in winter',
            'Watch for black rot and leaf blight',
            'Harvest when grapes are sweet',
            'Great for wine making',
          ],
        ),
      ];
    }

    if (_events.isEmpty) {
      _events = [
        PlantCareEvent(
          id: '1',
          title: 'Water Snake Plant',
          description: 'Water the snake plant in the living room',
          date: DateTime.now().add(const Duration(days: 1)),
          time: const TimeOfDay(hour: 9, minute: 0),
          type: PlantCareEventType.watering,
          plantName: 'Snake Plant',
          plantId: '1',
          isCompleted: false,
        ),
        PlantCareEvent(
          id: '2',
          title: 'Fertilize Monstera',
          description: 'Apply liquid fertilizer to Monstera',
          date: DateTime.now().add(const Duration(days: 3)),
          time: const TimeOfDay(hour: 14, minute: 0),
          type: PlantCareEventType.fertilizing,
          plantName: 'Monstera Deliciosa',
          plantId: '2',
          isCompleted: false,
        ),
        PlantCareEvent(
          id: '3',
          title: 'Check Soil Moisture',
          description: 'Check moisture levels for all plants',
          date: DateTime.now(),
          time: const TimeOfDay(hour: 16, minute: 30),
          type: PlantCareEventType.inspection,
          plantName: 'All Plants',
          plantId: 'all',
          isCompleted: false,
        ),
      ];
    }
    
    // Notify listeners that data has been initialized
    notifyListeners();
  }
}

