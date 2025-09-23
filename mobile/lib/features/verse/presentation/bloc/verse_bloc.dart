import 'package:bloc/bloc.dart';
import 'verse_event.dart';
import 'verse_state.dart';
import '../../domain/usecases/create_verse.dart';

class VerseBloc extends Bloc<VerseEvent, VerseState> {
  final CreateVerse createVerse;

  VerseBloc({required this.createVerse}) : super(VerseInitial()) {
    on<CreateVerseRequested>(_onCreateVerseRequested);
  }

  Future<void> _onCreateVerseRequested(
    CreateVerseRequested event,
    Emitter<VerseState> emit,
  ) async {
    emit(VerseCreationLoading());
    final result = await createVerse(event.verse);
    result.fold(
      (failure) => emit(
        VerseCreationFailure(failure.message),
      ), // You can map failures to specific messages
      (verse) => emit(VerseCreationSuccess(verse)),
    );
  }
}
