import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/core/routing/app_router.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/features/Authentication/presentation/bloc/register_user_bloc.dart';
import 'package:mobile/features/Authentication/presentation/bloc/invitation_validation_bloc.dart';
import 'package:mobile/features/Authentication/presentation/bloc/reset_password_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();

  // Initialize authentication service
  final authService = sl<AuthService>();
  await authService.initialize();

  await EasyLocalization.ensureInitialized();
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
        ],
        child: const MyApp(),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: AppRouter.instance.router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
