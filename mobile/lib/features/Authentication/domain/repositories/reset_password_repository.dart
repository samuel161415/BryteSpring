import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/Authentication/domain/entities/reset_password_entity.dart';

abstract class ResetPasswordRepository {
  Future<Either<Failure, ResetPasswordResponse>> resetPassword(
    ResetPasswordRequest request,
  );
  Future<Either<Failure, ResetPasswordResponse>> forgotPassword(String email);
}
