import 'dart:convert';
import 'api_service.dart';
import '../models/equipment.dart';

class EquipmentService {
  static Future<List<Equipment>> list() async {
    final response = await ApiService.get('/equipments');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List raw = data['equipments'] as List? ?? [];
      return raw.map((e) => Equipment.fromJson(e)).toList();
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

  // Métodos CRUD Administrativos
  static Future<Equipment> create(String nome, String descricao, int tipoId, double valor) async {
    final response = await ApiService.post('/equipments', body: {
      'nome': nome,
      'descricao': descricao,
      'tipo_id': tipoId,
      'valor': valor,
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Equipment.fromJson(jsonDecode(response.body));
    }
    throw ApiException(response.statusCode, 'Erro ao criar equipamento.');
  }

  static Future<Equipment> update(int id, String nome, String descricao, int tipoId, double valor) async {
    final response = await ApiService.put('/equipments/$id', body: {
      'nome': nome,
      'descricao': descricao,
      'tipo_id': tipoId,
      'valor': valor,
    });
    if (response.statusCode == 200) {
      return Equipment.fromJson(jsonDecode(response.body));
    }
    throw ApiException(response.statusCode, 'Erro ao atualizar equipamento.');
  }

  static Future<void> delete(int id) async {
    final response = await ApiService.delete('/equipments/$id');
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, 'Erro ao deletar equipamento.');
    }
  }
}