import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/features/verse_join/domain/entities/verse_join_entity.dart';

abstract class VerseJoinRemoteDataSource {
  Future<Either<Failure, VerseJoinEntity>> joinVerse(String verseId);
  Future<Either<Failure, void>> leaveVerse(String verseId);
  Future<Either<Failure, List<VerseJoinEntity>>> getJoinedVerses();
  Future<Either<Failure, VerseJoinEntity>> getVerse(String verseId);
}

class VerseJoinRemoteDataSourceImpl implements VerseJoinRemoteDataSource {
  final DioClient dioClient;

  VerseJoinRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Either<Failure, VerseJoinEntity>> joinVerse(String verseId) async {
    try {
      final response = await dioClient.post(
        '/verses/$verseId/join',
        data: {'verseId': verseId},
      );

      if (response.statusCode == 200) {
        final verse = VerseJoinEntity.fromJson(response.data);
        return Right(verse);
      } else {
        return Left(ServerFailure('Join verse failed: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveVerse(String verseId) async {
    try {
      final response = await dioClient.delete('/verses/$verseId/leave');

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure('Leave verse failed: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<VerseJoinEntity>>> getJoinedVerses() async {
    try {
      final response = await dioClient.get('/verses/joined');

      if (response.statusCode == 200) {
        final List<dynamic> versesJson = response.data;
        final verses = versesJson
            .map((json) => VerseJoinEntity.fromJson(json))
            .toList();
        return Right(verses);
      } else {
        return Left(
          ServerFailure('Get joined verses failed: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, VerseJoinEntity>> getVerse(String verseId) async {
    try {
      final response = await dioClient.get('/verses/$verseId');

      if (response.statusCode == 200) {
        final verse = VerseJoinEntity.fromJson(response.data);
        return Right(verse);
      } else {
        return Left(ServerFailure('Get verse failed: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
