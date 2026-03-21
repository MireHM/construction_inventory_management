import 'package:dio/dio.dart';
import '../models/login_response_model.dart';
import '../../../../core/network/api_client.dart';

/// Fuente de datos remota para autenticación.
/// Capa de Datos – hace las llamadas HTTP reales.
class AuthRemoteDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasource(this._apiClient);

  /// Llama a POST /api/v1/auth/login y retorna el modelo de respuesta.
  /// Lanza [DioException] si el servidor responde con error.
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
