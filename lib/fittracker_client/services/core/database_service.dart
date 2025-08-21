import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseService {
  // Base URL của JSON server
  static const String baseUrl = 'http://localhost:3000'; // hoặc URL server thật

  // Hàm GET
  static Future<List<Map<String, dynamic>>> getData(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // Hàm POST
  static Future<Map<String, dynamic>> postData(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }

  // Hàm PUT
  static Future<Map<String, dynamic>> putData(
    String endpoint,
    String id,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update data: ${response.statusCode}');
    }
  }

  // Hàm DELETE
  static Future<void> deleteData(String endpoint, String id) async {
    final url = Uri.parse('$baseUrl/$endpoint/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete data: ${response.statusCode}');
    }
  }
}
