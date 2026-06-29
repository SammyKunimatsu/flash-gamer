import 'package:flashgamer/models/game_entity.dart';
import 'package:flutter/material.dart';

abstract class Equipment extends GameEntity {
  final String nome;
  final String descricao;
  final double valor;
  final int tipoId;
  final bool comprado;
  final bool ativo;

  const Equipment({
    required super.id,
    required this.nome,
    required this.descricao,
    required this.valor,
    required this.tipoId,
    this.comprado = false,
    this.ativo = false,
  });

  String get categoryName;
  IconData get categoryIcon;

  factory Equipment.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    final nome = json['nome'] as String? ?? 'Equipamento';
    final descricao = json['descricao'] as String? ?? '';
    final valor = ((json['valor'] as num?)?.toDouble()) ?? 0.0;
    
    int tipoId = 3;
    if (json['tipo_id'] != null) {
      tipoId = json['tipo_id'] as int;
    } else if (json['tipo'] != null) {
      final String tNome = json['tipo'].toString().toLowerCase();
      if (tNome.contains('capa')) {
        tipoId = 1;
      } else if (tNome.contains('capacete') || tNome.contains('helm')) {
        tipoId = 2;
      } else {
        tipoId = 3;
      }
    }

    final comprado = json['comprado'] == 1 || json['comprado'] == true;
    final ativo = json['ativo'] == 1 || json['ativo'] == true;

    if (tipoId == 1) {
      return CapeEquipment(id: id, nome: nome, descricao: descricao, valor: valor, comprado: comprado, ativo: ativo);
    } else if (tipoId == 2) {
      return HelmetEquipment(id: id, nome: nome, descricao: descricao, valor: valor, comprado: comprado, ativo: ativo);
    } else {
      return PetEquipment(id: id, nome: nome, descricao: descricao, valor: valor, comprado: comprado, ativo: ativo);
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'descricao': descricao,
    'valor': valor,
    'tipo_id': tipoId,
    'comprado': comprado ? 1 : 0,
    'ativo': ativo ? 1 : 0,
  };
}

class CapeEquipment extends Equipment {
  const CapeEquipment({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.valor,
    super.comprado,
    super.ativo,
  }) : super(tipoId: 1);

  @override
  String get categoryName => 'Capa';

  @override
  IconData get categoryIcon => Icons.layers_rounded;
}

class HelmetEquipment extends Equipment {
  const HelmetEquipment({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.valor,
    super.comprado,
    super.ativo,
  }) : super(tipoId: 2);

  @override
  String get categoryName => 'Capacete';

  @override
  IconData get categoryIcon => Icons.healing_rounded;
}

class PetEquipment extends Equipment {
  const PetEquipment({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.valor,
    super.comprado,
    super.ativo,
  }) : super(tipoId: 3);

  @override
  String get categoryName => 'Pet';

  @override
  IconData get categoryIcon => Icons.pets_rounded;
}
