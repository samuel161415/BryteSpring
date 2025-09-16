import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/channels/data/datasources/channel_remote_datasource.dart';
import 'package:mobile/features/channels/domain/entities/channel_entity.dart';
import 'package:mobile/features/channels/domain/repositories/channel_repository.dart';

class ChannelRepositoryImpl implements ChannelRepository {
  final ChannelRemoteDataSource remoteDataSource;

  ChannelRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ChannelStructureResponse>> getVerseChannelStructure(String verseId) {
    return remoteDataSource.getVerseChannelStructure(verseId);
  }

  @override
  Future<Either<Failure, ChannelEntity>> getChannelContents(String channelId) {
    return remoteDataSource.getChannelContents(channelId);
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
  }) {
    return remoteDataSource.createChannel(
      verseId: verseId,
      name: name,
      parentChannelId: parentChannelId,
      type: type,
      assetTypes: assetTypes,
      isPublic: isPublic,
      description: description,
    );
  }

  @override
  Future<Either<Failure, ChannelEntity>> updateChannel(String channelId, Map<String, dynamic> updates) {
    return remoteDataSource.updateChannel(channelId, updates);
  }

  @override
  Future<Either<Failure, void>> deleteChannel(String channelId) {
    return remoteDataSource.deleteChannel(channelId);
  }
}
