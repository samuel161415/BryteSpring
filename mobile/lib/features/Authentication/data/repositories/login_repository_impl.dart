import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/storage/secure_storage.dart';
import 'package:mobile/features/Authentication/domain/entities/user.dart';
import 'package:mobile/features/Authentication/domain/repositories/login_repository.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRepositoryImpl implements LoginRepository {
  final DioClient dioClient;
  final SharedPreferences prefs;

  LoginRepositoryImpl({required this.dioClient, required this.prefs});

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      // Make API call to login endpoint
      final response = await dioClient.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        await prefs.setString('user_data', user.toJsonString());

        // Save tokens to secure storage
        await SecureStorage.saveTokens(
          user.token, // Assuming token field contains access token
          user.refreshToken, // Assuming refreshToken field contains refresh token
        );

        return Right(user);
      } else {
        return Left(ServerFailure('Login failed: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure('Dio error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Make API call to logout endpoint
      final response = await dioClient.post('/logout');

      if (response.statusCode == 200) {
        // Clear user data from local storage on logout
        await prefs.remove('user_data');
        return const Right(null);
      } else {
        return Left(ServerFailure('Logout failed: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure('Dio error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
