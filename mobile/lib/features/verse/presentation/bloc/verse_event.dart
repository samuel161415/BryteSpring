import 'package:equatable/equatable.dart';

import '../../domain/entities/verse.dart';

abstract class VerseEvent extends Equatable {
  const VerseEvent();

  @override
  List<Object> get props => [];
}

class CreateVerseRequested extends VerseEvent {
  final Verse verse;

  const CreateVerseRequested(this.verse);

  @override
  List<Object> get props => [verse];
}
