import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';
import 'package:mobile/features/Authentication/domain/repositories/invitation_repository.dart';

class InvitationUseCase {
  final InvitationRepository repository;

  InvitationUseCase(this.repository);

  Future<Either<Failure, InvitationEntity>> getInvitationByToken(
    String token,
  ) {
    return repository.getInvitationByToken(token);
  }
}
