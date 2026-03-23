import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/inventario_bloc.dart';
import '../bloc/inventario_event_state.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

class RegistroSalidaPage extends StatefulWidget {
  const RegistroSalidaPage({super.key});
  @override
  State<RegistroSalidaPage> createState() => _RegistroSalidaPageState();
}

class _RegistroSalidaPageState extends State<RegistroSalidaPage> {
  final _formKey       = GlobalKey<FormState>();
  final _cantidadCtrl  = TextEditingController();
  final _proyectoCtrl  = TextEditingController();
  final _frenteCtrl    = TextEditingController();
  final _motivoCtrl    = TextEditingController();

  List<Map<String, dynamic>> _materiales = [];
  Map<String, dynamic>? _materialSeleccionado;
  bool _cargandoMateriales = true;

  @override
  void initState() {
    super.initState();
    _cargarMateriales();
  }

  Future<void> _cargarMateriales() async {
    try {
      final res = await sl<ApiClient>().dio.get('/materiales');
      final list = (res.data['data'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      if (mounted) setState(() { _materiales = list; _cargandoMateriales = false; });
    } catch (_) {
      if (mounted) setState(() => _cargandoMateriales = false);
    }
  }

  @override
  void dispose() {
    _cantidadCtrl.dispose(); _proyectoCtrl.dispose();
    _frenteCtrl.dispose(); _motivoCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<InventarioBloc>().add(RegistrarSalida(
        materialId:  _materialSeleccionado!['id'] as int,
        cantidad:    double.parse(_cantidadCtrl.text.trim()),
        proyectoId:  int.parse(_proyectoCtrl.text.trim()),
        frenteObra:  _frenteCtrl.text.trim(),
        motivo:      _motivoCtrl.text.isNotEmpty ? _motivoCtrl.text.trim() : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Registrar Salida')),
      body: BlocListener<InventarioBloc, InventarioState>(
        listener: (context, state) {
          if (state is MovimientoRegistrado) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.mensaje),
              backgroundColor: AppTheme.stockCritico,
            ));
            context.pop();
          }
          if (state is InventarioError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.error,
            ));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Banner advertencia
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.stockCritico.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.stockCritico.withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.arrow_downward, color: AppTheme.stockCritico, size: 18),
                  SizedBox(width: 8),
                  Text('El stock se reducirá al registrar la salida.',
                      style: TextStyle(color: AppTheme.stockCritico, fontSize: 13)),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Dropdown de materiales ──────────────────────────────────
              _SectionLabel('MATERIAL *'),
              _cargandoMateriales
                  ? Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 10),
                    Text('Cargando materiales...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ]),
                ),
              )
                  : DropdownButtonFormField<Map<String, dynamic>>(
                value: _materialSeleccionado,
                isExpanded: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.inventory_2_outlined, size: 18),
                  hintText: 'Selecciona un material...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                items: _materiales.map((mat) {
                  final codigo = mat['codigo'] as String;
                  final nombre = mat['nombre'] as String;
                  final stock  = mat['stockActual'];
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: mat,
                    child: Text(
                      '$codigo · $nombre  (stock: $stock)',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _materialSeleccionado = val),
                validator: (_) => _materialSeleccionado == null ? 'Selecciona un material' : null,
              ),

              // Info del material seleccionado
              if (_materialSeleccionado != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.stockCritico.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.stockCritico.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    Icon(Icons.warehouse_outlined, size: 16,
                        color: _stockColor(_materialSeleccionado!['stockActual'],
                            _materialSeleccionado!['stockMinimo'])),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'Stock disponible: ${_materialSeleccionado!['stockActual']}  ·  '
                          'Mínimo: ${_materialSeleccionado!['stockMinimo']}',
                      style: TextStyle(fontSize: 12,
                          color: _stockColor(_materialSeleccionado!['stockActual'],
                              _materialSeleccionado!['stockMinimo'])),
                    )),
                  ]),
                ),
              ],
              const SizedBox(height: 14),

              // ── Cantidad ────────────────────────────────────────────────
              _SectionLabel('CANTIDAD *'),
              _Field(
                controller: _cantidadCtrl,
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefix: Icons.scale_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (double.tryParse(v) == null) return 'Valor inválido';
                  if (double.parse(v) <= 0) return 'Debe ser mayor a 0';
                  // Validar que no supere el stock disponible
                  if (_materialSeleccionado != null) {
                    final stock = (_materialSeleccionado!['stockActual'] as num).toDouble();
                    if (double.parse(v) > stock) return 'Supera el stock disponible ($stock)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Proyecto ────────────────────────────────────────────────
              _SectionLabel('ID PROYECTO *'),
              _Field(
                controller: _proyectoCtrl,
                hint: 'Ej: 1',
                keyboardType: TextInputType.number,
                prefix: Icons.business_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Requerido'
                    : int.tryParse(v) == null ? 'ID inválido' : null,
              ),
              const SizedBox(height: 14),

              // ── Frente de obra ───────────────────────────────────────────
              _SectionLabel('FRENTE DE OBRA *'),
              _Field(
                controller: _frenteCtrl,
                hint: 'Ej: Bloque A - Columnas',
                prefix: Icons.location_on_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 14),

              // ── Motivo ────────────────────────────────────────────────────
              _SectionLabel('MOTIVO / OBSERVACIONES'),
              _Field(controller: _motivoCtrl, hint: 'Descripción de la salida...', maxLines: 3),
              const SizedBox(height: 28),

              // ── Botón guardar ─────────────────────────────────────────────
              BlocBuilder<InventarioBloc, InventarioState>(
                builder: (context, state) => ElevatedButton.icon(
                  onPressed: state is InventarioLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.stockCritico),
                  icon: state is InventarioLoading
                      ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.arrow_downward),
                  label: const Text('Guardar Salida'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Color _stockColor(dynamic stock, dynamic minimo) {
    final s = (stock as num).toDouble();
    final m = (minimo as num).toDouble();
    if (s == 0) return AppTheme.stockCritico;
    if (s < m)  return AppTheme.stockBajo;
    return AppTheme.stockNormal;
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700,
        letterSpacing: 0.8, color: AppTheme.textSecondary)),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefix;
  final int maxLines;
  const _Field({required this.controller, required this.hint,
    this.keyboardType, this.validator, this.prefix, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller, keyboardType: keyboardType,
    maxLines: maxLines, validator: validator,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: prefix != null ? Icon(prefix, size: 18) : null,
    ),
  );
}