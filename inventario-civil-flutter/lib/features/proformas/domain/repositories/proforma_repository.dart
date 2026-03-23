import '../entities/proforma.dart';
import '../../../../core/errors/failures.dart';

abstract class ProformaRepository {
  Future<({List<Proforma>? proformas, Failure? failure})>
      listarPorProyecto(int proyectoId);

  Future<({Proforma? proforma, Failure? failure})> obtenerPorId(int id);

  Future<({List<Requerimiento>? requerimientos, Failure? failure})>
      calcularRequerimientos(int proformaId);

  Future<({List<Requerimiento>? requerimientos, Failure? failure})>
      obtenerRequerimientos(int proformaId);
}
