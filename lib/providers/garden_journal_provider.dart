import 'package:flutter/material.dart';
import '../models/garden_journal_entry.dart';
import '../services/database_service.dart';

class GardenJournalProvider extends ChangeNotifier {
  List<GardenJournalEntry> _entries = [];
  final DatabaseService _db = DatabaseService.instance;
  bool _isLoading = false;

  List<GardenJournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  GardenJournalProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _db.getAllJournalEntries();
    } catch (e) {
      print('Error loading journal entries: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry(GardenJournalEntry entry) async {
    try {
      await _db.insertJournalEntry(entry);
      _entries = await _db.getAllJournalEntries();
      notifyListeners();
    } catch (e) {
      print('Error adding journal entry: $e');
      rethrow;
    }
  }

  Future<void> updateEntry(GardenJournalEntry entry) async {
    try {
      await _db.updateJournalEntry(entry);
      _entries = await _db.getAllJournalEntries();
      notifyListeners();
    } catch (e) {
      print('Error updating journal entry: $e');
      rethrow;
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _db.deleteJournalEntry(entryId);
      _entries = await _db.getAllJournalEntries();
      notifyListeners();
    } catch (e) {
      print('Error deleting journal entry: $e');
      rethrow;
    }
  }

  List<GardenJournalEntry> getEntriesForDate(DateTime date) {
    return _entries.where((entry) => 
      entry.date.year == date.year &&
      entry.date.month == date.month &&
      entry.date.day == date.day
    ).toList();
  }

  List<GardenJournalEntry> getEntriesForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return _entries.where((entry) => 
      entry.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
      entry.date.isBefore(weekEnd.add(const Duration(days: 1)))
    ).toList();
  }

  List<GardenJournalEntry> getEntriesForPlant(String plantId) {
    return _entries.where((entry) => entry.plantId == plantId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<GardenJournalEntry> getEntriesByType(String entryType) {
    return _entries.where((entry) => entry.entryType == entryType).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<GardenJournalEntry> getEntriesByMood(String mood) {
    return _entries.where((entry) => entry.mood == mood).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<GardenJournalEntry> searchEntries(String query) {
    if (query.isEmpty) return _entries;
    
    final lowercaseQuery = query.toLowerCase();
    return _entries.where((entry) =>
      entry.title.toLowerCase().contains(lowercaseQuery) ||
      entry.content.toLowerCase().contains(lowercaseQuery) ||
      entry.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get recent entries (last 7 days)
  List<GardenJournalEntry> getRecentEntries() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _entries.where((entry) => entry.date.isAfter(weekAgo)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get entries for a specific month
  List<GardenJournalEntry> getEntriesForMonth(DateTime month) {
    return _entries.where((entry) => 
      entry.date.year == month.year &&
      entry.date.month == month.month
    ).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get journal statistics
  Map<String, dynamic> getJournalStats() {
    if (_entries.isEmpty) {
      return {
        'totalEntries': 0,
        'entriesThisWeek': 0,
        'entriesThisMonth': 0,
        'mostCommonMood': 'good',
        'averageEntriesPerWeek': 0.0,
        'totalPhotos': 0,
        'entriesWithWeather': 0,
      };
    }

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);
    
    final entriesThisWeek = _entries.where((entry) => entry.date.isAfter(weekAgo)).length;
    final entriesThisMonth = _entries.where((entry) => entry.date.isAfter(monthAgo)).length;
    
    // Calculate most common mood
    final moodCounts = <String, int>{};
    for (final entry in _entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }
    final mostCommonMood = moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    // Calculate average entries per week
    final firstEntry = _entries.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final weeksSinceFirst = now.difference(firstEntry).inDays / 7;
    final averageEntriesPerWeek = weeksSinceFirst > 0 ? _entries.length / weeksSinceFirst : 0.0;
    
    // Count photos and weather entries
    final totalPhotos = _entries.fold(0, (sum, entry) => sum + entry.photoPaths.length);
    final entriesWithWeather = _entries.where((entry) => entry.hasWeatherData).length;

    return {
      'totalEntries': _entries.length,
      'entriesThisWeek': entriesThisWeek,
      'entriesThisMonth': entriesThisMonth,
      'mostCommonMood': mostCommonMood,
      'averageEntriesPerWeek': averageEntriesPerWeek,
      'totalPhotos': totalPhotos,
      'entriesWithWeather': entriesWithWeather,
    };
  }

  // Get mood trends over time
  List<Map<String, dynamic>> getMoodTrends() {
    final moodTrends = <String, List<GardenJournalEntry>>{};
    
    for (final entry in _entries) {
      final weekKey = _getWeekKey(entry.date);
      if (!moodTrends.containsKey(weekKey)) {
        moodTrends[weekKey] = [];
      }
      moodTrends[weekKey]!.add(entry);
    }
    
    return moodTrends.entries.map((entry) {
      final weekEntries = entry.value;
      final moodCounts = <String, int>{};
      
      for (final journalEntry in weekEntries) {
        moodCounts[journalEntry.mood] = (moodCounts[journalEntry.mood] ?? 0) + 1;
      }
      
      final dominantMood = moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      
      return {
        'week': entry.key,
        'entries': weekEntries.length,
        'dominantMood': dominantMood,
        'moodCounts': moodCounts,
      };
    }).toList()
      ..sort((a, b) => (a['week'] as String).compareTo(b['week'] as String));
  }

  String _getWeekKey(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return '${startOfWeek.year}-W${startOfWeek.month}-${startOfWeek.day}';
  }

  // Get entries for PDF export
  List<GardenJournalEntry> getEntriesForExport({
    DateTime? startDate,
    DateTime? endDate,
    String? entryType,
    String? plantId,
  }) {
    List<GardenJournalEntry> filteredEntries = _entries;
    
    if (startDate != null) {
      filteredEntries = filteredEntries.where((entry) => entry.date.isAfter(startDate.subtract(const Duration(days: 1)))).toList();
    }
    
    if (endDate != null) {
      filteredEntries = filteredEntries.where((entry) => entry.date.isBefore(endDate.add(const Duration(days: 1)))).toList();
    }
    
    if (entryType != null) {
      filteredEntries = filteredEntries.where((entry) => entry.entryType == entryType).toList();
    }
    
    if (plantId != null) {
      filteredEntries = filteredEntries.where((entry) => entry.plantId == plantId).toList();
    }
    
    return filteredEntries..sort((a, b) => a.date.compareTo(b.date));
  }
}
