import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/core/storage/local_storage.dart';
import 'package:mobile/features/Authentication/data/datasources/invitation_remote_datasource.dart';
import 'package:mobile/features/Authentication/data/datasources/reset_password_remote_datasource.dart';
import 'package:mobile/features/Authentication/data/repositories/invitation_repository_impl.dart';
import 'package:mobile/features/Authentication/data/repositories/login_repository_impl.dart';
import 'package:mobile/features/Authentication/data/repositories/reset_password_repository_impl.dart';
import 'package:mobile/features/Authentication/domain/repositories/invitation_repository.dart';
import 'package:mobile/features/Authentication/domain/repositories/login_repository.dart';
import 'package:mobile/features/Authentication/domain/repositories/reset_password_repository.dart';
import 'package:mobile/features/Authentication/domain/usecases/invitation_usecase.dart';
import 'package:mobile/features/Authentication/domain/usecases/login_usecase.dart';
import 'package:mobile/features/Authentication/domain/usecases/reset_password_usecase.dart';
import 'package:mobile/features/verse_join/data/datasources/verse_join_remote_datasource.dart';
import 'package:mobile/features/verse_join/data/repositories/verse_join_repository_impl.dart';
import 'package:mobile/features/verse_join/domain/repositories/verse_join_repository.dart';
import 'package:mobile/features/verse_join/domain/usecases/verse_join_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefs);

  // Network
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => DioClient(dio: sl()));
  sl.registerLazySingleton(() => Connectivity());

  // Storage
  sl.registerLazySingleton(() => LocalStorage(sl.get<SharedPreferences>()));

  // Data sources
  sl.registerLazySingleton<InvitationRemoteDataSource>(
    () => InvitationRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<ResetPasswordRemoteDataSource>(
    () => ResetPasswordRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<VerseJoinRemoteDataSource>(
    () => VerseJoinRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repositories - Auth is online-only, Verse is offline-first
  sl.registerLazySingleton<InvitationRepository>(
    () => InvitationRepositoryImpl(remoteDataSource: sl()),
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
    () => VerseJoinRepositoryImpl(
      remoteDataSource: sl(),
      localStorage: sl(),
      connectivity: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => InvitationUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => VerseJoinUseCase(sl()));
}
