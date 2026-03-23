import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../materiales/presentation/bloc/material_bloc.dart';
import '../../../materiales/presentation/bloc/material_event_state.dart';
import '../../../materiales/domain/entities/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Pantalla Control de Inventario – Pantalla 4 del wireframe.
/// Muestra la lista de materiales con barra de stock visual y
/// botones de Ingreso / Salida en la parte inferior.
class ControlInventarioPage extends StatefulWidget {
  const ControlInventarioPage({super.key});

  @override
  State<ControlInventarioPage> createState() => _ControlInventarioPageState();
}

class _ControlInventarioPageState extends State<ControlInventarioPage> {
  @override
  void initState() {
    super.initState();
    context.read<MaterialBloc>().add(CargarMateriales());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Control de Inventario'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _LeyendaStock(),
          Expanded(child: _ListaMateriales()),
        ],
      ),
      bottomNavigationBar: _BottomButtons(),
    );
  }
}

class _LeyendaStock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialBloc, MaterialState>(
      builder: (context, state) {
        int total = 0;
        if (state is MaterialesLoaded) total = state.materiales.length;
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _LegendDot(AppTheme.stockNormal, 'Normal'),
              const SizedBox(width: 12),
              _LegendDot(AppTheme.stockBajo, 'Bajo'),
              const SizedBox(width: 12),
              _LegendDot(AppTheme.stockCritico, 'Crítico'),
              const Spacer(),
              Text('$total materiales',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 4),
      Text(label,
          style:
              const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
    ]);
  }
}

class _ListaMateriales extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialBloc, MaterialState>(
      builder: (context, state) {
        if (state is MaterialLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MaterialError) {
          return Center(child: Text(state.message));
        }
        if (state is MaterialesLoaded) {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            itemCount: state.materiales.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) =>
                _StockCard(material: state.materiales[i]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _StockCard extends StatelessWidget {
  final Material material;
  const _StockCard({required this.material});

  @override
  Widget build(BuildContext context) {
    final color   = _color(material.estadoStock);
    final porcentaje = material.stockMinimo > 0
        ? (material.stockActual / (material.stockMaximo ?? material.stockMinimo * 5))
              .clamp(0.0, 1.0)
        : 0.5;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Ícono
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.inventory_2_outlined,
                  size: 18, color: AppTheme.primary),
            ),
            const SizedBox(width: 10),

            // Info + barra de progreso
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(material.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(
                    '${material.stockActual.toStringAsFixed(0)} · Mín: ${material.stockMinimo.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: porcentaje,
                      minHeight: 5,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Porcentaje
            Text(
              '${(porcentaje * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }

  Color _color(EstadoStock estado) {
    switch (estado) {
      case EstadoStock.critico: return AppTheme.stockCritico;
      case EstadoStock.bajo:    return AppTheme.stockBajo;
      case EstadoStock.normal:  return AppTheme.stockNormal;
    }
  }
}

class _BottomButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.stockNormal,
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => context.push('/inventario/ingreso'),
              icon: const Icon(Icons.arrow_upward, size: 18),
              label: const Text('Ingreso'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.stockCritico,
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => context.push('/inventario/salida'),
              icon: const Icon(Icons.arrow_downward, size: 18),
              label: const Text('Salida'),
            ),
          ),
        ],
      ),
    );
  }
}
