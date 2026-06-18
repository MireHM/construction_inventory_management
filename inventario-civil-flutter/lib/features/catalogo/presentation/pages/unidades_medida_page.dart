import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

class UnidadesMedidaPage extends StatefulWidget {
  const UnidadesMedidaPage({super.key});
  @override
  State<UnidadesMedidaPage> createState() => _UnidadesMedidaPageState();
}

class _UnidadesMedidaPageState extends State<UnidadesMedidaPage> {
  List<dynamic> _unidades = [];
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
      final res = await sl<ApiClient>().dio.get('/api/v1/unidades-medida');
      setState(() {
        _unidades = (res.data['data'] as List?) ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Error al cargar unidades.'; _loading = false; });
    }
  }

  void _mostrarFormulario({Map<String, dynamic>? unidad}) {
    final simboloCtrl = TextEditingController(text: unidad?['simbolo'] ?? '');
    final nombreCtrl  = TextEditingController(text: unidad?['nombre'] ?? '');
    final esEdicion   = unidad != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(esEdicion ? 'Editar Unidad' : 'Nueva Unidad de Medida'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          if (!esEdicion)
            TextField(controller: simboloCtrl,
                decoration: const InputDecoration(labelText: 'Símbolo *', hintText: 'kg, m3, pza...')),
          if (!esEdicion) const SizedBox(height: 8),
          TextField(controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre *', hintText: 'Kilogramo, Metro cúbico...')),
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
                  await dio.put('/api/v1/unidades-medida/${unidad['id']}', data: {
                    'nombre': nombreCtrl.text,
                    'simbolo': unidad['simbolo'],
                  });
                } else {
                  if (simboloCtrl.text.isEmpty) return;
                  await dio.post('/api/v1/unidades-medida', data: {
                    'simbolo': simboloCtrl.text,
                    'nombre': nombreCtrl.text,
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
        title: const Text('Unidades de Medida'),
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
              : _unidades.isEmpty
                  ? const Center(child: Text('No hay unidades de medida.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _unidades.length,
                      itemBuilder: (_, i) {
                        final u = _unidades[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            leading: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(u['simbolo'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold,
                                        color: AppTheme.primary, fontSize: 13)),
                              ),
                            ),
                            title: Text(u['nombre'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('Símbolo: ${u['simbolo'] ?? ''}',
                                style: const TextStyle(fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => _mostrarFormulario(unidad: u),
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
