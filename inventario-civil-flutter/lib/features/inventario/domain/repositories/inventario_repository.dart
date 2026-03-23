import '../entities/movimiento.dart';
import '../entities/alerta_stock.dart';
import '../../../../core/errors/failures.dart';

abstract class InventarioRepository {
  Future<({Movimiento? movimiento, Failure? failure})> registrarIngreso({
    required int materialId,
    required double cantidad,
    double? precioUnitario,
    int? proveedorId,
    String? numeroFactura,
    int? proyectoId,
    String? motivo,
  });

  Future<({Movimiento? movimiento, Failure? failure})> registrarSalida({
    required int materialId,
    required double cantidad,
    required int proyectoId,
    required String frenteObra,
    String? motivo,
  });

  Future<({List<Movimiento>? movimientos, Failure? failure})>
      historialPorMaterial(int materialId);

  Future<({List<Movimiento>? movimientos, Failure? failure})> recientes();

  Future<({List<AlertaStock>? alertas, Failure? failure})> alertasPendientes();
}
