import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/verse.dart';

abstract class VerseRepository {
  Future<Either<Failure, Verse>> createVerse(Verse verse);
}
