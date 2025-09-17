import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:mobile/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardData {
  final DashboardRepository repository;

  GetDashboardData(this.repository);

  Future<Either<Failure, DashboardEntity>> call(String verseId) async {
    return await repository.getDashboardData(verseId);
  }

  /// Force refresh dashboard data from remote source
  Future<Either<Failure, DashboardEntity>> refresh(String verseId) async {
    return await repository.refreshDashboardData(verseId);
  }

  /// Clear cached dashboard data
  Future<void> clearCache(String verseId) async {
    await repository.clearCachedData(verseId);
  }

  /// Check if cached data is available
  Future<bool> hasCachedData(String verseId) async {
    return await repository.hasCachedData(verseId);
  }
}
