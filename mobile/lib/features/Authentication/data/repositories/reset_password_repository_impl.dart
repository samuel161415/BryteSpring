import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/Authentication/data/datasources/reset_password_remote_datasource.dart';
import 'package:mobile/features/Authentication/domain/entities/reset_password_entity.dart';
import 'package:mobile/features/Authentication/domain/repositories/reset_password_repository.dart';

class ResetPasswordRepositoryImpl implements ResetPasswordRepository {
  final ResetPasswordRemoteDataSource remoteDataSource;

  ResetPasswordRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ResetPasswordResponse>> resetPassword(ResetPasswordRequest request) async {
    return await remoteDataSource.resetPassword(request);
  }

  @override
  Future<Either<Failure, ResetPasswordResponse>> forgotPassword(String email) async {
    return await remoteDataSource.forgotPassword(email);
  }
}
