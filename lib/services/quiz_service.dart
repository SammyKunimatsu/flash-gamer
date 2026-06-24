import 'dart:convert';
import 'api_service.dart';
class QuizService {
  static Future<List<dynamic>> list() async {
    final response = await ApiService.get('/quizzes');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
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
}