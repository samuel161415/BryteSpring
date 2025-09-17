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
      final response = await dioClient.post('/verse/$verseId/join');

      if (response.statusCode == 200) {
        // Backend returns: { verse: {...}, role: {...}, user: {...} }
        final responseData = response.data;
        final verseData = responseData['verse'];

        if (verseData != null) {
          final verse = VerseJoinEntity.fromJson(verseData);
          return Right(verse);
        } else {
          return Left(
            ServerFailure('Invalid response format: missing verse data'),
          );
        }
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
      // TODO: Backend needs to implement DELETE /verse/:verseId/leave endpoint
      // For now, return success as this endpoint doesn't exist yet
      return const Right(null);

      // Uncomment when backend implements this endpoint:
      /*
      final response = await dioClient.delete('/verse/$verseId/leave');

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure('Leave verse failed: ${response.statusCode}'),
        );
      }
      */
    } on DioException catch (e) {
      return Left(ServerFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<VerseJoinEntity>>> getJoinedVerses() async {
    try {
      // TODO: Backend needs to implement GET /verse/joined endpoint
      // For now, return empty list as this endpoint doesn't exist yet
      return Right(<VerseJoinEntity>[]);

      // Uncomment when backend implements this endpoint:
      /*
      final response = await dioClient.get('/verse/joined');

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
      */
    } on DioException catch (e) {
      return Left(ServerFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, VerseJoinEntity>> getVerse(String verseId) async {
    try {
      final response = await dioClient.get('/verse/$verseId');

      if (response.statusCode == 200) {
        // Backend returns verse object directly
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
