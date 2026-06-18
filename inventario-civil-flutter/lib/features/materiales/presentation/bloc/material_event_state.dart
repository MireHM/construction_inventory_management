import 'package:equatable/equatable.dart';
import '../../domain/entities/material.dart';
import '../../../../core/errors/failures.dart';

// ── EVENTS ───────────────────────────────────────────────────────────────────

abstract class MaterialEvent extends Equatable {
  const MaterialEvent();
  @override List<Object?> get props => [];
}

class CargarMateriales extends MaterialEvent {}
class CargarAlertas    extends MaterialEvent {}
class BuscarMaterial   extends MaterialEvent {
  final String query;
  const BuscarMaterial(this.query);
  @override List<Object?> get props => [query];
}
class FiltrarPorCategoria extends MaterialEvent {
  final int? categoriaId;
  const FiltrarPorCategoria(this.categoriaId);
  @override List<Object?> get props => [categoriaId];
}
class BuscarConFiltros extends MaterialEvent {
  final String? q;
  final int? categoriaId;
  const BuscarConFiltros({this.q, this.categoriaId});
  @override List<Object?> get props => [q, categoriaId];
}

// ── STATES ───────────────────────────────────────────────────────────────────
// Renombrado a MatBlocState para evitar conflicto con MaterialState de Flutter

abstract class MatBlocState extends Equatable {
  const MatBlocState();
  @override List<Object?> get props => [];
}

class MaterialInitial extends MatBlocState {}
class MaterialLoading extends MatBlocState {}

class MaterialesLoaded extends MatBlocState {
  final List<MaterialItem> materiales;
  final List<MaterialItem> filtrados;
  final int stockCritico;
  final int stockBajo;

  MaterialesLoaded(this.materiales)
      : filtrados    = materiales,
        stockCritico = materiales.where((m) => m.esCritico).length,
        stockBajo    = materiales.where((m) => m.esBajo).length;

  MaterialesLoaded.conFiltro(this.materiales, this.filtrados)
      : stockCritico = materiales.where((m) => m.esCritico).length,
        stockBajo    = materiales.where((m) => m.esBajo).length;

  @override List<Object?> get props => [materiales, filtrados];
}

class MaterialError extends MatBlocState {
  final Failure failure;
  const MaterialError(this.failure);
  String get message => failure.message;
  @override List<Object?> get props => [failure];
}
