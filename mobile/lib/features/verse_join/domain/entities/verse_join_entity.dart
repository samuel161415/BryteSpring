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

  factory VerseJoinEntity.fromJson(Map<String, dynamic> json) {
    return VerseJoinEntity(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerseJoinEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
