import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/channels/domain/entities/channel_entity.dart';
import 'package:mobile/features/channels/domain/usecases/channel_usecase.dart';

// Events
abstract class ChannelEvent extends Equatable {
  const ChannelEvent();

  @override
  List<Object?> get props => [];
}

class LoadChannelStructure extends ChannelEvent {
  final String verseId;

  const LoadChannelStructure(this.verseId);

  @override
  List<Object?> get props => [verseId];
}

class LoadChannelContents extends ChannelEvent {
  final String channelId;

  const LoadChannelContents(this.channelId);

  @override
  List<Object?> get props => [channelId];
}

class RefreshChannelStructure extends ChannelEvent {
  final String verseId;

  const RefreshChannelStructure(this.verseId);

  @override
  List<Object?> get props => [verseId];
}

class RefreshChannelContents extends ChannelEvent {
  final String channelId;

  const RefreshChannelContents(this.channelId);

  @override
  List<Object?> get props => [channelId];
}

class ClearChannelCache extends ChannelEvent {
  final String verseId;
  final String? channelId;

  const ClearChannelCache(this.verseId, {this.channelId});

  @override
  List<Object?> get props => [verseId, channelId];
}

class CreateChannel extends ChannelEvent {
  final String verseId;
  final String name;
  final String? parentChannelId;
  final String type;
  final List<String> assetTypes;
  final bool? isPublic;
  final String? description;

  const CreateChannel({
    required this.verseId,
    required this.name,
    this.parentChannelId,
    this.type = 'folder',
    this.assetTypes = const [],
    this.isPublic,
    this.description,
  });

  @override
  List<Object?> get props => [
    verseId,
    name,
    parentChannelId,
    type,
    assetTypes,
    isPublic,
    description,
  ];
}

class UpdateChannel extends ChannelEvent {
  final String channelId;
  final Map<String, dynamic> updates;

  const UpdateChannel({required this.channelId, required this.updates});

  @override
  List<Object?> get props => [channelId, updates];
}

class DeleteChannel extends ChannelEvent {
  final String channelId;

  const DeleteChannel(this.channelId);

  @override
  List<Object?> get props => [channelId];
}

// States
abstract class ChannelState extends Equatable {
  const ChannelState();

  @override
  List<Object?> get props => [];
}

class ChannelInitial extends ChannelState {}

class ChannelLoading extends ChannelState {}

class ChannelStructureLoaded extends ChannelState {
  final ChannelStructureResponse structure;
  final bool isFromCache;

  const ChannelStructureLoaded(this.structure, {this.isFromCache = false});

  @override
  List<Object?> get props => [structure, isFromCache];
}

class ChannelContentsLoaded extends ChannelState {
  final ChannelEntity channel;
  final bool isFromCache;

  const ChannelContentsLoaded(this.channel, {this.isFromCache = false});

  @override
  List<Object?> get props => [channel, isFromCache];
}

class ChannelCreated extends ChannelState {
  final ChannelEntity channel;

  const ChannelCreated(this.channel);

  @override
  List<Object?> get props => [channel];
}

class ChannelUpdated extends ChannelState {
  final ChannelEntity channel;

  const ChannelUpdated(this.channel);

  @override
  List<Object?> get props => [channel];
}

class ChannelDeleted extends ChannelState {}

class ChannelFailure extends ChannelState {
  final String message;
  final bool isOffline;

  const ChannelFailure(this.message, {this.isOffline = false});

  @override
  List<Object?> get props => [message, isOffline];
}

// BLoC
class ChannelBloc extends Bloc<ChannelEvent, ChannelState> {
  final ChannelUseCase channelUseCase;

  ChannelBloc({required this.channelUseCase}) : super(ChannelInitial()) {
    on<LoadChannelStructure>(_onLoadChannelStructure);
    on<LoadChannelContents>(_onLoadChannelContents);
    on<RefreshChannelStructure>(_onRefreshChannelStructure);
    on<RefreshChannelContents>(_onRefreshChannelContents);
    on<ClearChannelCache>(_onClearChannelCache);
    on<CreateChannel>(_onCreateChannel);
    on<UpdateChannel>(_onUpdateChannel);
    on<DeleteChannel>(_onDeleteChannel);
  }

