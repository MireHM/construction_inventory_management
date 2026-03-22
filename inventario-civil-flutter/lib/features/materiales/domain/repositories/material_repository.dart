import '../entities/material.dart';
import '../../../../core/errors/failures.dart';

abstract class MaterialRepository {
  Future<({List<Material>? materiales, Failure? failure})> listarActivos();
  Future<({List<Material>? materiales, Failure? failure})> listarAlertas();
  Future<({Material? material, Failure? failure})> obtenerPorId(int id);
}
