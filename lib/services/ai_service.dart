import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // 🔐 Replace with your actual Gemini API Key
  static const String _apiKey = 'AIzaSyCSuzugJNBX05RO3PKd4bNXd0LmrFu9qbM';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey';

  Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": message}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data['candidates'][0]['content']['parts'][0]['text'];
      return reply.trim();
    } else {
      final error = jsonDecode(response.body);
      throw Exception('Gemini API error: ${error['error']['message']}');
    }
  }
}
