import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';
import 'package:mobile/features/verse_join/domain/entities/verse_join_entity.dart';
import 'package:mobile/features/verse_join/domain/usecases/verse_join_usecase.dart';

// Events
abstract class JoinVerseEvent extends Equatable {
  const JoinVerseEvent();

  @override
  List<Object?> get props => [];
}

class JoinVerse extends JoinVerseEvent {
  final String verseId;

  const JoinVerse(this.verseId);

  @override
  List<Object?> get props => [verseId];
}

// States
abstract class JoinVerseState extends Equatable {
  const JoinVerseState();

  @override
  List<Object?> get props => [];
}

class JoinVerseInitial extends JoinVerseState {}

class JoinVerseLoading extends JoinVerseState {}

class JoinVerseSuccess extends JoinVerseState {
  final VerseJoinEntity verse;

  const JoinVerseSuccess(this.verse);

  @override
  List<Object?> get props => [verse];
}

class JoinVerseFailure extends JoinVerseState {
  final String message;

  const JoinVerseFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class JoinVerseBloc extends Bloc<JoinVerseEvent, JoinVerseState> {
  final VerseJoinUseCase verseJoinUseCase;

  JoinVerseBloc({required this.verseJoinUseCase}) : super(JoinVerseInitial()) {
    on<JoinVerse>(_onJoinVerse);
  }

  Future<void> _onJoinVerse(
    JoinVerse event,
    Emitter<JoinVerseState> emit,
  ) async {
    emit(JoinVerseLoading());

    final result = await verseJoinUseCase.joinVerse(event.verseId);

    result.fold(
      (failure) => emit(JoinVerseFailure(_mapFailureToMessage(failure))),
      (verse) => emit(JoinVerseSuccess(verse)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
