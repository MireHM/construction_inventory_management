import 'package:dio/dio.dart';
import '../../domain/entities/movimiento.dart';
import '../../domain/entities/alerta_stock.dart';
import '../../domain/repositories/inventario_repository.dart';
import '../datasources/inventario_remote_datasource.dart';
import '../../../../core/errors/failures.dart';

class InventarioRepositoryImpl implements InventarioRepository {
  final InventarioRemoteDatasource _datasource;
  InventarioRepositoryImpl(this._datasource);

  @override
  Future<({Movimiento? movimiento, Failure? failure})> registrarIngreso({
    required int materialId,
    required double cantidad,
    double? precioUnitario,
    int? proveedorId,
    String? numeroFactura,
    int? proyectoId,
    String? motivo,
  }) async {
    try {
      final m = await _datasource.registrarIngreso({
        'materialId': materialId,
        'cantidad': cantidad,
        if (precioUnitario != null) 'precioUnitario': precioUnitario,
        if (proveedorId != null) 'proveedorId': proveedorId,
        if (numeroFactura != null) 'numeroFactura': numeroFactura,
        if (proyectoId != null) 'proyectoId': proyectoId,
        if (motivo != null) 'motivo': motivo,
      });
      return (movimiento: m.toEntity(), failure: null);
    } on DioException catch (e) {
      return (movimiento: null, failure: _map(e));
    }
  }

  @override
  Future<({Movimiento? movimiento, Failure? failure})> registrarSalida({
    required int materialId,
    required double cantidad,
    required int proyectoId,
    required String frenteObra,
    String? motivo,
  }) async {
    try {
      final m = await _datasource.registrarSalida({
        'materialId': materialId,
        'cantidad': cantidad,
        'proyectoId': proyectoId,
        'frenteObra': frenteObra,
        if (motivo != null) 'motivo': motivo,
      });
      return (movimiento: m.toEntity(), failure: null);
    } on DioException catch (e) {
      return (movimiento: null, failure: _map(e));
    }
  }

  @override
  Future<({List<Movimiento>? movimientos, Failure? failure})>
      historialPorMaterial(int materialId) async {
    try {
      final list = await _datasource.historialPorMaterial(materialId);
      return (movimientos: list.map((m) => m.toEntity()).toList(), failure: null);
    } on DioException catch (e) {
      return (movimientos: null, failure: _map(e));
    }
  }

  @override
  Future<({List<Movimiento>? movimientos, Failure? failure})> recientes() async {
    try {
      final list = await _datasource.recientes();
      return (movimientos: list.map((m) => m.toEntity()).toList(), failure: null);
    } on DioException catch (e) {
      return (movimientos: null, failure: _map(e));
    }
  }

  @override
  Future<({List<AlertaStock>? alertas, Failure? failure})>
      alertasPendientes() async {
    try {
      final list = await _datasource.alertasPendientes();
      final alertas = list.map((e) => AlertaStock(
        id: e['id'] as int,
        materialId: e['materialId'] as int,
        tipo: e['tipo'] as String,
        stockAlMomento: (e['stockAlMomento'] as num).toDouble(),
        atendida: e['atendida'] as bool,
        createdAt: DateTime.parse(e['createdAt'] as String),
      )).toList();
      return (alertas: alertas, failure: null);
    } on DioException catch (e) {
      return (alertas: null, failure: _map(e));
    }
  }

  Failure _map(DioException e) {
    if (e.type == DioExceptionType.connectionError) return const NetworkFailure();
    final msg = e.response?.data?['mensaje'] ?? 'Error del servidor.';
    if (e.response?.statusCode == 400) return ValidationFailure(msg);
    return ServerFailure(msg, statusCode: e.response?.statusCode);
  }
}
