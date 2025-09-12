import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/core/storage/local_storage.dart';
import 'package:mobile/features/Authentication/data/repositories/login_repository_impl.dart';
import 'package:mobile/features/Authentication/domain/repositories/login_repository.dart';
import 'package:mobile/features/Authentication/domain/usecases/login_usecase.dart';
import 'package:mobile/features/verse_join/data/repositories/offline_first_verse_repository.dart';
import 'package:mobile/features/verse_join/domain/repositories/verse_join_repository.dart';
import 'package:mobile/features/verse_join/domain/usecases/verse_join_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  sl.registerLazySingletonAsync(
    () async => await SharedPreferences.getInstance(),
  );

  // Network
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => DioClient(dio: sl()));
  sl.registerLazySingleton(() => Connectivity());

  // Storage
  sl.registerLazySingleton(() => LocalStorage(sl.get<SharedPreferences>()));

  // Repositories - Login is online-only, Verse is offline-first
  sl.registerLazySingleton<LoginRepository>(
    () => LoginRepositoryImpl(
      dioClient: sl(),
      prefs: sl.get<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<VerseJoinRepository>(
    () => OfflineFirstVerseRepository(
      dioClient: sl(),
      localStorage: sl(),
      connectivity: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => VerseJoinUseCase(sl()));
}
