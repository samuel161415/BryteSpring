import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/Authentication/domain/entities/user.dart';
import 'package:mobile/features/Authentication/domain/repositories/login_repository.dart';

class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase({required this.repository});

  Future<Either<Failure, User>> call(String email, String password) {
    return repository.login(email, password);
  }
}
