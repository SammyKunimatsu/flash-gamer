import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'token_service.dart';
import 'package:flutter/foundation.dart';
class AuthService {
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await TokenService.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Email ou senha incorretos.');
      } else {
        throw Exception('Erro ao fazer login. Tente novamente.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      debugPrint(e.toString());
      throw Exception('Erro de conexão. Verifique sua internet.');
    }
  }
  static Future<Map<String, dynamic>> register({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': senha,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 409) {
        throw Exception('Este email já está cadastrado.');
      } else {
        throw Exception('Erro ao criar conta. Tente novamente.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão. Verifique sua internet.');
    }
  }
  static Future<void> logout() async {
    try {
      final refreshToken = await TokenService.getRefreshToken();
      if (refreshToken != null) {
        await ApiService.post('/auth/logout', body: {'refreshToken': refreshToken});
      }
    } catch (_) {}
    await TokenService.deleteTokens();
  }
  static Future<bool> isLoggedIn() async {
    final token = await TokenService.getAccessToken();
    return token != null;
  }
}