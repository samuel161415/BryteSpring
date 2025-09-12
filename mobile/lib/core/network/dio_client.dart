import 'package:dio/dio.dart';
import 'package:mobile/core/network/interceptors.dart';

class DioClient {
  final Dio dio;

  DioClient({required this.dio}) {
    // Add interceptors
    dio.interceptors.addAll([LoggingInterceptor(), AuthInterceptor(dio: dio)]);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return dio.post(path, data: data);
  }
}
