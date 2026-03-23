import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/usuario_autenticado.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_remote_datasource.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl(this._remoteDatasource);

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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyAccessToken, model.accessToken);
      await prefs.setString(AppConstants.keyUserEmail,   model.email);
      await prefs.setString(AppConstants.keyUserRol,     model.rol);
      await prefs.setString('user_nombre',               model.nombre);
      return (usuario: model.toEntity(), failure: null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return (usuario: null, failure: const UnauthorizedFailure('Credenciales incorrectas.'));
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return (usuario: null, failure: const NetworkFailure());
      }
      return (usuario: null, failure: ServerFailure(
        e.response?.data?['mensaje'] ?? 'Error del servidor.',
        statusCode: e.response?.statusCode,
      ));
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<bool> haySessionActiva() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyAccessToken);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<UsuarioAutenticado?> obtenerSesionActual() async {
    final prefs  = await SharedPreferences.getInstance();
    final token  = prefs.getString(AppConstants.keyAccessToken);
    final email  = prefs.getString(AppConstants.keyUserEmail);
    final rol    = prefs.getString(AppConstants.keyUserRol);
    final nombre = prefs.getString('user_nombre') ?? '';
    if (token == null || email == null || rol == null) return null;
    return UsuarioAutenticado(
      id: '', nombre: nombre, email: email, rol: rol, accessToken: token,
    );
  }
}