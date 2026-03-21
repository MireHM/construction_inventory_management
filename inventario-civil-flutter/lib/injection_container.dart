import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'core/network/api_client.dart';

final sl = GetIt.instance;

/// Registro de dependencias con GetIt (Service Locator).
/// Organizado por capas siguiendo Clean Architecture:
/// Infrastructure → Data → Domain → Presentation
Future<void> initDependencies() async {
  // ── INFRAESTRUCTURA ──────────────────────────────────────────────────────
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(sl<FlutterSecureStorage>()),
  );

  // ── DATOS ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDatasource>(),
      sl<FlutterSecureStorage>(),
    ),
  );

  // ── PRESENTACIÓN (BLoC) ───────────────────────────────────────────────────
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRepository>()),
  );
}
