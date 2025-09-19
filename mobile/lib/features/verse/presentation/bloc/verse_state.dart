import 'package:equatable/equatable.dart';

import '../../domain/entities/verse.dart';

abstract class VerseState extends Equatable {
  const VerseState();

  @override
  List<Object> get props => [];
}

class VerseInitial extends VerseState {}

class VerseCreationLoading extends VerseState {}

class VerseCreationSuccess extends VerseState {
  final Verse verse;

  const VerseCreationSuccess(this.verse);

  @override
  List<Object> get props => [verse];
}

class VerseCreationFailure extends VerseState {
  final String message;

  const VerseCreationFailure(this.message);

  @override
  List<Object> get props => [message];
}
