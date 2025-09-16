import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/channels/domain/entities/channel_entity.dart';

abstract class ChannelRepository {
  Future<Either<Failure, ChannelStructureResponse>> getVerseChannelStructure(String verseId);
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
  Future<Either<Failure, ChannelEntity>> updateChannel(String channelId, Map<String, dynamic> updates);
  Future<Either<Failure, void>> deleteChannel(String channelId);
}
