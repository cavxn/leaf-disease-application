import 'package:flutter/material.dart';

enum PlantCareEventType {
  watering,
  fertilizing,
  repotting,
  inspection,
  pruning,
}

class PlantCareEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final PlantCareEventType type;
  final String plantName;
  final String plantId;
  final bool isCompleted;

  PlantCareEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.type,
    required this.plantName,
    required this.plantId,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'type': type.toString(),
      'plantName': plantName,
      'plantId': plantId,
      'isCompleted': isCompleted,
    };
  }

  factory PlantCareEvent.fromJson(Map<String, dynamic> json) {
    return PlantCareEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      time: TimeOfDay.fromDateTime(DateTime.parse('2024-01-01 ${json['time']}:00')),
      type: PlantCareEventType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PlantCareEventType.watering,
      ),
      plantName: json['plantName'],
      plantId: json['plantId'],
      isCompleted: json['isCompleted'],
    );
  }

  PlantCareEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    PlantCareEventType? type,
    String? plantName,
    String? plantId,
    bool? isCompleted,
  }) {
    return PlantCareEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      type: type ?? this.type,
      plantName: plantName ?? this.plantName,
      plantId: plantId ?? this.plantId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
