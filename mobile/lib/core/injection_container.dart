import 'package:connectivity/connectivity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/core/services/dynamic_theme_service.dart';
import 'package:mobile/core/services/saved_accounts_service.dart';
import 'package:mobile/core/storage/local_storage.dart';
import 'package:mobile/features/Authentication/data/datasources/invitation_remote_datasource.dart';
import 'package:mobile/features/Authentication/data/datasources/register_user_remote_datasource.dart';
import 'package:mobile/features/Authentication/data/datasources/reset_password_remote_datasource.dart';
import 'package:mobile/features/Authentication/data/repositories/invitation_repository_impl.dart';
import 'package:mobile/features/Authentication/data/repositories/register_user_repository_impl.dart';
import 'package:mobile/features/Authentication/data/repositories/reset_password_repository_impl.dart';
import 'package:mobile/features/Authentication/domain/repositories/invitation_repository.dart';
import 'package:mobile/core/services/token_service.dart';
import 'package:mobile/features/Authentication/domain/repositories/login_repository.dart';
import 'package:mobile/features/Authentication/domain/repositories/register_user_repository.dart';
import 'package:mobile/features/Authentication/domain/repositories/reset_password_repository.dart';
import 'package:mobile/features/Authentication/domain/usecases/invitation_usecase.dart';
import 'package:mobile/features/Authentication/domain/usecases/login_usecase.dart';
import 'package:mobile/features/Authentication/domain/usecases/register_user_usecase.dart';
import 'package:mobile/features/Authentication/domain/usecases/reset_password_usecase.dart';
import 'package:mobile/features/invite-user/data/datasourse/invite_user_datasourse.dart';
import 'package:mobile/features/invite-user/data/repostory/invite_user_repo_impl.dart';
import 'package:mobile/features/invite-user/domain/repostory/invitation_repo.dart';
import 'package:mobile/features/invite-user/domain/usecase/create_invitation_usecase.dart';
import 'package:mobile/features/invite-user/domain/usecase/get_verse_role.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_user_bloc.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_user_role_bloc.dart';
import 'package:mobile/features/verse_join/data/datasources/verse_join_remote_datasource.dart';
import 'package:mobile/features/verse_join/data/repositories/verse_join_repository_impl.dart';
import 'package:mobile/features/verse_join/domain/repositories/verse_join_repository.dart';
import 'package:mobile/features/verse_join/domain/usecases/verse_join_usecase.dart';
import 'package:mobile/features/channels/data/datasources/channel_remote_datasource.dart';
import 'package:mobile/features/channels/data/datasources/channel_local_datasource.dart';
import 'package:mobile/features/channels/data/repositories/channel_repository_impl.dart';
import 'package:mobile/features/channels/domain/repositories/channel_repository.dart';
import 'package:mobile/features/channels/domain/usecases/channel_usecase.dart';
import 'package:mobile/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:mobile/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:mobile/features/dashboard/domain/usecases/get_dashboard_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/Authentication/data/repositories/login_repository_impl.dart';
import 'package:mobile/features/verse/domain/repositories/verse_repository.dart';
import 'package:mobile/features/verse/data/repositories/verse_repository_impl.dart';
import 'package:mobile/features/verse/data/datasources/verse_remote_data_source.dart';
import 'package:mobile/features/verse/domain/usecases/create_verse.dart';
import 'package:mobile/features/verse/presentation/bloc/verse_bloc.dart';
import 'package:mobile/core/services/token_service.dart';

// Upload dependencies
import 'package:mobile/features/upload/data/datasources/upload_remote_data_source.dart';
import 'package:mobile/features/upload/domain/repositories/upload_repository.dart';
import 'package:mobile/features/upload/data/repositories/upload_repository_impl.dart';

import '../features/upload/domain/usecases/upload_usecase.dart';
import '../features/upload/presentation/bloc/upload_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefs);
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Network
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => DioClient(dio: sl()));
  sl.registerLazySingleton(() => Connectivity());

  // Services
  sl.registerLazySingleton(() => DynamicThemeService());

  // Data sources
  sl.registerLazySingleton<InvitationRemoteDataSource>(
    () => InvitationRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<RegisterUserRemoteDataSource>(
    () => RegisterUserRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<ResetPasswordRemoteDataSource>(
    () => ResetPasswordRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<VerseJoinRemoteDataSource>(
    () => VerseJoinRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories - Auth is online-only, Verse is offline-first
  sl.registerLazySingleton<InvitationRepository>(
    () => InvitationRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<RegisterUserRepository>(
    () => RegisterUserRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ResetPasswordRepository>(
    () => ResetPasswordRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<LoginRepository>(
    () => LoginRepositoryImpl(
      dioClient: sl(),
      prefs: sl.get<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<VerseJoinRepository>(
    () => VerseJoinRepositoryImpl(remoteDataSource: sl()),
  );

  // Channel dependencies
  sl.registerLazySingleton<ChannelRemoteDataSource>(
    () => ChannelRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<ChannelLocalDataSource>(
    () => ChannelLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<ChannelRepository>(
    () => ChannelRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl(),
    ),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => InvitationUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUserUseCase(repository: sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => VerseJoinUseCase(sl()));
  sl.registerLazySingleton(() => ChannelUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetDashboardData(sl()));

  // Services
  sl.registerLazySingleton(() => AuthService(sl()));
  sl.registerLazySingleton(
    () => SavedAccountsService(prefs: sl(), secureStorage: sl()),
  );

  // Register TokenService
  sl.registerLazySingleton(() => TokenService());

  // Verse Remote Data Source
  sl.registerLazySingleton<VerseRemoteDataSource>(
    () => VerseRemoteDataSourceImpl(dio: sl(), tokenService: sl()),
  );

  // Verse Repositories
  sl.registerLazySingleton<VerseRepository>(
    () => VerseRepositoryImpl(remoteDataSource: sl(), tokenService: sl()),
  );

  // Verse Use cases
  sl.registerLazySingleton(() => CreateVerse(sl()));

  // Verse Bloc
  sl.registerFactory(() => VerseBloc(createVerse: sl()));

  // Upload Remote Data Source
  sl.registerLazySingleton<UploadRemoteDataSource>(
    () => UploadRemoteDataSourceImpl(dio: sl(), tokenService: sl()),
  );

  // Upload Repository
  sl.registerLazySingleton<UploadRepository>(
    () => UploadRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => UploadImage(sl()));
  // Verse Bloc
  sl.registerFactory(() => UploadBloc(sl()));
  // Verse Use cases
  sl.registerLazySingleton(() => CreateUser(sl()));
  sl.registerLazySingleton(() => GetVerseRole(sl()));

  // Verse Bloc
  sl.registerFactory(() => UserInvitationBloc(sl()));
  sl.registerFactory(() => InvitedVerseUserRoleBloc(sl()));

  // Use cases

  // // Repository
  sl.registerLazySingleton<InvitationUserRepository>(
    () => InvitationUserRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<InviteUserDatasourse>(
    () => InviteUserDatasourseImpl(dio: sl()),
  );

  // Verse Bloc
}
