import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mobile/core/storage/secure_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/token_service.dart';

abstract class UploadRemoteDataSource {
  Future<String> uploadImage(File image, String verseId, String folderPath);
}

class UploadRemoteDataSourceImpl implements UploadRemoteDataSource {
  final Dio dio;
  final TokenService tokenService;

  UploadRemoteDataSourceImpl({required this.dio, required this.tokenService});

  @override
  Future<String> uploadImage(
    File image,
    String verseId,
    String folderPath,
  ) async {
    final token = await SecureStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const ServerException("Authentication token missing");
    }

    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
      "verse_id": verseId,
      "folder_path": folderPath,
    });

    try {
      final response = await dio.post(
        "https://brightcore-iugy8.ondigitalocean.app/upload/single",
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        return response
            .data['file']['url']; // Assuming response contains image URL
      } else {
        throw ServerException(
          "Upload failed with status ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      throw ServerException("Upload failed: ${e.message}");
    }
  }
}
