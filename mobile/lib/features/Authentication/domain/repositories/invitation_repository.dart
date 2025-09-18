import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';

abstract class InvitationRepository {
  Future<Either<Failure, InvitationEntity>> getInvitationByToken(String token);
}
