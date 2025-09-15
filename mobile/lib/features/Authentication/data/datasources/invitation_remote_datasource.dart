import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';

abstract class InvitationRemoteDataSource {
  Future<Either<Failure, InvitationEntity>> getInvitationByToken(String token);
}

class InvitationRemoteDataSourceImpl implements InvitationRemoteDataSource {
  final DioClient dioClient;

  InvitationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Either<Failure, InvitationEntity>> getInvitationByToken(
    String token,
  ) async {
    try {
      final response = await dioClient.get('/invitation/$token');

      if (response.statusCode == 200) {
        final responseData = response.data;
        final invitationData = responseData['invitation'];

        if (invitationData != null) {
          final invitation = InvitationEntity.fromJson(invitationData);
          return Right(invitation);
        } else {
          return Left(
            ServerFailure('Invalid response format: missing invitation data'),
          );
        }
      } else {
        return Left(
          ServerFailure('Get invitation failed: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(ServerFailure('Invitation not found'));
      } else if (e.type == DioExceptionType.connectionError) {
        return Left(
          ServerFailure(
            'Cannot connect to server. Please check if the backend server is running.',
          ),
        );
      }
      return Left(ServerFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
