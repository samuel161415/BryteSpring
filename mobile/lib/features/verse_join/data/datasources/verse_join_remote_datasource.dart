import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Expected: { message, verse: {...}, role: {...}, user: {...} }
        final data = response.data as Map<String, dynamic>;
        final verseJson = (data['verse'] ?? {}) as Map<String, dynamic>;
        final userJson = (data['user'] ?? {}) as Map<String, dynamic>;

        final verse = _mapMinimalVerseToEntity(verseJson, userJson);
        return Right(verse);
      }

      return Left(ServerFailure('Join verse failed: ${response.statusCode}'));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractServerMessage(e)));
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
      return Left(ServerFailure(_extractServerMessage(e)));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}

// Helpers
VerseJoinEntity _mapMinimalVerseToEntity(
  Map<String, dynamic> verseJson,
  Map<String, dynamic> userJson,
) {
  final now = DateTime.now();
  return VerseJoinEntity(
    id: (verseJson['_id'] ?? verseJson['id'] ?? '').toString(),
    name: (verseJson['name'] ?? '').toString(),
    adminEmail: (userJson['email'] ?? '').toString(),
    subdomain: verseJson['subdomain']?.toString(),
    organizationName: verseJson['organization_name']?.toString(),
    branding: const BrandingEntity(
      primaryColor: '#3B82F6',
      colorName: 'Primary Blue',
    ),
    settings: const SettingsEntity(
      isPublic: false,
      allowInvites: true,
      maxUsers: 50,
      storageLimit: 10737418240,
    ),
    isSetupComplete: (verseJson['is_setup_complete'] ?? true) == true,
    setupCompletedAt: null,
    setupCompletedBy: null,
    isActive: (verseJson['is_active'] ?? true) == true,
    createdAt: _safeParseDate(verseJson['created_at']) ?? now,
    updatedAt: _safeParseDate(verseJson['updated_at']) ?? now,
    createdBy: verseJson['created_by']?.toString(),
  );
}

DateTime? _safeParseDate(dynamic value) {
  if (value == null) return null;
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    if (kDebugMode) {
      print('VerseJoinRemoteDataSource: Failed to parse date: $value');
    }
    return null;
  }
}

String _extractServerMessage(DioException e) {
  try {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message; // e.g., "User has already joined this verse"
      }
    }
    return 'Request failed${status != null ? ' (HTTP $status)' : ''}: ${e.message}';
  } catch (_) {
    return 'Request failed: ${e.message}';
  }
}
