import 'package:flashgamer/models/game_entity.dart';

class QuizQuestionEntity extends GameEntity {
  final String nome;
  final int tempoParaResposta;
  final List<QuizAnswerEntity> respostas;

  const QuizQuestionEntity({
    required super.id,
    required this.nome,
    required this.tempoParaResposta,
    required this.respostas,
  });

  factory QuizQuestionEntity.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['respostas'] as List? ?? [];
    final List<QuizAnswerEntity> answers = rawAnswers
        .map((a) => QuizAnswerEntity.fromJson(Map<String, dynamic>.from(a)))
        .toList();

    return QuizQuestionEntity(
      id: json['id'] as int,
      nome: json['nome'] as String,
      tempoParaResposta: json['tempo_para_resposta'] as int? ?? 15,
      respostas: answers,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'tempo_para_resposta': tempoParaResposta,
    'respostas': respostas.map((r) => r.toJson()).toList(),
  };
}

class QuizAnswerEntity {
  final int id;
  final String nome;
  final bool certa;

  const QuizAnswerEntity({
    required this.id,
    required this.nome,
    required this.certa,
  });

  factory QuizAnswerEntity.fromJson(Map<String, dynamic> json) {
    return QuizAnswerEntity(
      id: json['id'] as int? ?? 0,
      nome: json['nome'] as String,
      certa: json['certa'] == 1 || json['certa'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'certa': certa ? 1 : 0,
  };
}
