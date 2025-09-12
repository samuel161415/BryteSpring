import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/features/Authentication/presentation/pages/login_page.dart';
import 'package:mobile/features/verse_join/presentation/pages/join_verse.dart';
import 'package:mobile/features/verse_join/presentation/pages/join_verse_almost_done.dart';

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
    GoRoute(
      path: Routelists.loginPath,
      name: Routelists.login,
      builder: (context, state) {
        return LoginPage();
      },
    ),
    GoRoute(
      path: Routelists.almostJoinVersePath,
      name: Routelists.almostJoinVerse,
      builder: (context, state) {
        return JoinVerseAlmostDone();
      },
    ),
    GoRoute(
      path: Routelists.joinVersePath,
      name: Routelists.joinVerse,
      builder: (context, state) {
        return JoinVerse();
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
