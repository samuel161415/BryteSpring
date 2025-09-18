import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/Authentication/domain/entities/register_user_entity.dart';
import 'package:mobile/features/Authentication/domain/repositories/register_user_repository.dart';

class RegisterUserUseCase {
  final RegisterUserRepository repository;

  RegisterUserUseCase({required this.repository});

  Future<Either<Failure, RegisterUserResponse>> call(
    RegisterUserRequest request,
  ) async {
    return await repository.registerUser(request);
  }
}
