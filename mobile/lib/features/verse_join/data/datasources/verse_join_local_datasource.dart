import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/verse_join/domain/entities/verse_join_entity.dart';

class VerseJoinLocalDataSource {
  static const String _joinedVersesKey = 'joined_verses';
  final SharedPreferences prefs;

  VerseJoinLocalDataSource(this.prefs);

  Future<Either<Failure, VerseJoinEntity>> joinVerse(String verseId) async {
    try {
      final joinedVerses = _getJoinedVerses();
      final now = DateTime.now();
      final entity = VerseJoinEntity(
        id: verseId,
        name:
            'Verse $verseId', // This would come from API in real implementation
        createdAt: now,
      );

      // Check if already joined
      if (joinedVerses.any((v) => v.id == verseId)) {
        return Right(entity);
      }

      // Add to joined list
      joinedVerses.add(entity);
      await _saveJoinedVerses(joinedVerses);

      return Right(entity);
    } catch (e) {
      return Left(CacheFailure('Failed to join verse: $e'));
    }
  }

  Future<Either<Failure, void>> leaveVerse(String verseId) async {
    try {
      final joinedVerses = _getJoinedVerses();
      joinedVerses.removeWhere((v) => v.id == verseId);
      await _saveJoinedVerses(joinedVerses);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to leave verse: $e'));
    }
  }

  Future<Either<Failure, List<VerseJoinEntity>>> getJoinedVerses() async {
    try {
      final joinedVerses = _getJoinedVerses();
      return Right(joinedVerses);
    } catch (e) {
      return Left(CacheFailure('Failed to get joined verses: $e'));
    }
  }

  List<VerseJoinEntity> _getJoinedVerses() {
    final jsonString = prefs.getString(_joinedVersesKey);
    if (jsonString == null) {
      return [];
    }

    try {
      // Simple implementation - in real app, use proper JSON serialization
      final List<dynamic> jsonList = jsonString.split('|');
      return jsonList.map((item) {
        final parts = item.split(',');
        return VerseJoinEntity(
          id: parts[0],
          name: parts[1],
          createdAt: DateTime.parse(parts[2]),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveJoinedVerses(List<VerseJoinEntity> verses) async {
    final jsonList = verses
        .map((verse) {
          return '${verse.id},${verse.name},${verse.createdAt.toIso8601String()}';
        })
        .join('|');

    await prefs.setString(_joinedVersesKey, jsonList);
  }
}
