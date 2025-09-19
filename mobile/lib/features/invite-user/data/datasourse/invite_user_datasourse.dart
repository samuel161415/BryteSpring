import 'package:dio/dio.dart';
import 'package:mobile/features/invite-user/data/model/invitation_user_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class InviteUserDatasourse {
  Future<String> createUser(InvitationUserModel user);
}

class InviteUserDatasourseImpl implements InviteUserDatasourse {
  final Dio dio;

  InviteUserDatasourseImpl({required this.dio});

  @override
  Future<String> createUser(InvitationUserModel user) async {
    try {
      final response = await dio.post(
        "https://your-api-url.com/users",
        data: user.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 201) {
        return response.data['message']; // Adjust per API response
      } else {
        throw ServerException("Failed to create user");
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? "Unknown error");
    }
  }
}
