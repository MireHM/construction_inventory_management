/// Constantes globales de la aplicación.
/// URL base se selecciona según el entorno (--dart-define=ENV=prod para producción).
class AppConstants {
  AppConstants._();

  // API
  static const String baseUrlDev  = 'http://localhost:8080/api/v1';
  static const String baseUrlProd = 'https://inventario-civil-api.onrender.com/api/v1';

  // Lee el entorno desde dart-define: flutter build web --dart-define=ENV=prod
  static const String _env = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const String baseUrl = _env == 'prod' ? baseUrlProd : baseUrlDev;

  // Storage keys
  static const String keyAccessToken  = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserEmail    = 'user_email';
  static const String keyUserRol      = 'user_rol';

  // Timeouts
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;

  // Paginación
  static const int pageSize = 20;

  // Roles
  static const String rolAdministrador = 'ADMINISTRADOR';
  static const String rolAlmacenero    = 'ALMACENERO';
  static const String rolResidente     = 'RESIDENTE';
  static const String rolGerente       = 'GERENTE';
}
