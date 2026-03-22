import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../materiales/presentation/bloc/material_bloc.dart';
import '../../../materiales/presentation/bloc/material_event_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event_state.dart';
import '../../../../core/theme/app_theme.dart';

/// Pantalla Dashboard principal.
/// Coincide con el wireframe aprobado (Pantalla 2).
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<MaterialBloc>().add(CargarMateriales());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final nombreUsuario = authState is AuthAuthenticated
        ? authState.usuario.nombre
        : 'Usuario';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.warehouse_rounded, size: 22),
            const SizedBox(width: 8),
            const Text('InvGest',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accent,
              child: Text(
                nombreUsuario.isNotEmpty
                    ? nombreUsuario[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(nombreUsuario),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Proyectos',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(String nombreUsuario) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saludo
          Text(
            'Buenas tardes, $nombreUsuario 👋',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const Text(
            'Resumen del sistema',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // KPI Cards
          _buildKpiSection(),
          const SizedBox(height: 24),

          // Últimos movimientos (placeholder)
          _buildUltimosMovimientos(),
        ],
      ),
    );
  }

  Widget _buildKpiSection() {
    return BlocBuilder<MaterialBloc, MaterialState>(
      builder: (context, state) {
        int criticos = 0, bajos = 0;
        if (state is MaterialesLoaded) {
          criticos = state.stockCritico;
          bajos    = state.stockBajo;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RESUMEN GENERAL',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppTheme.textSecondary)),
                TextButton(
                  onPressed: () {},
                  child: const Text('Ver todo →',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _KpiCard(
                  label: 'Stock Crítico',
                  value: criticos.toString(),
                  subtitle: 'materiales bajo mínimo',
                  color: AppTheme.stockCritico,
                ),
                _KpiCard(
                  label: 'Proyectos Activos',
                  value: '—',
                  subtitle: 'en ejecución',
                  color: AppTheme.primary,
                ),
                _KpiCard(
                  label: 'Stock Bajo',
                  value: bajos.toString(),
                  subtitle: 'requieren atención',
                  color: AppTheme.stockBajo,
                ),
                _KpiCard(
                  label: 'OC Pendientes',
                  value: '—',
                  subtitle: 'sin aprobar',
                  color: AppTheme.accent,
                  textColor: AppTheme.primary,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildUltimosMovimientos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ÚLTIMOS MOVIMIENTOS',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppTheme.textSecondary)),
            TextButton(
              onPressed: () {},
              child: const Text('Ver todos →',
                  style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _MovimientoItem(
                  tipo: 'INGRESO',
                  nombre: 'Cemento Portland 42.5',
                  detalle: '200 bolsas · Proveedor: SOBOCE',
                  hora: '14:23',
                ),
                const Divider(height: 16),
                _MovimientoItem(
                  tipo: 'SALIDA',
                  nombre: 'Varilla corrugada 1/2"',
                  detalle: '150 kg · Obra: Bloque B',
                  hora: '11:05',
                ),
                const Divider(height: 16),
                _MovimientoItem(
                  tipo: 'INGRESO',
                  nombre: 'Pintura blanca látex',
                  detalle: '40 galones · Factura #1547',
                  hora: '09:30',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final Color? textColor;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? color)),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _MovimientoItem extends StatelessWidget {
  final String tipo;
  final String nombre;
  final String detalle;
  final String hora;

  const _MovimientoItem({
    required this.tipo,
    required this.nombre,
    required this.detalle,
    required this.hora,
  });

  @override
  Widget build(BuildContext context) {
    final esIngreso = tipo == 'INGRESO';
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: esIngreso ? AppTheme.stockNormal : AppTheme.stockCritico,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${esIngreso ? "Ingreso" : "Salida"}: $nombre',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(detalle,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        Text(hora,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}
