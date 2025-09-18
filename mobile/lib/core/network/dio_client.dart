import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/network/interceptors.dart';
import 'package:mobile/core/network/connectivity_interceptor.dart';

class DioClient {
  final Dio dio;

  DioClient({required this.dio}) {
    // Configure Dio
    dio.options = BaseOptions(
      baseUrl: // Local development
          'https://brightcore-iugy8.ondigitalocean.app/', // Production
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    dio.interceptors.addAll([
      ConnectivityInterceptor(),
      LoggingInterceptor(),
      AuthInterceptor(dio: dio),
    ]);

    // Add error interceptor for better error handling
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) {
          _handleError(error);
          handler.next(error);
        },
      ),
    );
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

  Future<Response> put(String path, {dynamic data}) async {
    return dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return dio.delete(path);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return dio.patch(path, data: data);
  }

  void _handleError(DioException error) {
    if (kDebugMode) {
      print('Dio Error: ${error.type}');
      print('Message: ${error.message}');
      print('Response: ${error.response?.data}');
      print('Status Code: ${error.response?.statusCode}');
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        print('Timeout error occurred');
        break;
      case DioExceptionType.badResponse:
        print('Bad response: ${error.response?.statusCode}');
        break;
      case DioExceptionType.cancel:
        print('Request was cancelled');
        break;
      case DioExceptionType.connectionError:
        print('Connection error occurred');
        break;
      case DioExceptionType.badCertificate:
        print('Bad certificate error');
        break;
      case DioExceptionType.unknown:
        print('Unknown error occurred');
        break;
    }
  }
}
