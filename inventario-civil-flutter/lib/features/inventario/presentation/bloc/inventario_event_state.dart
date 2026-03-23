import 'package:equatable/equatable.dart';
import '../../domain/entities/movimiento.dart';
import '../../domain/entities/alerta_stock.dart';
import '../../../../core/errors/failures.dart';

// ── EVENTS ───────────────────────────────────────────────────────────────────

abstract class InventarioEvent extends Equatable {
  const InventarioEvent();
  @override List<Object?> get props => [];
}

class CargarMovimientosRecientes extends InventarioEvent {}
class CargarHistorialMaterial    extends InventarioEvent {
  final int materialId;
  const CargarHistorialMaterial(this.materialId);
  @override List<Object?> get props => [materialId];
}

class RegistrarIngreso extends InventarioEvent {
  final int    materialId;
  final double cantidad;
  final double? precioUnitario;
  final int?   proveedorId;
  final String? numeroFactura;
  final int?   proyectoId;
  final String? motivo;

  const RegistrarIngreso({
    required this.materialId,
    required this.cantidad,
    this.precioUnitario,
    this.proveedorId,
    this.numeroFactura,
    this.proyectoId,
    this.motivo,
  });
  @override List<Object?> get props =>
      [materialId, cantidad, numeroFactura];
}

class RegistrarSalida extends InventarioEvent {
  final int    materialId;
  final double cantidad;
  final int    proyectoId;
  final String frenteObra;
  final String? motivo;

  const RegistrarSalida({
    required this.materialId,
    required this.cantidad,
    required this.proyectoId,
    required this.frenteObra,
    this.motivo,
  });
  @override List<Object?> get props => [materialId, cantidad, frenteObra];
}

// ── STATES ───────────────────────────────────────────────────────────────────

abstract class InventarioState extends Equatable {
  const InventarioState();
  @override List<Object?> get props => [];
}

class InventarioInitial  extends InventarioState {}
class InventarioLoading  extends InventarioState {}

class MovimientosLoaded extends InventarioState {
  final List<Movimiento> movimientos;
  const MovimientosLoaded(this.movimientos);
  @override List<Object?> get props => [movimientos];
}

class MovimientoRegistrado extends InventarioState {
  final Movimiento movimiento;
  final String mensaje;
  const MovimientoRegistrado(this.movimiento, this.mensaje);
  @override List<Object?> get props => [movimiento];
}

class InventarioError extends InventarioState {
  final Failure failure;
  const InventarioError(this.failure);
  String get message => failure.message;
  @override List<Object?> get props => [failure];
}
