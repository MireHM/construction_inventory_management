import 'package:dio/dio.dart';
import '../../domain/entities/material.dart';
import '../../domain/repositories/material_repository.dart';
import 'material_remote_datasource.dart';
import '../../../../core/errors/failures.dart';

class MaterialRepositoryImpl implements MaterialRepository {
  final MaterialRemoteDatasource _datasource;
  MaterialRepositoryImpl(this._datasource);

  @override
  Future<({List<MaterialItem>? materiales, Failure? failure})> listarActivos() async {
    try {
      final models = await _datasource.listarActivos();
      return (materiales: models.map((m) => m.toEntity()).toList(), failure: null);
    } on DioException catch (e) { return (materiales: null, failure: _map(e)); }
  }

  @override
  Future<({List<MaterialItem>? materiales, Failure? failure})> listarAlertas() async {
    try {
      final models = await _datasource.listarAlertas();
      return (materiales: models.map((m) => m.toEntity()).toList(), failure: null);
    } on DioException catch (e) { return (materiales: null, failure: _map(e)); }
  }

  @override
  Future<({MaterialItem? material, Failure? failure})> obtenerPorId(int id) async {
    try {
      return (material: (await _datasource.obtenerPorId(id)).toEntity(), failure: null);
    } on DioException catch (e) { return (material: null, failure: _map(e)); }
  }

  Failure _map(DioException e) {
    if (e.type == DioExceptionType.connectionError) return const NetworkFailure();
    final msg = e.response?.data?['mensaje'] ?? 'Error del servidor.';
    if (e.response?.statusCode == 404) return NotFoundFailure(msg);
    return ServerFailure(msg, statusCode: e.response?.statusCode);
  }
}
