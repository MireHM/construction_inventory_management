import 'package:equatable/equatable.dart';

/// Entidad de dominio Usuario autenticado.
/// Capa de Dominio – sin dependencias de Flutter ni de API.
class UsuarioAutenticado extends Equatable {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final String accessToken;

  const UsuarioAutenticado({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.accessToken,
  });

  bool get esAdministrador => rol == 'ADMINISTRADOR';
  bool get esAlmacenero    => rol == 'ALMACENERO';
  bool get esResidente     => rol == 'RESIDENTE';
  bool get esGerente       => rol == 'GERENTE';

  @override
  List<Object?> get props => [id, email, rol, accessToken];
}
