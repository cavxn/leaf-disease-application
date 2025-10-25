import 'dart:io';

class DiseaseDetection {
  final String id;
  final File image;
  final String diseaseName;
  final double confidence;
  final DateTime timestamp;
  final String? location;
  final List<String> symptoms;
  final List<String> treatments;
  final bool isHealthy;

  DiseaseDetection({
    required this.id,
    required this.image,
    required this.diseaseName,
    required this.confidence,
    required this.timestamp,
    this.location,
    required this.symptoms,
    required this.treatments,
    required this.isHealthy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': image.path,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'symptoms': symptoms,
      'treatments': treatments,
      'isHealthy': isHealthy,
    };
  }

  /// Factory method to create a model from backend JSON response + local image
    factory DiseaseDetection.fromBackendJson(Map<String, dynamic> json, File image) {
    final diseaseName = json['class'] ?? 'Unknown';
    final confidence = (json['confidence'] ?? 0.0).toDouble();

    // ✅ Determine if it’s healthy
    final isHealthy = diseaseName.toLowerCase().contains('healthy');

    // ✅ Set fallback values for symptoms & treatments
    final List<String> defaultSymptoms = isHealthy
        ? []
        : ['Leaf discoloration', 'Spots or blight', 'Wilting or mold'];

    final List<String> defaultTreatments = isHealthy
        ? []
        : ['Use fungicide', 'Prune infected leaves', 'Ensure proper irrigation'];

    // ✅ Return the model instance
    return DiseaseDetection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      image: image,
      diseaseName: diseaseName,
      confidence: confidence,
      timestamp: DateTime.now(),
      location: null,
      symptoms: defaultSymptoms,
      treatments: defaultTreatments,
      isHealthy: isHealthy,
    );
  }

}
