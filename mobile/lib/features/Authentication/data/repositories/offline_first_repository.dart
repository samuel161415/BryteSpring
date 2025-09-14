import 'package:connectivity/connectivity.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/core/storage/local_storage.dart';
import 'package:mobile/features/Authentication/domain/entities/user.dart';
import 'package:mobile/features/Authentication/domain/repositories/login_repository.dart';

class OfflineFirstRepository implements LoginRepository {
  final DioClient dioClient;
  final LocalStorage localStorage;
  final Connectivity connectivity;

  OfflineFirstRepository({
    required this.dioClient,
    required this.localStorage,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      // Check connectivity first
      final connectivityResult = await connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Try online first
        try {
          final response = await dioClient.post(
            '/auth/login',
            data: {'email': email, 'password': password},
          );

          if (response.statusCode == 200) {
            final user = User.fromJson(response.data);

            // Cache user data locally for offline access
            await localStorage.cacheUserData(user);

            return Right(user);
          } else {
            return Left(ServerFailure('Login failed: ${response.statusCode}'));
          }
        } on DioException catch (e) {
          if (kDebugMode) {
            print('Online login failed, trying offline: ${e.message}');
          }
          // Fall through to offline attempt
        }
      }

      // Try offline/cached data
      final cachedUser = await localStorage.getCachedUserData();
      if (cachedUser != null) {
        if (kDebugMode) {
          print('Using cached user data for offline login');
        }
        return Right(cachedUser);
      }

      return Left(
        NetworkFailure('No internet connection and no cached data available'),
      );
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        try {
          await dioClient.post('/auth/logout');
        } catch (e) {
          if (kDebugMode) {
            print('Online logout failed: $e');
          }
        }
      }

      // Always clear local data
      await localStorage.clearUserData();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Logout error: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        try {
          // Try to get fresh user data
          final response = await dioClient.get('/auth/me');
          if (response.statusCode == 200) {
            final user = User.fromJson(response.data);
            await localStorage.cacheUserData(user);
            return Right(user);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Failed to get fresh user data: $e');
          }
        }
      }

      // Fall back to cached data
      final cachedUser = await localStorage.getCachedUserData();
      return Right(cachedUser);
    } catch (e) {
      return Left(ServerFailure('Get user error: $e'));
    }
  }
}
