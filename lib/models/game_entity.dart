abstract class GameEntity {
  final int id;
  const GameEntity({required this.id});
  Map<String, dynamic> toJson();
}
