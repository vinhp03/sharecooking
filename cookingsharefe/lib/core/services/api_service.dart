import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' show basename;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class ApiService {
  final SharedPreferences prefs;
  final String baseUrl = 'http://localhost:3000/api';
  static const String _tokenKey = 'auth_token';

  ApiService(this.prefs);

  String? get token => prefs.getString(_tokenKey);

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };

    final token = prefs.getString(_tokenKey);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    final headers = await _getHeaders();
    var uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get data: ${response.body}');
    }
  }

  Future<dynamic> post(String endpoint, [Map<String, dynamic>? data]) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: data != null ? json.encode(data) : null,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to post data: ${response.body}');
    }
  }

  Future<dynamic> put(String endpoint, [Map<String, dynamic>? data]) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: data != null ? json.encode(data) : null,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to put data: ${response.body}');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete data: ${response.body}');
    }
  }

  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields,
    Map<String, String> files, {
    Map<String, Uint8List>? fileBytes,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add auth token if available
      final token = await _getHeaders();
      request.headers.addAll({
        'Authorization': token['Authorization'] ?? '',
      });

      // Add text fields
      request.fields.addAll(fields);

      // Add file fields from paths (mobile)
      if (!kIsWeb) {
        for (var entry in files.entries) {
          if (entry.value.isNotEmpty) {
            final file = File(entry.value);
            final stream = http.ByteStream(file.openRead());
            final length = await file.length();

            // Get MIME type based on file extension
            String? mimeType;
            if (entry.key == 'image') {
              mimeType = 'image/${_getFileExtension(entry.key)}';
            } else if (entry.key == 'video') {
              mimeType = 'video/${_getFileExtension(entry.key)}';
            }

            final multipartFile = http.MultipartFile(
              entry.key,
              stream,
              length,
              filename: basename(file.path),
              contentType: mimeType != null ? MediaType.parse(mimeType) : null,
            );
            request.files.add(multipartFile);
          }
        }
      }

      // Add file fields from bytes (web)
      if (kIsWeb && fileBytes != null) {
        for (var entry in fileBytes.entries) {
          // Get MIME type based on file type
          String? mimeType;
          if (entry.key == 'image') {
            mimeType = 'image/${_getFileExtension(entry.key)}';
          } else if (entry.key == 'video') {
            mimeType = 'video/${_getFileExtension(entry.key)}';
          }

          final multipartFile = http.MultipartFile.fromBytes(
            entry.key,
            entry.value,
            filename: '${entry.key}.${_getFileExtension(entry.key)}',
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          );
          request.files.add(multipartFile);
        }
      }

      print('Request fields: ${request.fields}');
      print(
          'Request files: ${request.files.map((f) => '${f.field}: ${f.filename}, ${f.contentType}')}');

      final response = await request.send();
      final responseStr = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseStr');

      if (response.statusCode >= 400) {
        throw Exception(
            'Failed to upload files: ${response.statusCode}\nResponse: $responseStr');
      }

      return json.decode(responseStr);
    } catch (e) {
      print('Error in postMultipart: $e');
      rethrow;
    }
  }

  String _getFileExtension(String key) {
    switch (key) {
      case 'image':
        return 'jpg';
      case 'video':
        return 'mp4';
      default:
        return 'bin';
    }
  }
}
