import '../../domain/entities/movimiento.dart';

class MovimientoModel {
  final int id;
  final int materialId;
  final int? proyectoId;
  final String tipo;
  final double cantidad;
  final double? precioUnitario;
  final String? numeroFactura;
  final String? frenteObra;
  final String? motivo;
  final double stockAnterior;
  final double stockResultante;
  final DateTime fechaMovimiento;

  const MovimientoModel({
    required this.id,
    required this.materialId,
    this.proyectoId,
    required this.tipo,
    required this.cantidad,
    this.precioUnitario,
    this.numeroFactura,
    this.frenteObra,
    this.motivo,
    required this.stockAnterior,
    required this.stockResultante,
    required this.fechaMovimiento,
  });

  factory MovimientoModel.fromJson(Map<String, dynamic> json) => MovimientoModel(
        id: json['id'] as int,
        materialId: json['materialId'] as int,
        proyectoId: json['proyectoId'] as int?,
        tipo: json['tipo'] as String,
        cantidad: (json['cantidad'] as num).toDouble(),
        precioUnitario: json['precioUnitario'] != null
            ? (json['precioUnitario'] as num).toDouble()
            : null,
        numeroFactura: json['numeroFactura'] as String?,
        frenteObra: json['frenteObra'] as String?,
        motivo: json['motivo'] as String?,
        stockAnterior: (json['stockAnterior'] as num).toDouble(),
        stockResultante: (json['stockResultante'] as num).toDouble(),
        fechaMovimiento: DateTime.parse(json['fechaMovimiento'] as String),
      );

  Movimiento toEntity() => Movimiento(
        id: id,
        materialId: materialId,
        proyectoId: proyectoId,
        tipo: _parseTipo(tipo),
        cantidad: cantidad,
        precioUnitario: precioUnitario,
        numeroFactura: numeroFactura,
        frenteObra: frenteObra,
        motivo: motivo,
        stockAnterior: stockAnterior,
        stockResultante: stockResultante,
        fechaMovimiento: fechaMovimiento,
      );

  static TipoMovimiento _parseTipo(String v) {
    switch (v.toUpperCase()) {
      case 'SALIDA':     return TipoMovimiento.salida;
      case 'AJUSTE':     return TipoMovimiento.ajuste;
      case 'DEVOLUCION': return TipoMovimiento.devolucion;
      default:           return TipoMovimiento.ingreso;
    }
  }
}
