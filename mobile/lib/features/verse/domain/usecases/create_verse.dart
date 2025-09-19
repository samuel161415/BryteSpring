import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/verse.dart';
import '../repositories/verse_repository.dart';

class CreateVerse implements UseCase<Verse, Verse> {
  final VerseRepository repository;

  CreateVerse(this.repository);

  @override
  Future<Either<Failure, Verse>> call(Verse verse) async {
    return await repository.createVerse(verse);
  }
}
