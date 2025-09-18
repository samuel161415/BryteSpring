import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/channels/domain/entities/channel_entity.dart';
import 'package:mobile/features/channels/domain/repositories/channel_repository.dart';

class ChannelUseCase {
  final ChannelRepository repository;

  ChannelUseCase({required this.repository});

  Future<Either<Failure, ChannelStructureResponse>> getVerseChannelStructure(String verseId) {
    return repository.getVerseChannelStructure(verseId);
  }

  Future<Either<Failure, ChannelEntity>> getChannelContents(String channelId) {
    return repository.getChannelContents(channelId);
  }

  Future<Either<Failure, ChannelEntity>> createChannel({
    required String verseId,
    required String name,
    String? parentChannelId,
    String type = 'folder',
    List<String> assetTypes = const [],
    bool? isPublic,
    String? description,
  }) {
    return repository.createChannel(
      verseId: verseId,
      name: name,
      parentChannelId: parentChannelId,
      type: type,
      assetTypes: assetTypes,
      isPublic: isPublic,
      description: description,
    );
  }

  Future<Either<Failure, ChannelEntity>> updateChannel(String channelId, Map<String, dynamic> updates) {
    return repository.updateChannel(channelId, updates);
  }

  Future<Either<Failure, void>> deleteChannel(String channelId) {
    return repository.deleteChannel(channelId);
  }

  /// Force refresh channel structure from remote source
  Future<Either<Failure, ChannelStructureResponse>> refreshChannelStructure(String verseId) {
    return repository.refreshChannelStructure(verseId);
  }

  /// Force refresh channel contents from remote source
  Future<Either<Failure, ChannelEntity>> refreshChannelContents(String channelId) {
    return repository.refreshChannelContents(channelId);
  }

  /// Clear cached channel data
  Future<void> clearCachedData(String verseId, {String? channelId}) {
    return repository.clearCachedData(verseId, channelId: channelId);
  }

  /// Check if cached channel structure is available
  Future<bool> hasCachedChannelStructure(String verseId) {
    return repository.hasCachedChannelStructure(verseId);
  }

  /// Check if cached channel contents are available
  Future<bool> hasCachedChannelContents(String channelId) {
    return repository.hasCachedChannelContents(channelId);
  }
}
