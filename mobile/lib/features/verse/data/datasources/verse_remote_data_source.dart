import 'package:dio/dio.dart';
import 'package:mobile/core/storage/secure_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../models/verse_model.dart';
import '../../../../core/services/token_service.dart';

abstract class VerseRemoteDataSource {
  /// Calls the https://your-api.com/verses endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<VerseModel> createVerse(VerseModel verse);
}

class VerseRemoteDataSourceImpl implements VerseRemoteDataSource {
  final Dio dio;
  final TokenService tokenService;

  VerseRemoteDataSourceImpl({required this.dio, required this.tokenService});

  @override
  Future<VerseModel> createVerse(VerseModel verse) async {
    try {
      final token = await tokenService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw const ServerException("Authentication token missing");
      }
      verse.logo = "https://example.com/logo.png";

      final body = verse.toJson();
      print("=== Verse JSON Payload==");
      print(verse.toJson());

      final response = await dio.post(
        'https://brightcore-iugy8.ondigitalocean.app/verse/complete-setup',
        data: body,
        // {
        //   "verse_id": verse.verseId,
        //   "name": "tempo Verse",
        //   "subdomain": "bnw",
        //   "email": "samuelnegalign1er@gmail.com",
        //   "organization_name": "BNW Corporation",
        //   "branding": {
        //     "logo_url": "https://example.com/logo.png",
        //     "primary_color": "#3B82F6",
        //     "color_name": "Primary Blue",
        //   },
        //   "initial_channels": [
        //     {
        //       "name": "general",
        //       "type": "channel",
        //       "description": "General discussion channel",
        //     },
        //     {
        //       "name": "announcements",
        //       "type": "channel",
        //       "description": "Important announcements",
        //     },
        //   ],
        //   "is_neutral_view": false,
        // },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return VerseModel.fromJson(response.data);
      } else {
        throw ServerException("unknown error");
      }
    } on DioException catch (e) {
      print("=== ERROR RESPONSE ===");
      print("Status code: ${e.response?.statusCode}");
      print("Data: ${e.response?.data}");
      throw ServerException("Upload failed: ${e.message}");
    }
  }
}
