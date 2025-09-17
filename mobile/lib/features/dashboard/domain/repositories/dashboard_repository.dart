import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardEntity>> getDashboardData(String verseId);

  /// Force refresh dashboard data from remote source
  Future<Either<Failure, DashboardEntity>> refreshDashboardData(String verseId);

  /// Clear cached dashboard data
  Future<void> clearCachedData(String verseId);

  /// Check if cached data is available
  Future<bool> hasCachedData(String verseId);
}
