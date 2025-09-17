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
  
  /// Force refresh channel structure from remote source
  Future<Either<Failure, ChannelStructureResponse>> refreshChannelStructure(String verseId);
  
  /// Force refresh channel contents from remote source
  Future<Either<Failure, ChannelEntity>> refreshChannelContents(String channelId);
  
  /// Clear cached channel data
  Future<void> clearCachedData(String verseId, {String? channelId});
  
  /// Check if cached channel structure is available
  Future<bool> hasCachedChannelStructure(String verseId);
  
  /// Check if cached channel contents are available
  Future<bool> hasCachedChannelContents(String channelId);
}
