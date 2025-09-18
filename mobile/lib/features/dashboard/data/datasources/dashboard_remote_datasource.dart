import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/core/network/error_extractor.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_entity.dart';

abstract class DashboardRemoteDataSource {
  Future<Either<Failure, DashboardEntity>> getDashboardData(String verseId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient dioClient;

  DashboardRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Either<Failure, DashboardEntity>> getDashboardData(String verseId) async {
    try {
      final response = await dioClient.get('/dashboard/$verseId');
      
      if (response.statusCode == 200) {
        final dashboardEntity = DashboardEntity.fromJson(response.data);
        return Right(dashboardEntity);
      } else {
        return Left(ServerFailure('Failed to load dashboard data: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(ErrorExtractor.extractServerMessage(e)));
    } catch (e) {
      return Left(ServerFailure('Error loading dashboard data: $e'));
    }
  }
}
