import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/orden_bloc.dart';
import '../../domain/entities/orden_compra.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

class OrdenesPage extends StatefulWidget {
  const OrdenesPage({super.key});
  @override
  State<OrdenesPage> createState() => _OrdenesPageState();
}

class _OrdenesPageState extends State<OrdenesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  Map<int, Map<String, dynamic>> _materiales = {};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    context.read<OrdenBloc>().add(CargarOrdenes());
    _cargarMateriales();
  }

  Future<void> _cargarMateriales() async {
    try {
      final res = await sl<ApiClient>().dio.get('/materiales');
      final list = res.data['data'] as List;
      final map = <int, Map<String, dynamic>>{};
      for (final m in list) {
        final mat = m as Map<String, dynamic>;
        map[mat['id'] as int] = mat;
      }
      if (mounted) setState(() => _materiales = map);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Órdenes de Compra'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppTheme.accent,
          tabs: const [Tab(text: 'Todas'), Tab(text: 'Pendientes')],
        ),
      ),
      body: BlocConsumer<OrdenBloc, OrdenState>(
        listener: (context, state) {
          if (state is OrdenActualizada) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.mensaje),
              backgroundColor: AppTheme.stockNormal,
            ));
            context.read<OrdenBloc>().add(CargarOrdenes());
          }
          if (state is OrdenError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.error,
            ));
          }
          if (state is OrdenesGeneradas) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${state.ordenes.length} órdenes generadas.'),
              backgroundColor: AppTheme.stockNormal,
            ));
            context.read<OrdenBloc>().add(CargarOrdenes());
          }
        },
        builder: (context, state) {
          if (state is OrdenLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          List<OrdenCompra> ordenes = [];
          if (state is OrdenesLoaded) ordenes = state.ordenes;
          return TabBarView(
            controller: _tabs,
            children: [
              _ListaOrdenes(
                ordenes: ordenes,
                materiales: _materiales,
                onRefresh: () => context.read<OrdenBloc>().add(CargarOrdenes()),
              ),
              _ListaOrdenes(
                ordenes: ordenes.where((o) => o.esPendiente).toList(),
                materiales: _materiales,
                onRefresh: () => context.read<OrdenBloc>().add(CargarPendientes()),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Lista ─────────────────────────────────────────────────────────────────────

class _ListaOrdenes extends StatelessWidget {
  final List<OrdenCompra> ordenes;
  final Map<int, Map<String, dynamic>> materiales;
  final VoidCallback onRefresh;
  const _ListaOrdenes({required this.ordenes, required this.materiales, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (ordenes.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.receipt_long_outlined, size: 56, color: AppTheme.textSecondary),
        const SizedBox(height: 12),
        const Text('No hay órdenes de compra.', style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: onRefresh, icon: const Icon(Icons.refresh), label: const Text('Actualizar')),
      ]));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ordenes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _OrdenCard(orden: ordenes[i], material: materiales[ordenes[i].materialId]),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _OrdenCard extends StatelessWidget {
  final OrdenCompra orden;
  final Map<String, dynamic>? material;
  const _OrdenCard({required this.orden, this.material});

  @override
  Widget build(BuildContext context) {
    final nombre  = material?['nombre'] as String? ?? 'Material #${orden.materialId}';
    final codigo  = material?['codigo'] as String? ?? '';
    final unidad  = _unidadSimbolo(material?['unidadMedidaId'] as int?);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Encabezado — número OC + estado
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('OC-${orden.id.toString().padLeft(4, '0')}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            _EstadoBadge(estado: orden.estado),
          ]),
          const SizedBox(height: 8),

          // Nombre del material
          Text(nombre,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
          const SizedBox(height: 2),

          // Código + cantidad + unidad
          Row(children: [
            if (codigo.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(codigo, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              '${orden.cantidad.toStringAsFixed(0)} ${unidad.isNotEmpty ? unidad : 'unid.'}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            if (orden.costoEstimado != null) ...[
              const SizedBox(width: 8),
              const Text('·', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(width: 8),
              Text('Bs. ${orden.costoEstimado!.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ]),
          const SizedBox(height: 4),
          Text(_formatFecha(orden.fechaGeneracion),
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),

          // Botones de acción según estado
          if (orden.esPendiente)
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.stockNormal,
                    side: const BorderSide(color: AppTheme.stockNormal)),
                onPressed: () => context.read<OrdenBloc>().add(AprobarOrden(orden.id)),
                icon: const Icon(Icons.check, size: 16), label: const Text('Aprobar'),
              )),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: const BorderSide(color: AppTheme.error)),
                onPressed: () => _showRechazarDialog(context, orden.id),
                icon: const Icon(Icons.close, size: 16), label: const Text('Rechazar'),
              )),
            ]),

          if (orden.esAprobada)
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              onPressed: () => context.read<OrdenBloc>().add(RecibirOrden(orden.id)),
              icon: const Icon(Icons.local_shipping_outlined, size: 16),
              label: const Text('Registrar recepción'),
            )),

          if (orden.esRecibida)
            const Row(children: [
              Icon(Icons.check_circle, color: AppTheme.stockNormal, size: 16),
              SizedBox(width: 6),
              Text('Recibida – stock actualizado',
                  style: TextStyle(color: AppTheme.stockNormal, fontSize: 12)),
            ]),

          if (orden.esRechazada && orden.observaciones != null)
            Row(children: [
              const Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 14),
              const SizedBox(width: 4),
              Expanded(child: Text(orden.observaciones!,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
            ]),
        ]),
      ),
    );
  }

  void _showRechazarDialog(BuildContext context, int id) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rechazar Orden', style: TextStyle(fontSize: 16)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Motivo del rechazo...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              context.read<OrdenBloc>().add(RechazarOrden(id, ctrl.text));
              Navigator.pop(context);
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime dt) =>
      '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}  '
          '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';

  String _unidadSimbolo(int? id) {
    const map = {1:'m', 2:'m²', 3:'m³', 4:'kg', 5:'und', 6:'gl', 7:'bolsa', 8:'saco', 9:'lt', 10:'tn'};
    return map[id] ?? '';
  }
}

// ── Badge de estado ───────────────────────────────────────────────────────────

class _EstadoBadge extends StatelessWidget {
  final EstadoOC estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    late String label; late Color color;
    switch (estado) {
      case EstadoOC.pendiente:  label = 'Pendiente';  color = AppTheme.stockBajo; break;
      case EstadoOC.aprobada:   label = 'Aprobada';   color = AppTheme.stockNormal; break;
      case EstadoOC.recibida:   label = 'Recibida';   color = AppTheme.primary; break;
      case EstadoOC.rechazada:  label = 'Rechazada';  color = AppTheme.error; break;
      case EstadoOC.anulada:    label = 'Anulada';    color = AppTheme.textSecondary; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}