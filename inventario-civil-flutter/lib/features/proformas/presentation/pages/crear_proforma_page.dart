import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

/// Pantalla para crear una nueva proforma con sus partidas.
class CrearProformaPage extends StatefulWidget {
  final int proyectoId;
  const CrearProformaPage({super.key, required this.proyectoId});
  @override
  State<CrearProformaPage> createState() => _CrearProformaPageState();
}

class _CrearProformaPageState extends State<CrearProformaPage> {
  final _formKey     = GlobalKey<FormState>();
  final _codigoCtrl  = TextEditingController();
  final _nombreCtrl  = TextEditingController();
  final _descCtrl    = TextEditingController();
  bool _loading      = false;

  // Lista de partidas a agregar
  final List<Map<String, dynamic>> _partidas = [];

  @override
  void dispose() {
    _codigoCtrl.dispose(); _nombreCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  void _agregarPartida() {
    showDialog(
      context: context,
      builder: (_) => _DialogPartida(
        onAgregar: (partida) => setState(() => _partidas.add(partida)),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await sl<ApiClient>().dio.post('/proformas', data: {
        'proyectoId':  widget.proyectoId,
        'codigo':      _codigoCtrl.text.trim(),
        'nombre':      _nombreCtrl.text.trim(),
        'descripcion': _descCtrl.text.isNotEmpty ? _descCtrl.text.trim() : null,
        'partidas':    _partidas,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Proforma creada correctamente.'),
          backgroundColor: AppTheme.stockNormal,
        ));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'), backgroundColor: AppTheme.error,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Nueva Proforma')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('CÓDIGO *'),
            _field(_codigoCtrl, 'Ej: PRF-2025-001',
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 14),

            _label('NOMBRE *'),
            _field(_nombreCtrl, 'Ej: Estructura Bloque A',
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 14),

            _label('DESCRIPCIÓN'),
            _field(_descCtrl, 'Descripción opcional...', maxLines: 2),
            const SizedBox(height: 20),

            // Partidas
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('PARTIDAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppTheme.textSecondary)),
              TextButton.icon(
                onPressed: _agregarPartida,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar'),
              ),
            ]),
            const SizedBox(height: 8),

            if (_partidas.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(child: Text('Sin partidas. Toca "Agregar" para añadir.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
              )
            else
              ...(_partidas.asMap().entries.map((entry) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    child: Text('${entry.key + 1}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(entry.value['descripcion'] ?? 'APU #${entry.value['apuId']}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text('APU ID: ${entry.value['apuId']} · ${entry.value['cantidadObra']} ${entry.value['unidad'] ?? ''}',
                      style: const TextStyle(fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                    onPressed: () => setState(() => _partidas.removeAt(entry.key)),
                  ),
                ),
              ))),
            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: const Text('Crear Proforma'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppTheme.textSecondary)),
  );

  Widget _field(TextEditingController ctrl, String hint,
      {String? Function(String?)? validator, int maxLines = 1}) =>
    TextFormField(controller: ctrl, maxLines: maxLines, validator: validator,
      decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)));
}

// ── Diálogo para agregar partida ──────────────────────────────────────────────
class _DialogPartida extends StatefulWidget {
  final void Function(Map<String, dynamic>) onAgregar;
  const _DialogPartida({required this.onAgregar});
  @override
  State<_DialogPartida> createState() => _DialogPartidaState();
}

class _DialogPartidaState extends State<_DialogPartida> {
  final _apuCtrl    = TextEditingController();
  final _cantCtrl   = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _itemCtrl   = TextEditingController();

  @override
  void dispose() {
    _apuCtrl.dispose(); _cantCtrl.dispose(); _descCtrl.dispose(); _itemCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Partida', style: TextStyle(fontSize: 16)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _itemCtrl,
              decoration: const InputDecoration(labelText: 'Ítem (Ej: 1.1)', isDense: true)),
          const SizedBox(height: 12),
          TextField(controller: _apuCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'ID del APU *', isDense: true)),
          const SizedBox(height: 12),
          TextField(controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción', isDense: true)),
          const SizedBox(height: 12),
          TextField(controller: _cantCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Cantidad de obra *', isDense: true)),
        ]),
      ),
      actions: [
        //TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            final apuId = int.tryParse(_apuCtrl.text);
            final cant  = double.tryParse(_cantCtrl.text);
            if (apuId == null || cant == null || cant <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('APU ID y cantidad son requeridos.'),
                backgroundColor: AppTheme.error,
              ));
              return;
            }
            widget.onAgregar({
              'apuId':        apuId,
              'itemNumero':   _itemCtrl.text.isNotEmpty ? _itemCtrl.text : null,
              'descripcion':  _descCtrl.text.isNotEmpty ? _descCtrl.text : null,
              'cantidadObra': cant,
              'orden':        1,
            });
            Navigator.pop(context);
          },
          child: const Text('Agregar'),
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
