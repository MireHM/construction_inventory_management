import 'package:equatable/equatable.dart';

class AlertaStock extends Equatable {
  final int id;
  final int materialId;
  final String tipo; // STOCK_MINIMO | STOCK_MAXIMO | SIN_STOCK
  final double stockAlMomento;
  final bool atendida;
  final DateTime createdAt;

  const AlertaStock({
    required this.id,
    required this.materialId,
    required this.tipo,
    required this.stockAlMomento,
    required this.atendida,
    required this.createdAt,
  });

  bool get esCritica => tipo == 'SIN_STOCK';

  @override
  List<Object?> get props => [id, materialId, tipo, atendida];
}
