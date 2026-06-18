import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

class ProyectosPage extends StatefulWidget {
  const ProyectosPage({super.key});
  @override
  State<ProyectosPage> createState() => _ProyectosPageState();
}

class _ProyectosPageState extends State<ProyectosPage> {
  List<dynamic> _proyectos = [];
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
      final res = await sl<ApiClient>().dio.get('/api/v1/proyectos');
      setState(() {
        _proyectos = (res.data['data'] as List?) ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Error al cargar proyectos.'; _loading = false; });
    }
  }

  void _mostrarFormulario({Map<String, dynamic>? proyecto}) {
    final codigoCtrl    = TextEditingController(text: proyecto?['codigo'] ?? '');
    final nombreCtrl    = TextEditingController(text: proyecto?['nombre'] ?? '');
    final descCtrl      = TextEditingController(text: proyecto?['descripcion'] ?? '');
    final presupCtrl    = TextEditingController(
        text: proyecto?['presupuesto']?.toString() ?? '');
    String estado = proyecto?['estado'] ?? 'PLANIFICACION';
    final estados = ['PLANIFICACION', 'EN_EJECUCION', 'PAUSADO', 'FINALIZADO'];
    final esEdicion = proyecto != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        title: Text(esEdicion ? 'Editar Proyecto' : 'Nuevo Proyecto'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (!esEdicion) ...[
            TextField(controller: codigoCtrl,
                decoration: const InputDecoration(labelText: 'Código *', hintText: 'PROY-004')),
            const SizedBox(height: 8),
          ],
          TextField(controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre *')),
          const SizedBox(height: 8),
          TextField(controller: descCtrl, maxLines: 2,
              decoration: const InputDecoration(labelText: 'Descripción')),
          const SizedBox(height: 8),
          TextField(controller: presupCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Presupuesto (Bs.)', prefixText: 'Bs. ')),
          if (esEdicion) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: estado,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: estados.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setS(() => estado = v ?? estado),
            ),
          ],
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
                  await dio.put('/api/v1/proyectos/${proyecto['id']}', data: {
                    'nombre': nombreCtrl.text,
                    'descripcion': descCtrl.text.isEmpty ? null : descCtrl.text,
                    'estado': estado,
                    'presupuesto': presupCtrl.text.isEmpty ? null : double.tryParse(presupCtrl.text),
                  });
                } else {
                  await dio.post('/api/v1/proyectos', data: {
                    'codigo': codigoCtrl.text,
                    'nombre': nombreCtrl.text,
                    'descripcion': descCtrl.text.isEmpty ? null : descCtrl.text,
                    'presupuesto': presupCtrl.text.isEmpty ? null : double.tryParse(presupCtrl.text),
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
      )),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'EN_EJECUCION':  return AppTheme.stockNormal;
      case 'PLANIFICACION': return AppTheme.primary;
      case 'FINALIZADO':    return AppTheme.textSecondary;
      case 'PAUSADO':       return AppTheme.stockBajo;
      default:              return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Proyectos'),
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
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _cargar, child: const Text('Reintentar')),
                ]))
              : _proyectos.isEmpty
                  ? const Center(child: Text('No hay proyectos registrados.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _proyectos.length,
                      itemBuilder: (_, i) {
                        final p = _proyectos[i];
                        final estado = p['estado'] as String? ?? '';
                        final presupuesto = p['presupuesto'];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Expanded(child: Text(p['nombre'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _colorEstado(estado).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: _colorEstado(estado).withOpacity(0.4)),
                                  ),
                                  child: Text(estado.replaceAll('_', ' '),
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                          color: _colorEstado(estado))),
                                ),
                              ]),
                              const SizedBox(height: 4),
                              Text('Cód: ${p['codigo'] ?? ''}',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              if (p['descripcion'] != null && p['descripcion'].toString().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(p['descripcion'],
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
                              ],
                              if (presupuesto != null) ...[
                                const SizedBox(height: 6),
                                Text('Presupuesto: Bs. ${presupuesto.toString()}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              ],
                              const SizedBox(height: 10),
                              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                TextButton.icon(
                                  onPressed: () => _mostrarFormulario(proyecto: p),
                                  icon: const Icon(Icons.edit_outlined, size: 16),
                                  label: const Text('Editar', style: TextStyle(fontSize: 12)),
                                ),
                              ]),
                            ]),
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
