import '../entities/usuario_autenticado.dart';
import '../../../../core/errors/failures.dart';

/// Puerto del repositorio de Autenticación.
/// Capa de Dominio – la implementación concreta vive en la capa de Datos.
abstract class AuthRepository {
  /// Autentica al usuario con email y contraseña.
  /// Retorna [UsuarioAutenticado] si es exitoso o un [Failure] si falla.
  Future<({UsuarioAutenticado? usuario, Failure? failure})> login({
    required String email,
    required String password,
  });

  /// Cierra la sesión del usuario actual eliminando el token almacenado.
  Future<void> logout();

  /// Verifica si hay una sesión activa guardada localmente.
  Future<bool> haySessionActiva();

  /// Recupera el usuario de la sesión activa desde el almacenamiento seguro.
  Future<UsuarioAutenticado?> obtenerSesionActual();
}
