import 'package:flashgamer/models/game_entity.dart';

class MissionEntity extends GameEntity {
  final String nome;
  final String descricao;
  final String categoria;
  final int xpRecompensa;
  final int? quizId;

  const MissionEntity({
    required super.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.xpRecompensa,
    this.quizId,
  });

  factory MissionEntity.fromJson(Map<String, dynamic> json) {
    return MissionEntity(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      categoria: json['categoria'] as String,
      xpRecompensa: json['xp_recompensa'] as int? ?? 100,
      quizId: json['quiz_id'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'descricao': descricao,
    'categoria': categoria,
    'xp_recompensa': xpRecompensa,
    'quiz_id': quizId,
  };
}
