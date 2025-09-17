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
}
