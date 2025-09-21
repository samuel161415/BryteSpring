import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/core/routing/app_router.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/core/widgets/dynamic_theme_provider.dart';
import 'package:mobile/features/Authentication/presentation/bloc/register_user_bloc.dart';
import 'package:mobile/features/Authentication/presentation/bloc/invitation_validation_bloc.dart';
import 'package:mobile/features/Authentication/presentation/bloc/reset_password_bloc.dart';
import 'package:mobile/features/channels/presentation/bloc/channel_bloc.dart';
import 'package:mobile/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile/features/verse_join/presentation/bloc/join_verse_bloc.dart';
import 'package:mobile/features/upload/presentation/bloc/upload_bloc.dart';
import 'package:mobile/features/verse/presentation/bloc/verse_bloc.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set URL strategy to use path-based routing (removes # from URLs)

  await init();

  // Initialize authentication service
  final authService = sl<AuthService>();
  await authService.initialize();

  await EasyLocalization.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  setPathUrlStrategy();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('de')],
      path: 'assets/translations',
      fallbackLocale: const Locale('de'),
      startLocale: const Locale('de'),
      saveLocale: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RegisterUserBloc>(
            create: (context) => RegisterUserBloc(registerUserUseCase: sl()),
          ),
          BlocProvider<InvitationValidationBloc>(
            create: (context) => InvitationValidationBloc(
              invitationUseCase: sl(),
              loginRepository: sl(),
            ),
          ),
          BlocProvider<ResetPasswordBloc>(
            create: (context) => ResetPasswordBloc(resetPasswordUseCase: sl()),
          ),
          BlocProvider<ChannelBloc>(
            create: (context) => ChannelBloc(channelUseCase: sl()),
          ),
          BlocProvider<JoinVerseBloc>(
            create: (context) => JoinVerseBloc(verseJoinUseCase: sl()),
          ),
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(getDashboardData: sl()),
          ),
          BlocProvider<VerseBloc>(
            create: (context) => VerseBloc(createVerse: sl()),
          ),
          BlocProvider<UploadBloc>(create: (context) => UploadBloc(sl())),
        ],
        child: DynamicThemeProvider(child: const MyApp()),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BryteSpring',
      routerConfig: AppRouter.instance.router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
