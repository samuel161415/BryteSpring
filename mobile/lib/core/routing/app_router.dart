import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';
import 'package:mobile/features/Authentication/presentation/pages/login_page.dart';
import 'package:mobile/features/Authentication/presentation/pages/reset_password_page.dart';
import 'package:mobile/features/Authentication/presentation/pages/invitation_validation_page.dart';
import 'package:mobile/features/invite-user/presentation/pages/invite_user_page.dart';
import 'package:mobile/features/verse/domain/usecases/create_verse.dart';
import 'package:mobile/features/verse/presentation/pages/verse_creation_page.dart';
import 'package:mobile/features/verse_join/presentation/pages/get_to_know_role.dart';
import 'package:mobile/features/verse_join/presentation/pages/join_verse.dart';
import 'package:mobile/features/verse_join/presentation/pages/join_verse_almost_done.dart';
import 'package:mobile/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:mobile/features/channels/presentation/pages/create_folder_page.dart';
import 'package:mobile/features/channels/presentation/pages/create_folder_confirmation_page.dart';
import 'package:mobile/features/verse_join/presentation/pages/join_verse_success.dart';

import '../../features/invite-user/presentation/pages/invite_complete_page.dart';

/// App router configuration using go_router
class AppRouter {
  /// Singleton instance
  AppRouter._();

  static final AppRouter instance = AppRouter._();

  // No explicit RouteInformationProvider; let Flutter/GoRouter infer from the browser.

  late final GoRouter router = GoRouter(
    routes: _routes,
    debugLogDiagnostics: true,
    initialLocation: '/',
    errorBuilder: (context, state) {
      print('GoRouter Error: ${state.error}');
      print('GoRouter Error Location: ${state.uri}');
      // If it's an invitation validation URL, extract the token and navigate properly
      if (state.uri.path == '/invitation-validation' &&
          state.uri.queryParameters.containsKey('token')) {
        final token = state.uri.queryParameters['token'];
        return InvitationValidationPage(token: token ?? '');
      }
      // For other errors, redirect to login
      return LoginPage();
    },
    redirect: (context, state) {
      try {
        final authService = sl<AuthService>();

        // Debug logging
        print('AppRouter - Redirect check: ${state.uri.path}');
        print('AppRouter - Full location: ${state.uri.toString()}');
        print('AppRouter - State: $state');
        print('AppRouter - Matched location: ${state.matchedLocation}');
        print('AppRouter - Route name: ${state.name}');
        print('AppRouter - Route path: ${state.path}');

        // Wait for auth service to initialize
        if (!authService.isInitialized) {
          print('AppRouter - Auth service not initialized, allowing');
          return null; // Let the app initialize
        }

        final isAuthenticated = authService.isAuthenticated;
        final isLoginRoute = state.uri.path == '/login';
        final isDashboardRoute = state.uri.path == '/dashboard';

        // More comprehensive check for invitation validation routes
        final isInvitationValidationRoute = state.uri.path.startsWith(
          '/invitation-validation',
        );

        final isJoinVerseRoute =
            state.uri.path.startsWith('/${Routelists.almostJoinVerse}') ||
            state.uri.path.startsWith('/${Routelists.joinVerse}') ||
            state.uri.path.startsWith('/${Routelists.getToKnowRole}') ||
            state.uri.path.startsWith('/${Routelists.joinVerseSuccess}');

        print(
          'AppRouter - isInvitationValidationRoute: $isInvitationValidationRoute',
        );
        print('AppRouter - isJoinVerseRoute: $isJoinVerseRoute');
        print('AppRouter - isAuthenticated: $isAuthenticated');

        // Allow access to invitation validation and join verse routes regardless of authentication status
        if (isInvitationValidationRoute || isJoinVerseRoute) {
          print('AppRouter - Allowing access to invitation/join verse route');
          return null; // No redirect needed
        }

        // If user is authenticated and trying to access login, redirect to dashboard
        if (isAuthenticated && isLoginRoute) {
          return '/dashboard';
        }

        // If user is not authenticated and trying to access dashboard, redirect to login
        if (!isAuthenticated && isDashboardRoute) {
          return '/login';
        }

        // If user is not authenticated and on root, redirect to login
        if (!isAuthenticated && state.uri.path == '/') {
          return '/login';
        }

        // If user is authenticated and on root, redirect to dashboard
        if (isAuthenticated && state.uri.path == '/') {
          return '/dashboard';
        }

        return null; // No redirect needed
      } catch (e) {
        // If there's any error, redirect to login as fallback
        print('AppRouter - Error in redirect: $e');
        return '/login';
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
      path: '/login',
      name: 'login',
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
      path: '/invitation-validation',
      name: 'invitation-validation',
      pageBuilder: (context, state) {
        final token = state.uri.queryParameters['token'];
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
      pageBuilder: (context, state) {
        final invitation = state.extra as InvitationEntity?;
        if (invitation == null) {
          // If no invitation provided, redirect to login
          return _buildPage(context, state, LoginPage());
        }
        return _buildPage(
          context,
          state,
          JoinVerseAlmostDone(invitation: invitation),
        );
      },
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
        return _buildPage(
          context,
          state,
          JoinVersePage(invitation: invitation),
        );
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
      path: '/${Routelists.joinVerseSuccess}',
      name: Routelists.joinVerseSuccess,
      pageBuilder: (context, state) {
        final invitation = state.extra as InvitationEntity?;
        if (invitation == null) {
          // If no invitation provided, redirect to login
          return _buildPage(context, state, LoginPage());
        }
        return _buildPage(
          context,
          state,
          JoinVerseSuccessPage(invitation: invitation),
        );
      },
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
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
    GoRoute(
      path: '/${Routelists.createFolderConfirmation}',
      name: Routelists.createFolderConfirmation,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final folderName = extra?['folderName'] as String? ?? 'Folder';
        final channelName = extra?['channelName'] as String? ?? 'Channel';

        return _buildPage(
          context,
          state,
          CreateFolderConfirmationPage(
            folderName: folderName,
            channelName: channelName,
          ),
        );
      },
    ),
    GoRoute(
      path: '/${Routelists.createVerse}',
      name: Routelists.createVerse,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final verseId = extra?['verseId'] as String?;
        final currentUserName = extra?['currentUserName'] as String?;
        final email = extra?['email'] as String?;
        if (verseId == null || currentUserName == null || email == null) {
          // If no extra provided, redirect to dashboard
          return _buildPage(context, state, const DashboardPage());
        }

        return _buildPage(
          context,
          state,
          VerseCreationPage(
            verseId: verseId,
            currentUserName: currentUserName,
            email: email,
          ),
        );
      },
    ),
    GoRoute(
      path: '/${Routelists.inviteUser}',
      name: Routelists.inviteUser,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final verseId = extra?['verseId'] as String? ?? 'verseId';
        return _buildPage(context, state, InviteUserPage(verseId: verseId));
      },
    ),
    GoRoute(
      path: '/${Routelists.completeUserInvite}',
      name: Routelists.completeUserInvite,
      pageBuilder: (context, state) =>
          _buildPage(context, state, const InviteCompletePage()),
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
