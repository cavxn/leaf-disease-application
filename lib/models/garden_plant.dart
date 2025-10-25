import 'dart:io';

class GardenPlant {
  static File? _getFileFromPath(String? path) {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }
  final String id;
  final String name;
  final String? scientificName;
  final String? notes;
  final DateTime dateAdded;
  final File? image;
  final String status; // "healthy", "treating", "recovering", "watch"
  final List<String> healthHistory;
  
  GardenPlant({
    required this.id,
    required this.name,
    this.scientificName,
    this.notes,
    required this.dateAdded,
    this.image,
    this.status = "healthy",
    List<String>? healthHistory,
  }) : healthHistory = healthHistory ?? [];
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'notes': notes,
      'dateAdded': dateAdded.toIso8601String(),
      'imagePath': image?.path,
      'status': status,
      'healthHistory': healthHistory,
    };
  }
  
  factory GardenPlant.fromJson(Map<String, dynamic> json) {
    return GardenPlant(
      id: json['id'],
      name: json['name'],
      scientificName: json['scientificName'],
      notes: json['notes'],
      dateAdded: DateTime.parse(json['dateAdded']),
      image: _getFileFromPath(json['imagePath']),
      status: json['status'] ?? 'healthy',
      healthHistory: List<String>.from(json['healthHistory'] ?? []),
    );
  }
  
  GardenPlant copyWith({
    String? id,
    String? name,
    String? scientificName,
    String? notes,
    DateTime? dateAdded,
    File? image,
    String? status,
    List<String>? healthHistory,
  }) {
    return GardenPlant(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      notes: notes ?? this.notes,
      dateAdded: dateAdded ?? this.dateAdded,
      image: image ?? this.image,
      status: status ?? this.status,
      healthHistory: healthHistory ?? this.healthHistory,
    );
  }
}
