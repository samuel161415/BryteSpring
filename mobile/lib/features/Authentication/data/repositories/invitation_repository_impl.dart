import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/Authentication/data/datasources/invitation_remote_datasource.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';
import 'package:mobile/features/Authentication/domain/repositories/invitation_repository.dart';

class InvitationRepositoryImpl implements InvitationRepository {
  final InvitationRemoteDataSource remoteDataSource;

  InvitationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, InvitationEntity>> getInvitationByToken(
    String token,
  ) async {
    return await remoteDataSource.getInvitationByToken(token);
  }
}
