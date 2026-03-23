import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/inventario_bloc.dart';
import '../bloc/inventario_event_state.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

class RegistroIngresoPage extends StatefulWidget {
  const RegistroIngresoPage({super.key});
  @override
  State<RegistroIngresoPage> createState() => _RegistroIngresoPageState();
}

class _RegistroIngresoPageState extends State<RegistroIngresoPage> {
  final _formKey      = GlobalKey<FormState>();
  final _cantidadCtrl = TextEditingController();
  final _precioCtrl   = TextEditingController();
  final _facturaCtrl  = TextEditingController();
  final _proveedorCtrl= TextEditingController();
  final _motivoCtrl   = TextEditingController();

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
    _cantidadCtrl.dispose(); _precioCtrl.dispose();
    _facturaCtrl.dispose();  _proveedorCtrl.dispose(); _motivoCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<InventarioBloc>().add(RegistrarIngreso(
        materialId:    _materialSeleccionado!['id'] as int,
        cantidad:      double.parse(_cantidadCtrl.text.trim()),
        precioUnitario: _precioCtrl.text.isNotEmpty
            ? double.tryParse(_precioCtrl.text.trim()) : null,
        numeroFactura: _facturaCtrl.text.isNotEmpty
            ? _facturaCtrl.text.trim() : null,
        motivo:        _motivoCtrl.text.isNotEmpty
            ? _motivoCtrl.text.trim() : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Registrar Ingreso')),
      body: BlocListener<InventarioBloc, InventarioState>(
        listener: (context, state) {
          if (state is MovimientoRegistrado) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.mensaje),
              backgroundColor: AppTheme.stockNormal,
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
                    color: AppTheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'Stock mínimo: ${_materialSeleccionado!['stockMinimo']}  ·  '
                          'Stock máximo: ${_materialSeleccionado!['stockMaximo'] ?? '—'}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.primary),
                    )),
                  ]),
                ),
              ],
              const SizedBox(height: 14),

              // ── Proveedor ────────────────────────────────────────────────
              _SectionLabel('PROVEEDOR'),
              _Field(controller: _proveedorCtrl, hint: 'Nombre del proveedor',
                  prefix: Icons.business_outlined),
              const SizedBox(height: 14),

              // ── Cantidad + Precio ────────────────────────────────────────
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _SectionLabel('CANTIDAD *'),
                  _Field(
                    controller: _cantidadCtrl, hint: '0',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (double.tryParse(v) == null) return 'Inválido';
                      if (double.parse(v) <= 0) return 'Debe ser > 0';
                      return null;
                    },
                  ),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _SectionLabel('PRECIO UNIT. (Bs.)'),
                  _Field(controller: _precioCtrl, hint: 'Bs. 0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                ])),
              ]),
              const SizedBox(height: 14),

              // ── Factura ──────────────────────────────────────────────────
              _SectionLabel('N° FACTURA'),
              _Field(controller: _facturaCtrl, hint: 'FAC-2025-000001',
                  prefix: Icons.receipt_outlined),
              const SizedBox(height: 14),

              // ── Motivo ───────────────────────────────────────────────────
              _SectionLabel('MOTIVO / OBSERVACIONES'),
              _Field(controller: _motivoCtrl, hint: 'Descripción del ingreso...', maxLines: 3),
              const SizedBox(height: 14),

              // ── Total estimado ───────────────────────────────────────────
              if (_cantidadCtrl.text.isNotEmpty && _precioCtrl.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total estimado',
                          style: TextStyle(color: AppTheme.textSecondary)),
                      Text(_calcTotal(),
                          style: const TextStyle(fontSize: 18,
                              fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // ── Botón guardar ─────────────────────────────────────────────
              BlocBuilder<InventarioBloc, InventarioState>(
                builder: (context, state) => ElevatedButton.icon(
                  onPressed: state is InventarioLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.stockNormal),
                  icon: state is InventarioLoading
                      ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.arrow_upward_rounded),
                  label: const Text('Guardar Ingreso'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  String _calcTotal() {
    final cant  = double.tryParse(_cantidadCtrl.text) ?? 0;
    final precio = double.tryParse(_precioCtrl.text) ?? 0;
    return 'Bs. ${(cant * precio).toStringAsFixed(2)}';
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
    onChanged: (_) {},
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: prefix != null ? Icon(prefix, size: 18) : null,
    ),
  );
}