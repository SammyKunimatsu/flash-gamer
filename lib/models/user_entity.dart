import 'package:flashgamer/models/game_entity.dart';

class UserEntity extends GameEntity {
  final String nome;
  final String email;
  final int lv;
  final int xp;
  final double saldo;
  final String? imagem;
  final int diasSeguidos;

  const UserEntity({
    required super.id,
    required this.nome,
    required this.email,
    required this.lv,
    required this.xp,
    required this.saldo,
    this.imagem,
    this.diasSeguidos = 0,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      lv: json['lv'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
      imagem: json['imagem'] as String?,
      diasSeguidos: json['dias_seguidos'] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'email': email,
    'lv': lv,
    'xp': xp,
    'saldo': saldo,
    'imagem': imagem,
    'dias_seguidos': diasSeguidos,
  };
}
