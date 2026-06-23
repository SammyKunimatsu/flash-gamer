import 'dart:convert';
import 'api_service.dart';

class UserService {
  static Future<Map<String, dynamic>> getMyProfile() async {
    final response = await ApiService.get('/users/me');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw ApiException(response.statusCode, 'Erro ao buscar perfil.');
  }

  static Future<Map<String, dynamic>> updateProfile({String? nome}) async {
    final body = <String, dynamic>{};
    if (nome != null) body['nome'] = nome;

    final response = await ApiService.put('/users/me', body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw ApiException(response.statusCode, 'Erro ao atualizar perfil.');
  }

  static Future<Map<String, dynamic>> addXp(int xp) async {
    final response = await ApiService.post('/users/me/xp', body: {'xp': xp});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw ApiException(response.statusCode, 'Erro ao adicionar XP.');
  }

  static Future<Map<String, dynamic>> updateSaldo(int valor) async {
    final response = await ApiService.post('/users/me/saldo', body: {'valor': valor});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw ApiException(response.statusCode, 'Erro ao atualizar saldo.');
  }

  static Future<List<dynamic>> getRanking() async {
    final response = await ApiService.get('/users/ranking');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw ApiException(response.statusCode, 'Erro ao buscar ranking.');
  }
}
