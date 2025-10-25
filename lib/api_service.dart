import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _url = "https://leaf-disease-application.onrender.com/predict";

  static Future<String> predictDisease(File image) async {
    final request = http.MultipartRequest('POST', Uri.parse(_url));
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    final resBody = await http.Response.fromStream(response);

    if (resBody.statusCode == 200) {
      final data = json.decode(resBody.body);
      return data['prediction'];
    } else {
      throw Exception('Prediction failed: ${resBody.statusCode}');
    }
  }
}