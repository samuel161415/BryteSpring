import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';

abstract class UploadRepository {
  Future<Either<Failure, String>> uploadImage(
    File image,
    String verseId,
    String folderPath,
  );
}
