import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/verse_join/domain/entities/verse_join_entity.dart';
import 'package:mobile/features/verse_join/domain/repositories/verse_join_repository.dart';

class VerseJoinUseCase {
  final VerseJoinRepository repository;

  VerseJoinUseCase(this.repository);

  Future<Either<Failure, VerseJoinEntity>> joinVerse(String verseId) {
    return repository.joinVerse(verseId);
  }

  Future<Either<Failure, void>> leaveVerse(String verseId) {
    return repository.leaveVerse(verseId);
  }

  Future<Either<Failure, List<VerseJoinEntity>>> getJoinedVerses() {
    return repository.getJoinedVerses();
  }

  Future<Either<Failure, VerseJoinEntity>> getVerse(String verseId) {
    return repository.getVerse(verseId);
  }
}
