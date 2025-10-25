class WeatherData {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final String location;
  final DateTime lastUpdated;
  final double feelsLike;
  final int pressure;
  final int visibility;
  final double uvIndex;
  final String condition;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.location,
    required this.lastUpdated,
    required this.feelsLike,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.condition,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      icon: json['weather'][0]['icon'] as String,
      location: '${json['name']}, ${json['sys']['country']}',
      lastUpdated: DateTime.now(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      pressure: json['main']['pressure'] as int,
      visibility: (json['visibility'] as num).toInt(),
      uvIndex: 0.0, // UV index not available in basic weather API
      condition: json['weather'][0]['main'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'description': description,
      'icon': icon,
      'location': location,
      'lastUpdated': lastUpdated.toIso8601String(),
      'feelsLike': feelsLike,
      'pressure': pressure,
      'visibility': visibility,
      'uvIndex': uvIndex,
      'condition': condition,
    };
  }

  // Helper methods for plant care recommendations
  String getTemperatureStatus() {
    if (temperature < 10) return 'Too cold for most plants';
    if (temperature > 35) return 'Too hot for most plants';
    if (temperature >= 29 && temperature <= 34) return 'Warm conditions - good for tropical plants';
    if (temperature >= 18 && temperature <= 28) return 'Ideal temperature';
    return 'Moderate conditions';
  }

  String getHumidityStatus() {
    if (humidity < 30) return 'Low humidity - consider misting';
    if (humidity > 80) return 'High humidity - ensure good ventilation';
    if (humidity >= 40 && humidity <= 70) return 'Perfect humidity level';
    if (humidity >= 30 && humidity < 40) return 'Moderately low - mist plants';
    if (humidity > 70 && humidity <= 80) return 'Moderately high - good air flow';
    return 'Moderate humidity';
  }

  String getPlantCareAdvice() {
    String advice = '';
    
    // Temperature advice for 29-34°C range
    if (temperature < 15) {
      advice += '• Move sensitive plants indoors\n';
    } else if (temperature >= 29 && temperature <= 34) {
      advice += '• Perfect for tropical and heat-loving plants\n';
      advice += '• Ensure adequate watering in warm conditions\n';
      advice += '• Provide afternoon shade for sensitive plants\n';
    } else if (temperature > 34) {
      advice += '• Provide shade for outdoor plants\n';
      advice += '• Increase watering frequency\n';
    }
    
    // Humidity advice
    if (humidity < 30) {
      advice += '• Mist your plants regularly\n';
      advice += '• Consider a humidifier\n';
      advice += '• Group plants together for humidity\n';
    } else if (humidity < 40) {
      advice += '• Light misting recommended\n';
      advice += '• Monitor plant moisture levels\n';
    } else if (humidity > 80) {
      advice += '• Ensure excellent air circulation\n';
      advice += '• Watch for fungal issues\n';
      advice += '• Consider a dehumidifier\n';
    } else if (humidity > 75) {
      advice += '• Good air circulation needed\n';
      advice += '• Monitor for excess moisture\n';
    }
    
    // Wind advice
    if (windSpeed > 20) {
      advice += '• Protect plants from strong winds\n';
      advice += '• Move delicate plants indoors\n';
    } else if (windSpeed > 15) {
      advice += '• Monitor plants for wind damage\n';
      advice += '• Consider wind barriers\n';
    } else if (windSpeed > 10) {
      advice += '• Gentle breeze - good for air circulation\n';
    }
    
    return advice.isNotEmpty ? advice : '• Great conditions for plant care!';
  }

  WeatherData copyWith({
    double? temperature,
    double? humidity,
    double? windSpeed,
    String? description,
    String? icon,
    String? location,
    DateTime? lastUpdated,
    double? feelsLike,
    int? pressure,
    int? visibility,
    double? uvIndex,
    String? condition,
  }) {
    return WeatherData(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      location: location ?? this.location,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      feelsLike: feelsLike ?? this.feelsLike,
      pressure: pressure ?? this.pressure,
      visibility: visibility ?? this.visibility,
      uvIndex: uvIndex ?? this.uvIndex,
      condition: condition ?? this.condition,
    );
  }
}
