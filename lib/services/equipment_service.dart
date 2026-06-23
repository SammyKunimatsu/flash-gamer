import 'dart:convert';
import 'api_service.dart';

class EquipmentService {
  static Future<List<dynamic>> list() async {
    final response = await ApiService.get('/equipments');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw ApiException(response.statusCode, 'Erro ao listar equipamentos.');
  }

  static Future<Map<String, dynamic>> buy(int equipamentoId) async {
    final response = await ApiService.post('/equipments/buy', body: {
      'equipamentoId': equipamentoId,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw ApiException(response.statusCode, 'Erro ao comprar equipamento.');
  }

  static Future<Map<String, dynamic>> toggle({
    required int equipamentoId,
    required int ativo,
  }) async {
    final response = await ApiService.post('/equipments/toggle', body: {
      'equipamentoId': equipamentoId,
      'ativo': ativo,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw ApiException(response.statusCode, 'Erro ao equipar/desequipar item.');
  }
}
