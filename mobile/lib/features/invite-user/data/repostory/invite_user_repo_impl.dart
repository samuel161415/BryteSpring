import 'package:dartz/dartz.dart';
import 'package:mobile/features/invite-user/data/datasourse/invite_user_datasourse.dart';
import 'package:mobile/features/invite-user/data/model/invitation_user_model.dart';
import 'package:mobile/features/invite-user/domain/model/invitation_model.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repostory/invitation_repo.dart';

class InvitationRepositoryImpl implements InvitationRepository {
  final InviteUserDatasourse remoteDataSource;

  InvitationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, String>> createUser(InvitationUser user) async {
    try {
      final userModel = InvitationUserModel(
        email: user.email,
        position: user.position,
        role: user.role,
      );
      final result = await remoteDataSource.createUser(userModel);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
