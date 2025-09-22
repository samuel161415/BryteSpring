import 'package:dartz/dartz.dart';
import 'package:mobile/features/invite-user/data/datasourse/invite_user_datasourse.dart';
import 'package:mobile/features/invite-user/data/model/invitation_user_model.dart';
import 'package:mobile/features/invite-user/domain/model/invitation_model.dart';
import 'package:mobile/features/invite-user/domain/model/invite_user_role.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repostory/invitation_repo.dart';

class InvitationUserRepositoryImpl implements InvitationUserRepository {
  final InviteUserDatasourse remoteDataSource;

  InvitationUserRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, String>> createUser(InvitationUser user) async {
    try {
      final userModel = InvitationUserModel(
        verseId: user.verseId,
        email: user.email,
        position: user.position,
        roleId: user.roleId,
        firstName: user.firstName,
        lastName: user.lastName,
        subdomain: user.subdomain,
      );
      final result = await remoteDataSource.createUser(userModel);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InviteUserRole>>> getVerseRole(
    String verseId,
  ) async {
    try {
      final userModel = await remoteDataSource.getRoleForVerse(verseId);
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
