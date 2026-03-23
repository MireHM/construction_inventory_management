import 'package:equatable/equatable.dart';

class OrdenCompra extends Equatable {
  final int id;
  final int requerimientoId;
  final int materialId;
  final String? nombreProveedor;
  final double cantidad;
  final double? precioUnitario;
  final double? costoEstimado;
  final EstadoOC estado;
  final DateTime fechaGeneracion;
  final DateTime? fechaAprobacion;
  final DateTime? fechaRecepcion;
  final String? observaciones;

  const OrdenCompra({
    required this.id,
    required this.requerimientoId,
    required this.materialId,
    this.nombreProveedor,
    required this.cantidad,
    this.precioUnitario,
    this.costoEstimado,
    required this.estado,
    required this.fechaGeneracion,
    this.fechaAprobacion,
    this.fechaRecepcion,
    this.observaciones,
  });

  bool get esPendiente  => estado == EstadoOC.pendiente;
  bool get esAprobada   => estado == EstadoOC.aprobada;
  bool get esRecibida   => estado == EstadoOC.recibida;
  bool get esRechazada  => estado == EstadoOC.rechazada;

  @override
  List<Object?> get props => [id, materialId, estado];
}

enum EstadoOC { pendiente, aprobada, recibida, rechazada, anulada }
