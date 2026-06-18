import '../../../../core/network/api_client.dart';
import '../models/material_model.dart';

class MaterialRemoteDatasource {
  final ApiClient _apiClient;
  MaterialRemoteDatasource(this._apiClient);

  Future<List<MaterialModel>> listarActivos() async {
    final res = await _apiClient.dio.get('/materiales');
    final List data = res.data['data'] as List;
    return data.map((e) => MaterialModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MaterialModel>> listarAlertas() async {
    final res = await _apiClient.dio.get('/materiales/alertas');
    final List data = res.data['data'] as List;
    return data.map((e) => MaterialModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MaterialModel> obtenerPorId(int id) async {
    final res = await _apiClient.dio.get('/materiales/$id');
    return MaterialModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<MaterialModel>> buscar({String? q, int? categoriaId, int page = 0, int size = 50}) async {
    final params = <String, dynamic>{'page': page, 'size': size};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (categoriaId != null) params['categoriaId'] = categoriaId;
    final res = await _apiClient.dio.get('/materiales/buscar', queryParameters: params);
    final List content = res.data['data']['content'] as List;
    return content.map((e) => MaterialModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
