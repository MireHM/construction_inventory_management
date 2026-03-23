import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/inventario_bloc.dart';
import '../bloc/inventario_event_state.dart';
import '../../../../core/theme/app_theme.dart';

/// Pantalla Registro de Ingreso – Pantalla 5 del wireframe.
class RegistroIngresoPage extends StatefulWidget {
  const RegistroIngresoPage({super.key});

  @override
  State<RegistroIngresoPage> createState() => _RegistroIngresoPageState();
}

class _RegistroIngresoPageState extends State<RegistroIngresoPage> {
  final _formKey         = GlobalKey<FormState>();
  final _cantidadCtrl    = TextEditingController();
  final _precioCtrl      = TextEditingController();
  final _facturaCtrl     = TextEditingController();
  final _motivoCtrl      = TextEditingController();

  // En producción estos valores vienen del selector de materiales/proyectos
  // Por ahora son campos de texto para demostrar el flujo completo
  final _materialIdCtrl  = TextEditingController();
  final _proveedorCtrl   = TextEditingController();

  @override
  void dispose() {
    _cantidadCtrl.dispose(); _precioCtrl.dispose();
    _facturaCtrl.dispose();  _motivoCtrl.dispose();
    _materialIdCtrl.dispose(); _proveedorCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<InventarioBloc>().add(RegistrarIngreso(
            materialId:    int.parse(_materialIdCtrl.text.trim()),
            cantidad:      double.parse(_cantidadCtrl.text.trim()),
            precioUnitario: _precioCtrl.text.isNotEmpty
                ? double.parse(_precioCtrl.text.trim())
                : null,
            numeroFactura: _facturaCtrl.text.isNotEmpty
                ? _facturaCtrl.text.trim()
                : null,
            motivo: _motivoCtrl.text.isNotEmpty
                ? _motivoCtrl.text.trim()
                : null,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel('MATERIAL *'),
                _Field(
                  controller: _materialIdCtrl,
                  hint: 'ID del material',
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Requerido'
                      : int.tryParse(v) == null
                          ? 'ID inválido'
                          : null,
                  prefix: Icons.inventory_2_outlined,
                ),
                const SizedBox(height: 14),
                _SectionLabel('PROVEEDOR'),
                _Field(
                  controller: _proveedorCtrl,
                  hint: 'Nombre del proveedor',
                  prefix: Icons.business_outlined,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('CANTIDAD *'),
                          _Field(
                            controller: _cantidadCtrl,
                            hint: '0',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requerido';
                              if (double.tryParse(v) == null) return 'Inválido';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('PRECIO UNIT. (Bs.)'),
                          _Field(
                            controller: _precioCtrl,
                            hint: 'Bs. 0.00',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SectionLabel('N° FACTURA *'),
                _Field(
                  controller: _facturaCtrl,
                  hint: 'FAC-2025-000001',
                  prefix: Icons.receipt_outlined,
                ),
                const SizedBox(height: 14),
                _SectionLabel('MOTIVO / OBSERVACIONES'),
                _Field(
                  controller: _motivoCtrl,
                  hint: 'Descripción del ingreso...',
                  maxLines: 3,
                ),
                const SizedBox(height: 28),

                // Total estimado
                if (_cantidadCtrl.text.isNotEmpty &&
                    _precioCtrl.text.isNotEmpty)
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
                        Text(
                          _calcTotal(),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // Botón guardar
                BlocBuilder<InventarioBloc, InventarioState>(
                  builder: (context, state) {
                    return ElevatedButton.icon(
                      onPressed: state is InventarioLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.stockNormal),
                      icon: state is InventarioLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_circle_outline),
                      label: const Text('Guardar Ingreso'),
                    );
                  },
                ),
              ],
            ),
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppTheme.textSecondary)),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefix;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.prefix,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefix != null ? Icon(prefix, size: 18) : null,
      ),
    );
  }
}
