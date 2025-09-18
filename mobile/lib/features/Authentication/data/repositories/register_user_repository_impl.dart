import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/Authentication/data/datasources/register_user_remote_datasource.dart';
import 'package:mobile/features/Authentication/domain/entities/register_user_entity.dart';
import 'package:mobile/features/Authentication/domain/repositories/register_user_repository.dart';

class RegisterUserRepositoryImpl implements RegisterUserRepository {
  final RegisterUserRemoteDataSource remoteDataSource;

  RegisterUserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, RegisterUserResponse>> registerUser(
    RegisterUserRequest request,
  ) async {
    return await remoteDataSource.registerUser(request);
  }
}
