import 'package:dartz/dartz.dart';
import 'package:connectivity/connectivity.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:mobile/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:mobile/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final DashboardLocalDataSource localDataSource;
  final Connectivity connectivity;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, DashboardEntity>> getDashboardData(String verseId) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        // Try to get data from remote source
        final remoteResult = await remoteDataSource.getDashboardData(verseId);
        
        return remoteResult.fold(
          (failure) async {
            // If remote fails, try to get cached data
            print('Remote dashboard data failed, trying cached data: ${failure.message}');
            return await _getCachedData(verseId);
          },
          (dashboardData) async {
            // Cache the successful remote data
            await localDataSource.cacheDashboardData(verseId, dashboardData);
            print('Dashboard data loaded from remote and cached');
            return Right(dashboardData);
          },
        );
      } else {
        // No internet connection, try to get cached data
        print('No internet connection, trying cached dashboard data');
        return await _getCachedData(verseId);
      }
    } catch (e) {
      print('Error in getDashboardData: $e');
      // Try to get cached data as fallback
      return await _getCachedData(verseId);
    }
  }

  Future<Either<Failure, DashboardEntity>> _getCachedData(String verseId) async {
    try {
      final cachedData = await localDataSource.getCachedDashboardData(verseId);
      
      if (cachedData != null) {
        print('Dashboard data loaded from cache');
        return Right(cachedData);
      } else {
        print('No cached dashboard data available');
        return Left(CacheFailure('No cached dashboard data available'));
      }
    } catch (e) {
      print('Error getting cached dashboard data: $e');
      return Left(CacheFailure('Failed to load cached dashboard data: $e'));
    }
  }

  /// Force refresh dashboard data from remote source
  Future<Either<Failure, DashboardEntity>> refreshDashboardData(String verseId) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (!isConnected) {
        return Left(NetworkFailure('No internet connection available'));
      }

      // Get fresh data from remote source
      final remoteResult = await remoteDataSource.getDashboardData(verseId);
      
      return remoteResult.fold(
        (failure) => Left(failure),
        (dashboardData) async {
          // Cache the fresh data
          await localDataSource.cacheDashboardData(verseId, dashboardData);
          print('Dashboard data refreshed from remote and cached');
          return Right(dashboardData);
        },
      );
    } catch (e) {
      print('Error refreshing dashboard data: $e');
      return Left(NetworkFailure('Failed to refresh dashboard data: $e'));
    }
  }

  /// Clear cached dashboard data
  Future<void> clearCachedData(String verseId) async {
    await localDataSource.clearCachedDashboardData(verseId);
  }

  /// Check if cached data is available
  Future<bool> hasCachedData(String verseId) async {
    return await localDataSource.hasValidCachedData(verseId);
  }
}
