import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/features/Authentication/presentation/pages/login_page.dart';
import 'package:mobile/features/verse_join/presentation/pages/get_to_know_role.dart';
import 'package:mobile/features/verse_join/presentation/pages/join_verse.dart';
import 'package:mobile/features/verse_join/presentation/pages/join_verse_almost_done.dart';

/// App router configuration using go_router
class AppRouter {
  /// Singleton instance
  AppRouter._();

  static final AppRouter instance = AppRouter._();

  late final GoRouter router = GoRouter(
    initialLocation: '/${Routelists.login}',
    routes: _routes,
    debugLogDiagnostics: false,
  );

  final List<GoRoute> _routes = [
    GoRoute(
      path: '/${Routelists.login}',
      name: Routelists.login,
      pageBuilder: (context, state) => _buildPage(context, state, LoginPage()),
    ),
    GoRoute(
      path: '/${Routelists.almostJoinVerse}',
      name: Routelists.almostJoinVerse,
      pageBuilder: (context, state) => _buildPage(context, state, JoinVerseAlmostDone()),
    ),
    GoRoute(
      path: '/${Routelists.joinVerse}',
      name: Routelists.joinVerse,
      pageBuilder: (context, state) => _buildPage(context, state, JoinVerse()),
    ),
    GoRoute(
      path: '/${Routelists.getToKnowRole}',
      name: Routelists.getToKnowRole,
      pageBuilder: (context, state) => _buildPage(context, state, GetToKnowRole()),
    ),
  ];

  static Page<dynamic> _buildPage(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    if (kIsWeb) {
      return NoTransitionPage(child: child);
    }
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 150),
      reverseTransitionDuration: const Duration(milliseconds: 120),
    );
  }

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
