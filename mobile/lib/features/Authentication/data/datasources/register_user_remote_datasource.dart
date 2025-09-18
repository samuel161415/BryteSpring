import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/core/network/error_extractor.dart';
import 'package:mobile/features/Authentication/domain/entities/register_user_entity.dart';

abstract class RegisterUserRemoteDataSource {
  Future<Either<Failure, RegisterUserResponse>> registerUser(
    RegisterUserRequest request,
  );
}

class RegisterUserRemoteDataSourceImpl implements RegisterUserRemoteDataSource {
  final DioClient dioClient;

  RegisterUserRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Either<Failure, RegisterUserResponse>> registerUser(
    RegisterUserRequest request,
  ) async {
    try {
      final response = await dioClient.post(
        '/register',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        final registerResponse = RegisterUserResponse.fromJson(response.data);
        return Right(registerResponse);
      } else {
        return Left(
          ServerFailure('Registration failed: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure(ErrorExtractor.extractServerMessage(e)));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
