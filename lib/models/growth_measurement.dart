class GrowthMeasurement {
  final String id;
  final String plantId;
  final DateTime timestamp;
  final double height; // in cm
  final double width; // in cm
  final double? leafCount;
  final String? notes;
  final String? imagePath;
  final String measurementType; // "manual", "photo_analysis", "sensor"
  
  GrowthMeasurement({
    required this.id,
    required this.plantId,
    required this.timestamp,
    required this.height,
    required this.width,
    this.leafCount,
    this.notes,
    this.imagePath,
    this.measurementType = "manual",
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'timestamp': timestamp.toIso8601String(),
      'height': height,
      'width': width,
      'leafCount': leafCount,
      'notes': notes,
      'imagePath': imagePath,
      'measurementType': measurementType,
    };
  }
  
  factory GrowthMeasurement.fromJson(Map<String, dynamic> json) {
    return GrowthMeasurement(
      id: json['id'],
      plantId: json['plantId'],
      timestamp: DateTime.parse(json['timestamp']),
      height: json['height'].toDouble(),
      width: json['width'].toDouble(),
      leafCount: json['leafCount']?.toDouble(),
      notes: json['notes'],
      imagePath: json['imagePath'],
      measurementType: json['measurementType'] ?? 'manual',
    );
  }
  
  GrowthMeasurement copyWith({
    String? id,
    String? plantId,
    DateTime? timestamp,
    double? height,
    double? width,
    double? leafCount,
    String? notes,
    String? imagePath,
    String? measurementType,
  }) {
    return GrowthMeasurement(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      timestamp: timestamp ?? this.timestamp,
      height: height ?? this.height,
      width: width ?? this.width,
      leafCount: leafCount ?? this.leafCount,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      measurementType: measurementType ?? this.measurementType,
    );
  }
  
  // Calculate growth rate between two measurements
  static double calculateGrowthRate(GrowthMeasurement previous, GrowthMeasurement current, String dimension) {
    final timeDiff = current.timestamp.difference(previous.timestamp).inDays;
    if (timeDiff == 0) return 0.0;
    
    double previousValue = dimension == 'height' ? previous.height : previous.width;
    double currentValue = dimension == 'height' ? current.height : current.width;
    
    return (currentValue - previousValue) / timeDiff; // cm per day
  }
  
  // Calculate percentage growth
  static double calculatePercentageGrowth(GrowthMeasurement previous, GrowthMeasurement current, String dimension) {
    double previousValue = dimension == 'height' ? previous.height : previous.width;
    double currentValue = dimension == 'height' ? current.height : current.width;
    
    if (previousValue == 0) return 0.0;
    return ((currentValue - previousValue) / previousValue) * 100;
  }
}
