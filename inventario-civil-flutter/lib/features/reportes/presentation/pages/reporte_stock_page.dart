import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

/// Reporte de Stock — muestra el estado actual de todos los materiales
/// con resumen por estado (NORMAL / BAJO / CRÍTICO) y detalle.
class ReporteStockPage extends StatefulWidget {
  const ReporteStockPage({super.key});
  @override
  State<ReporteStockPage> createState() => _ReporteStockPageState();
}

class _ReporteStockPageState extends State<ReporteStockPage> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  String _filtro = 'TODOS'; // TODOS | NORMAL | BAJO | CRITICO

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await sl<ApiClient>().dio.get('/reportes/stock');
      setState(() { _data = res.data['data'] as Map<String, dynamic>; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Error al cargar reporte.'; _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _detalleFiltrado {
    final detalle = (_data?['detalle'] as List? ?? [])
        .map((e) => e as Map<String, dynamic>).toList();
    if (_filtro == 'TODOS') return detalle;
    return detalle.where((m) => m['estado'] == _filtro).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Reporte de Stock'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const SizedBox(height: 12),
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(onPressed: _cargar, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
                ]))
              : Column(children: [
                  // ── Resumen KPIs ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      _KpiMini('Normal', '${_data?['normal'] ?? 0}', AppTheme.stockNormal),
                      const SizedBox(width: 10),
                      _KpiMini('Bajo', '${_data?['bajo'] ?? 0}', AppTheme.stockBajo),
                      const SizedBox(width: 10),
                      _KpiMini('Crítico', '${_data?['critico'] ?? 0}', AppTheme.stockCritico),
                      const SizedBox(width: 10),
                      _KpiMini('Total', '${_data?['total'] ?? 0}', AppTheme.primary),
                    ]),
                  ),

                  // ── Filtros ──────────────────────────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(children: ['TODOS', 'NORMAL', 'BAJO', 'CRITICO'].map((f) =>
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f),
                          selected: _filtro == f,
                          onSelected: (_) => setState(() => _filtro = f),
                          selectedColor: AppTheme.primary.withOpacity(0.15),
                          checkmarkColor: AppTheme.primary,
                        ),
                      ),
                    ).toList()),
                  ),
                  const SizedBox(height: 8),

                  // ── Lista detalle ─────────────────────────────────────────
                  Expanded(child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _detalleFiltrado.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final m = _detalleFiltrado[i];
                      final estado = m['estado'] as String;
                      Color color;
                      switch (estado) {
                        case 'CRITICO': color = AppTheme.stockCritico; break;
                        case 'BAJO':    color = AppTheme.stockBajo; break;
                        default:        color = AppTheme.stockNormal;
                      }
                      final stock    = (m['stockActual'] as num).toDouble();
                      final minimo   = (m['stockMinimo'] as num).toDouble();
                      final pct      = minimo > 0 ? (stock / (minimo * 5)).clamp(0.0, 1.0) : 0.5;

                      return Card(child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(m['nombre'] as String,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: color.withOpacity(0.3)),
                              ),
                              child: Text(estado, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ]),
                          const SizedBox(height: 4),
                          Text('Cód: ${m['codigo']}  ·  Stock: $stock  ·  Mín: $minimo',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct, minHeight: 6,
                              backgroundColor: color.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ]),
                      ));
                    },
                  )),
                ]),
    );
  }
}

class _KpiMini extends StatelessWidget {
  final String label, value;
  final Color color;
  const _KpiMini(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(10),
      border: Border(left: BorderSide(color: color, width: 3)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
    ),
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
    ]),
  ));
}
