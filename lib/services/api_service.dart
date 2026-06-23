import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class ApiService {
  static const String baseUrl = 'https://flashgamer.discloud.app';

  static Future<Map<String, String>> _authHeaders() async {
    final token = await TokenService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<bool> _refreshToken() async {
    final refreshToken = await TokenService.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await TokenService.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        return true;
      }
    } catch (_) {}

    await TokenService.deleteTokens();
    return false;
  }

  static Future<http.Response> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    final headers = await _authHeaders();
    var response = await http.get(uri, headers: headers);

    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final newHeaders = await _authHeaders();
        response = await http.get(uri, headers: newHeaders);
      } else {
        throw ApiException(401, 'Sessão expirada. Faça login novamente.');
      }
    }

    return response;
  }

  static Future<http.Response> post(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = auth ? await _authHeaders() : {'Content-Type': 'application/json'};
    var response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);

    if (auth && response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final newHeaders = await _authHeaders();
        response = await http.post(uri, headers: newHeaders, body: body != null ? jsonEncode(body) : null);
      } else {
        throw ApiException(401, 'Sessão expirada. Faça login novamente.');
      }
    }

    return response;
  }

  static Future<http.Response> put(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _authHeaders();
    var response = await http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null);

    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final newHeaders = await _authHeaders();
        response = await http.put(uri, headers: newHeaders, body: body != null ? jsonEncode(body) : null);
      } else {
        throw ApiException(401, 'Sessão expirada. Faça login novamente.');
      }
    }

    return response;
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}
