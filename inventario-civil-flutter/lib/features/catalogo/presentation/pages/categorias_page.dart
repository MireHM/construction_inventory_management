import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});
  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  List<dynamic> _categorias = [];
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
      final res = await sl<ApiClient>().dio.get('/api/v1/categorias');
      setState(() {
        _categorias = (res.data['data'] as List?) ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Error al cargar categorías.'; _loading = false; });
    }
  }

  void _mostrarFormulario({Map<String, dynamic>? categoria}) {
    final nombreCtrl = TextEditingController(text: categoria?['nombre'] ?? '');
    final descCtrl   = TextEditingController(text: categoria?['descripcion'] ?? '');
    final esEdicion  = categoria != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(esEdicion ? 'Editar Categoría' : 'Nueva Categoría'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre *')),
          const SizedBox(height: 8),
          TextField(controller: descCtrl, maxLines: 2,
              decoration: const InputDecoration(labelText: 'Descripción')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () async {
              if (nombreCtrl.text.isEmpty) return;
              try {
                final dio = sl<ApiClient>().dio;
                if (esEdicion) {
                  await dio.put('/api/v1/categorias/${categoria['id']}', data: {
                    'nombre': nombreCtrl.text,
                    'descripcion': descCtrl.text.isEmpty ? null : descCtrl.text,
                  });
                } else {
                  await dio.post('/api/v1/categorias', data: {
                    'nombre': nombreCtrl.text,
                    'descripcion': descCtrl.text.isEmpty ? null : descCtrl.text,
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
        title: const Text('Categorías de Materiales'),
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
              : _categorias.isEmpty
                  ? const Center(child: Text('No hay categorías registradas.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _categorias.length,
                      itemBuilder: (_, i) {
                        final c = _categorias[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            leading: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.category_outlined, color: AppTheme.primary),
                            ),
                            title: Text(c['nombre'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: c['descripcion'] != null && c['descripcion'].toString().isNotEmpty
                                ? Text(c['descripcion'], style: const TextStyle(fontSize: 12))
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => _mostrarFormulario(categoria: c),
                            ),
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
