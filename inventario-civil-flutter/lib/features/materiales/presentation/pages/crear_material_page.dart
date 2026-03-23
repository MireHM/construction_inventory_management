import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

/// Pantalla para crear un nuevo material en el catálogo.
class CrearMaterialPage extends StatefulWidget {
  const CrearMaterialPage({super.key});
  @override
  State<CrearMaterialPage> createState() => _CrearMaterialPageState();
}

class _CrearMaterialPageState extends State<CrearMaterialPage> {
  final _formKey         = GlobalKey<FormState>();
  final _codigoCtrl      = TextEditingController();
  final _nombreCtrl      = TextEditingController();
  final _descCtrl        = TextEditingController();
  final _precioCtrl      = TextEditingController();
  final _stockMinCtrl    = TextEditingController();
  final _stockMaxCtrl    = TextEditingController();
  int _categoriaId       = 1;
  int _unidadMedidaId    = 5;
  bool _loading          = false;

  final List<Map<String, dynamic>> _categorias = [
    {'id': 1, 'nombre': 'Áridos y Agregados'},
    {'id': 2, 'nombre': 'Cemento y Morteros'},
    {'id': 3, 'nombre': 'Acero y Fierro'},
    {'id': 4, 'nombre': 'Madera y Encofrado'},
    {'id': 5, 'nombre': 'Instalaciones'},
    {'id': 6, 'nombre': 'Acabados'},
    {'id': 7, 'nombre': 'Herramientas'},
    {'id': 8, 'nombre': 'Insumos Generales'},
  ];

  final List<Map<String, dynamic>> _unidades = [
    {'id': 1, 'simbolo': 'm'},
    {'id': 2, 'simbolo': 'm2'},
    {'id': 3, 'simbolo': 'm3'},
    {'id': 4, 'simbolo': 'kg'},
    {'id': 5, 'simbolo': 'und'},
    {'id': 6, 'simbolo': 'gl'},
    {'id': 7, 'simbolo': 'bolsa'},
    {'id': 8, 'simbolo': 'saco'},
    {'id': 9, 'simbolo': 'lt'},
    {'id': 10, 'simbolo': 'tn'},
  ];

  @override
  void dispose() {
    _codigoCtrl.dispose(); _nombreCtrl.dispose(); _descCtrl.dispose();
    _precioCtrl.dispose(); _stockMinCtrl.dispose(); _stockMaxCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await sl<ApiClient>().dio.post('/materiales', data: {
        'codigo':          _codigoCtrl.text.trim(),
        'nombre':          _nombreCtrl.text.trim(),
        'descripcion':     _descCtrl.text.isNotEmpty ? _descCtrl.text.trim() : null,
        'categoriaId':     _categoriaId,
        'unidadMedidaId':  _unidadMedidaId,
        'precioReferencia': double.tryParse(_precioCtrl.text) ?? 0.0,
        'stockMinimo':     double.tryParse(_stockMinCtrl.text) ?? 0.0,
        'stockMaximo':     _stockMaxCtrl.text.isNotEmpty ? double.tryParse(_stockMaxCtrl.text) : null,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Material creado correctamente.'),
          backgroundColor: AppTheme.stockNormal,
        ));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Nuevo Material')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('CÓDIGO *'),
            _field(_codigoCtrl, 'Ej: MAT-011',
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 14),

            _label('NOMBRE *'),
            _field(_nombreCtrl, 'Nombre del material',
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 14),

            _label('DESCRIPCIÓN'),
            _field(_descCtrl, 'Descripción opcional...', maxLines: 2),
            const SizedBox(height: 14),

            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('CATEGORÍA'),
                DropdownButtonFormField<int>(
                  value: _categoriaId,
                  decoration: _inputDec(''),
                  items: _categorias.map((c) => DropdownMenuItem<int>(
                    value: c['id'] as int,
                    child: Text(c['nombre'] as String, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (v) => setState(() => _categoriaId = v!),
                ),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('UNIDAD'),
                DropdownButtonFormField<int>(
                  value: _unidadMedidaId,
                  decoration: _inputDec(''),
                  items: _unidades.map((u) => DropdownMenuItem<int>(
                    value: u['id'] as int,
                    child: Text(u['simbolo'] as String),
                  )).toList(),
                  onChanged: (v) => setState(() => _unidadMedidaId = v!),
                ),
              ])),
            ]),
            const SizedBox(height: 14),

            _label('PRECIO REFERENCIA (Bs.)'),
            _field(_precioCtrl, '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 14),

            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('STOCK MÍNIMO *'),
                _field(_stockMinCtrl, '0',
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('STOCK MÁXIMO'),
                _field(_stockMaxCtrl, 'Opcional', keyboardType: TextInputType.number),
              ])),
            ]),
            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: const Text('Guardar Material'),
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
      {TextInputType? keyboardType, String? Function(String?)? validator, int maxLines = 1}) =>
    TextFormField(controller: ctrl, keyboardType: keyboardType,
        maxLines: maxLines, validator: validator,
        decoration: _inputDec(hint));

  InputDecoration _inputDec(String hint) => InputDecoration(
    hintText: hint, filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}
