import 'package:dartz/dartz.dart';
import 'package:mobile/features/invite-user/domain/model/invitation_model.dart';
import 'package:mobile/features/invite-user/domain/model/invite_user_role.dart';
import '../../../../core/error/failure.dart';

abstract class InvitationUserRepository {
  Future<Either<Failure, String>> createUser(InvitationUser user);
  Future<Either<Failure, List<InviteUserRole>>> getVerseRole(String verseId);
}
