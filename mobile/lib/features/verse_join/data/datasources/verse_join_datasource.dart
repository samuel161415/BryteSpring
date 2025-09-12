import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/verse_join/domain/entities/verse_join_entity.dart';

abstract class VerseJoinDataSource {
  Future<Either<Failure, VerseJoinEntity>> joinVerse(String verseId);
  Future<Either<Failure, void>> leaveVerse(String verseId);
  Future<Either<Failure, List<VerseJoinEntity>>> getJoinedVerses();
  Future<Either<Failure, VerseJoinEntity>> getVerse(String verseId);
}
