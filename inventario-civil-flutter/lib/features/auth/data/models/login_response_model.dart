import '../../domain/entities/usuario_autenticado.dart';

/// Modelo de respuesta del endpoint POST /api/v1/auth/login.
/// Capa de Datos – mapea JSON de la API al dominio.
class LoginResponseModel {
  final String accessToken;
  final String id;
  final String nombre;
  final String email;
  final String rol;

  const LoginResponseModel({
    required this.accessToken,
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['accessToken'] as String,
      id: json['id'].toString(),
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String,
    );
  }

  /// Convierte el modelo de datos a la entidad de dominio.
  UsuarioAutenticado toEntity() => UsuarioAutenticado(
        id: id,
        nombre: nombre,
        email: email,
        rol: rol,
        accessToken: accessToken,
      );
}
