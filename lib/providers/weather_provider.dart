import 'package:flutter/foundation.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherData? _currentWeather;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;

  WeatherData? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  bool get hasWeather => _currentWeather != null;
  bool get isStale => _lastUpdated == null || 
    DateTime.now().difference(_lastUpdated!).inMinutes > 30;

  Future<void> fetchCurrentWeather() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🌤️ Fetching current weather...');
      final weather = await WeatherService.getCurrentWeather();
      
      if (weather != null) {
        _currentWeather = weather;
        _lastUpdated = DateTime.now();
        print('✅ Weather updated: ${weather.temperature}°C, ${weather.humidity}% humidity');
      } else {
        _error = 'Unable to fetch weather data';
        print('❌ Failed to fetch weather data');
      }
    } catch (e) {
      _error = 'Error fetching weather: ${e.toString()}';
      print('❌ Weather fetch error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchWeatherByCity(String cityName) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🌤️ Fetching weather for $cityName...');
      final weather = await WeatherService.getWeatherByCity(cityName);
      
      if (weather != null) {
        _currentWeather = weather;
        _lastUpdated = DateTime.now();
        print('✅ Weather updated for $cityName: ${weather.temperature}°C');
      } else {
        _error = 'Unable to fetch weather data for $cityName';
        print('❌ Failed to fetch weather for $cityName');
      }
    } catch (e) {
      _error = 'Error fetching weather: ${e.toString()}';
      print('❌ Weather fetch error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> refreshWeather() async {
    if (isStale) {
      await fetchCurrentWeather();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  // Helper methods for UI
  String getTemperatureDisplay() {
    if (_currentWeather == null) return '--°C';
    return '${_currentWeather!.temperature.round()}°C';
  }

  String getHumidityDisplay() {
    if (_currentWeather == null) return '--%';
    return '${_currentWeather!.humidity.round()}%';
  }

  String getWindSpeedDisplay() {
    if (_currentWeather == null) return '-- km/h';
    return '${_currentWeather!.windSpeed.round()} km/h';
  }

  String getLocationDisplay() {
    if (_currentWeather == null) return 'Unknown Location';
    return _currentWeather!.location;
  }

  String getConditionDisplay() {
    if (_currentWeather == null) return 'Unknown';
    return _currentWeather!.description;
  }

  String getTemperatureStatus() {
    if (_currentWeather == null) return 'No data';
    return _currentWeather!.getTemperatureStatus();
  }

  String getHumidityStatus() {
    if (_currentWeather == null) return 'No data';
    return _currentWeather!.getHumidityStatus();
  }

  String getPlantCareAdvice() {
    if (_currentWeather == null) return 'No weather data available';
    return _currentWeather!.getPlantCareAdvice();
  }

  List<String> getPlantCareRecommendations() {
    if (_currentWeather == null) return [];
    return WeatherService.getPlantCareRecommendations(_currentWeather!);
  }

  // Weather icon URL
  String getWeatherIconUrl() {
    if (_currentWeather == null) return '';
    return WeatherService.getWeatherIconUrl(_currentWeather!.icon);
  }

  // Check if weather is suitable for plant care
  bool get isGoodForPlantCare {
    if (_currentWeather == null) return false;
    
    final temp = _currentWeather!.temperature;
    final humidity = _currentWeather!.humidity;
    final wind = _currentWeather!.windSpeed;
    
    return temp >= 15 && temp <= 30 && 
           humidity >= 40 && humidity <= 80 && 
           wind <= 20;
  }

  // Get weather quality score (0-100)
  int get weatherQualityScore {
    if (_currentWeather == null) return 0;
    
    int score = 0;
    final temp = _currentWeather!.temperature;
    final humidity = _currentWeather!.humidity;
    final wind = _currentWeather!.windSpeed;
    
    // Temperature score (40 points max)
    if (temp >= 18 && temp <= 28) {
      score += 40;
    } else if (temp >= 15 && temp <= 30) {
      score += 30;
    } else if (temp >= 10 && temp <= 35) {
      score += 20;
    } else {
      score += 10;
    }
    
    // Humidity score (30 points max)
    if (humidity >= 50 && humidity <= 70) {
      score += 30;
    } else if (humidity >= 40 && humidity <= 80) {
      score += 20;
    } else {
      score += 10;
    }
    
    // Wind score (30 points max)
    if (wind <= 10) {
      score += 30;
    } else if (wind <= 20) {
      score += 20;
    } else {
      score += 10;
    }
    
    return score;
  }
}
