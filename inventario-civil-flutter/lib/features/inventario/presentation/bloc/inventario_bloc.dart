import 'package:flutter_bloc/flutter_bloc.dart';
import 'inventario_event_state.dart';
import '../../domain/repositories/inventario_repository.dart';

class InventarioBloc extends Bloc<InventarioEvent, InventarioState> {
  final InventarioRepository _repository;

  InventarioBloc(this._repository) : super(InventarioInitial()) {
    on<CargarMovimientosRecientes>(_onCargarRecientes);
    on<CargarHistorialMaterial>(_onCargarHistorial);
    on<RegistrarIngreso>(_onRegistrarIngreso);
    on<RegistrarSalida>(_onRegistrarSalida);
  }

  Future<void> _onCargarRecientes(
    CargarMovimientosRecientes event,
    Emitter<InventarioState> emit,
  ) async {
    emit(InventarioLoading());
    final result = await _repository.recientes();
    if (result.failure != null) {
      emit(InventarioError(result.failure!));
    } else {
      emit(MovimientosLoaded(result.movimientos!));
    }
  }

  Future<void> _onCargarHistorial(
    CargarHistorialMaterial event,
    Emitter<InventarioState> emit,
  ) async {
    emit(InventarioLoading());
    final result = await _repository.historialPorMaterial(event.materialId);
    if (result.failure != null) {
      emit(InventarioError(result.failure!));
    } else {
      emit(MovimientosLoaded(result.movimientos!));
    }
  }

  Future<void> _onRegistrarIngreso(
    RegistrarIngreso event,
    Emitter<InventarioState> emit,
  ) async {
    emit(InventarioLoading());
    final result = await _repository.registrarIngreso(
      materialId:     event.materialId,
      cantidad:       event.cantidad,
      precioUnitario: event.precioUnitario,
      proveedorId:    event.proveedorId,
      numeroFactura:  event.numeroFactura,
      proyectoId:     event.proyectoId,
      motivo:         event.motivo,
    );
    if (result.failure != null) {
      emit(InventarioError(result.failure!));
    } else {
      emit(MovimientoRegistrado(result.movimiento!, 'Ingreso registrado correctamente.'));
    }
  }

  Future<void> _onRegistrarSalida(
    RegistrarSalida event,
    Emitter<InventarioState> emit,
  ) async {
    emit(InventarioLoading());
    final result = await _repository.registrarSalida(
      materialId:  event.materialId,
      cantidad:    event.cantidad,
      proyectoId:  event.proyectoId,
      frenteObra:  event.frenteObra,
      motivo:      event.motivo,
    );
    if (result.failure != null) {
      emit(InventarioError(result.failure!));
    } else {
      emit(MovimientoRegistrado(result.movimiento!, 'Salida registrada correctamente.'));
    }
  }
}
