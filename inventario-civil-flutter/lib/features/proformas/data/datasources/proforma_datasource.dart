import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/proforma.dart';
import '../../domain/repositories/proforma_repository.dart';
import '../models/proforma_model.dart';

class ProformaRemoteDatasource {
  final ApiClient _api;
  ProformaRemoteDatasource(this._api);

  Future<List<ProformaModel>> listarPorProyecto(int proyectoId) async {
    final res = await _api.dio.get('/proformas', queryParameters: {'proyectoId': proyectoId});
    return (res.data['data'] as List)
        .map((e) => ProformaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProformaModel> obtenerPorId(int id) async {
    final res = await _api.dio.get('/proformas/$id');
    return ProformaModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<RequerimientoModel>> calcular(int id) async {
    final res = await _api.dio.post('/proformas/$id/calcular');
    return (res.data['data'] as List)
        .map((e) => RequerimientoModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<RequerimientoModel>> requerimientos(int id) async {
    final res = await _api.dio.get('/proformas/$id/requerimientos');
    return (res.data['data'] as List)
        .map((e) => RequerimientoModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class ProformaRepositoryImpl implements ProformaRepository {
  final ProformaRemoteDatasource _ds;
  ProformaRepositoryImpl(this._ds);

  @override
  Future<({List<Proforma>? proformas, Failure? failure})>
      listarPorProyecto(int proyectoId) async {
    try {
      final list = await _ds.listarPorProyecto(proyectoId);
      return (proformas: list.map((m) => m.toEntity()).toList(), failure: null);
    } on DioException catch (e) { return (proformas: null, failure: _map(e)); }
  }

  @override
  Future<({Proforma? proforma, Failure? failure})> obtenerPorId(int id) async {
    try {
      return (proforma: (await _ds.obtenerPorId(id)).toEntity(), failure: null);
    } on DioException catch (e) { return (proforma: null, failure: _map(e)); }
  }

  @override
  Future<({List<Requerimiento>? requerimientos, Failure? failure})>
      calcularRequerimientos(int proformaId) async {
    try {
      final list = await _ds.calcular(proformaId);
      return (requerimientos: list.map((m) => m.toEntity()).toList(), failure: null);
    } on DioException catch (e) { return (requerimientos: null, failure: _map(e)); }
  }

  @override
  Future<({List<Requerimiento>? requerimientos, Failure? failure})>
      obtenerRequerimientos(int proformaId) async {
    try {
      final list = await _ds.requerimientos(proformaId);
      return (requerimientos: list.map((m) => m.toEntity()).toList(), failure: null);
    } on DioException catch (e) { return (requerimientos: null, failure: _map(e)); }
  }

  Failure _map(DioException e) {
    if (e.type == DioExceptionType.connectionError) return const NetworkFailure();
    final msg = e.response?.data?['mensaje'] ?? 'Error del servidor.';
    return ServerFailure(msg, statusCode: e.response?.statusCode);
  }
}
