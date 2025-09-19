// presentation/bloc/upload_event.dart
import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class UploadEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UploadImageEvent extends UploadEvent {
  final File image;
  final String verseId;
  final String folderPath;

  UploadImageEvent(this.image, this.verseId, this.folderPath);

  @override
  List<Object?> get props => [image, verseId, folderPath];
}
