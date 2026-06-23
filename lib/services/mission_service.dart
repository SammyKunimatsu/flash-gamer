import 'dart:convert';
import 'api_service.dart';

class MissionService {
  static Future<List<dynamic>> list() async {
    final response = await ApiService.get('/missions');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
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
}
