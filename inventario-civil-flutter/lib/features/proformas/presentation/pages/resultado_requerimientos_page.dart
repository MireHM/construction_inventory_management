import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/proforma_bloc.dart';
import '../../domain/entities/proforma.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/requerimientos_pdf.dart';
import '../../../../injection_container.dart';

class ResultadoRequerimientosPage extends StatefulWidget {
  final int proformaId;
  const ResultadoRequerimientosPage({super.key, required this.proformaId});

  @override
  State<ResultadoRequerimientosPage> createState() =>
      _ResultadoRequerimientosPageState();
}

class _ResultadoRequerimientosPageState
    extends State<ResultadoRequerimientosPage> {

  Map<int, Map<String, dynamic>> _materiales = {};
  bool _generandoOC = false;

  @override
  void initState() {
    super.initState();
    _cargarMateriales();
    final state = context.read<ProformaBloc>().state;
    if (state is! RequerimientosLoaded) {
      context.read<ProformaBloc>().add(EjecutarCalculoAPU(widget.proformaId));
    }
  }

  Future<void> _cargarMateriales() async {
    try {
      final res = await sl<ApiClient>().dio.get('/materiales');
      final list = res.data['data'] as List;
      final map = <int, Map<String, dynamic>>{};
      for (final m in list) {
        final mat = m as Map<String, dynamic>;
        map[mat['id'] as int] = mat;
      }
      if (mounted) setState(() => _materiales = map);
    } catch (_) {}
  }

  Future<void> _descargarPdf(RequerimientosLoaded state) async {
    try {
      await RequerimientosPdf.descargar(
        context: context,
        requerimientos: state.requerimientos,
        materiales: _materiales,
        proformaId: widget.proformaId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al generar PDF: $e'),
          backgroundColor: AppTheme.error,
        ));
      }
    }
  }

  Future<void> _generarOC() async {
    setState(() => _generandoOC = true);
    try {
      final res = await sl<ApiClient>().dio.post(
        '/ordenes/generar',
        queryParameters: {'proformaId': widget.proformaId},
      );
      final ordenes = res.data['data'] as List;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${ordenes.length} orden(es) de compra generada(s).'),
          backgroundColor: AppTheme.stockNormal,
          duration: const Duration(seconds: 3),
        ));
        context.push('/ordenes');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Error al generar órdenes de compra.'),
          backgroundColor: AppTheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _generandoOC = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProformaBloc, ProformaState>(
      builder: (context, state) {
        // Extraer requerimientos si ya están cargados
        final reqs = state is RequerimientosLoaded ? state : null;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Requerimientos'),
            actions: [
              IconButton(
                icon: const Icon(Icons.download_outlined),
                tooltip: 'Descargar PDF',
                // Solo habilitado cuando hay datos cargados
                onPressed: reqs != null
                    ? () => _descargarPdf(reqs)
                    : null,
              ),
            ],
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(ProformaState state) {
    if (state is ProformaLoading) {
      return const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Calculando requerimientos...',
              style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ));
    }

    if (state is ProformaError) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
          const SizedBox(height: 12),
          Text(state.message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<ProformaBloc>()
                .add(EjecutarCalculoAPU(widget.proformaId)),
            icon: const Icon(Icons.refresh),
            label: const Text('Recalcular'),
          ),
        ],
      ));
    }

    if (state is RequerimientosLoaded) {
      return Column(children: [
        _ResumenHeader(
          state: state,
          onGenerarOC: _generarOC,
          generando: _generandoOC,
        ),
        _TablaEncabezado(),
        Expanded(child: _TablaRequerimientos(
          requerimientos: state.requerimientos,
          materiales: _materiales,
        )),
        if (state.totalAComprar > 0)
          _BotonGenerarOC(
            state: state,
            onTap: _generarOC,
            generando: _generandoOC,
          ),
      ]);
    }

    return const SizedBox.shrink();
  }
}

// ── Encabezado ────────────────────────────────────────────────────────────────

