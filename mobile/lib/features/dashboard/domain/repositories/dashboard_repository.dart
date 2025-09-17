import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardEntity>> getDashboardData(String verseId);
}
