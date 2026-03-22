import 'package:equatable/equatable.dart';
import '../../domain/entities/material.dart';
import '../../../../core/errors/failures.dart';

// ── EVENTS ──────────────────────────────────────────────────────────────────

abstract class MaterialEvent extends Equatable {
  const MaterialEvent();
  @override List<Object?> get props => [];
}

class CargarMateriales extends MaterialEvent {}
class CargarAlertas extends MaterialEvent {}
class BuscarMaterial extends MaterialEvent {
  final String query;
  const BuscarMaterial(this.query);
  @override List<Object?> get props => [query];
}

// ── STATES ──────────────────────────────────────────────────────────────────

abstract class MaterialState extends Equatable {
  const MaterialState();
  @override List<Object?> get props => [];
}

class MaterialInitial extends MaterialState {}
class MaterialLoading extends MaterialState {}

class MaterialesLoaded extends MaterialState {
  final List<Material> materiales;
  final List<Material> filtrados;
  final int stockCritico;
  final int stockBajo;

  MaterialesLoaded(this.materiales)
      : filtrados = materiales,
        stockCritico = materiales.where((m) => m.esCritico).length,
        stockBajo    = materiales.where((m) => m.esBajo).length;

  MaterialesLoaded.conFiltro(this.materiales, this.filtrados)
      : stockCritico = materiales.where((m) => m.esCritico).length,
        stockBajo    = materiales.where((m) => m.esBajo).length;

  @override List<Object?> get props => [materiales, filtrados];
}

class MaterialError extends MaterialState {
  final Failure failure;
  const MaterialError(this.failure);
  String get message => failure.message;
  @override List<Object?> get props => [failure];
}
