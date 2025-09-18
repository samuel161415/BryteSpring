import 'package:dio/dio.dart';
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
    final token = await tokenService.getToken();
    if (token == null || token.isEmpty) {
      throw const ServerException("Authentication token missing");
    }

    final response = await dio.post(
      'https://bryte-spring.vercel.app/verse/complete-setup',
      data: verse.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 201) {
      return VerseModel.fromJson(response.data);
    } else {
      throw ServerException("unknown error");
    }
  }
}
