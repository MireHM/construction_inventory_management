import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/usuario_autenticado.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';

/// Implementación concreta del repositorio de autenticación.
/// Capa de Datos – implementa el port del dominio.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl(this._remoteDatasource, this._storage);

  @override
  Future<({UsuarioAutenticado? usuario, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remoteDatasource.login(
        email: email,
        password: password,
      );

      // Persistir token y datos de sesión de forma segura
      await _storage.write(
          key: AppConstants.keyAccessToken, value: model.accessToken);
      await _storage.write(
          key: AppConstants.keyUserEmail, value: model.email);
      await _storage.write(
          key: AppConstants.keyUserRol, value: model.rol);

      return (usuario: model.toEntity(), failure: null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return (
          usuario: null,
          failure: const UnauthorizedFailure('Credenciales incorrectas.')
        );
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return (usuario: null, failure: const NetworkFailure());
      }
      return (
        usuario: null,
        failure: ServerFailure(
          e.response?.data?['message'] ?? 'Error del servidor.',
          statusCode: e.response?.statusCode,
        )
      );
    }
  }

  @override
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> haySessionActiva() async {
    final token = await _storage.read(key: AppConstants.keyAccessToken);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<UsuarioAutenticado?> obtenerSesionActual() async {
    final token = await _storage.read(key: AppConstants.keyAccessToken);
    final email = await _storage.read(key: AppConstants.keyUserEmail);
    final rol   = await _storage.read(key: AppConstants.keyUserRol);

    if (token == null || email == null || rol == null) return null;

    return UsuarioAutenticado(
      id: '',
      nombre: '',
      email: email,
      rol: rol,
      accessToken: token,
    );
  }
}
