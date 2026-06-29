import 'dart:convert';
import 'api_service.dart';
import '../models/user_entity.dart';

class UserService {
  static Future<UserEntity> getMyProfile() async {
    final response = await ApiService.get('/users/me');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserEntity.fromJson(data['user'] ?? data);
    }
    throw ApiException(response.statusCode, 'Erro ao buscar perfil.');
  }

  static Future<UserEntity> updateProfile({String? nome}) async {
    final body = <String, dynamic>{};
    if (nome != null) body['nome'] = nome;
    final response = await ApiService.put('/users/me', body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserEntity.fromJson(data['user'] ?? data);
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
      final data = jsonDecode(response.body);
      return data['ranking'] as List<dynamic>;
    }
    throw ApiException(response.statusCode, 'Erro ao buscar ranking.');
  }

  // Métodos CRUD Administrativos
  static Future<List<UserEntity>> listAllUsers() async {
    final response = await ApiService.get('/users');
    if (response.statusCode == 200) {
      final List raw = jsonDecode(response.body)['users'] as List;
      return raw.map((u) => UserEntity.fromJson(u)).toList();
    }
    throw ApiException(response.statusCode, 'Erro ao listar usuários.');
  }

  static Future<UserEntity> createUserAdmin(String nome, String email, String senha, int lv, int xp, double saldo) async {
    final response = await ApiService.post('/users', body: {
      'nome': nome,
      'email': email,
      'senha': senha,
      'lv': lv,
      'xp': xp,
      'saldo': saldo,
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserEntity.fromJson(jsonDecode(response.body));
    }
    throw ApiException(response.statusCode, 'Erro ao criar usuário.');
  }

  static Future<UserEntity> updateUserAdmin(int id, String nome, String email, {String? senha, int? lv, int? xp, double? saldo}) async {
    final response = await ApiService.put('/users/$id', body: {
      'nome': nome,
      'email': email,
      if (senha != null && senha.isNotEmpty) 'senha': senha,
      'lv': lv,
      'xp': xp,
      'saldo': saldo,
    });
    if (response.statusCode == 200) {
      return UserEntity.fromJson(jsonDecode(response.body));
    }
    throw ApiException(response.statusCode, 'Erro ao atualizar usuário.');
  }

  static Future<void> deleteUserAdmin(int id) async {
    final response = await ApiService.delete('/users/$id');
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, 'Erro ao deletar usuário.');
    }
  }
}