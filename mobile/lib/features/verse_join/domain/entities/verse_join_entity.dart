// Verse Join Entity
class VerseJoinEntity {
  final String id;
  final String name;
  final DateTime createdAt;

  VerseJoinEntity({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerseJoinEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
