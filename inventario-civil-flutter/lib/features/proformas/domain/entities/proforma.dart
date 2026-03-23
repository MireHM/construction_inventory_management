import 'package:equatable/equatable.dart';

class PartidaProforma extends Equatable {
  final int id;
  final int apuId;
  final String? itemNumero;
  final String? descripcion;
  final double cantidadObra;
  final double? precioUnitario;
  final int orden;

  const PartidaProforma({
    required this.id,
    required this.apuId,
    this.itemNumero,
    this.descripcion,
    required this.cantidadObra,
    this.precioUnitario,
    required this.orden,
  });

  @override
  List<Object?> get props => [id, apuId, cantidadObra];
}

class Proforma extends Equatable {
  final int id;
  final int proyectoId;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String estado;
  final List<PartidaProforma> partidas;
  final DateTime createdAt;

  const Proforma({
    required this.id,
    required this.proyectoId,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.estado,
    required this.partidas,
    required this.createdAt,
  });

  bool get esBorrador => estado == 'BORRADOR';
  bool get esVigente  => estado == 'VIGENTE';

  @override
  List<Object?> get props => [id, codigo, estado];
}

class Requerimiento extends Equatable {
  final int id;
  final int materialId;
  final int? partidaId;
  final double cantidadCalculada;
  final double cantidadDisponible;
  final double cantidadAComprar;
  final DateTime fechaCalculo;

  const Requerimiento({
    required this.id,
    required this.materialId,
    this.partidaId,
    required this.cantidadCalculada,
    required this.cantidadDisponible,
    required this.cantidadAComprar,
    required this.fechaCalculo,
  });

  bool get necesitaCompra => cantidadAComprar > 0;

  @override
  List<Object?> get props => [id, materialId, cantidadCalculada];
}
