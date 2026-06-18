import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<dynamic> _usuarios = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() { _loading = true; _error = null; });
    try {
      final dio = sl<ApiClient>().dio;
      final response = await dio.get('/api/v1/usuarios');
      setState(() {
        _usuarios = (response.data['data'] as List?) ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Error al cargar usuarios: $e'; _loading = false; });
    }
  }

  Future<void> _toggleActivo(int id, bool activoActual) async {
    try {
      final dio = sl<ApiClient>().dio;
      await dio.patch('/api/v1/usuarios/$id/toggle-activo');
      _cargarUsuarios();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _mostrarDialogoCrear() {
    final nombreCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Usuario'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre completo')),
            const SizedBox(height: 8),
            TextField(controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 8),
            TextField(controller: passCtrl,
                decoration: const InputDecoration(labelText: 'Contraseña (mín. 8 chars)'),
                obscureText: true),
            const SizedBox(height: 8),
            TextField(controller: telefonoCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
                keyboardType: TextInputType.phone),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () async {
              if (nombreCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
              try {
                final dio = sl<ApiClient>().dio;
                await dio.post('/api/v1/usuarios', data: {
                  'nombre': nombreCtrl.text,
                  'email': emailCtrl.text,
                  'password': passCtrl.text,
                  'telefono': telefonoCtrl.text.isEmpty ? null : telefonoCtrl.text,
                });
                if (ctx.mounted) Navigator.pop(ctx);
                _cargarUsuarios();
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
                  );
                }
              }
            },
            child: const Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarUsuarios),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const SizedBox(height: 8),
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _cargarUsuarios, child: const Text('Reintentar')),
                ]))
              : _usuarios.isEmpty
                  ? const Center(child: Text('No hay usuarios registrados.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _usuarios.length,
                      itemBuilder: (context, index) {
                        final u = _usuarios[index];
                        final roles = (u['roles'] as List?)?.map((r) => r['nombre'] as String).join(', ') ?? '';
                        final activo = u['activo'] as bool? ?? false;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: activo ? AppTheme.primary : Colors.grey,
                              child: Text(
                                (u['nombre'] as String? ?? '?').substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(u['nombre'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(u['email'] ?? '', style: const TextStyle(color: AppTheme.textSecondary)),
                              if (roles.isNotEmpty)
                                Text('Roles: $roles',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.accent)),
                            ]),
                            trailing: Switch(
                              value: activo,
                              activeTrackColor: AppTheme.success,
                              onChanged: (v) => _toggleActivo(u['id'] as int, activo),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: _mostrarDialogoCrear,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
