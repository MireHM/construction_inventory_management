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
  List<dynamic> _proyectos = [];
  bool _loading = true;
  String? _error;

  static const _rolesDisponibles = [
    {'id': 1, 'nombre': 'ADMINISTRADOR'},
    {'id': 2, 'nombre': 'ALMACENERO'},
    {'id': 3, 'nombre': 'RESIDENTE'},
    {'id': 4, 'nombre': 'GERENTE'},
  ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final dio = sl<ApiClient>().dio;
      final results = await Future.wait([
        dio.get('/usuarios'),
        dio.get('/proyectos'),
      ]);
      setState(() {
        _usuarios  = (results[0].data['data'] as List?) ?? [];
        _proyectos = (results[1].data['data'] as List?) ?? [];
        _loading   = false;
      });
    } catch (e) {
      setState(() { _error = 'Error al cargar usuarios.'; _loading = false; });
    }
  }

  Future<void> _toggleActivo(int id) async {
    try {
      await sl<ApiClient>().dio.patch('/usuarios/$id/toggle-activo');
      _cargar();
    } catch (e) {
      if (mounted) _showError('Error al cambiar estado: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppTheme.error));
  }

  // ── Diálogo: Crear usuario ─────────────────────────────────────────────────
  void _mostrarCrear() {
    final nombreCtrl = TextEditingController();
    final emailCtrl  = TextEditingController();
    final passCtrl   = TextEditingController();
    final telCtrl    = TextEditingController();

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Nuevo Usuario'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre completo *')),
        const SizedBox(height: 8),
        TextField(controller: emailCtrl,  decoration: const InputDecoration(labelText: 'Correo electrónico *'), keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 8),
        TextField(controller: passCtrl,   decoration: const InputDecoration(labelText: 'Contraseña (mín. 8) *'), obscureText: true),
        const SizedBox(height: 8),
        TextField(controller: telCtrl,    decoration: const InputDecoration(labelText: 'Teléfono'), keyboardType: TextInputType.phone),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          onPressed: () async {
            if (nombreCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
            try {
              await sl<ApiClient>().dio.post('/usuarios', data: {
                'nombre': nombreCtrl.text, 'email': emailCtrl.text,
                'password': passCtrl.text,
                'telefono': telCtrl.text.isEmpty ? null : telCtrl.text,
              });
              if (ctx.mounted) Navigator.pop(ctx);
              _cargar();
            } catch (e) {
              if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
            }
          },
          child: const Text('Crear', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  // ── Diálogo: Editar nombre/teléfono ───────────────────────────────────────
  void _mostrarEditar(Map<String, dynamic> u) {
    final nombreCtrl = TextEditingController(text: u['nombre'] ?? '');
    final telCtrl    = TextEditingController(text: u['telefono'] ?? '');

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Editar Usuario'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre completo *')),
        const SizedBox(height: 8),
        TextField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Teléfono'), keyboardType: TextInputType.phone),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          onPressed: () async {
            if (nombreCtrl.text.isEmpty) return;
            try {
              await sl<ApiClient>().dio.put('/usuarios/${u['id']}', data: {
                'nombre': nombreCtrl.text,
                'telefono': telCtrl.text.isEmpty ? null : telCtrl.text,
              });
              if (ctx.mounted) Navigator.pop(ctx);
              _cargar();
            } catch (e) {
              if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
            }
          },
          child: const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  // ── Diálogo: Asignar roles ─────────────────────────────────────────────────
  void _mostrarRoles(Map<String, dynamic> u) {
    final actuales = ((u['roles'] as List?) ?? []).map((r) => r['id'] as int).toSet();
    final seleccionados = Set<int>.from(actuales);

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        title: Text('Roles de ${u['nombre']}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: _rolesDisponibles.map((rol) {
          final id = rol['id'] as int;
          return CheckboxListTile(
            title: Text(rol['nombre'] as String),
            value: seleccionados.contains(id),
            activeColor: AppTheme.primary,
            onChanged: (v) => setS(() { if (v == true) seleccionados.add(id); else seleccionados.remove(id); }),
          );
        }).toList()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () async {
              if (seleccionados.isEmpty) return;
              try {
                await sl<ApiClient>().dio.patch('/usuarios/${u['id']}/roles',
                    data: {'rolIds': seleccionados.toList()});
                if (ctx.mounted) Navigator.pop(ctx);
                _cargar();
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ));
  }

  // ── Diálogo: Asignar proyectos ─────────────────────────────────────────────
  void _mostrarProyectos(Map<String, dynamic> u) {
    final actuales = ((u['proyectos'] as List?) ?? []).map((p) => p['id'] as int).toSet();
    final seleccionados = Set<int>.from(actuales);

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        title: Text('Proyectos de ${u['nombre']}'),
        content: _proyectos.isEmpty
            ? const Text('No hay proyectos disponibles.')
            : SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
                children: _proyectos.map((p) {
                  final id = p['id'] as int;
                  return CheckboxListTile(
                    title: Text(p['nombre'] as String),
                    subtitle: Text(p['codigo'] as String? ?? '',
                        style: const TextStyle(fontSize: 11)),
                    value: seleccionados.contains(id),
                    activeColor: AppTheme.primary,
                    onChanged: (v) => setS(() { if (v == true) seleccionados.add(id); else seleccionados.remove(id); }),
                  );
                }).toList())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () async {
              try {
                await sl<ApiClient>().dio.patch('/usuarios/${u['id']}/proyectos',
                    data: {'proyectoIds': seleccionados.toList()});
                if (ctx.mounted) Navigator.pop(ctx);
                _cargar();
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ));
  }

  // ── Diálogo: Cambiar contraseña ────────────────────────────────────────────
  void _mostrarCambiarPassword(Map<String, dynamic> u) {
    final passCtrl     = TextEditingController();
    final confirmCtrl  = TextEditingController();

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Cambiar contraseña\n${u['nombre']}',
          style: const TextStyle(fontSize: 15)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: passCtrl,    decoration: const InputDecoration(labelText: 'Nueva contraseña *'), obscureText: true),
        const SizedBox(height: 8),
        TextField(controller: confirmCtrl, decoration: const InputDecoration(labelText: 'Confirmar contraseña *'), obscureText: true),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          onPressed: () async {
            if (passCtrl.text.length < 8) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Mínimo 8 caracteres'), backgroundColor: AppTheme.error));
              return;
            }
            if (passCtrl.text != confirmCtrl.text) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: AppTheme.error));
              return;
            }
            try {
              await sl<ApiClient>().dio.patch('/usuarios/${u['id']}/password',
                  data: {'nuevaPassword': passCtrl.text});
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contraseña actualizada'), backgroundColor: AppTheme.success));
            } catch (e) {
              if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
            }
          },
          child: const Text('Cambiar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const SizedBox(height: 8),
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _cargar, child: const Text('Reintentar')),
                ]))
              : _usuarios.isEmpty
                  ? const Center(child: Text('No hay usuarios registrados.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _usuarios.length,
                      itemBuilder: (_, i) => _UsuarioCard(
                        usuario: _usuarios[i],
                        onToggle: () => _toggleActivo(_usuarios[i]['id'] as int),
                        onEditar: () => _mostrarEditar(_usuarios[i]),
                        onRoles: () => _mostrarRoles(_usuarios[i]),
                        onProyectos: () => _mostrarProyectos(_usuarios[i]),
                        onPassword: () => _mostrarCambiarPassword(_usuarios[i]),
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: _mostrarCrear,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onToggle, onEditar, onRoles, onProyectos, onPassword;
  const _UsuarioCard({
    required this.usuario,
    required this.onToggle,
    required this.onEditar,
    required this.onRoles,
    required this.onProyectos,
    required this.onPassword,
  });

  @override
  Widget build(BuildContext context) {
    final activo  = usuario['activo'] as bool? ?? false;
    final nombre  = usuario['nombre'] as String? ?? '';
    final email   = usuario['email']  as String? ?? '';
    final roles   = (usuario['roles'] as List?)?.map((r) => r['nombre'] as String).join(', ') ?? '';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: activo ? AppTheme.primary : Colors.grey,
              child: Text(inicial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(nombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              Text(email, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              if (roles.isNotEmpty)
                Text(roles, style: const TextStyle(fontSize: 11, color: AppTheme.accent)),
            ])),
            Switch(
              value: activo,
              activeTrackColor: AppTheme.success,
              onChanged: (_) => onToggle(),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _ActionChip(Icons.edit_outlined,    'Editar',     onEditar),
            const SizedBox(width: 6),
            _ActionChip(Icons.security_outlined, 'Roles',     onRoles),
            const SizedBox(width: 6),
            _ActionChip(Icons.folder_outlined,   'Proyectos', onProyectos),
            const SizedBox(width: 6),
            _ActionChip(Icons.lock_outline,      'Contraseña',onPassword),
          ]),
        ]),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionChip(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppTheme.primary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}
