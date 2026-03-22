import 'package:dio/dio.dart';
import '../../domain/entities/material.dart';
import '../../domain/repositories/material_repository.dart';
import '../datasources/material_remote_datasource.dart';
import '../../../../core/errors/failures.dart';

class MaterialRepositoryImpl implements MaterialRepository {
  final MaterialRemoteDatasource _datasource;
  MaterialRepositoryImpl(this._datasource);

  @override
  Future<({List<Material>? materiales, Failure? failure})> listarActivos() async {
    try {
      final models = await _datasource.listarActivos();
      return (materiales: models.map((m) => m.toEntity()).toList(), failure: null);
    } on DioException catch (e) {
      return (materiales: null, failure: _mapError(e));
    }
  }

  @override
  Future<({List<Material>? materiales, Failure? failure})> listarAlertas() async {
    try {
      final models = await _datasource.listarAlertas();
      return (materiales: models.map((m) => m.toEntity()).toList(), failure: null);
    } on DioException catch (e) {
      return (materiales: null, failure: _mapError(e));
    }
  }

  @override
  Future<({Material? material, Failure? failure})> obtenerPorId(int id) async {
    try {
      final model = await _datasource.obtenerPorId(id);
      return (material: model.toEntity(), failure: null);
    } on DioException catch (e) {
      return (material: null, failure: _mapError(e));
    }
  }

  Failure _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError) return const NetworkFailure();
    if (e.response?.statusCode == 404) return NotFoundFailure(e.response?.data?['mensaje'] ?? 'No encontrado.');
    return ServerFailure(e.response?.data?['mensaje'] ?? 'Error del servidor.', statusCode: e.response?.statusCode);
  }
}
