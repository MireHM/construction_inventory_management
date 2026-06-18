import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../materiales/presentation/bloc/material_bloc.dart';
import '../../../materiales/presentation/bloc/material_event_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event_state.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _kpis;
  Map<int, String> _nombresMateriales = {};
  bool _loading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<MaterialBloc>().add(CargarMateriales());
    _cargarKpis();
  }

  Future<void> _cargarKpis() async {
    try {
      final results = await Future.wait([
        sl<ApiClient>().dio.get('/reportes/dashboard'),
        sl<ApiClient>().dio.get('/materiales'),
      ]);
      final kpisData = results[0].data['data'] as Map<String, dynamic>;
      final matList  = results[1].data['data'] as List;
      final nombres  = <int, String>{};
      for (final m in matList) {
        final mat = m as Map<String, dynamic>;
        nombres[mat['id'] as int] = mat['nombre'] as String;
      }
      if (mounted) setState(() {
        _kpis = kpisData;
        _nombresMateriales = nombres;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final nombre = authState is AuthAuthenticated ? authState.usuario.nombre.split(' ').first : 'Usuario';
    final alertaCount = (_kpis?['alertasPendientes'] ?? 0) as int;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.warehouse_rounded, size: 22), SizedBox(width: 8), Text('InvGest', style: TextStyle(fontWeight: FontWeight.bold))]),
        actions: [
          Stack(children: [
            IconButton(icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/alertas')),
            if (alertaCount > 0)
              Positioned(right: 8, top: 8, child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle),
                child: Text('$alertaCount', style: const TextStyle(color: Colors.white, fontSize: 9)),
              )),
          ]),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 48),
              onSelected: (value) async {
                if (value == 'logout') {
                  context.read<AuthBloc>().add(LogoutRequested());
                  context.go('/login');
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const Text('Administrador', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ]),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(children: [
                    Icon(Icons.logout, size: 18, color: AppTheme.error),
                    SizedBox(width: 10),
                    Text('Cerrar sesión', style: TextStyle(color: AppTheme.error)),
                  ]),
                ),
              ],
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.accent,
                child: Text(
                  nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(child: ListView(padding: EdgeInsets.zero, children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: AppTheme.primary),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
            const Icon(Icons.warehouse_rounded, size: 36, color: Colors.white),
            const SizedBox(height: 8),
            const Text('InventarioPro', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(nombre, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
        ),
        _DrawerItem(Icons.home_outlined, 'Inicio', () => context.pop()),
        _DrawerItem(Icons.inventory_2_outlined, 'Catálogo de Materiales', () { context.pop(); context.push('/catalogo'); }),
        _DrawerItem(Icons.bar_chart_outlined, 'Control de Inventario', () { context.pop(); context.push('/inventario'); }),
        _DrawerItem(Icons.history, 'Historial de Movimientos', () { context.pop(); context.push('/historial'); }),
        _DrawerItem(Icons.notifications_outlined, 'Alertas de Stock', () { context.pop(); context.push('/alertas'); }),
        _DrawerItem(Icons.receipt_long_outlined, 'Órdenes de Compra', () { context.pop(); context.push('/ordenes'); }),
        _DrawerItem(Icons.calculate_outlined, 'Proformas / APU', () { context.pop(); context.push('/proformas/1'); }),
        _DrawerItem(Icons.assessment_outlined, 'Reporte de Stock', () { context.pop(); context.push('/reportes/stock'); }),
        const Divider(),
        _DrawerItem(Icons.folder_outlined, 'Proyectos', () { context.pop(); context.push('/proyectos'); }),
        _DrawerItem(Icons.store_outlined, 'Proveedores', () { context.pop(); context.push('/proveedores'); }),
        _DrawerItem(Icons.category_outlined, 'Categorías', () { context.pop(); context.push('/categorias'); }),
        _DrawerItem(Icons.straighten_outlined, 'Unidades de Medida', () { context.pop(); context.push('/unidades-medida'); }),
        _DrawerItem(Icons.people_outlined, 'Usuarios', () { context.pop(); context.push('/usuarios'); }),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: AppTheme.error),
          title: const Text('Cerrar sesión', style: TextStyle(color: AppTheme.error)),
          onTap: () {
            context.read<AuthBloc>().add(LogoutRequested());
            context.go('/login');
          },
        ),
      ])),
      body: RefreshIndicator(
        onRefresh: () async { context.read<MaterialBloc>().add(CargarMateriales()); await _cargarKpis(); },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Buenas tardes, $nombre', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const Text('Resumen del sistema', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            _loading ? const Center(child: CircularProgressIndicator()) : _buildKpis(),
            const SizedBox(height: 24),
            _buildUltimosMovimientos(),
            const SizedBox(height: 24),
            _buildAccesosRapidos(context),
          ]),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          setState(() => _selectedIndex = i);
          switch (i) {
            case 1: context.push('/catalogo'); break;
            case 2: context.push('/inventario'); break;
            case 3: context.push('/ordenes'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Catálogo'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Inventario'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Órdenes'),
        ],
      ),
    );
  }

  Widget _buildKpis() => Row(
    children: [
      Expanded(child: _KpiCard(label: 'Stock\nCritico', value: '${_kpis?['materialesSinStock'] ?? 0}', subtitle: 'sin stock', color: AppTheme.stockCritico, onTap: () => context.push('/reportes/stock'))),
      const SizedBox(width: 8),
      Expanded(child: _KpiCard(label: 'Stock\nBajo', value: '${_kpis?['materialesBajoMin'] ?? 0}', subtitle: 'bajo min.', color: AppTheme.stockBajo, onTap: () => context.push('/reportes/stock'))),
      const SizedBox(width: 8),
      Expanded(child: _KpiCard(label: 'OC\nPend.', value: '${_kpis?['ocPendientes'] ?? 0}', subtitle: 'sin aprobar', color: AppTheme.accent, textColor: AppTheme.primary, onTap: () => context.push('/ordenes'))),
      const SizedBox(width: 8),
      Expanded(child: _KpiCard(label: 'Alertas\nPend.', value: '${_kpis?['alertasPendientes'] ?? 0}', subtitle: 'pendientes', color: AppTheme.primary, onTap: () => context.push('/alertas'))),
    ],
  );

  Widget _buildUltimosMovimientos() {
    final movs = _kpis?['ultimosMovimientos'] as List? ?? [];
    if (movs.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('ÚLTIMOS MOVIMIENTOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppTheme.textSecondary)),
        TextButton(onPressed: () => context.push('/historial'), child: const Text('Ver todos →', style: TextStyle(fontSize: 12))),
      ]),
      const SizedBox(height: 8),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: movs.asMap().entries.map((entry) {
        final m = entry.value as Map<String, dynamic>;
        final esIngreso = m['tipo'] == 'INGRESO';
        return Column(children: [
          if (entry.key > 0) const Divider(height: 14),
          Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle,
                color: esIngreso ? AppTheme.stockNormal : AppTheme.stockCritico)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${esIngreso ? "Ingreso" : "Salida"}: ${_nombresMateriales[m["materialId"] as int] ?? "Material #${m["materialId"]}"}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text('Cantidad: ${m["cantidad"]}  ·  ${_fmtFecha(m["fecha"] as String? ?? "")}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ])),
          ]),
        ]);
      }).toList()))),
    ]);
  }

  Widget _buildAccesosRapidos(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('ACCESOS RÁPIDOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppTheme.textSecondary)),
    const SizedBox(height: 10),
    Row(children: [
      _AccesoRapido(Icons.arrow_upward,        'Ingreso',     AppTheme.stockNormal,   () => context.push('/inventario/ingreso')),
      const SizedBox(width: 8),
      _AccesoRapido(Icons.arrow_downward,      'Salida',      AppTheme.stockCritico,  () => context.push('/inventario/salida')),
      const SizedBox(width: 8),
      _AccesoRapido(Icons.calculate_outlined,  'Calcular',    AppTheme.primary,       () => context.push('/proformas/1')),
      const SizedBox(width: 8),
      _AccesoRapido(Icons.bar_chart_outlined,  'Reporte',     AppTheme.stockBajo,     () => context.push('/reportes/stock')),
    ]),
  ]);

  String _fmtFecha(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} '
          '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) { return iso; }
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value, subtitle;
  final Color color;
  final Color? textColor;
  final VoidCallback? onTap;
  const _KpiCard({required this.label, required this.value, required this.subtitle, required this.color, this.textColor, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor ?? color)),
        Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
      ]),
    ),
  );
}

class _AccesoRapido extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _AccesoRapido(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: color, size: 22), const SizedBox(height: 4),
      Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    ]),
  )));
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppTheme.primary, size: 22),
    title: Text(label, style: const TextStyle(fontSize: 14)),
    onTap: onTap,
    dense: true,
  );
}