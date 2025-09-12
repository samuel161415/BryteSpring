import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/verse_join/data/datasources/verse_join_datasource.dart';
import 'package:mobile/features/verse_join/domain/entities/verse_join_entity.dart';
import 'package:mobile/features/verse_join/domain/repositories/verse_join_repository.dart';

class VerseJoinRepositoryImpl implements VerseJoinRepository {
  final VerseJoinDataSource dataSource;

  VerseJoinRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, VerseJoinEntity>> joinVerse(String verseId) {
    return dataSource.joinVerse(verseId);
  }

  @override
  Future<Either<Failure, void>> leaveVerse(String verseId) {
    return dataSource.leaveVerse(verseId);
  }

  @override
  Future<Either<Failure, List<VerseJoinEntity>>> getJoinedVerses() {
    return dataSource.getJoinedVerses();
  }
}
