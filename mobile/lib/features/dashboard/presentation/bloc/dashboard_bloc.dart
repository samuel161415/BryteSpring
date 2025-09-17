import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:mobile/features/dashboard/domain/usecases/get_dashboard_data.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  final String verseId;

  const LoadDashboardData(this.verseId);

  @override
  List<Object> get props => [verseId];
}

class RefreshDashboardData extends DashboardEvent {
  final String verseId;

  const RefreshDashboardData(this.verseId);

  @override
  List<Object> get props => [verseId];
}

class ClearDashboardCache extends DashboardEvent {
  final String verseId;

  const ClearDashboardCache(this.verseId);

  @override
  List<Object> get props => [verseId];
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardEntity dashboardData;
  final bool isFromCache;

  const DashboardLoaded(this.dashboardData, {this.isFromCache = false});

  @override
  List<Object> get props => [dashboardData, isFromCache];
}

class DashboardFailure extends DashboardState {
  final String message;
  final bool isOffline;

  const DashboardFailure(this.message, {this.isOffline = false});

  @override
  List<Object> get props => [message, isOffline];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardData getDashboardData;

  DashboardBloc({required this.getDashboardData}) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<ClearDashboardCache>(_onClearDashboardCache);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final result = await getDashboardData(event.verseId);

    result.fold(
      (failure) {
        final isOffline = failure is CacheFailure;
        emit(DashboardFailure(_mapFailureToMessage(failure), isOffline: isOffline));
      },
      (dashboardData) {
        // Check if data came from cache
        final isFromCache = _isDataFromCache(failure: null);
        emit(DashboardLoaded(dashboardData, isFromCache: isFromCache));
      },
    );
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final result = await getDashboardData.refresh(event.verseId);

    result.fold(
      (failure) => emit(DashboardFailure(_mapFailureToMessage(failure))),
      (dashboardData) => emit(DashboardLoaded(dashboardData, isFromCache: false)),
    );
  }

  Future<void> _onClearDashboardCache(
    ClearDashboardCache event,
    Emitter<DashboardState> emit,
  ) async {
    await getDashboardData.clearCache(event.verseId);
    // Optionally reload data after clearing cache
    add(LoadDashboardData(event.verseId));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error: ${failure.message}';
      case NetworkFailure:
        return 'Network error: ${failure.message}';
      case CacheFailure:
        return 'Offline mode: ${failure.message}';
      default:
        return 'Unexpected error: ${failure.message}';
    }
  }

  bool _isDataFromCache({Failure? failure}) {
    // This is a simplified check - in a real implementation,
    // you might want to track the data source more explicitly
    return failure is CacheFailure;
  }
}
