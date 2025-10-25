import 'dart:io';

class GardenJournalEntry {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final List<String> photoPaths;
  final String? weatherData;
  final String? temperature;
  final String? humidity;
  final String? weatherCondition;
  final String entryType; // 'daily', 'weekly', 'special'
  final List<String> tags;
  final String? plantId; // Optional: link to specific plant
  final String mood; // 'great', 'good', 'okay', 'concerned', 'worried'
  
  GardenJournalEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    List<String>? photoPaths,
    this.weatherData,
    this.temperature,
    this.humidity,
    this.weatherCondition,
    this.entryType = 'daily',
    List<String>? tags,
    this.plantId,
    this.mood = 'good',
  }) : photoPaths = photoPaths ?? [],
       tags = tags ?? [];
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
      'photoPaths': photoPaths,
      'weatherData': weatherData,
      'temperature': temperature,
      'humidity': humidity,
      'weatherCondition': weatherCondition,
      'entryType': entryType,
      'tags': tags,
      'plantId': plantId,
      'mood': mood,
    };
  }
  
  factory GardenJournalEntry.fromJson(Map<String, dynamic> json) {
    return GardenJournalEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      content: json['content'],
      photoPaths: List<String>.from(json['photoPaths'] ?? []),
      weatherData: json['weatherData'],
      temperature: json['temperature'],
      humidity: json['humidity'],
      weatherCondition: json['weatherCondition'],
      entryType: json['entryType'] ?? 'daily',
      tags: List<String>.from(json['tags'] ?? []),
      plantId: json['plantId'],
      mood: json['mood'] ?? 'good',
    );
  }
  
  GardenJournalEntry copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? content,
    List<String>? photoPaths,
    String? weatherData,
    String? temperature,
    String? humidity,
    String? weatherCondition,
    String? entryType,
    List<String>? tags,
    String? plantId,
    String? mood,
  }) {
    return GardenJournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      photoPaths: photoPaths ?? this.photoPaths,
      weatherData: weatherData ?? this.weatherData,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      entryType: entryType ?? this.entryType,
      tags: tags ?? this.tags,
      plantId: plantId ?? this.plantId,
      mood: mood ?? this.mood,
    );
  }
  
  // Helper methods
  bool get hasPhotos => photoPaths.isNotEmpty;
  bool get hasWeatherData => weatherData != null;
  bool get isLinkedToPlant => plantId != null;
  
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String get moodEmoji {
    switch (mood) {
      case 'great': return '😊';
      case 'good': return '😌';
      case 'okay': return '😐';
      case 'concerned': return '😟';
      case 'worried': return '😰';
      default: return '😌';
    }
  }
  
  String get weatherEmoji {
    switch (weatherCondition?.toLowerCase()) {
      case 'sunny': return '☀️';
      case 'cloudy': return '☁️';
      case 'rainy': return '🌧️';
      case 'stormy': return '⛈️';
      case 'snowy': return '❄️';
      case 'windy': return '💨';
      default: return '🌤️';
    }
  }
}
