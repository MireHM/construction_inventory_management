import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/orden_compra.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/orden_compra_datasource.dart';

// ── EVENTS ────────────────────────────────────────────────────────────────────
abstract class OrdenEvent extends Equatable {
  const OrdenEvent();
  @override List<Object?> get props => [];
}
class CargarOrdenes        extends OrdenEvent {}
class CargarPendientes     extends OrdenEvent {}
class GenerarOrdenes       extends OrdenEvent {
  final int proformaId;
  const GenerarOrdenes(this.proformaId);
  @override List<Object?> get props => [proformaId];
}
class AprobarOrden         extends OrdenEvent {
  final int id;
  const AprobarOrden(this.id);
  @override List<Object?> get props => [id];
}
class RechazarOrden        extends OrdenEvent {
  final int id;
  final String observaciones;
  const RechazarOrden(this.id, this.observaciones);
  @override List<Object?> get props => [id];
}
class RecibirOrden         extends OrdenEvent {
  final int id;
  const RecibirOrden(this.id);
  @override List<Object?> get props => [id];
}

// ── STATES ────────────────────────────────────────────────────────────────────
abstract class OrdenState extends Equatable {
  const OrdenState();
  @override List<Object?> get props => [];
}
class OrdenInitial  extends OrdenState {}
class OrdenLoading  extends OrdenState {}
class OrdenesLoaded extends OrdenState {
  final List<OrdenCompra> ordenes;
  const OrdenesLoaded(this.ordenes);
  @override List<Object?> get props => [ordenes];
}
class OrdenActualizada extends OrdenState {
  final OrdenCompra orden;
  final String mensaje;
  const OrdenActualizada(this.orden, this.mensaje);
  @override List<Object?> get props => [orden];
}
class OrdenesGeneradas extends OrdenState {
  final List<OrdenCompra> ordenes;
  const OrdenesGeneradas(this.ordenes);
  @override List<Object?> get props => [ordenes];
}
class OrdenError extends OrdenState {
  final Failure failure;
  const OrdenError(this.failure);
  String get message => failure.message;
  @override List<Object?> get props => [failure];
}

// ── BLOC ──────────────────────────────────────────────────────────────────────
class OrdenBloc extends Bloc<OrdenEvent, OrdenState> {
  final OrdenCompraRepository _repo;
  OrdenBloc(this._repo) : super(OrdenInitial()) {
    on<CargarOrdenes>(_onCargar);
    on<CargarPendientes>(_onPendientes);
    on<GenerarOrdenes>(_onGenerar);
    on<AprobarOrden>(_onAprobar);
    on<RechazarOrden>(_onRechazar);
    on<RecibirOrden>(_onRecibir);
  }

  Future<void> _onCargar(CargarOrdenes e, Emitter<OrdenState> emit) async {
    emit(OrdenLoading());
    final r = await _repo.listar();
    r.failure != null ? emit(OrdenError(r.failure!)) : emit(OrdenesLoaded(r.ordenes!));
  }

  Future<void> _onPendientes(CargarPendientes e, Emitter<OrdenState> emit) async {
    emit(OrdenLoading());
    final r = await _repo.pendientes();
    r.failure != null ? emit(OrdenError(r.failure!)) : emit(OrdenesLoaded(r.ordenes!));
  }

  Future<void> _onGenerar(GenerarOrdenes e, Emitter<OrdenState> emit) async {
    emit(OrdenLoading());
    final r = await _repo.generarDesdeProforma(e.proformaId);
    r.failure != null ? emit(OrdenError(r.failure!)) : emit(OrdenesGeneradas(r.ordenes!));
  }

  Future<void> _onAprobar(AprobarOrden e, Emitter<OrdenState> emit) async {
    emit(OrdenLoading());
    final r = await _repo.aprobar(e.id);
    r.failure != null ? emit(OrdenError(r.failure!))
        : emit(OrdenActualizada(r.orden!, 'Orden aprobada correctamente.'));
  }

  Future<void> _onRechazar(RechazarOrden e, Emitter<OrdenState> emit) async {
    emit(OrdenLoading());
    final r = await _repo.rechazar(e.id, e.observaciones);
    r.failure != null ? emit(OrdenError(r.failure!))
        : emit(OrdenActualizada(r.orden!, 'Orden rechazada.'));
  }

  Future<void> _onRecibir(RecibirOrden e, Emitter<OrdenState> emit) async {
    emit(OrdenLoading());
    final r = await _repo.recibir(e.id);
    r.failure != null ? emit(OrdenError(r.failure!))
        : emit(OrdenActualizada(r.orden!, 'Materiales recibidos. Stock actualizado.'));
  }
}