  Future<void> _onLoadChannelStructure(
    LoadChannelStructure event,
    Emitter<ChannelState> emit,
  ) async {
    // Validate verseId
    if (event.verseId.isEmpty) {
      emit(const ChannelFailure('Verse ID cannot be empty'));
      return;
    }

    emit(ChannelLoading());

    final result = await channelUseCase.getVerseChannelStructure(event.verseId);

    result.fold(
      (failure) {
        final isOffline = failure is CacheFailure;
        emit(ChannelFailure(_mapFailureToMessage(failure), isOffline: isOffline));
      },
      (structure) {
        // Check if data came from cache
        final isFromCache = _isDataFromCache(failure: null);
        emit(ChannelStructureLoaded(structure, isFromCache: isFromCache));
      },
    );
  }

  Future<void> _onLoadChannelContents(
    LoadChannelContents event,
    Emitter<ChannelState> emit,
  ) async {
    emit(ChannelLoading());

    final result = await channelUseCase.getChannelContents(event.channelId);

    result.fold(
      (failure) {
        final isOffline = failure is CacheFailure;
        emit(ChannelFailure(_mapFailureToMessage(failure), isOffline: isOffline));
      },
      (channel) {
        // Check if data came from cache
        final isFromCache = _isDataFromCache(failure: null);
        emit(ChannelContentsLoaded(channel, isFromCache: isFromCache));
      },
    );
  }

  Future<void> _onRefreshChannelStructure(
    RefreshChannelStructure event,
    Emitter<ChannelState> emit,
  ) async {
    emit(ChannelLoading());

    final result = await channelUseCase.refreshChannelStructure(event.verseId);

    result.fold(
      (failure) => emit(ChannelFailure(_mapFailureToMessage(failure))),
      (structure) => emit(ChannelStructureLoaded(structure, isFromCache: false)),
    );
  }

  Future<void> _onRefreshChannelContents(
    RefreshChannelContents event,
    Emitter<ChannelState> emit,
  ) async {
    emit(ChannelLoading());

    final result = await channelUseCase.refreshChannelContents(event.channelId);

    result.fold(
      (failure) => emit(ChannelFailure(_mapFailureToMessage(failure))),
      (channel) => emit(ChannelContentsLoaded(channel, isFromCache: false)),
    );
  }

  Future<void> _onClearChannelCache(
    ClearChannelCache event,
    Emitter<ChannelState> emit,
  ) async {
    await channelUseCase.clearCachedData(event.verseId, channelId: event.channelId);
    // Optionally reload data after clearing cache
    if (event.channelId != null) {
      add(LoadChannelContents(event.channelId!));
    } else {
      add(LoadChannelStructure(event.verseId));
    }
  }

  Future<void> _onCreateChannel(
    CreateChannel event,
    Emitter<ChannelState> emit,
  ) async {
    emit(ChannelLoading());

    final result = await channelUseCase.createChannel(
      verseId: event.verseId,
      name: event.name,
      parentChannelId: event.parentChannelId,
      type: event.type,
      assetTypes: event.assetTypes,
      isPublic: event.isPublic,
      description: event.description,
    );

    result.fold(
      (failure) => emit(ChannelFailure(_mapFailureToMessage(failure))),
      (channel) => emit(ChannelCreated(channel)),
    );
  }

  Future<void> _onUpdateChannel(
    UpdateChannel event,
    Emitter<ChannelState> emit,
  ) async {
    emit(ChannelLoading());

    final result = await channelUseCase.updateChannel(
      event.channelId,
      event.updates,
    );

    result.fold(
      (failure) => emit(ChannelFailure(_mapFailureToMessage(failure))),
      (channel) => emit(ChannelUpdated(channel)),
    );
  }

  Future<void> _onDeleteChannel(
    DeleteChannel event,
    Emitter<ChannelState> emit,
  ) async {
    emit(ChannelLoading());

    final result = await channelUseCase.deleteChannel(event.channelId);

    result.fold(
      (failure) => emit(ChannelFailure(_mapFailureToMessage(failure))),
      (_) => emit(ChannelDeleted()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      case CacheFailure:
        return 'Offline mode: ${failure.message}';
      default:
        return 'An unexpected error occurred.';
    }
  }

  bool _isDataFromCache({Failure? failure}) {
    // This is a simplified check - in a real implementation,
    // you might want to track the data source more explicitly
    return failure is CacheFailure;
  }
}
