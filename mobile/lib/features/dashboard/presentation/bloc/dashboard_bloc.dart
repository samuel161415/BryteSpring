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

  const DashboardLoaded(this.dashboardData);

  @override
  List<Object> get props => [dashboardData];
}

class DashboardFailure extends DashboardState {
  final String message;

  const DashboardFailure(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardData getDashboardData;

  DashboardBloc({required this.getDashboardData}) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final result = await getDashboardData(event.verseId);

    result.fold(
      (failure) => emit(DashboardFailure(_mapFailureToMessage(failure))),
      (dashboardData) => emit(DashboardLoaded(dashboardData)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error: ${failure.message}';
      case NetworkFailure:
        return 'Network error: ${failure.message}';
      default:
        return 'Unexpected error: ${failure.message}';
    }
  }
}
