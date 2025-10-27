import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'offline_service.dart';

class ApiException implements Exception {
  final String message;
  final String code;
  final String? details;
  
  ApiException(this.message, this.code, {this.details});
  
  @override
  String toString() => 'ApiException($code): $message${details != null ? ' - $details' : ''}';
}

class ApiService {
  // Local backend URL - running on computer's IP address
  static const String _baseUrl = "http://172.20.188.100:8000";
  static const String _predictEndpoint = "/predict";
  
  // Timeout duration for API calls
  static const Duration _timeoutDuration = Duration(seconds: 30);

  static Future<Map<String, dynamic>> predictDisease(File image) async {
    try {
      print('🌐 Starting disease prediction for: ${image.path}');
      
      // Check if image file exists and is readable
      if (!await image.exists()) {
        throw ApiException('Image file does not exist', 'FILE_NOT_FOUND');
      }
      
      // Check file size (max 10MB)
      final fileSize = await image.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw ApiException('Image file is too large (max 10MB)', 'FILE_TOO_LARGE');
      }
      
      // Check for cached prediction first
      final cachedResult = await OfflineService.getCachedPrediction(image.path);
      if (cachedResult != null) {
        print('📱 Using cached prediction (offline mode)');
        return {
          ...cachedResult,
          'cached': true,
          'model_type': 'cached',
        };
      }
      
      // Check internet connectivity
      final hasInternet = await OfflineService.hasInternetConnection();
      if (!hasInternet) {
        print('📱 No internet connection, using mock prediction');
        final mockResult = {
          'prediction': _getMockPrediction(),
          'confidence': 0.75,
          'model_type': 'mock_offline',
          'offline': true,
        };
        
        // Cache the mock result
        await OfflineService.cachePrediction(
          imagePath: image.path,
          prediction: mockResult,
        );
        
        return mockResult;
      }
      
      print('🌐 Sending image to backend: $_baseUrl$_predictEndpoint');
      
      final request = http.MultipartRequest(
        'POST', 
        Uri.parse('$_baseUrl$_predictEndpoint')
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('file', image.path)
      );

      final response = await request.send().timeout(_timeoutDuration);
      final responseBody = await http.Response.fromStream(response).timeout(_timeoutDuration);

      print('📡 Response status: ${responseBody.statusCode}');
      print('📄 Response body: ${responseBody.body}');

      if (responseBody.statusCode == 200) {
        final data = json.decode(responseBody.body);
        print('🔍 Parsed data: $data');
        
        // Handle different response formats
        String prediction = data['prediction'] ?? data['class'] ?? 'Unknown';
        double confidence = 0.0;
        
        if (data['confidence'] != null) {
          confidence = (data['confidence'] is double) 
              ? data['confidence'] 
              : double.tryParse(data['confidence'].toString()) ?? 0.0;
        }
        
        final result = {
          'prediction': prediction,
          'confidence': confidence,
          'model_type': data['model_type'] ?? 'unknown',
        };
        
        // Cache the successful prediction
        await OfflineService.cachePrediction(
          imagePath: image.path,
          prediction: result,
        );
        
        print('✅ Final result: $result');
        return result;
      } else {
        print('❌ API Error: ${responseBody.statusCode} - ${responseBody.body}');
        throw ApiException(
          'Server error: ${responseBody.statusCode}', 
          'SERVER_ERROR',
          details: responseBody.body
        );
      }
    } on ApiException {
      rethrow; // Re-throw our custom exceptions
    } on http.ClientException catch (e) {
      print('💥 Network connection error: $e');
      throw ApiException('Network connection failed', 'NETWORK_ERROR', details: e.toString());
    } on TimeoutException catch (e) {
      print('⏰ Request timeout: $e');
      throw ApiException('Request timed out', 'TIMEOUT_ERROR', details: e.toString());
    } on FormatException catch (e) {
      print('📄 JSON parsing error: $e');
      throw ApiException('Invalid response format', 'PARSE_ERROR', details: e.toString());
    } catch (e) {
      print('💥 Unexpected error: $e');
      
      // Fallback to mock data for testing
      print('🔄 Using fallback mock data');
      return {
        'prediction': _getMockPrediction(),
        'confidence': 0.85, // 85% confidence for mock data
        'model_type': 'mock',
        'fallback_reason': e.toString(),
      };
    }
  }

  static String _getMockPrediction() {
    final diseases = [
      'Healthy Leaf',
      'Early Blight',
      'Late Blight',
      'Leaf Spot Disease',
      'Powdery Mildew',
      'Bacterial Spot',
      'Yellow Leaf Curl Virus',
    ];
    
    // Return a random disease for demo
    final random = DateTime.now().millisecond % diseases.length;
    return diseases[random];
  }

  // Add your OpenAI API key here
  static const String _openAIApiKey = 'YOUR_OPENAI_API_KEY';

  static Future<Map<String, dynamic>> getDiseaseInfo(String diseaseName) async {
    // Mock disease information
    final diseaseInfo = {
      'Early Blight': {
        'description': 'A fungal disease that affects tomato and potato plants',
        'symptoms': [
          'Dark brown spots with concentric rings',
          'Yellowing of leaves',
          'Premature leaf drop'
        ],
        'treatments': [
          'Remove infected leaves',
          'Apply fungicide',
          'Improve air circulation',
          'Avoid overhead watering'
        ],
        'prevention': [
          'Crop rotation',
          'Proper spacing',
          'Mulching',
          'Regular monitoring'
        ]
      },
      'Late Blight': {
        'description': 'A serious disease that can destroy entire crops',
        'symptoms': [
          'Water-soaked lesions',
          'White fungal growth',
          'Rapid plant death'
        ],
        'treatments': [
          'Immediate removal of infected plants',
          'Copper-based fungicides',
          'Systemic fungicides'
        ],
        'prevention': [
          'Resistant varieties',
          'Good drainage',
          'Regular fungicide application'
        ]
      },
      'Healthy Leaf': {
        'description': 'Your plant appears to be healthy',
        'symptoms': ['No visible symptoms'],
        'treatments': ['Continue current care routine'],
        'prevention': [
          'Regular watering',
          'Proper fertilization',
          'Monitor for pests',
          'Good air circulation'
        ]
      }
    };

    if (diseaseInfo.containsKey(diseaseName)) {
      return diseaseInfo[diseaseName]!;
    } else {
      // Use OpenAI to generate info for unknown diseases
      return await _fetchDiseaseInfoFromOpenAI(diseaseName);
    }
  }

  static Future<Map<String, dynamic>> _fetchDiseaseInfoFromOpenAI(String diseaseName) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final prompt =
        'Provide a short description, a list of 3-5 symptoms, a list of 3-5 treatments, and a list of 3-5 prevention tips for the plant disease "$diseaseName". Respond in JSON with keys: description, symptoms, treatments, prevention.';

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openAIApiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a helpful plant pathology assistant.'},
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 500,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = data['choices'][0]['message']['content'];
      // Parse the JSON from the AI's response
      try {
        final info = json.decode(content);
        return {
          'description': info['description'] ?? 'No description available.',
          'symptoms': List<String>.from(info['symptoms'] ?? []),
          'treatments': List<String>.from(info['treatments'] ?? []),
          'prevention': List<String>.from(info['prevention'] ?? []),
        };
      } catch (e) {
        // If parsing fails, return a generic fallback
        return {
          'description': 'No detailed information available for $diseaseName.',
          'symptoms': ['Unknown symptoms'],
          'treatments': ['Consult a plant expert'],
          'prevention': ['Regular monitoring'],
        };
      }
    } else {
      // If OpenAI API fails, return a generic fallback
      return {
        'description': 'No detailed information available for $diseaseName.',
        'symptoms': ['Unknown symptoms'],
        'treatments': ['Consult a plant expert'],
        'prevention': ['Regular monitoring'],
      };
    }
  }
} 