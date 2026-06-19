import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

class ProveedoresPage extends StatefulWidget {
  const ProveedoresPage({super.key});
  @override
  State<ProveedoresPage> createState() => _ProveedoresPageState();
}

class _ProveedoresPageState extends State<ProveedoresPage> {
  List<dynamic> _proveedores = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await sl<ApiClient>().dio.get('/proveedores');
      setState(() {
        _proveedores = (res.data['data'] as List?) ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Error al cargar proveedores.'; _loading = false; });
    }
  }

  void _mostrarFormulario({Map<String, dynamic>? proveedor}) {
    final nombreCtrl   = TextEditingController(text: proveedor?['nombre'] ?? '');
    final nitCtrl      = TextEditingController(text: proveedor?['nit'] ?? '');
    final telefonoCtrl = TextEditingController(text: proveedor?['telefono'] ?? '');
    final emailCtrl    = TextEditingController(text: proveedor?['email'] ?? '');
    final dirCtrl      = TextEditingController(text: proveedor?['direccion'] ?? '');
    final contactoCtrl = TextEditingController(text: proveedor?['contacto'] ?? '');
    final esEdicion    = proveedor != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(esEdicion ? 'Editar Proveedor' : 'Nuevo Proveedor'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre *')),
          const SizedBox(height: 8),
          if (!esEdicion)
            TextField(controller: nitCtrl,
                decoration: const InputDecoration(labelText: 'NIT'),
                keyboardType: TextInputType.number),
          if (!esEdicion) const SizedBox(height: 8),
          TextField(controller: telefonoCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone),
          const SizedBox(height: 8),
          TextField(controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 8),
          TextField(controller: dirCtrl,
              decoration: const InputDecoration(labelText: 'Dirección')),
          const SizedBox(height: 8),
          TextField(controller: contactoCtrl,
              decoration: const InputDecoration(labelText: 'Persona de contacto')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () async {
              if (nombreCtrl.text.isEmpty) return;
              try {
                final dio = sl<ApiClient>().dio;
                if (esEdicion) {
                  await dio.put('/proveedores/${proveedor['id']}', data: {
                    'nombre':   nombreCtrl.text,
                    'telefono': telefonoCtrl.text.isEmpty ? null : telefonoCtrl.text,
                    'email':    emailCtrl.text.isEmpty ? null : emailCtrl.text,
                    'direccion': dirCtrl.text.isEmpty ? null : dirCtrl.text,
                    'contacto': contactoCtrl.text.isEmpty ? null : contactoCtrl.text,
                  });
                } else {
                  await dio.post('/proveedores', data: {
                    'nombre':   nombreCtrl.text,
                    'nit':      nitCtrl.text.isEmpty ? null : nitCtrl.text,
                    'telefono': telefonoCtrl.text.isEmpty ? null : telefonoCtrl.text,
                    'email':    emailCtrl.text.isEmpty ? null : emailCtrl.text,
                    'direccion': dirCtrl.text.isEmpty ? null : dirCtrl.text,
                    'contacto': contactoCtrl.text.isEmpty ? null : contactoCtrl.text,
                  });
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _cargar();
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
              }
            },
            child: Text(esEdicion ? 'Guardar' : 'Crear',
                style: const TextStyle(color: Colors.white)),
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
        title: const Text('Proveedores'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const SizedBox(height: 8), Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _cargar, child: const Text('Reintentar')),
                ]))
              : _proveedores.isEmpty
                  ? const Center(child: Text('No hay proveedores registrados.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _proveedores.length,
                      itemBuilder: (_, i) {
                        final p = _proveedores[i];
                        final activo = p['activo'] as bool? ?? true;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: activo
                                  ? AppTheme.primary.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              child: Icon(Icons.store_outlined,
                                  color: activo ? AppTheme.primary : Colors.grey),
                            ),
                            title: Text(p['nombre'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              if (p['nit'] != null && p['nit'].toString().isNotEmpty)
                                Text('NIT: ${p['nit']}',
                                    style: const TextStyle(fontSize: 12)),
                              if (p['telefono'] != null && p['telefono'].toString().isNotEmpty)
                                Text('Tel: ${p['telefono']}  ${p['email'] ?? ''}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              if (p['contacto'] != null && p['contacto'].toString().isNotEmpty)
                                Text('Contacto: ${p['contacto']}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            ]),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => _mostrarFormulario(proveedor: p),
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
