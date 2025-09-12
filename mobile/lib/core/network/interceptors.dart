import 'package:dio/dio.dart';
import 'package:mobile/core/storage/secure_storage.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('Request: ${options.method} ${options.uri}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('Response: ${response.statusCode} ${response.requestOptions.uri}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('Error: ${err.message}');
    super.onError(err, handler);
  }
}

class AuthInterceptor extends Interceptor {
  final Dio dio;
  AuthInterceptor({required this.dio});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get access token from secure storage
    final accessToken = await SecureStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        // Get refresh token from secure storage
        final refreshToken = await SecureStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          throw Exception('No refresh token available');
        }

        // Refresh token logic
        final newTokens = await _refreshToken(refreshToken!);
        await SecureStorage.saveTokens(
          newTokens['accessToken']!,
          newTokens['refreshToken']!,
        );

        // Update request with new token
        final request = err.requestOptions;
        request.headers['Authorization'] = 'Bearer ${newTokens['accessToken']}';

        // Retry the request
        final response = await dio.fetch(request);
        return handler.resolve(response);
      } catch (e) {
        // Clear tokens on refresh failure
        await SecureStorage.clearTokens();
        handler.reject(err);
      }
    } else {
      handler.next(err);
    }
  }

  Future<Map<String, String>> _refreshToken(String refreshToken) async {
    // Make actual token refresh API call
    final response = await dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    if (response.statusCode == 200) {
      return {
        'accessToken': response.data['accessToken'],
        'refreshToken': response.data['refreshToken'],
      };
    } else {
      throw Exception('Token refresh failed');
    }
  }
}
