import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/materiales/data/datasources/material_remote_datasource.dart';
import 'features/materiales/data/datasources/material_repository_impl.dart';
import 'features/materiales/domain/repositories/material_repository.dart';
import 'features/materiales/presentation/bloc/material_bloc.dart';
import 'features/inventario/data/datasources/inventario_remote_datasource.dart';
import 'features/inventario/data/datasources/inventario_repository_impl.dart';
import 'features/inventario/domain/repositories/inventario_repository.dart';
import 'features/inventario/presentation/bloc/inventario_bloc.dart';
import 'features/proformas/data/datasources/proforma_datasource.dart';
import 'features/proformas/domain/repositories/proforma_repository.dart';
import 'features/proformas/presentation/bloc/proforma_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
  sl.registerLazySingleton<ApiClient>(
      () => ApiClient(sl<FlutterSecureStorage>()));
  // Auth
  sl.registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasource(sl<ApiClient>()));
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDatasource>(), sl<FlutterSecureStorage>()));
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));
  // Materiales
  sl.registerLazySingleton<MaterialRemoteDatasource>(
      () => MaterialRemoteDatasource(sl<ApiClient>()));
  sl.registerLazySingleton<MaterialRepository>(
      () => MaterialRepositoryImpl(sl<MaterialRemoteDatasource>()));
  sl.registerFactory<MaterialBloc>(
      () => MaterialBloc(sl<MaterialRepository>()));
  // Inventario
  sl.registerLazySingleton<InventarioRemoteDatasource>(
      () => InventarioRemoteDatasource(sl<ApiClient>()));
  sl.registerLazySingleton<InventarioRepository>(
      () => InventarioRepositoryImpl(sl<InventarioRemoteDatasource>()));
  sl.registerFactory<InventarioBloc>(
      () => InventarioBloc(sl<InventarioRepository>()));
  // Proformas
  sl.registerLazySingleton<ProformaRemoteDatasource>(
      () => ProformaRemoteDatasource(sl<ApiClient>()));
  sl.registerLazySingleton<ProformaRepository>(
      () => ProformaRepositoryImpl(sl<ProformaRemoteDatasource>()));
  sl.registerFactory<ProformaBloc>(
      () => ProformaBloc(sl<ProformaRepository>()));
}
