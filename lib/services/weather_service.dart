import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/weather_data.dart';

class WeatherService {
  static const String _apiKey = 'YOUR_OPENWEATHER_API_KEY'; // Replace with your API key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  
  // Fallback API key for demo purposes (you should replace this with your own)
  static const String _demoApiKey = 'demo_key_for_development';
  
  static Future<WeatherData?> getCurrentWeather() async {
    try {
      // Get user's location
      final position = await _getCurrentPosition();
      if (position == null) {
        print('❌ Could not get location');
        return null;
      }

      // For demo purposes, we'll use a fallback location if API key is not set
      if (_apiKey == 'YOUR_OPENWEATHER_API_KEY') {
        return _getDemoWeatherData(position);
      }

      // Make API call to OpenWeatherMap
      final url = '$_baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else {
        print('❌ Weather API error: ${response.statusCode}');
        return _getDemoWeatherData(position);
      }
    } catch (e) {
      print('❌ Error fetching weather: $e');
      return _getDemoWeatherData(null);
    }
  }

  static Future<WeatherData?> getWeatherByCity(String cityName) async {
    try {
      if (_apiKey == 'YOUR_OPENWEATHER_API_KEY') {
        return _getDemoWeatherData(null, cityName: cityName);
      }

      final url = '$_baseUrl?q=$cityName&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else {
        print('❌ Weather API error: ${response.statusCode}');
        return _getDemoWeatherData(null, cityName: cityName);
      }
    } catch (e) {
      print('❌ Error fetching weather: $e');
      return _getDemoWeatherData(null, cityName: cityName);
    }
  }

  static Future<Position?> _getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled');
        return null;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permissions are permanently denied');
        return null;
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

  static Future<String> getCityName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality ?? place.administrativeArea ?? 'Unknown'}, ${place.country ?? ''}';
      }
      return 'Unknown Location';
    } catch (e) {
      print('❌ Error getting city name: $e');
      return 'Unknown Location';
    }
  }

  // Demo weather data for development/testing
  static WeatherData _getDemoWeatherData(Position? position, {String? cityName}) {
    // Randomize all weather parameters
    final random = DateTime.now().millisecondsSinceEpoch;
    final random2 = DateTime.now().microsecondsSinceEpoch;
    final random3 = DateTime.now().millisecondsSinceEpoch % 1000;
    
    // Randomize temperature between 29°C and 34°C
    final temperature = 29.0 + (random % 500) / 100.0; // 29.0 to 33.99
    
    // Randomize humidity between 40% and 85%
    final humidity = 40.0 + (random2 % 450) / 10.0; // 40.0 to 84.9
    
    // Randomize wind speed between 2 and 25 km/h
    final windSpeed = 2.0 + (random3 % 230) / 10.0; // 2.0 to 24.9
    
    // Randomize pressure between 1000 and 1030 hPa
    final pressure = 1000 + (random % 30); // 1000 to 1029
    
    // Simulate different weather conditions based on time of day
    final now = DateTime.now();
    final hour = now.hour;
    
    String description;
    String icon;
    String condition;
    
    if (hour >= 6 && hour < 12) {
      // Morning
      description = 'Partly cloudy morning';
      icon = '02d';
      condition = 'Clouds';
    } else if (hour >= 12 && hour < 18) {
      // Afternoon
      description = 'Sunny afternoon';
      icon = '01d';
      condition = 'Clear';
    } else if (hour >= 18 && hour < 22) {
      // Evening
      description = 'Clear evening';
      icon = '01n';
      condition = 'Clear';
    } else {
      // Night
      description = 'Clear night';
      icon = '01n';
      condition = 'Clear';
    }

    final location = cityName ?? (position != null ? 'Current Location' : 'Demo City');
    
    return WeatherData(
      temperature: temperature,
      humidity: humidity,
      windSpeed: windSpeed,
      description: description,
      icon: icon,
      location: location,
      lastUpdated: DateTime.now(),
      feelsLike: temperature + (random % 100) / 50.0 - 1.0, // Random feels like between -1 and +1 from actual temp
      pressure: pressure,
      visibility: 8000 + (random % 2000), // Random visibility between 8000-10000m
      uvIndex: hour >= 10 && hour <= 16 ? (hour - 10) * 0.5 : 0.0,
      condition: condition,
    );
  }

  // Get weather icon URL
  static String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  // Get plant care recommendations based on weather
  static List<String> getPlantCareRecommendations(WeatherData weather) {
    List<String> recommendations = [];
    
    // Temperature recommendations for 29-34°C range
    if (weather.temperature < 10) {
      recommendations.add('🌡️ Move sensitive plants indoors');
    } else if (weather.temperature >= 29 && weather.temperature <= 34) {
      recommendations.add('🌡️ Perfect for tropical plants');
      recommendations.add('🌡️ Great for heat-loving species');
      recommendations.add('🌡️ Monitor watering needs closely');
    } else if (weather.temperature > 35) {
      recommendations.add('🌡️ Provide shade for outdoor plants');
    }
    
    // Humidity recommendations
    if (weather.humidity < 30) {
      recommendations.add('💧 Mist your plants regularly');
    } else if (weather.humidity > 80) {
      recommendations.add('💧 Ensure good air circulation');
    }
    
    // Wind recommendations
    if (weather.windSpeed > 15) {
      recommendations.add('💨 Protect plants from strong winds');
    }
    
    // UV recommendations
    if (weather.uvIndex > 6) {
      recommendations.add('☀️ Provide shade during peak sun hours');
    }
    
    return recommendations;
  }
}
