import 'package:connectivity/connectivity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/storage/local_storage.dart';
import 'package:mobile/features/verse_join/data/datasources/verse_join_remote_datasource.dart';
import 'package:mobile/features/verse_join/domain/entities/verse_join_entity.dart';
import 'package:mobile/features/verse_join/domain/repositories/verse_join_repository.dart';

class VerseJoinRepositoryImpl implements VerseJoinRepository {
  final VerseJoinRemoteDataSource remoteDataSource;
  final LocalStorage localStorage;
  final Connectivity connectivity;

  VerseJoinRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorage,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, VerseJoinEntity>> joinVerse(String verseId) async {
    try {
      // Check connectivity first
      final connectivityResult = await connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Try online first using remote datasource
        final result = await remoteDataSource.joinVerse(verseId);
        
        if (result.isRight()) {
          final verse = result.getOrElse(() => throw Exception());
          
          // Cache verse data locally for offline access
          await localStorage.cacheData('verse_$verseId', verse.toJson());
          
          // Also cache in joined verses list
          await _addToJoinedVersesCache(verse);
          
          return Right(verse);
        } else {
          if (kDebugMode) {
            print('Online join verse failed, trying offline');
          }
          // Fall through to offline attempt
        }
      }

      // Try offline/cached data
      final cachedVerse = await localStorage.getCachedData('verse_$verseId');
      if (cachedVerse != null) {
        final verse = VerseJoinEntity.fromJson(cachedVerse);
        if (kDebugMode) {
          print('Using cached verse data for offline join');
        }
        return Right(verse);
      }

      // Queue offline action for later sync
      await localStorage.queueOfflineAction('join_verse', {'verseId': verseId});

      return Left(
        NetworkFailure(
          'No internet connection and no cached verse data available',
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveVerse(String verseId) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Try online using remote datasource
        await remoteDataSource.leaveVerse(verseId);
      }

      // Always remove from local cache
      await localStorage.clearCachedData('verse_$verseId');
      await _removeFromJoinedVersesCache(verseId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Leave verse error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<VerseJoinEntity>>> getJoinedVerses() async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Try to get fresh joined verses using remote datasource
        final result = await remoteDataSource.getJoinedVerses();
        
        if (result.isRight()) {
          final verses = result.getOrElse(() => throw Exception());
          
          // Cache joined verses locally
          final versesJson = verses.map((v) => v.toJson()).toList();
          await localStorage.cacheData('joined_verses', {
            'verses': versesJson,
          });
          
          return Right(verses);
        } else {
          if (kDebugMode) {
            print('Failed to get fresh joined verses');
          }
        }
      }

      // Fall back to cached data
      final cachedData = await localStorage.getCachedData('joined_verses');
      if (cachedData != null) {
        final List<dynamic> versesJson = cachedData['verses'];
        final verses = versesJson
            .map((json) => VerseJoinEntity.fromJson(json))
            .toList();
        return Right(verses);
      }

      return Right([]); // Return empty list if no cached data
    } catch (e) {
      return Left(ServerFailure('Get joined verses error: $e'));
    }
  }

  @override
  Future<Either<Failure, VerseJoinEntity>> getVerse(String verseId) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Try to get fresh verse data using remote datasource
        final result = await remoteDataSource.getVerse(verseId);
        
        if (result.isRight()) {
          final verse = result.getOrElse(() => throw Exception());
          
          // Cache verse data locally
          await localStorage.cacheData('verse_$verseId', verse.toJson());
          
          return Right(verse);
        } else {
          if (kDebugMode) {
            print('Failed to get fresh verse data');
          }
        }
      }

      // Fall back to cached data
      final cachedVerse = await localStorage.getCachedData('verse_$verseId');
      if (cachedVerse != null) {
        final verse = VerseJoinEntity.fromJson(cachedVerse);
        return Right(verse);
      }

      return Left(
        NetworkFailure(
          'No internet connection and no cached verse data available',
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Get verse error: $e'));
    }
  }

  /// Add verse to joined verses cache
  Future<void> _addToJoinedVersesCache(VerseJoinEntity verse) async {
    try {
      final cachedData = await localStorage.getCachedData('joined_verses');
      List<dynamic> versesJson = [];

      if (cachedData != null) {
        versesJson = List<dynamic>.from(cachedData['verses']);
      }

      // Add new verse if not already present
      if (!versesJson.any((v) => v['id'] == verse.id)) {
        versesJson.add(verse.toJson());
        await localStorage.cacheData('joined_verses', {'verses': versesJson});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add verse to joined cache: $e');
      }
    }
  }

  /// Remove verse from joined verses cache
  Future<void> _removeFromJoinedVersesCache(String verseId) async {
    try {
      final cachedData = await localStorage.getCachedData('joined_verses');
      if (cachedData != null) {
        final List<dynamic> versesJson = List<dynamic>.from(
          cachedData['verses'],
        );
        versesJson.removeWhere((v) => v['id'] == verseId);
        await localStorage.cacheData('joined_verses', {'verses': versesJson});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to remove verse from joined cache: $e');
      }
    }
  }
}
