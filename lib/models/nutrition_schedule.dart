import 'package:flutter/foundation.dart';

class NutritionSchedule {
  final String id;
  final String plantId;
  final String plantName;
  final String fertilizerType;
  final String frequency; // 'weekly', 'biweekly', 'monthly'
  final DateTime nextApplication;
  final bool isActive;
  final String notes;

  NutritionSchedule({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.fertilizerType,
    required this.frequency,
    required this.nextApplication,
    this.isActive = true,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'plantName': plantName,
      'fertilizerType': fertilizerType,
      'frequency': frequency,
      'nextApplication': nextApplication.toIso8601String(),
      'isActive': isActive,
      'notes': notes,
    };
  }

  factory NutritionSchedule.fromJson(Map<String, dynamic> json) {
    return NutritionSchedule(
      id: json['id'],
      plantId: json['plantId'],
      plantName: json['plantName'],
      fertilizerType: json['fertilizerType'],
      frequency: json['frequency'],
      nextApplication: DateTime.parse(json['nextApplication']),
      isActive: json['isActive'] ?? true,
      notes: json['notes'] ?? '',
    );
  }

  NutritionSchedule copyWith({
    String? id,
    String? plantId,
    String? plantName,
    String? fertilizerType,
    String? frequency,
    DateTime? nextApplication,
    bool? isActive,
    String? notes,
  }) {
    return NutritionSchedule(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      plantName: plantName ?? this.plantName,
      fertilizerType: fertilizerType ?? this.fertilizerType,
      frequency: frequency ?? this.frequency,
      nextApplication: nextApplication ?? this.nextApplication,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }
}
