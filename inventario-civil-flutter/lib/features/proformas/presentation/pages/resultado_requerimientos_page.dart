import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/proforma_bloc.dart';
import '../../domain/entities/proforma.dart';
import '../../../../core/theme/app_theme.dart';

/// Pantalla Resultado de Requerimientos – Pantalla 7 del wireframe.
/// Muestra el resultado del motor de cálculo APU:
/// Material | Requerido | Disponible | A Comprar
class ResultadoRequerimientosPage extends StatefulWidget {
  final int proformaId;
  const ResultadoRequerimientosPage({super.key, required this.proformaId});

  @override
  State<ResultadoRequerimientosPage> createState() =>
      _ResultadoRequerimientosPageState();
}

class _ResultadoRequerimientosPageState
    extends State<ResultadoRequerimientosPage> {
  @override
  void initState() {
    super.initState();
    // Si ya se ejecutó el cálculo en la pantalla anterior el estado
    // ya es RequerimientosLoaded. Si no, cargamos los existentes.
    final state = context.read<ProformaBloc>().state;
    if (state is! RequerimientosLoaded) {
      context
          .read<ProformaBloc>()
          .add(CargarRequerimientos(widget.proformaId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Requerimientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Exportar',
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<ProformaBloc, ProformaState>(
        builder: (context, state) {
          if (state is ProformaLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Calculando requerimientos...',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            );
          }

          if (state is ProformaError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppTheme.error),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<ProformaBloc>()
                        .add(EjecutarCalculoAPU(widget.proformaId)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Recalcular'),
                  ),
                ],
              ),
            );
          }

          if (state is RequerimientosLoaded) {
            return Column(
              children: [
                _ResumenHeader(state: state),
                _TablaEncabezado(),
                Expanded(child: _TablaRequerimientos(state.requerimientos)),
                if (state.totalAComprar > 0) _BotonGenerarOC(state),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ResumenHeader extends StatelessWidget {
  final RequerimientosLoaded state;
  const _ResumenHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _Chip(
            value: state.requerimientos.length.toString(),
            label: 'materiales',
            color: AppTheme.primary,
          ),
          const SizedBox(width: 12),
          _Chip(
            value: state.totalAComprar.toString(),
            label: 'a comprar',
            color: state.totalAComprar > 0
                ? AppTheme.stockCritico
                : AppTheme.stockNormal,
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {},
            icon: const Icon(Icons.receipt_outlined, size: 16),
            label: const Text('Generar OC', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Chip(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _TablaEncabezado extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        children: [
          Expanded(
              flex: 4,
              child: Text('MATERIAL',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5))),
          _ColHeader('REQ.'),
          _ColHeader('DISP.'),
          _ColHeader('COMPRAR'),
          SizedBox(width: 28),
        ],
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Text(text,
          textAlign: TextAlign.right,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5)),
    );
  }
}

class _TablaRequerimientos extends StatelessWidget {
  final List<Requerimiento> requerimientos;
  const _TablaRequerimientos(this.requerimientos);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      itemCount: requerimientos.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFEDF2F7)),
      itemBuilder: (_, i) => _FilaRequerimiento(req: requerimientos[i]),
    );
  }
}

class _FilaRequerimiento extends StatelessWidget {
  final Requerimiento req;
  const _FilaRequerimiento({required this.req});

  @override
  Widget build(BuildContext context) {
    final necesita = req.necesitaCompra;
    return Container(
      color: necesita ? AppTheme.error.withOpacity(0.03) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Material (usamos ID por ahora; en commit 5 se resuelve el nombre)
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Material #${req.materialId}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  'ID: ${req.materialId}',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),

          // Requerido
          SizedBox(
            width: 60,
            child: Text(
              req.cantidadCalculada.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          // Disponible
          SizedBox(
            width: 60,
            child: Text(
              req.cantidadDisponible.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: req.cantidadDisponible >= req.cantidadCalculada
                      ? AppTheme.stockNormal
                      : AppTheme.stockBajo),
            ),
          ),

          // A comprar
          SizedBox(
            width: 60,
            child: Text(
              req.cantidadAComprar > 0
                  ? req.cantidadAComprar.toStringAsFixed(1)
                  : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: necesita
                      ? AppTheme.stockCritico
                      : AppTheme.stockNormal),
            ),
          ),

          // Checkbox OC
          SizedBox(
            width: 28,
            child: necesita
                ? Checkbox(
                    value: true,
                    onChanged: (_) {},
                    activeColor: AppTheme.primary,
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _BotonGenerarOC extends StatelessWidget {
  final RequerimientosLoaded state;
  const _BotonGenerarOC(this.state);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -2))
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Generando OC para ${state.totalAComprar} materiales...'),
            backgroundColor: AppTheme.primary,
          ));
        },
        icon: const Icon(Icons.receipt_long_outlined),
        label: Text(
            'Generar Orden de Compra (${state.totalAComprar} ítems)'),
      ),
    );
  }
}
