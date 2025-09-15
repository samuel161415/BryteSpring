import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';
import 'package:mobile/features/Authentication/presentation/pages/login_page.dart';
import 'package:mobile/features/Authentication/presentation/pages/reset_password_page.dart';
import 'package:mobile/features/Authentication/presentation/pages/invitation_validation_page.dart';
import 'package:mobile/features/verse_join/presentation/pages/get_to_know_role.dart';
import 'package:mobile/features/verse_join/presentation/pages/join_verse.dart';
import 'package:mobile/features/verse_join/presentation/pages/join_verse_almost_done.dart';
import 'package:mobile/features/dashboard/presentation/pages/dashboard_page.dart';

/// App router configuration using go_router
class AppRouter {
  /// Singleton instance
  AppRouter._();

  static final AppRouter instance = AppRouter._();

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: _routes,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authService = sl<AuthService>();

      // Wait for auth service to initialize
      if (!authService.isInitialized) {
        return null; // Let the app initialize
      }

        final isAuthenticated = authService.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/${Routelists.login}';
        final isDashboardRoute =
            state.matchedLocation == '/${Routelists.dashboard}';

        // If user is authenticated and trying to access login, redirect to dashboard
        if (isAuthenticated && isLoginRoute) {
          return '/${Routelists.dashboard}';
        }

        // If user is not authenticated and trying to access dashboard, redirect to login
        if (!isAuthenticated && isDashboardRoute) {
          return '/${Routelists.login}';
        }

        // If user is not authenticated and on root, redirect to login
        if (!isAuthenticated && state.matchedLocation == '/') {
          return '/${Routelists.login}';
        }

      // If user is authenticated and on root, redirect to dashboard
      if (isAuthenticated && state.matchedLocation == '/') {
        return '/${Routelists.dashboard}';
      }

      return null; // No redirect needed
    },
  );

  final List<GoRoute> _routes = [
    GoRoute(
      path: '/',
      name: 'root',
      pageBuilder: (context, state) =>
          _buildPage(context, state, const SizedBox()),
    ),
    GoRoute(
      path: '/${Routelists.login}',
      name: Routelists.login,
      pageBuilder: (context, state) => _buildPage(context, state, LoginPage()),
    ),
    GoRoute(
      path: '/${Routelists.resetPassword}',
      name: Routelists.resetPassword,
      pageBuilder: (context, state) => _buildPage(
        context,
        state,
        ResetPasswordPage(invitation: state.extra as InvitationEntity),
      ),
    ),
    GoRoute(
      path: '/invitation-validation/:token',
      name: Routelists.invitationValidation,
      pageBuilder: (context, state) {
        final token = state.pathParameters['token']!;
        return _buildPage(
          context,
          state,
          InvitationValidationPage(token: token),
        );
      },
    ),
    GoRoute(
      path: '/${Routelists.almostJoinVerse}',
      name: Routelists.almostJoinVerse,
      pageBuilder: (context, state) =>
          _buildPage(context, state, JoinVerseAlmostDone()),
    ),
    GoRoute(
      path: '/${Routelists.joinVerse}',
      name: Routelists.joinVerse,
      pageBuilder: (context, state) => _buildPage(context, state, JoinVerse()),
    ),
    GoRoute(
      path: '/${Routelists.getToKnowRole}',
      name: Routelists.getToKnowRole,
      pageBuilder: (context, state) =>
          _buildPage(context, state, GetToKnowRole()),
    ),
    GoRoute(
      path: '/${Routelists.dashboard}',
      name: Routelists.dashboard,
      pageBuilder: (context, state) =>
          _buildPage(context, state, const DashboardPage()),
    ),
  ];

  static Page<dynamic> _buildPage(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return NoTransitionPage(child: child);
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
