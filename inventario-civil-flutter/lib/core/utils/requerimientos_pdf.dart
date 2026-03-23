import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../features/proformas/domain/entities/proforma.dart';

class RequerimientosPdf {

  /// Genera el PDF, lo guarda en Descargas y muestra un diálogo de confirmación.
  static Future<void> descargar({
    required BuildContext context,
    required List<Requerimiento> requerimientos,
    required Map<int, Map<String, dynamic>> materiales,
    required int proformaId,
  }) async {
    final pdf   = _buildPdf(requerimientos, materiales, proformaId);
    final bytes = await pdf.save();

    // Guardar en el directorio de Documentos del usuario
    final dir  = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/Requerimientos_PRF-$proformaId.pdf');
    await file.writeAsBytes(bytes);

    // Abrir con el visor del sistema (Preview en macOS)
    if (Platform.isMacOS) {
      await Process.run('open', [file.path]);
    } else {
      await Process.run('xdg-open', [file.path]);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('PDF guardado en Documentos: Requerimientos_PRF-$proformaId.pdf'),
        backgroundColor: const Color(0xFF1B3A6B),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ));
    }
  }

  static pw.Document _buildPdf(
      List<Requerimiento> reqs,
      Map<int, Map<String, dynamic>> materiales,
      int proformaId,
      ) {
    final pdf   = pw.Document();
    final total = reqs.length;
    final aComprar = reqs.where((r) => r.necesitaCompra).length;
    final fecha = _fecha(DateTime.now());

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (_) => _header(proformaId, fecha),
      footer: (ctx) => _footer(ctx),
      build: (_) => [
        _resumen(total, aComprar),
        pw.SizedBox(height: 16),
        _tabla(reqs, materiales),
        pw.SizedBox(height: 20),
        _leyenda(),
      ],
    ));
    return pdf;
  }

  // ── Header ────────────────────────────────────────────────────────────────

  static pw.Widget _header(int proformaId, String fecha) => pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 10),
    decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blueGrey200))),
    child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('REPORTE DE REQUERIMIENTOS DE MATERIALES',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#1B3A6B'))),
        pw.SizedBox(height: 2),
        pw.Text('Proforma #$proformaId   Generado: $fecha',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
      ]),
      pw.Text('InventarioPro',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1B3A6B'))),
    ]),
  );

  static pw.Widget _footer(pw.Context ctx) => pw.Container(
    padding: const pw.EdgeInsets.only(top: 6),
    decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.blueGrey100, width: 0.5))),
    child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text('Sistema de Control de Inventario - UCB',
          style: pw.TextStyle(fontSize: 7, color: PdfColors.grey400)),
      pw.Text('Pag. ${ctx.pageNumber} / ${ctx.pagesCount}',
          style: pw.TextStyle(fontSize: 7, color: PdfColors.grey400)),
    ]),
  );

  // ── Resumen ───────────────────────────────────────────────────────────────

  static pw.Widget _resumen(int total, int aComprar) => pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromHex('#EFF6FF'),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      border: pw.Border.all(color: PdfColor.fromHex('#BFDBFE'), width: 0.5),
    ),
    child: pw.Row(children: [
      _chip('TOTAL', '$total', PdfColor.fromHex('#1B3A6B')),
      pw.SizedBox(width: 32),
      _chip('A COMPRAR', '$aComprar',
          aComprar > 0 ? PdfColor.fromHex('#DC2626') : PdfColor.fromHex('#16A34A')),
      pw.SizedBox(width: 32),
      _chip('STOCK OK', '${total - aComprar}', PdfColor.fromHex('#16A34A')),
    ]),
  );

  static pw.Widget _chip(String label, String value, PdfColor color) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500,
            fontWeight: pw.FontWeight.bold)),
        pw.Text(value, style: pw.TextStyle(fontSize: 20,
            fontWeight: pw.FontWeight.bold, color: color)),
      ]);

  // ── Tabla ─────────────────────────────────────────────────────────────────

  static pw.Widget _tabla(
      List<Requerimiento> reqs, Map<int, Map<String, dynamic>> materiales) {

    final hStyle = pw.TextStyle(fontSize: 8, color: PdfColors.white,
        fontWeight: pw.FontWeight.bold);
    final hBg = PdfColor.fromHex('#1B3A6B');

    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(4.5),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1.2),
        4: const pw.FlexColumnWidth(1.2),
        5: const pw.FlexColumnWidth(1),
      },
      border: pw.TableBorder.all(color: PdfColors.blueGrey100, width: 0.5),
      children: [
        pw.TableRow(decoration: pw.BoxDecoration(color: hBg), children: [
          _c('MATERIAL',  s: hStyle, a: pw.Alignment.centerLeft),
          _c('UNIDAD',    s: hStyle, a: pw.Alignment.center),
          _c('REQ.',      s: hStyle, a: pw.Alignment.centerRight),
          _c('DISP.',     s: hStyle, a: pw.Alignment.centerRight),
          _c('COMPRAR',   s: hStyle, a: pw.Alignment.centerRight),
          _c('ESTADO',    s: hStyle, a: pw.Alignment.center),
        ]),
        ...reqs.asMap().entries.map((e) {
          final i   = e.key;
          final req = e.value;
          final mat = materiales[req.materialId];
          final nombre  = _ascii(mat?['nombre'] as String? ?? 'Mat #${req.materialId}');
          final codigo  = mat?['codigo'] as String? ?? '';
          final unidad  = _unidad(mat?['unidadMedidaId'] as int?);
          final ok      = !req.necesitaCompra;
          final rowBg   = req.necesitaCompra
              ? PdfColor.fromHex('#FEF2F2')
              : (i % 2 == 0 ? PdfColors.white : PdfColor.fromHex('#F8FAFC'));

          return pw.TableRow(decoration: pw.BoxDecoration(color: rowBg), children: [
            // Material
            pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(nombre, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  if (codigo.isNotEmpty)
                    pw.Text(codigo, style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
                ])),
            _c(unidad, a: pw.Alignment.center,
                s: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            _c(req.cantidadCalculada.toStringAsFixed(1), a: pw.Alignment.centerRight,
                s: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            _c(req.cantidadDisponible.toStringAsFixed(1), a: pw.Alignment.centerRight,
                s: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold,
                    color: ok ? PdfColor.fromHex('#16A34A') : PdfColor.fromHex('#D97706'))),
            _c(req.necesitaCompra ? req.cantidadAComprar.toStringAsFixed(1) : '-',
                a: pw.Alignment.centerRight,
                s: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold,
                    color: req.necesitaCompra
                        ? PdfColor.fromHex('#DC2626') : PdfColor.fromHex('#16A34A'))),
            // Estado badge
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              decoration: pw.BoxDecoration(
                color: ok ? PdfColor.fromHex('#DCFCE7') : PdfColor.fromHex('#FEE2E2'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
              ),
              child: pw.Text(ok ? 'OK' : 'COMPRAR',
                  style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold,
                      color: ok ? PdfColor.fromHex('#16A34A') : PdfColor.fromHex('#DC2626'))),
            )),
          ]);
        }),
      ],
    );
  }

  static pw.Widget _leyenda() => pw.Row(children: [
    _dot(PdfColor.fromHex('#DCFCE7'), PdfColor.fromHex('#16A34A')),
    pw.SizedBox(width: 4),
    pw.Text('Stock suficiente', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
    pw.SizedBox(width: 12),
    _dot(PdfColor.fromHex('#FEE2E2'), PdfColor.fromHex('#DC2626')),
    pw.SizedBox(width: 4),
    pw.Text('Requiere compra', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
  ]);

  static pw.Widget _dot(PdfColor bg, PdfColor border) => pw.Container(
      width: 9, height: 9,
      decoration: pw.BoxDecoration(color: bg,
          border: pw.Border.all(color: border, width: 0.5)));

  static pw.Widget _c(String t, {pw.TextStyle? s, pw.Alignment a = pw.Alignment.centerLeft}) =>
      pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: pw.Align(alignment: a,
              child: pw.Text(t, style: s ?? pw.TextStyle(fontSize: 8))));

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Convierte texto a ASCII puro para evitar problemas con Helvetica
  static String _ascii(String t) => t
      .replaceAll('\u00e1','a').replaceAll('\u00e9','e')
      .replaceAll('\u00ed','i').replaceAll('\u00f3','o')
      .replaceAll('\u00fa','u').replaceAll('\u00f1','n')
      .replaceAll('\u00c1','A').replaceAll('\u00c9','E')
      .replaceAll('\u00cd','I').replaceAll('\u00d3','O')
      .replaceAll('\u00da','U').replaceAll('\u00d1','N')
      .replaceAll('\u00fc','u').replaceAll('\u00e3','a')
      .replaceAll('\u00d7','x').replaceAll('\u00b0','')
      .replaceAll(RegExp(r'[^\x00-\x7E]'), '?');

  static String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year} '
          '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

  static String _unidad(int? id) {
    const m = {1:'m',2:'m2',3:'m3',4:'kg',5:'und',6:'gl',7:'bolsa',8:'saco',9:'lt',10:'tn'};
    return m[id] ?? '';
  }
}