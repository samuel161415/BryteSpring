import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/verse_join/data/datasources/verse_join_remote_datasource.dart';
import 'package:mobile/features/verse_join/domain/entities/verse_join_entity.dart';
import 'package:mobile/features/verse_join/domain/repositories/verse_join_repository.dart';

class VerseJoinRepositoryImpl implements VerseJoinRepository {
  final VerseJoinRemoteDataSource remoteDataSource;

  VerseJoinRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, VerseJoinEntity>> joinVerse(String verseId) async {
    return await remoteDataSource.joinVerse(verseId);
  }

  @override
  Future<Either<Failure, void>> leaveVerse(String verseId) async {
    final result = await remoteDataSource.leaveVerse(verseId);
    return result;
  }

  @override
  Future<Either<Failure, List<VerseJoinEntity>>> getJoinedVerses() async {
    return await remoteDataSource.getJoinedVerses();
  }

  @override
  Future<Either<Failure, VerseJoinEntity>> getVerse(String verseId) async {
    return await remoteDataSource.getVerse(verseId);
  }
}
