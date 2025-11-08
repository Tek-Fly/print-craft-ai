import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _baseUrl = kDebugMode ? 'http://10.0.2.2:8000/api/v1' : 'https://api.printcraft.ai/v1';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Auth Endpoints
  Future<Map<String, dynamic>> loginWithFirebase(String idToken) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'idToken': idToken}),
    );
    return _handleResponse(response);
  }

  // User Endpoints
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/user/profile'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateProfile({String? displayName, String? photoUrl}) async {
    final body = {
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
    final response = await _client.put(
      Uri.parse('$_baseUrl/user/profile'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  // Generation Endpoints
  Future<Map<String, dynamic>> createGeneration(String prompt, String style) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/generation'),
      headers: _headers,
      body: jsonEncode({'prompt': prompt, 'style': style}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getGenerationHistory() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/generation/history'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getGenerationStatus(String id) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/generation/$id'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<void> deleteGeneration(String id) async {
     final response = await _client.delete(
      Uri.parse('$_baseUrl/generation/$id'),
      headers: _headers,
    );
    _handleResponse(response);
  }

  Future<List<dynamic>> getStyles() async {
    final response = await _client.get(
        Uri.parse('$_baseUrl/generation/styles'),
        headers: _headers,
    );
    final decoded = _handleResponse(response);
    return decoded['data'] as List<dynamic>;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }
  }
}
