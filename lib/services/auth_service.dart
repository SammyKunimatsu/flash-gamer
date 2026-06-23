import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database_helper.dart';

class AuthService {
  static const String _baseUrl = 'https://api.example.com';

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String;
        await DatabaseHelper.instance.saveToken(token);
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Email ou senha incorretos.');
      } else {
        throw Exception('Erro ao fazer login. Tente novamente.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão. Verifique sua internet.');
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await DatabaseHelper.instance.getToken();
    return token != null;
  }

  static Future<void> logout() async {
    await DatabaseHelper.instance.deleteToken();
  }
}
