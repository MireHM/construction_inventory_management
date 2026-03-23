/// Constantes globales de la aplicación.
/// URL base apunta a localhost en desarrollo y a Railway en producción.
class AppConstants {
  AppConstants._();

  // API
  static const String baseUrlDev = 'http://localhost:8080/api/v1';
  static const String baseUrlProd = 'https://inventario-civil-api.railway.app/api/v1';

  // Usar dev por defecto; cambiar a prod al desplegar
  static const String baseUrl = baseUrlDev;

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
