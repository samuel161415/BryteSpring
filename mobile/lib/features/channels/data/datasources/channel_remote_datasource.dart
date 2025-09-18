import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/core/network/error_extractor.dart';
import 'package:mobile/features/channels/domain/entities/channel_entity.dart';

abstract class ChannelRemoteDataSource {
  Future<Either<Failure, ChannelStructureResponse>> getVerseChannelStructure(
    String verseId,
  );
  Future<Either<Failure, ChannelEntity>> getChannelContents(String channelId);
  Future<Either<Failure, ChannelEntity>> createChannel({
    required String verseId,
    required String name,
    String? parentChannelId,
    String type = 'folder',
    List<String> assetTypes = const [],
    bool? isPublic,
    String? description,
  });
  Future<Either<Failure, ChannelEntity>> updateChannel(
    String channelId,
    Map<String, dynamic> updates,
  );
  Future<Either<Failure, void>> deleteChannel(String channelId);
}

class ChannelRemoteDataSourceImpl implements ChannelRemoteDataSource {
  final DioClient dioClient;

  ChannelRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Either<Failure, ChannelStructureResponse>> getVerseChannelStructure(
    String verseId,
  ) async {
    try {
      print('🔍 Loading channel structure for verse: $verseId');
      print('🌐 Making request to: /channel/verse/$verseId/structure');

      final response = await dioClient.get('/channel/verse/$verseId/structure');

      if (response.statusCode == 200) {
        final channelStructure = ChannelStructureResponse.fromJson(
          response.data,
        );
        return Right(channelStructure);
      } else {
        return Left(
          ServerFailure(
            'Failed to get channel structure: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.type}');
      print('📊 Status Code: ${e.response?.statusCode}');
      print('📄 Response Data: ${e.response?.data}');
      print('🔗 Request URL: ${e.requestOptions.uri}');

      if (e.response?.statusCode == 403) {
        return Left(ServerFailure('You do not have access to this verse'));
      } else if (e.response?.statusCode == 404) {
        return Left(
          ServerFailure('Verse not found or endpoint does not exist'),
        );
      }
      return Left(ServerFailure(ErrorExtractor.extractServerMessage(e)));
    } catch (e) {
      print('💥 Unexpected error: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ChannelEntity>> getChannelContents(
    String channelId,
  ) async {
    try {
      final response = await dioClient.get('/channel/$channelId/contents');

      if (response.statusCode == 200) {
        final channel = ChannelEntity.fromJson(response.data['channel']);
        return Right(channel);
      } else {
        return Left(
          ServerFailure(
            'Failed to get channel contents: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return Left(ServerFailure('You do not have access to this verse'));
      } else if (e.response?.statusCode == 404) {
        return Left(ServerFailure('Channel not found'));
      }
      return Left(ServerFailure(ErrorExtractor.extractServerMessage(e)));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
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
      final data = {
        'verse_id': verseId,
        'name': name,
        'type': type,
        'asset_types': assetTypes,
        if (parentChannelId != null) 'parent_channel_id': parentChannelId,
        if (isPublic != null) 'is_public': isPublic,
        if (description != null) 'description': description,
      };

      final response = await dioClient.post('/channel/create', data: data);

      if (response.statusCode == 201) {
        final channel = ChannelEntity.fromJson(response.data['channel']);
        return Right(channel);
      } else {
        return Left(
          ServerFailure('Failed to create channel: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message =
            e.response?.data['message'] ?? 'Failed to create channel';
        return Left(ServerFailure(message));
      } else if (e.response?.statusCode == 403) {
        return Left(
          ServerFailure('Insufficient permissions to create channels'),
        );
      }
      return Left(ServerFailure(ErrorExtractor.extractServerMessage(e)));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ChannelEntity>> updateChannel(
    String channelId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await dioClient.put(
        '/channel/$channelId',
        data: updates,
      );

      if (response.statusCode == 200) {
        final channel = ChannelEntity.fromJson(response.data['channel']);
        return Right(channel);
      } else {
        return Left(
          ServerFailure('Failed to update channel: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message =
            e.response?.data['message'] ?? 'Failed to update channel';
        return Left(ServerFailure(message));
      } else if (e.response?.statusCode == 403) {
        return Left(
          ServerFailure('Insufficient permissions to update channels'),
        );
      } else if (e.response?.statusCode == 404) {
        return Left(ServerFailure('Channel not found'));
      }
      return Left(ServerFailure(ErrorExtractor.extractServerMessage(e)));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChannel(String channelId) async {
    try {
      final response = await dioClient.delete('/channel/$channelId');

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure('Failed to delete channel: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message =
            e.response?.data['message'] ?? 'Failed to delete channel';
        return Left(ServerFailure(message));
      } else if (e.response?.statusCode == 403) {
        return Left(
          ServerFailure('Insufficient permissions to delete channels'),
        );
      } else if (e.response?.statusCode == 404) {
        return Left(ServerFailure('Channel not found'));
      }
      return Left(ServerFailure(ErrorExtractor.extractServerMessage(e)));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
