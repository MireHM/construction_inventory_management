import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

class HistorialMovimientosPage extends StatefulWidget {
  const HistorialMovimientosPage({super.key});
  @override
  State<HistorialMovimientosPage> createState() => _HistorialMovimientosPageState();
}

class _HistorialMovimientosPageState extends State<HistorialMovimientosPage> {
  List<Map<String, dynamic>> _todos    = [];
  List<Map<String, dynamic>> _filtrados = [];
  Map<int, String> _nombres = {};
  bool _loading = true;
  String? _error;

  // Filtros
  String _tipoFiltro = 'TODOS'; // TODOS | INGRESO | SALIDA
  DateTime? _desde;
  DateTime? _hasta;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        sl<ApiClient>().dio.get('/reportes/movimientos'),
        sl<ApiClient>().dio.get('/materiales'),
      ]);
      final movs = (results[0].data['data'] as List)
          .map((e) => e as Map<String, dynamic>).toList();
      final mats = results[1].data['data'] as List;
      final map = <int, String>{};
      for (final m in mats) {
        final mat = m as Map<String, dynamic>;
        map[mat['id'] as int] = mat['nombre'] as String;
      }
      if (mounted) {
        setState(() {
          _todos    = movs;
          _nombres  = map;
          _loading  = false;
        });
        _aplicarFiltros();
      }
    } catch (e) {
      setState(() { _error = 'Error al cargar movimientos.'; _loading = false; });
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _filtrados = _todos.where((m) {
        // Filtro tipo
        if (_tipoFiltro != 'TODOS' && m['tipo'] != _tipoFiltro) return false;
        // Filtro fecha
        if (_desde != null || _hasta != null) {
          final fecha = DateTime.parse((m['fechaMovimiento'] ?? m['fecha']) as String? ?? '');
          if (_desde != null && fecha.isBefore(_desde!)) return false;
          if (_hasta != null && fecha.isAfter(_hasta!.add(const Duration(days: 1)))) return false;
        }
        return true;
      }).toList();
    });
  }

  Future<void> _seleccionarFecha(bool esDe) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (esDe) _desde = picked; else _hasta = picked;
      });
      _aplicarFiltros();
    }
  }

  void _limpiarFiltros() {
    setState(() { _tipoFiltro = 'TODOS'; _desde = null; _hasta = null; });
    _aplicarFiltros();
  }

  Future<void> _exportarPdf() async {
    final pdf = pw.Document();
    final fecha = _formatFecha(DateTime.now());

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('HISTORIAL DE MOVIMIENTOS DE INVENTARIO',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#1B3A6B'))),
        pw.Text('Generado: $fecha  |  Total: ${_filtrados.length} movimientos',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        pw.Divider(color: PdfColors.blueGrey200),
      ]),
      footer: (ctx) => pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('InventarioPro - UCB', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey400)),
        pw.Text('Pag. ${ctx.pageNumber}/${ctx.pagesCount}',
            style: pw.TextStyle(fontSize: 7, color: PdfColors.grey400)),
      ]),
      build: (_) => [
        pw.Table(
          columnWidths: {
            0: const pw.FlexColumnWidth(2.5),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1.2),
            3: const pw.FlexColumnWidth(1.2),
            4: const pw.FlexColumnWidth(1.2),
            5: const pw.FlexColumnWidth(2),
          },
          border: pw.TableBorder.all(color: PdfColors.blueGrey100, width: 0.5),
          children: [
            pw.TableRow(decoration: pw.BoxDecoration(color: PdfColor.fromHex('#1B3A6B')),
                children: ['MATERIAL','TIPO','CANTIDAD','ANT.','RESULT.','FECHA'].map((h) =>
                    pw.Padding(padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(h, style: pw.TextStyle(fontSize: 8,
                            color: PdfColors.white, fontWeight: pw.FontWeight.bold)))).toList()),
            ..._filtrados.map((m) {
              final esIngreso = m['tipo'] == 'INGRESO';
              final nombre = _ascii(_nombres[m['materialId'] as int] ?? 'Mat #${m['materialId']}');
              final color = esIngreso ? PdfColor.fromHex('#F0FDF4') : PdfColor.fromHex('#FEF2F2');
              return pw.TableRow(decoration: pw.BoxDecoration(color: color), children: [
                pw.Padding(padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(nombre, style: pw.TextStyle(fontSize: 8))),
                pw.Padding(padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(m['tipo'] as String, style: pw.TextStyle(fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: esIngreso ? PdfColor.fromHex('#16A34A') : PdfColor.fromHex('#DC2626')))),
                pw.Padding(padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('${m['cantidad']}', style: pw.TextStyle(fontSize: 8))),
                pw.Padding(padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('${m['stockAnterior']}', style: pw.TextStyle(fontSize: 8))),
                pw.Padding(padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('${m['stockResultante']}', style: pw.TextStyle(fontSize: 8))),
                pw.Padding(padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(_formatFechaCorta((m['fechaMovimiento'] ?? m['fecha']) as String? ?? ''),
                        style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600))),
              ]);
            }),
          ],
        ),
      ],
    ));

    final bytes = await pdf.save();
    final dir   = await getApplicationDocumentsDirectory();
    final file  = File('${dir.path}/Historial_Movimientos_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    if (Platform.isMacOS) await Process.run('open', [file.path]);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('PDF guardado en Documentos.'),
        backgroundColor: Color(0xFF1B3A6B),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Historial de Movimientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar PDF',
            onPressed: _filtrados.isEmpty ? null : _exportarPdf,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar),
        ],
      ),
      body: Column(children: [
        _buildFiltros(),
        if (_filtrados.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(children: [
              Text('${_filtrados.length} movimientos',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const Spacer(),
              if (_tipoFiltro != 'TODOS' || _desde != null || _hasta != null)
                TextButton.icon(
                  onPressed: _limpiarFiltros,
                  icon: const Icon(Icons.clear, size: 14),
                  label: const Text('Limpiar', style: TextStyle(fontSize: 12)),
                ),
            ]),
          ),
        Expanded(child: _buildLista()),
      ]),
    );
  }

  Widget _buildFiltros() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(children: [
        // Filtro por tipo
        Row(children: ['TODOS','INGRESO','SALIDA'].map((t) =>
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(t, style: const TextStyle(fontSize: 12)),
                selected: _tipoFiltro == t,
                onSelected: (_) { setState(() => _tipoFiltro = t); _aplicarFiltros(); },
                selectedColor: t == 'INGRESO'
                    ? AppTheme.stockNormal.withOpacity(0.2)
                    : t == 'SALIDA'
                    ? AppTheme.stockCritico.withOpacity(0.2)
                    : AppTheme.primary.withOpacity(0.15),
              ),
            ),
        ).toList()),
        const SizedBox(height: 8),
        // Filtro por fecha
        Row(children: [
          Expanded(child: _DateButton(
            label: _desde == null ? 'Desde fecha' : _formatFechaCorta(_desde!.toIso8601String()),
            onTap: () => _seleccionarFecha(true),
            set: _desde != null,
          )),
          const SizedBox(width: 8),
          Expanded(child: _DateButton(
            label: _hasta == null ? 'Hasta fecha' : _formatFechaCorta(_hasta!.toIso8601String()),
            onTap: () => _seleccionarFecha(false),
            set: _hasta != null,
          )),
        ]),
      ]),
    );
  }

  Widget _buildLista() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
      const SizedBox(height: 12),
      Text(_error!),
      const SizedBox(height: 16),
      ElevatedButton.icon(onPressed: _cargar, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
    ]));
    if (_filtrados.isEmpty) return const Center(
        child: Text('No hay movimientos con los filtros aplicados.',
            style: TextStyle(color: AppTheme.textSecondary)));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filtrados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final m = _filtrados[i];
        final esIngreso = m['tipo'] == 'INGRESO';
        final nombre = _nombres[m['materialId'] as int] ?? 'Material #${m['materialId']}';
        final fecha  = _formatFechaCompleta((m['fechaMovimiento'] ?? m['fecha']) as String? ?? '');
        return Card(child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: esIngreso
                    ? AppTheme.stockNormal.withOpacity(0.1)
                    : AppTheme.stockCritico.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                esIngreso ? Icons.arrow_upward : Icons.arrow_downward,
                color: esIngreso ? AppTheme.stockNormal : AppTheme.stockCritico,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: esIngreso
                        ? AppTheme.stockNormal.withOpacity(0.1)
                        : AppTheme.stockCritico.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(m['tipo'] as String,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                          color: esIngreso ? AppTheme.stockNormal : AppTheme.stockCritico)),
                ),
                const SizedBox(width: 8),
                Text('Cant: ${m['cantidad']}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ]),
              const SizedBox(height: 2),
              Text(_formatFechaCompleta((m['fechaMovimiento'] ?? m['fecha']) as String? ?? ''), style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${m['stockResultante']}',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold,
                      color: esIngreso ? AppTheme.stockNormal : AppTheme.stockCritico)),
              Text('en stock', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ]),
          ]),
        ));
      },
    );
  }

  String _formatFecha(DateTime dt) =>
      '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} '
          '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';

  String _formatFechaCorta(String iso) {
    final dt = DateTime.parse(iso);
    return '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}';
  }

  String _formatFechaCompleta(String iso) {
    final dt = DateTime.parse(iso);
    return '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}  '
        '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  String _ascii(String t) => t
      .replaceAll('\u00e1','a').replaceAll('\u00e9','e').replaceAll('\u00ed','i')
      .replaceAll('\u00f3','o').replaceAll('\u00fa','u').replaceAll('\u00f1','n')
      .replaceAll('\u00c1','A').replaceAll('\u00c9','E').replaceAll('\u00cd','I')
      .replaceAll('\u00d3','O').replaceAll('\u00da','U').replaceAll('\u00d1','N')
      .replaceAll(RegExp(r'[^\x00-\x7E]'), '?');
}

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool set;
  const _DateButton({required this.label, required this.onTap, required this.set});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      foregroundColor: set ? AppTheme.primary : AppTheme.textSecondary,
      side: BorderSide(color: set ? AppTheme.primary : const Color(0xFFE2E8F0)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    icon: Icon(Icons.calendar_today_outlined, size: 14),
    label: Text(label, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
  );
}