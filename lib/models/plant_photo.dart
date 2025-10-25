import 'dart:io';

class PlantPhoto {
  final String id;
  final String plantId;
  final File image;
  final DateTime timestamp;
  final String? description;
  final String? diseaseDetected;
  final bool isTreatmentBefore;

  PlantPhoto({
    required this.id,
    required this.plantId,
    required this.image,
    required this.timestamp,
    this.description,
    this.diseaseDetected,
    this.isTreatmentBefore = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'imagePath': image.path,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'diseaseDetected': diseaseDetected,
      'isTreatmentBefore': isTreatmentBefore,
    };
  }

  factory PlantPhoto.fromJson(Map<String, dynamic> json) {
    return PlantPhoto(
      id: json['id'],
      plantId: json['plantId'],
      image: _getFileFromPath(json['imagePath']),
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
      diseaseDetected: json['diseaseDetected'],
      isTreatmentBefore: json['isTreatmentBefore'] ?? false,
    );
  }
  
  static File _getFileFromPath(String path) {
    return File(path);
  }

  PlantPhoto copyWith({
    String? id,
    String? plantId,
    File? image,
    DateTime? timestamp,
    String? description,
    String? diseaseDetected,
    bool? isTreatmentBefore,
  }) {
    return PlantPhoto(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      image: image ?? this.image,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      diseaseDetected: diseaseDetected ?? this.diseaseDetected,
      isTreatmentBefore: isTreatmentBefore ?? this.isTreatmentBefore,
    );
  }
}
