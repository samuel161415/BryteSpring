import 'package:dartz/dartz.dart';
import 'package:mobile/features/invite-user/domain/model/invitation_model.dart';
import 'package:mobile/features/invite-user/domain/model/invite_user_role.dart';
import 'package:mobile/features/invite-user/domain/repostory/invitation_repo.dart';
import '../../../../core/error/failure.dart';

class GetVerseRole {
  final InvitationUserRepository repository;

  GetVerseRole(this.repository);

  Future<Either<Failure, List<InviteUserRole>>> call(String verseId) {
    return repository.getVerseRole(verseId);
  }
}
