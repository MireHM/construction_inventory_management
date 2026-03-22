import 'package:equatable/equatable.dart';

/// Entidad de dominio Material.
/// Capa de Dominio – contiene reglas de negocio del inventario.
class Material extends Equatable {
  final int id;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final int categoriaId;
  final int unidadMedidaId;
  final double precioReferencia;
  final double stockActual;
  final double stockMinimo;
  final double? stockMaximo;
  final bool activo;
  final EstadoStock estadoStock;

  const Material({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.categoriaId,
    required this.unidadMedidaId,
    required this.precioReferencia,
    required this.stockActual,
    required this.stockMinimo,
    this.stockMaximo,
    required this.activo,
    required this.estadoStock,
  });

  bool get esCritico  => estadoStock == EstadoStock.critico;
  bool get esBajo     => estadoStock == EstadoStock.bajo;
  bool get esNormal   => estadoStock == EstadoStock.normal;

  @override
  List<Object?> get props => [id, codigo, nombre, stockActual, estadoStock];
}

enum EstadoStock { normal, bajo, critico }
