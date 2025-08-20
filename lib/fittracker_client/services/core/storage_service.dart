// lib/fittracker_client/service/core/storage_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class StorageService {
  static const String baseUrl = 'http://localhost:3000'; // hoặc URL server thật

  /// Upload file lên server, trả về URL của file
  static Future<String> uploadFile(File file, String folder) async {
    final uri = Uri.parse('$baseUrl/upload/$folder');
    final request = http.MultipartRequest('POST', uri);

    // Thêm file
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    // Gửi request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['url']; // server trả về URL file
    } else {
      throw Exception('Failed to upload file: ${response.statusCode}');
    }
  }

  /// Xóa file trên server bằng URL hoặc ID
  static Future<void> deleteFile(String fileIdOrUrl, String folder) async {
    final uri = Uri.parse('$baseUrl/upload/$folder/$fileIdOrUrl');
    final response = await http.delete(uri);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete file: ${response.statusCode}');
    }
  }
}
