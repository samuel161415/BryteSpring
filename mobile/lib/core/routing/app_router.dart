import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/features/Authentication/presentation/pages/login_page.dart';

/// App router configuration using go_router
class AppRouter {
  /// Singleton instance
  AppRouter._();

  static final AppRouter instance = AppRouter._();

  late final GoRouter router = GoRouter(
    routes: _routes,
    debugLogDiagnostics: false,
  );

  final List<GoRoute> _routes = [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return LoginPage();
      },
    ),
  ];

  /// Push a named route
  void pushNamed(
    BuildContext context,
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
  }) {
    context.pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
    );
  }

  /// Replace current route with a named route
  void replaceNamed(
    BuildContext context,
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
  }) {
    context.replaceNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
    );
  }

  /// Pop the current route
  void pop(BuildContext context) {
    context.pop();
  }
}
