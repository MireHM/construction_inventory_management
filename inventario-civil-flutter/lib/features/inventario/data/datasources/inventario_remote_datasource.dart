import '../../../../core/network/api_client.dart';
import '../models/movimiento_model.dart';

class InventarioRemoteDatasource {
  final ApiClient _apiClient;
  InventarioRemoteDatasource(this._apiClient);

  Future<MovimientoModel> registrarIngreso(Map<String, dynamic> body) async {
    final res = await _apiClient.dio.post('/inventario/ingresos', data: body);
    return MovimientoModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<MovimientoModel> registrarSalida(Map<String, dynamic> body) async {
    final res = await _apiClient.dio.post('/inventario/salidas', data: body);
    return MovimientoModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<MovimientoModel>> historialPorMaterial(int materialId) async {
    final res = await _apiClient.dio
        .get('/inventario/materiales/$materialId/historial');
    final List data = res.data['data'] as List;
    return data
        .map((e) => MovimientoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MovimientoModel>> recientes() async {
    final res = await _apiClient.dio.get('/inventario/movimientos/recientes');
    final List data = res.data['data'] as List;
    return data
        .map((e) => MovimientoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> alertasPendientes() async {
    final res = await _apiClient.dio.get('/inventario/alertas');
    return (res.data['data'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}
