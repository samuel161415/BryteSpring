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
import 'package:mobile/features/channels/presentation/pages/create_folder_page.dart';

/// App router configuration using go_router
class AppRouter {
  /// Singleton instance
  AppRouter._();

  static final AppRouter instance = AppRouter._();

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: _routes,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      try {
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
      } catch (e) {
        // If there's any error, redirect to login as fallback
        return '/${Routelists.login}';
      }
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
      pageBuilder: (context, state) {
        final invitation = state.extra as InvitationEntity?;
        print('AppRouter - Login route with invitation: $invitation');
        return _buildPage(
          context,
          state,
          LoginPage(
            key: ValueKey(invitation?.id ?? 'no-invitation'),
            invitation: invitation,
          ),
        );
      },
    ),
    GoRoute(
      path: '/${Routelists.resetPassword}',
      name: Routelists.resetPassword,
      pageBuilder: (context, state) {
        final invitation = state.extra as InvitationEntity?;
        if (invitation == null) {
          // If no invitation provided, redirect to login
          return _buildPage(context, state, LoginPage());
        }
        return _buildPage(
          context,
          state,
          ResetPasswordPage(invitation: invitation),
        );
      },
    ),
    GoRoute(
      path: '/invitation-validation/:token',
      name: Routelists.invitationValidation,
      pageBuilder: (context, state) {
        final token = state.pathParameters['token'];
        if (token == null || token.isEmpty) {
          // If no token provided, redirect to login
          return _buildPage(context, state, LoginPage());
        }
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
      pageBuilder: (context, state) => _buildPage(
        context,
        state,
        JoinVerseAlmostDone(invitation: state.extra as InvitationEntity),
      ),
    ),
    GoRoute(
      path: '/${Routelists.joinVerse}',
      name: Routelists.joinVerse,
      pageBuilder: (context, state) {
        final invitation = state.extra as InvitationEntity?;
        if (invitation == null) {
          // If no invitation provided, redirect to login
          return _buildPage(context, state, LoginPage());
        }
        return _buildPage(context, state, JoinVerse(invitation: invitation));
      },
    ),
    GoRoute(
      path: '/${Routelists.getToKnowRole}',
      name: Routelists.getToKnowRole,
      pageBuilder: (context, state) {
        final invitation = state.extra as InvitationEntity?;
        if (invitation == null) {
          // If no invitation provided, redirect to login
          return _buildPage(context, state, LoginPage());
        }
        return _buildPage(
          context,
          state,
          GetToKnowRole(invitation: invitation),
        );
      },
    ),
    GoRoute(
      path: '/${Routelists.dashboard}',
      name: Routelists.dashboard,
      pageBuilder: (context, state) =>
          _buildPage(context, state, const DashboardPage()),
    ),
    GoRoute(
      path: '/${Routelists.createFolder}',
      name: Routelists.createFolder,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final parentChannelId = extra?['parentChannelId'] as String?;
        final verseId = extra?['verseId'] as String?;

        if (verseId == null) {
          // If no verse ID provided, redirect to dashboard
          return _buildPage(context, state, const DashboardPage());
        }

        return _buildPage(
          context,
          state,
          CreateFolderPage(parentChannelId: parentChannelId, verseId: verseId),
        );
      },
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
