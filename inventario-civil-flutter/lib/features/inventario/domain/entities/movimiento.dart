import 'package:equatable/equatable.dart';

class Movimiento extends Equatable {
  final int id;
  final int materialId;
  final int? proyectoId;
  final TipoMovimiento tipo;
  final double cantidad;
  final double? precioUnitario;
  final String? numeroFactura;
  final String? frenteObra;
  final String? motivo;
  final double stockAnterior;
  final double stockResultante;
  final DateTime fechaMovimiento;

  const Movimiento({
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

  bool get esIngreso  => tipo == TipoMovimiento.ingreso;
  bool get esSalida   => tipo == TipoMovimiento.salida;

  @override
  List<Object?> get props => [id, materialId, tipo, cantidad, fechaMovimiento];
}

enum TipoMovimiento { ingreso, salida, ajuste, devolucion }
