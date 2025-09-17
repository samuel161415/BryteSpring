import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:mobile/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DashboardEntity>> getDashboardData(String verseId) async {
    return await remoteDataSource.getDashboardData(verseId);
  }
}
