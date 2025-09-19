import 'package:dartz/dartz.dart';
import 'package:mobile/features/invite-user/domain/model/invitation_model.dart';
import '../../../../core/error/failure.dart';

abstract class InvitationRepository {
  Future<Either<Failure, String>> createUser(InvitationUser user);
}
