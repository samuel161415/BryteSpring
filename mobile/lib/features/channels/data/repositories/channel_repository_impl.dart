import 'package:dartz/dartz.dart';
import 'package:connectivity/connectivity.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/channels/data/datasources/channel_remote_datasource.dart';
import 'package:mobile/features/channels/data/datasources/channel_local_datasource.dart';
import 'package:mobile/features/channels/domain/entities/channel_entity.dart';
import 'package:mobile/features/channels/domain/repositories/channel_repository.dart';

class ChannelRepositoryImpl implements ChannelRepository {
  final ChannelRemoteDataSource remoteDataSource;
  final ChannelLocalDataSource localDataSource;
  final Connectivity connectivity;

  ChannelRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, ChannelStructureResponse>> getVerseChannelStructure(String verseId) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        // Try to get data from remote source
        final remoteResult = await remoteDataSource.getVerseChannelStructure(verseId);
        
        return remoteResult.fold(
          (failure) async {
            // If remote fails, try to get cached data
            print('Remote channel structure failed, trying cached data: ${failure.message}');
            return await _getCachedChannelStructure(verseId);
          },
          (channelStructure) async {
            // Cache the successful remote data
            await localDataSource.cacheChannelStructure(verseId, channelStructure);
            print('Channel structure loaded from remote and cached');
            return Right(channelStructure);
          },
        );
      } else {
        // No internet connection, try to get cached data
        print('No internet connection, trying cached channel structure');
        return await _getCachedChannelStructure(verseId);
      }
    } catch (e) {
      print('Error in getVerseChannelStructure: $e');
      // Try to get cached data as fallback
      return await _getCachedChannelStructure(verseId);
    }
  }

  @override
  Future<Either<Failure, ChannelEntity>> getChannelContents(String channelId) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        // Try to get data from remote source
        final remoteResult = await remoteDataSource.getChannelContents(channelId);
        
        return remoteResult.fold(
          (failure) async {
            // If remote fails, try to get cached data
            print('Remote channel contents failed, trying cached data: ${failure.message}');
            return await _getCachedChannelContents(channelId);
          },
          (channelContents) async {
            // Cache the successful remote data
            await localDataSource.cacheChannelContents(channelId, channelContents);
            print('Channel contents loaded from remote and cached');
            return Right(channelContents);
          },
        );
      } else {
        // No internet connection, try to get cached data
        print('No internet connection, trying cached channel contents');
        return await _getCachedChannelContents(channelId);
      }
    } catch (e) {
      print('Error in getChannelContents: $e');
      // Try to get cached data as fallback
      return await _getCachedChannelContents(channelId);
    }
  }

  Future<Either<Failure, ChannelStructureResponse>> _getCachedChannelStructure(String verseId) async {
    try {
      final cachedData = await localDataSource.getCachedChannelStructure(verseId);
      
      if (cachedData != null) {
        print('Channel structure loaded from cache');
        return Right(cachedData);
      } else {
        print('No cached channel structure available');
        return Left(CacheFailure('No cached channel structure available'));
      }
    } catch (e) {
      print('Error getting cached channel structure: $e');
      return Left(CacheFailure('Failed to load cached channel structure: $e'));
    }
  }

  Future<Either<Failure, ChannelEntity>> _getCachedChannelContents(String channelId) async {
    try {
      final cachedData = await localDataSource.getCachedChannelContents(channelId);
      
      if (cachedData != null) {
        print('Channel contents loaded from cache');
        return Right(cachedData);
      } else {
        print('No cached channel contents available');
        return Left(CacheFailure('No cached channel contents available'));
      }
    } catch (e) {
      print('Error getting cached channel contents: $e');
      return Left(CacheFailure('Failed to load cached channel contents: $e'));
    }
  }

  @override
  Future<Either<Failure, ChannelEntity>> createChannel({
    required String verseId,
    required String name,
    String? parentChannelId,
    String type = 'folder',
    List<String> assetTypes = const [],
    bool? isPublic,
    String? description,
  }) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (!isConnected) {
        return Left(NetworkFailure('No internet connection available for creating channel'));
      }

      // Create channel via remote source
      final result = await remoteDataSource.createChannel(
        verseId: verseId,
        name: name,
        parentChannelId: parentChannelId,
        type: type,
        assetTypes: assetTypes,
        isPublic: isPublic,
        description: description,
      );

      return result.fold(
        (failure) => Left(failure),
        (channel) async {
          // Clear cached structure since it's now outdated
          await localDataSource.clearCachedChannelStructure(verseId);
          print('Channel created and cache cleared');
          return Right(channel);
        },
      );
    } catch (e) {
      print('Error creating channel: $e');
      return Left(NetworkFailure('Failed to create channel: $e'));
    }
  }

  @override
  Future<Either<Failure, ChannelEntity>> updateChannel(String channelId, Map<String, dynamic> updates) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (!isConnected) {
        return Left(NetworkFailure('No internet connection available for updating channel'));
      }

      // Update channel via remote source
      final result = await remoteDataSource.updateChannel(channelId, updates);

      return result.fold(
        (failure) => Left(failure),
        (channel) async {
          // Clear cached data since it's now outdated
          await localDataSource.clearCachedChannelContents(channelId);
          await localDataSource.clearCachedChannelStructure(channel.verseId);
          print('Channel updated and cache cleared');
          return Right(channel);
        },
      );
    } catch (e) {
      print('Error updating channel: $e');
      return Left(NetworkFailure('Failed to update channel: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChannel(String channelId) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (!isConnected) {
        return Left(NetworkFailure('No internet connection available for deleting channel'));
      }

      // Delete channel via remote source
      final result = await remoteDataSource.deleteChannel(channelId);

      return result.fold(
        (failure) => Left(failure),
        (_) async {
          // Clear cached data since it's now outdated
          await localDataSource.clearCachedChannelContents(channelId);
          // Note: We can't clear structure cache here as we don't have verseId
          print('Channel deleted and cache cleared');
          return const Right(null);
        },
      );
    } catch (e) {
      print('Error deleting channel: $e');
      return Left(NetworkFailure('Failed to delete channel: $e'));
    }
  }

  /// Force refresh channel structure from remote source
  Future<Either<Failure, ChannelStructureResponse>> refreshChannelStructure(String verseId) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (!isConnected) {
        return Left(NetworkFailure('No internet connection available'));
      }

      // Get fresh data from remote source
      final remoteResult = await remoteDataSource.getVerseChannelStructure(verseId);
      
      return remoteResult.fold(
        (failure) => Left(failure),
        (channelStructure) async {
          // Cache the fresh data
          await localDataSource.cacheChannelStructure(verseId, channelStructure);
          print('Channel structure refreshed from remote and cached');
          return Right(channelStructure);
        },
      );
    } catch (e) {
      print('Error refreshing channel structure: $e');
      return Left(NetworkFailure('Failed to refresh channel structure: $e'));
    }
  }

  /// Force refresh channel contents from remote source
  Future<Either<Failure, ChannelEntity>> refreshChannelContents(String channelId) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (!isConnected) {
        return Left(NetworkFailure('No internet connection available'));
      }

      // Get fresh data from remote source
      final remoteResult = await remoteDataSource.getChannelContents(channelId);
      
      return remoteResult.fold(
        (failure) => Left(failure),
        (channelContents) async {
          // Cache the fresh data
          await localDataSource.cacheChannelContents(channelId, channelContents);
          print('Channel contents refreshed from remote and cached');
          return Right(channelContents);
        },
      );
    } catch (e) {
      print('Error refreshing channel contents: $e');
      return Left(NetworkFailure('Failed to refresh channel contents: $e'));
    }
  }

  /// Clear cached channel data
  Future<void> clearCachedData(String verseId, {String? channelId}) async {
    await localDataSource.clearCachedChannelStructure(verseId);
    if (channelId != null) {
      await localDataSource.clearCachedChannelContents(channelId);
    }
  }

  /// Check if cached data is available
  Future<bool> hasCachedChannelStructure(String verseId) async {
    return await localDataSource.hasValidCachedChannelStructure(verseId);
  }

  /// Check if cached channel contents are available
  Future<bool> hasCachedChannelContents(String channelId) async {
    return await localDataSource.hasValidCachedChannelContents(channelId);
  }
}
