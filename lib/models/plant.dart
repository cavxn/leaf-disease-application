class Plant {
  final String id;
  final String name;
  final String scientificName;
  final String image;
  final String careLevel;
  final String wateringFrequency;
  final String lightRequirement;
  final String temperature;
  final String humidity;
  final String fertilizing;
  final String repotting;
  final List<String> tips;

  Plant({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.image,
    required this.careLevel,
    required this.wateringFrequency,
    required this.lightRequirement,
    required this.temperature,
    required this.humidity,
    required this.fertilizing,
    required this.repotting,
    required this.tips,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'image': image,
      'careLevel': careLevel,
      'wateringFrequency': wateringFrequency,
      'lightRequirement': lightRequirement,
      'temperature': temperature,
      'humidity': humidity,
      'fertilizing': fertilizing,
      'repotting': repotting,
      'tips': tips,
    };
  }

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      name: json['name'],
      scientificName: json['scientificName'],
      image: json['image'],
      careLevel: json['careLevel'],
      wateringFrequency: json['wateringFrequency'],
      lightRequirement: json['lightRequirement'],
      temperature: json['temperature'],
      humidity: json['humidity'],
      fertilizing: json['fertilizing'],
      repotting: json['repotting'],
      tips: List<String>.from(json['tips']),
    );
  }
}
