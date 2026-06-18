import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/materiales/presentation/bloc/material_bloc.dart';
import 'features/materiales/presentation/bloc/material_event_state.dart';
import 'features/materiales/presentation/pages/catalogo_materiales_page.dart';
import 'features/materiales/presentation/pages/crear_material_page.dart';
import 'features/inventario/presentation/bloc/inventario_bloc.dart';
import 'features/inventario/presentation/pages/control_inventario_page.dart';
import 'features/inventario/presentation/pages/registro_ingreso_page.dart';
import 'features/inventario/presentation/pages/registro_salida_page.dart';
import 'features/inventario/presentation/pages/alertas_page.dart';
import 'features/inventario/presentation/pages/historial_movimientos_page.dart';
import 'features/proformas/presentation/bloc/proforma_bloc.dart';
import 'features/proformas/presentation/pages/proformas_page.dart';
import 'features/proformas/presentation/pages/resultado_requerimientos_page.dart';
import 'features/proformas/presentation/pages/crear_proforma_page.dart';
import 'features/ordenes/presentation/bloc/orden_bloc.dart';
import 'features/ordenes/presentation/pages/ordenes_page.dart';
import 'features/reportes/presentation/pages/reporte_stock_page.dart';
import 'features/usuarios/presentation/pages/usuarios_page.dart';
import 'features/proyectos/presentation/pages/proyectos_page.dart';
import 'features/proveedores/presentation/pages/proveedores_page.dart';
import 'features/catalogo/presentation/pages/categorias_page.dart';
import 'features/catalogo/presentation/pages/unidades_medida_page.dart';
import 'injection_container.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const _SplashPage()),

      GoRoute(path: '/login',
          builder: (c, s) => BlocProvider(
              create: (_) => sl<AuthBloc>()..add(CheckAuthStatus()),
              child: const LoginPage())),

      GoRoute(path: '/dashboard',
          builder: (c, s) => MultiBlocProvider(providers: [
            BlocProvider(create: (_) => sl<AuthBloc>()..add(CheckAuthStatus())),
            BlocProvider(create: (_) => sl<MaterialBloc>()),
          ], child: const DashboardPage())),

      GoRoute(path: '/catalogo',
          builder: (c, s) => BlocProvider(
              create: (_) => sl<MaterialBloc>()..add(CargarMateriales()),
              child: const CatalogoMaterialesPage())),

      GoRoute(path: '/materiales/nuevo',
          builder: (c, s) => const CrearMaterialPage()),

      GoRoute(path: '/inventario',
          builder: (c, s) => MultiBlocProvider(providers: [
            BlocProvider(create: (_) => sl<MaterialBloc>()..add(CargarMateriales())),
            BlocProvider(create: (_) => sl<InventarioBloc>()),
          ], child: const ControlInventarioPage())),

      GoRoute(path: '/inventario/ingreso',
          builder: (c, s) => BlocProvider(
              create: (_) => sl<InventarioBloc>(),
              child: const RegistroIngresoPage())),

      GoRoute(path: '/inventario/salida',
          builder: (c, s) => BlocProvider(
              create: (_) => sl<InventarioBloc>(),
              child: const RegistroSalidaPage())),

      GoRoute(path: '/alertas',
          builder: (c, s) => const AlertasPage()),

      GoRoute(path: '/historial',
          builder: (c, s) => const HistorialMovimientosPage()),

      GoRoute(path: '/reportes/stock',
          builder: (c, s) => const ReporteStockPage()),

      GoRoute(path: '/proformas/:proyectoId',
          builder: (c, s) {
            final id = int.parse(s.pathParameters['proyectoId']!);
            return BlocProvider(create: (_) => sl<ProformaBloc>(), child: ProformasPage(proyectoId: id));
          }),

      GoRoute(path: '/proformas/:proyectoId/nueva',
          builder: (c, s) {
            final id = int.parse(s.pathParameters['proyectoId']!);
            return CrearProformaPage(proyectoId: id);
          }),

      GoRoute(path: '/proformas/:proformaId/requerimientos',
          builder: (c, s) {
            final id = int.parse(s.pathParameters['proformaId']!);
            return BlocProvider(create: (_) => sl<ProformaBloc>(), child: ResultadoRequerimientosPage(proformaId: id));
          }),

      GoRoute(path: '/ordenes',
          builder: (c, s) => BlocProvider(
              create: (_) => sl<OrdenBloc>(), child: const OrdenesPage())),

      GoRoute(path: '/usuarios',
          builder: (c, s) => const UsuariosPage()),

      GoRoute(path: '/proyectos',
          builder: (c, s) => const ProyectosPage()),

      GoRoute(path: '/proveedores',
          builder: (c, s) => const ProveedoresPage()),

      GoRoute(path: '/categorias',
          builder: (c, s) => const CategoriasPage()),

      GoRoute(path: '/unidades-medida',
          builder: (c, s) => const UnidadesMedidaPage()),
    ],
  );
}

class _SplashPage extends StatefulWidget {
  const _SplashPage();
  @override State<_SplashPage> createState() => _SplashPageState();
}
class _SplashPageState extends State<_SplashPage> {
  @override
  void initState() { super.initState(); _check(); }
  Future<void> _check() async {
    final bloc = sl<AuthBloc>()..add(CheckAuthStatus());
    final s = await bloc.stream.first;
    if (!mounted) return;
    context.go(s is AuthAuthenticated ? '/dashboard' : '/login');
  }
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: Color(0xFF1B3A6B),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.warehouse_rounded, size: 64, color: Colors.white),
      SizedBox(height: 16),
      Text('InventarioPro', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      SizedBox(height: 32),
      CircularProgressIndicator(color: Colors.white),
    ])),
  );
}