import 'dart:convert';
import 'api_service.dart';
import '../models/quiz_entity.dart';

class QuizService {
  static Future<List<QuizQuestionEntity>> list() async {
    final response = await ApiService.get('/quizzes');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List raw = data['quizzes'] as List? ?? [];
      return raw.map((e) => QuizQuestionEntity.fromJson(e)).toList();
    }
    throw ApiException(response.statusCode, 'Erro ao listar perguntas.');
  }

  static Future<Map<String, dynamic>> submit({
    required int questionId,
    required int respostaId,
  }) async {
    final response = await ApiService.post('/quizzes/submit', body: {
      'questionId': questionId,
      'respostaId': respostaId,
    });
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw ApiException(response.statusCode, 'Erro ao submeter resposta.');
  }

  // Métodos CRUD Administrativos
  static Future<QuizQuestionEntity> create(String nome, int tempoParaResposta, List<Map<String, dynamic>> respostas) async {
    final response = await ApiService.post('/quizzes', body: {
      'nome': nome,
      'tempo_para_resposta': tempoParaResposta,
      'respostas': respostas,
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return QuizQuestionEntity.fromJson(jsonDecode(response.body));
    }
    throw ApiException(response.statusCode, 'Erro ao criar quiz.');
  }

  static Future<QuizQuestionEntity> update(int id, String nome, int tempoParaResposta, List<Map<String, dynamic>> respostas) async {
    final response = await ApiService.put('/quizzes/$id', body: {
      'nome': nome,
      'tempo_para_resposta': tempoParaResposta,
      'respostas': respostas,
    });
    if (response.statusCode == 200) {
      return QuizQuestionEntity.fromJson(jsonDecode(response.body));
    }
    throw ApiException(response.statusCode, 'Erro ao atualizar quiz.');
  }

  static Future<void> delete(int id) async {
    final response = await ApiService.delete('/quizzes/$id');
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, 'Erro ao deletar quiz.');
    }
  }
}