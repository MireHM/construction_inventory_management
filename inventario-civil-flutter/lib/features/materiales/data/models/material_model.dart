import '../../domain/entities/material.dart';

class MaterialModel {
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
  final String estadoStock;

  const MaterialModel({
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

  factory MaterialModel.fromJson(Map<String, dynamic> json) => MaterialModel(
        id: json['id'] as int,
        codigo: json['codigo'] as String,
        nombre: json['nombre'] as String,
        descripcion: json['descripcion'] as String?,
        categoriaId: json['categoriaId'] as int,
        unidadMedidaId: json['unidadMedidaId'] as int,
        precioReferencia: (json['precioReferencia'] as num).toDouble(),
        stockActual: (json['stockActual'] as num).toDouble(),
        stockMinimo: (json['stockMinimo'] as num).toDouble(),
        stockMaximo: json['stockMaximo'] != null
            ? (json['stockMaximo'] as num).toDouble()
            : null,
        activo: json['activo'] as bool,
        estadoStock: json['estadoStock'] as String? ?? 'NORMAL',
      );

  Material toEntity() => Material(
        id: id,
        codigo: codigo,
        nombre: nombre,
        descripcion: descripcion,
        categoriaId: categoriaId,
        unidadMedidaId: unidadMedidaId,
        precioReferencia: precioReferencia,
        stockActual: stockActual,
        stockMinimo: stockMinimo,
        stockMaximo: stockMaximo,
        activo: activo,
        estadoStock: _parseEstado(estadoStock),
      );

  static EstadoStock _parseEstado(String v) {
    switch (v.toUpperCase()) {
      case 'CRITICO': return EstadoStock.critico;
      case 'BAJO':    return EstadoStock.bajo;
      default:        return EstadoStock.normal;
    }
  }
}
