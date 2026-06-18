import '../entities/material.dart';
import '../../../../core/errors/failures.dart';

abstract class MaterialRepository {
  Future<({List<MaterialItem>? materiales, Failure? failure})> listarActivos();
  Future<({List<MaterialItem>? materiales, Failure? failure})> listarAlertas();
  Future<({MaterialItem? material, Failure? failure})> obtenerPorId(int id);
  Future<({List<MaterialItem>? materiales, Failure? failure})> buscar({String? q, int? categoriaId});
}
