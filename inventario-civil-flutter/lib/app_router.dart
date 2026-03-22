import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/materiales/presentation/bloc/material_bloc.dart';
import 'features/materiales/presentation/pages/catalogo_materiales_page.dart';
import 'injection_container.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthBloc>()..add(CheckAuthStatus()),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<AuthBloc>()),
            BlocProvider(create: (_) => sl<MaterialBloc>()),
          ],
          child: const DashboardPage(),
        ),
      ),
      GoRoute(
        path: '/catalogo',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<MaterialBloc>()..add(CargarMateriales()),
          child: const CatalogoMaterialesPage(),
        ),
      ),
    ],
  );
}

class _SplashPage extends StatefulWidget {
  const _SplashPage();
  @override
  State<_SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<_SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authBloc = sl<AuthBloc>()..add(CheckAuthStatus());
    final state = await authBloc.stream.first;
    if (!mounted) return;
    if (state is AuthAuthenticated) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1B3A6B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warehouse_rounded, size: 64, color: Colors.white),
            SizedBox(height: 16),
            Text('InventarioPro',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
