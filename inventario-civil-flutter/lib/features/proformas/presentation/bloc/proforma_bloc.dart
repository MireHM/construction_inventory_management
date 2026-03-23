import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/proforma.dart';
import '../../domain/repositories/proforma_repository.dart';
import '../../../../core/errors/failures.dart';

// ── EVENTS ────────────────────────────────────────────────────────────────────
abstract class ProformaEvent extends Equatable {
  const ProformaEvent();
  @override List<Object?> get props => [];
}
class CargarProformas        extends ProformaEvent {
  final int proyectoId;
  const CargarProformas(this.proyectoId);
  @override List<Object?> get props => [proyectoId];
}
class SeleccionarProforma    extends ProformaEvent {
  final int proformaId;
  const SeleccionarProforma(this.proformaId);
  @override List<Object?> get props => [proformaId];
}
class EjecutarCalculoAPU     extends ProformaEvent {
  final int proformaId;
  const EjecutarCalculoAPU(this.proformaId);
  @override List<Object?> get props => [proformaId];
}
class CargarRequerimientos   extends ProformaEvent {
  final int proformaId;
  const CargarRequerimientos(this.proformaId);
  @override List<Object?> get props => [proformaId];
}

// ── STATES ────────────────────────────────────────────────────────────────────
abstract class ProformaState extends Equatable {
  const ProformaState();
  @override List<Object?> get props => [];
}
class ProformaInitial         extends ProformaState {}
class ProformaLoading         extends ProformaState {}
class ProformasLoaded extends ProformaState {
  final List<Proforma> proformas;
  const ProformasLoaded(this.proformas);
  @override List<Object?> get props => [proformas];
}
class ProformaDetalle extends ProformaState {
  final Proforma proforma;
  const ProformaDetalle(this.proforma);
  @override List<Object?> get props => [proforma];
}
class RequerimientosLoaded extends ProformaState {
  final List<Requerimiento> requerimientos;
  final int totalAComprar;
  RequerimientosLoaded(this.requerimientos)
      : totalAComprar = requerimientos.where((r) => r.necesitaCompra).length;
  @override List<Object?> get props => [requerimientos];
}
class ProformaError extends ProformaState {
  final Failure failure;
  const ProformaError(this.failure);
  String get message => failure.message;
  @override List<Object?> get props => [failure];
}

// ── BLOC ──────────────────────────────────────────────────────────────────────
class ProformaBloc extends Bloc<ProformaEvent, ProformaState> {
  final ProformaRepository _repository;

  ProformaBloc(this._repository) : super(ProformaInitial()) {
    on<CargarProformas>(_onCargar);
    on<SeleccionarProforma>(_onSeleccionar);
    on<EjecutarCalculoAPU>(_onCalcular);
    on<CargarRequerimientos>(_onCargarReq);
  }

  Future<void> _onCargar(CargarProformas e, Emitter<ProformaState> emit) async {
    emit(ProformaLoading());
    final r = await _repository.listarPorProyecto(e.proyectoId);
    r.failure != null ? emit(ProformaError(r.failure!)) : emit(ProformasLoaded(r.proformas!));
  }

  Future<void> _onSeleccionar(SeleccionarProforma e, Emitter<ProformaState> emit) async {
    emit(ProformaLoading());
    final r = await _repository.obtenerPorId(e.proformaId);
    r.failure != null ? emit(ProformaError(r.failure!)) : emit(ProformaDetalle(r.proforma!));
  }

  Future<void> _onCalcular(EjecutarCalculoAPU e, Emitter<ProformaState> emit) async {
    emit(ProformaLoading());
    final r = await _repository.calcularRequerimientos(e.proformaId);
    r.failure != null ? emit(ProformaError(r.failure!)) : emit(RequerimientosLoaded(r.requerimientos!));
  }

  Future<void> _onCargarReq(CargarRequerimientos e, Emitter<ProformaState> emit) async {
    emit(ProformaLoading());
    final r = await _repository.obtenerRequerimientos(e.proformaId);
    r.failure != null ? emit(ProformaError(r.failure!)) : emit(RequerimientosLoaded(r.requerimientos!));
  }
}
