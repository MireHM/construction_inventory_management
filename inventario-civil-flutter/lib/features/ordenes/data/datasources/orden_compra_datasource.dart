import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/orden_compra.dart';

// ── REPOSITORY PORT ──────────────────────────────────────────────────────────

abstract class OrdenCompraRepository {
  Future<({List<OrdenCompra>? ordenes, Failure? failure})> listar();
  Future<({List<OrdenCompra>? ordenes, Failure? failure})> pendientes();
  Future<({List<OrdenCompra>? ordenes, Failure? failure})>
      generarDesdeProforma(int proformaId);
  Future<({OrdenCompra? orden, Failure? failure})> aprobar(int id);
  Future<({OrdenCompra? orden, Failure? failure})> rechazar(int id, String obs);
  Future<({OrdenCompra? orden, Failure? failure})> recibir(int id);
}

// ── MODEL ─────────────────────────────────────────────────────────────────────

class OrdenCompraModel {
  final int id;
  final int requerimientoId;
  final int materialId;
  final String? nombreProveedor;
  final double cantidad;
  final double? precioUnitario;
  final double? costoEstimado;
  final String estado;
  final DateTime fechaGeneracion;
  final DateTime? fechaAprobacion;
  final DateTime? fechaRecepcion;
  final String? observaciones;

  const OrdenCompraModel({
    required this.id, required this.requerimientoId,
    required this.materialId, this.nombreProveedor,
    required this.cantidad, this.precioUnitario, this.costoEstimado,
    required this.estado, required this.fechaGeneracion,
    this.fechaAprobacion, this.fechaRecepcion, this.observaciones,
  });

  factory OrdenCompraModel.fromJson(Map<String, dynamic> j) => OrdenCompraModel(
    id: j['id'] as int,
    requerimientoId: j['requerimientoId'] as int,
    materialId: j['materialId'] as int,
    nombreProveedor: j['nombreProveedor'] as String?,
    cantidad: (j['cantidad'] as num).toDouble(),
    precioUnitario: j['precioUnitario'] != null ? (j['precioUnitario'] as num).toDouble() : null,
    costoEstimado: j['costoEstimado'] != null ? (j['costoEstimado'] as num).toDouble() : null,
    estado: j['estado'] as String,
    fechaGeneracion: DateTime.parse(j['fechaGeneracion'] as String),
    fechaAprobacion: j['fechaAprobacion'] != null ? DateTime.parse(j['fechaAprobacion'] as String) : null,
    fechaRecepcion: j['fechaRecepcion'] != null ? DateTime.parse(j['fechaRecepcion'] as String) : null,
    observaciones: j['observaciones'] as String?,
  );

  OrdenCompra toEntity() => OrdenCompra(
    id: id, requerimientoId: requerimientoId, materialId: materialId,
    nombreProveedor: nombreProveedor, cantidad: cantidad,
    precioUnitario: precioUnitario, costoEstimado: costoEstimado,
    estado: _parseEstado(estado), fechaGeneracion: fechaGeneracion,
    fechaAprobacion: fechaAprobacion, fechaRecepcion: fechaRecepcion,
    observaciones: observaciones,
  );

  static EstadoOC _parseEstado(String v) {
    switch (v.toUpperCase()) {
      case 'APROBADA':  return EstadoOC.aprobada;
      case 'RECIBIDA':  return EstadoOC.recibida;
      case 'RECHAZADA': return EstadoOC.rechazada;
      case 'ANULADA':   return EstadoOC.anulada;
      default:          return EstadoOC.pendiente;
    }
  }
}

// ── DATASOURCE ────────────────────────────────────────────────────────────────

class OrdenCompraRemoteDatasource {
  final ApiClient _api;
  OrdenCompraRemoteDatasource(this._api);

  Future<List<OrdenCompraModel>> listar() async {
    final r = await _api.dio.get('/ordenes');
    return (r.data['data'] as List).map((e) => OrdenCompraModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<OrdenCompraModel>> pendientes() async {
    final r = await _api.dio.get('/ordenes/pendientes');
    return (r.data['data'] as List).map((e) => OrdenCompraModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<OrdenCompraModel>> generar(int proformaId) async {
    final r = await _api.dio.post('/ordenes/generar', queryParameters: {'proformaId': proformaId});
    return (r.data['data'] as List).map((e) => OrdenCompraModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrdenCompraModel> aprobar(int id) async {
    final r = await _api.dio.post('/ordenes/$id/aprobar');
    return OrdenCompraModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  Future<OrdenCompraModel> rechazar(int id, String obs) async {
    final r = await _api.dio.post('/ordenes/$id/rechazar', data: {'observaciones': obs});
    return OrdenCompraModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  Future<OrdenCompraModel> recibir(int id) async {
    final r = await _api.dio.post('/ordenes/$id/recibir');
    return OrdenCompraModel.fromJson(r.data['data'] as Map<String, dynamic>);
  }
}

// ── REPOSITORY IMPL ───────────────────────────────────────────────────────────

class OrdenCompraRepositoryImpl implements OrdenCompraRepository {
  final OrdenCompraRemoteDatasource _ds;
  OrdenCompraRepositoryImpl(this._ds);

  @override
  Future<({List<OrdenCompra>? ordenes, Failure? failure})> listar() async {
    try { return (ordenes: (await _ds.listar()).map((m) => m.toEntity()).toList(), failure: null); }
    on DioException catch (e) { return (ordenes: null, failure: _map(e)); }
  }

  @override
  Future<({List<OrdenCompra>? ordenes, Failure? failure})> pendientes() async {
    try { return (ordenes: (await _ds.pendientes()).map((m) => m.toEntity()).toList(), failure: null); }
    on DioException catch (e) { return (ordenes: null, failure: _map(e)); }
  }

  @override
  Future<({List<OrdenCompra>? ordenes, Failure? failure})> generarDesdeProforma(int proformaId) async {
    try { return (ordenes: (await _ds.generar(proformaId)).map((m) => m.toEntity()).toList(), failure: null); }
    on DioException catch (e) { return (ordenes: null, failure: _map(e)); }
  }

  @override
  Future<({OrdenCompra? orden, Failure? failure})> aprobar(int id) async {
    try { return (orden: (await _ds.aprobar(id)).toEntity(), failure: null); }
    on DioException catch (e) { return (orden: null, failure: _map(e)); }
  }

  @override
  Future<({OrdenCompra? orden, Failure? failure})> rechazar(int id, String obs) async {
    try { return (orden: (await _ds.rechazar(id, obs)).toEntity(), failure: null); }
    on DioException catch (e) { return (orden: null, failure: _map(e)); }
  }

  @override
  Future<({OrdenCompra? orden, Failure? failure})> recibir(int id) async {
    try { return (orden: (await _ds.recibir(id)).toEntity(), failure: null); }
    on DioException catch (e) { return (orden: null, failure: _map(e)); }
  }

  Failure _map(DioException e) {
    if (e.type == DioExceptionType.connectionError) return const NetworkFailure();
    final msg = e.response?.data?['mensaje'] ?? 'Error del servidor.';
    if (e.response?.statusCode == 400) return ValidationFailure(msg);
    return ServerFailure(msg, statusCode: e.response?.statusCode);
  }
}
