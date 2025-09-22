import 'package:dio/dio.dart';
import 'package:mobile/core/storage/secure_storage.dart';
import 'package:mobile/features/invite-user/data/model/invitation_user_model.dart';
import 'package:mobile/features/invite-user/data/model/invite_user_role_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class InviteUserDatasourse {
  Future<String> createUser(InvitationUserModel user);
  Future<List<InviteUserRoleModel>> getRoleForVerse(String verseId);
}

class InviteUserDatasourseImpl implements InviteUserDatasourse {
  final Dio dio;

  InviteUserDatasourseImpl({required this.dio});

  @override
  Future<String> createUser(InvitationUserModel user) async {
    try {
      final token = await SecureStorage.getRefreshToken();
      if (token == null || token.isEmpty) {
        throw const ServerException("Authentication token missing");
      }

      final response = await dio.post(
        "https://brightcore-iugy8.ondigitalocean.app/invitation",
        data: user.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data['message']; // Adjust per API response
      } else {
        throw ServerException("Failed to create user");
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? "Unknown error");
    }
  }

  @override
  Future<List<InviteUserRoleModel>> getRoleForVerse(String verseId) async {
    try {
      final token = await SecureStorage.getRefreshToken();
      if (token == null || token.isEmpty) {
        throw const ServerException("Authentication token missing");
      }
      final response = await dio.get(
        "https://brightcore-iugy8.ondigitalocean.app/role/verse/${verseId}",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',

            "Content-Type": "application/json",
          },
        ),
      );
      // final response = await dio.post(
      //   "'https://brightcore-iugy8.ondigitalocean.app/invitation",
      //   data: user.toJson(),
      //   options: Options(headers: {"Content-Type": "application/json"}),
      // );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data['roles'] as List;
        return data.map((e) => InviteUserRoleModel.fromJson(e)).toList();
      } else {
        throw ServerException("Failed to create user");
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? "Unknown error");
    }
  }
}
