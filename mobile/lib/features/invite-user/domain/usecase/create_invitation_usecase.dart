import 'package:dartz/dartz.dart';
import 'package:mobile/features/invite-user/domain/model/invitation_model.dart';
import 'package:mobile/features/invite-user/domain/repostory/invitation_repo.dart';
import '../../../../core/error/failure.dart';

class CreateUser {
  final InvitationRepository repository;

  CreateUser(this.repository);

  Future<Either<Failure, String>> call(InvitationUser user) {
    return repository.createUser(user);
  }
}