class _ResumenHeader extends StatelessWidget {
  final RequerimientosLoaded state;
  final VoidCallback onGenerarOC;
  final bool generando;
  const _ResumenHeader({required this.state, required this.onGenerarOC, required this.generando});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        _Chip(value: '${state.requerimientos.length}', label: 'materiales', color: AppTheme.primary),
        const SizedBox(width: 12),
        _Chip(value: '${state.totalAComprar}', label: 'a comprar',
            color: state.totalAComprar > 0 ? AppTheme.stockCritico : AppTheme.stockNormal),
        const Spacer(),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String value, label;
  final Color color;
  const _Chip({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
  ]);
}

// ── Encabezado tabla ──────────────────────────────────────────────────────────

class _TablaEncabezado extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(children: [
        Expanded(flex: 5, child: Text('MATERIAL',
            style: TextStyle(color: Colors.white70, fontSize: 11,
                fontWeight: FontWeight.w600, letterSpacing: 0.5))),
        _ColHeader('REQ.'),
        _ColHeader('DISP.'),
        _ColHeader('COMPRAR'),
        SizedBox(width: 28),
      ]),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 66,
    child: Text(text, textAlign: TextAlign.right,
        style: const TextStyle(color: Colors.white70, fontSize: 11,
            fontWeight: FontWeight.w600, letterSpacing: 0.5)),
  );
}

// ── Filas ─────────────────────────────────────────────────────────────────────

class _TablaRequerimientos extends StatelessWidget {
  final List<Requerimiento> requerimientos;
  final Map<int, Map<String, dynamic>> materiales;
  const _TablaRequerimientos({required this.requerimientos, required this.materiales});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      itemCount: requerimientos.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEDF2F7)),
      itemBuilder: (_, i) => _FilaRequerimiento(
        req:      requerimientos[i],
        material: materiales[requerimientos[i].materialId],
      ),
    );
  }
}

class _FilaRequerimiento extends StatelessWidget {
  final Requerimiento req;
  final Map<String, dynamic>? material;
  const _FilaRequerimiento({required this.req, this.material});

  @override
  Widget build(BuildContext context) {
    final necesita = req.necesitaCompra;
    final nombre   = material?['nombre'] as String? ?? 'Material #${req.materialId}';
    final codigo   = material?['codigo'] as String? ?? '';
    final unidad   = _unidadSimbolo(material?['unidadMedidaId'] as int?);

    return Container(
      color: necesita ? AppTheme.error.withOpacity(0.03) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Expanded(flex: 5, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(codigo.isNotEmpty ? codigo : 'ID: ${req.materialId}',
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        )),
        SizedBox(width: 66, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(req.cantidadCalculada.toStringAsFixed(1), textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          if (unidad.isNotEmpty)
            Text(unidad, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        ])),
        SizedBox(width: 66, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(req.cantidadDisponible.toStringAsFixed(1), textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                  color: req.cantidadDisponible >= req.cantidadCalculada
                      ? AppTheme.stockNormal : AppTheme.stockBajo)),
          if (unidad.isNotEmpty)
            Text(unidad, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        ])),
        SizedBox(width: 66, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(req.cantidadAComprar > 0 ? req.cantidadAComprar.toStringAsFixed(1) : '—',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
                  color: necesita ? AppTheme.stockCritico : AppTheme.stockNormal)),
          if (necesita && unidad.isNotEmpty)
            Text(unidad, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        ])),
        SizedBox(width: 28, child: necesita
            ? Checkbox(value: true, onChanged: (_) {},
            activeColor: AppTheme.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)
            : const SizedBox.shrink()),
      ]),
    );
  }

  String _unidadSimbolo(int? id) {
    const map = {1:'m', 2:'m²', 3:'m³', 4:'kg', 5:'und', 6:'gl', 7:'bolsa', 8:'saco', 9:'lt', 10:'tn'};
    return map[id] ?? '';
  }
}

// ── Botón inferior ────────────────────────────────────────────────────────────

class _BotonGenerarOC extends StatelessWidget {
  final RequerimientosLoaded state;
  final VoidCallback onTap;
  final bool generando;
  const _BotonGenerarOC({required this.state, required this.onTap, required this.generando});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: generando ? null : onTap,
        icon: generando
            ? const SizedBox(width: 18, height: 18,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.receipt_long_outlined),
        label: Text(generando
            ? 'Generando...'
            : 'Generar Orden de Compra (${state.totalAComprar} ítems)'),
      ),
    );
  }
}