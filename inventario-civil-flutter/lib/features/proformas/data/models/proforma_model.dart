import '../../domain/entities/proforma.dart';

class PartidaModel {
  final int id;
  final int apuId;
  final String? itemNumero;
  final String? descripcion;
  final double cantidadObra;
  final double? precioUnitario;
  final int orden;

  const PartidaModel({
    required this.id, required this.apuId, this.itemNumero,
    this.descripcion, required this.cantidadObra,
    this.precioUnitario, required this.orden,
  });

  factory PartidaModel.fromJson(Map<String, dynamic> j) => PartidaModel(
    id: j['id'] as int, apuId: j['apuId'] as int,
    itemNumero: j['itemNumero'] as String?,
    descripcion: j['descripcion'] as String?,
    cantidadObra: (j['cantidadObra'] as num).toDouble(),
    precioUnitario: j['precioUnitario'] != null
        ? (j['precioUnitario'] as num).toDouble() : null,
    orden: j['orden'] as int? ?? 1,
  );

  PartidaProforma toEntity() => PartidaProforma(
    id: id, apuId: apuId, itemNumero: itemNumero,
    descripcion: descripcion, cantidadObra: cantidadObra,
    precioUnitario: precioUnitario, orden: orden,
  );
}

class ProformaModel {
  final int id;
  final int proyectoId;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String estado;
  final List<PartidaModel> partidas;
  final DateTime createdAt;

  const ProformaModel({
    required this.id, required this.proyectoId, required this.codigo,
    required this.nombre, this.descripcion, required this.estado,
    required this.partidas, required this.createdAt,
  });

  factory ProformaModel.fromJson(Map<String, dynamic> j) => ProformaModel(
    id: j['id'] as int, proyectoId: j['proyectoId'] as int,
    codigo: j['codigo'] as String, nombre: j['nombre'] as String,
    descripcion: j['descripcion'] as String?, estado: j['estado'] as String,
    partidas: (j['partidas'] as List? ?? [])
        .map((e) => PartidaModel.fromJson(e as Map<String, dynamic>)).toList(),
    createdAt: DateTime.parse(j['createdAt'] as String),
  );

  Proforma toEntity() => Proforma(
    id: id, proyectoId: proyectoId, codigo: codigo, nombre: nombre,
    descripcion: descripcion, estado: estado,
    partidas: partidas.map((p) => p.toEntity()).toList(),
    createdAt: createdAt,
  );
}

class RequerimientoModel {
  final int id;
  final int materialId;
  final int? partidaId;
  final double cantidadCalculada;
  final double cantidadDisponible;
  final double cantidadAComprar;
  final DateTime fechaCalculo;

  const RequerimientoModel({
    required this.id, required this.materialId, this.partidaId,
    required this.cantidadCalculada, required this.cantidadDisponible,
    required this.cantidadAComprar, required this.fechaCalculo,
  });

  factory RequerimientoModel.fromJson(Map<String, dynamic> j) =>
      RequerimientoModel(
        id: j['id'] as int, materialId: j['materialId'] as int,
        partidaId: j['partidaId'] as int?,
        cantidadCalculada: (j['cantidadCalculada'] as num).toDouble(),
        cantidadDisponible: (j['cantidadDisponible'] as num).toDouble(),
        cantidadAComprar: (j['cantidadAComprar'] as num).toDouble(),
        fechaCalculo: DateTime.parse(j['fechaCalculo'] as String),
      );

  Requerimiento toEntity() => Requerimiento(
    id: id, materialId: materialId, partidaId: partidaId,
    cantidadCalculada: cantidadCalculada,
    cantidadDisponible: cantidadDisponible,
    cantidadAComprar: cantidadAComprar,
    fechaCalculo: fechaCalculo,
  );
}
