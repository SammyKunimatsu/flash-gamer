import 'dart:convert';
import 'api_service.dart';
import '../models/mission_entity.dart';

class MissionService {
  static Future<List<MissionEntity>> list() async {
    final response = await ApiService.get('/missions');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['missions'] as List? ?? [];
      return list.map((e) => MissionEntity.fromJson(e)).toList();
    }
    throw ApiException(response.statusCode, 'Erro ao listar missões.');
  }

  static Future<Map<String, dynamic>> complete(int missionId) async {
    final response = await ApiService.post('/missions/complete', body: {
      'missionId': missionId,
    });
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw ApiException(response.statusCode, 'Erro ao concluir missão.');
  }

  // Métodos CRUD Administrativos
  static Future<MissionEntity> create(String nome, String descricao, String categoria, int xpRecompensa, {int? quizId}) async {
    final response = await ApiService.post('/missions', body: {
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'xp_recompensa': xpRecompensa,
      'quiz_id': quizId,
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return MissionEntity.fromJson(jsonDecode(response.body));
    }
    throw ApiException(response.statusCode, 'Erro ao criar missão.');
  }

  static Future<MissionEntity> update(int id, String nome, String descricao, String categoria, int xpRecompensa, {int? quizId}) async {
    final response = await ApiService.put('/missions/$id', body: {
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'xp_recompensa': xpRecompensa,
      'quiz_id': quizId,
    });
    if (response.statusCode == 200) {
      return MissionEntity.fromJson(jsonDecode(response.body));
    }
    throw ApiException(response.statusCode, 'Erro ao atualizar missão.');
  }

  static Future<void> delete(int id) async {
    final response = await ApiService.delete('/missions/$id');
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, 'Erro ao deletar missão.');
    }
  }
}