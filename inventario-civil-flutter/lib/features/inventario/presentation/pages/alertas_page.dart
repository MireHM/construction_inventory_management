import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

class AlertasPage extends StatefulWidget {
  const AlertasPage({super.key});
  @override
  State<AlertasPage> createState() => _AlertasPageState();
}

class _AlertasPageState extends State<AlertasPage> {
  List<Map<String, dynamic>> _alertas = [];
  Map<int, Map<String, dynamic>> _materiales = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        sl<ApiClient>().dio.get('/inventario/alertas'),
        sl<ApiClient>().dio.get('/materiales'),
      ]);
      final alertasList   = results[0].data['data'] as List;
      final materialesList = results[1].data['data'] as List;
      final map = <int, Map<String, dynamic>>{};
      for (final m in materialesList) {
        final mat = m as Map<String, dynamic>;
        map[mat['id'] as int] = mat;
      }
      setState(() {
        _alertas    = alertasList.map((e) => e as Map<String, dynamic>).toList();
        _materiales = map;
        _loading    = false;
      });
    } catch (e) {
      setState(() { _error = 'Error al cargar alertas.'; _loading = false; });
    }
  }

  // Cuenta por tipo para el resumen superior
  int _count(String tipo) => _alertas.where((a) => a['tipo'] == tipo).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Alertas de Stock'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
        const SizedBox(height: 12),
        Text(_error!, style: const TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _cargar, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
      ]))
          : _alertas.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.check_circle_outline, size: 64, color: AppTheme.stockNormal),
        SizedBox(height: 16),
        Text('Sin alertas pendientes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text('Todos los materiales están dentro del rango de stock.',
            textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
      ]))
          : Column(children: [

        // ── Leyenda de tipos ────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(children: [
            _TipoResumen(
              color: _AlertaTipoConfig.sinStock.color,
              icon:  _AlertaTipoConfig.sinStock.icon,
              label: 'Sin Stock',
              count: _count('SIN_STOCK'),
            ),
            _Divider(),
            _TipoResumen(
              color: _AlertaTipoConfig.stockMinimo.color,
              icon:  _AlertaTipoConfig.stockMinimo.icon,
              label: 'Stock Mín.',
              count: _count('STOCK_MINIMO'),
            ),
            _Divider(),
            _TipoResumen(
              color: _AlertaTipoConfig.stockMaximo.color,
              icon:  _AlertaTipoConfig.stockMaximo.icon,
              label: 'Stock Máx.',
              count: _count('STOCK_MAXIMO'),
            ),
          ]),
        ),

        // ── Lista ───────────────────────────────────────────
        Expanded(child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: _alertas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _AlertaCard(
            alerta:   _alertas[i],
            material: _materiales[_alertas[i]['materialId'] as int],
          ),
        )),
      ]),
    );
  }
}

// ── Configuración visual por tipo ─────────────────────────────────────────────

class _AlertaTipoConfig {
  final Color  color;
  final Color  bgColor;
  final IconData icon;
  final String titulo;

  const _AlertaTipoConfig({
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.titulo,
  });

  static const sinStock = _AlertaTipoConfig(
    color:   Color(0xFFDC2626),   // Rojo
    bgColor: Color(0xFFFEF2F2),
    icon:    Icons.do_not_disturb_on_outlined,
    titulo:  'Sin Stock',
  );

  static const stockMinimo = _AlertaTipoConfig(
    color:   Color(0xFFD97706),   // Ámbar
    bgColor: Color(0xFFFFFBEB),
    icon:    Icons.trending_down_rounded,
    titulo:  'Stock Mínimo',
  );

  static const stockMaximo = _AlertaTipoConfig(
    color:   Color(0xFF2563EB),   // Azul
    bgColor: Color(0xFFEFF6FF),
    icon:    Icons.trending_up_rounded,
    titulo:  'Stock Máximo Excedido',
  );

  static _AlertaTipoConfig from(String tipo) {
    switch (tipo) {
      case 'SIN_STOCK':    return sinStock;
      case 'STOCK_MAXIMO': return stockMaximo;
      default:             return stockMinimo;
    }
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _TipoResumen extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final int count;
  const _TipoResumen({required this.color, required this.icon, required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Expanded(child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
      ]),
    ],
  ));
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 36,
    color: const Color(0xFFE2E8F0),
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

class _AlertaCard extends StatelessWidget {
  final Map<String, dynamic> alerta;
  final Map<String, dynamic>? material;
  const _AlertaCard({required this.alerta, this.material});

  @override
  Widget build(BuildContext context) {
    final tipo    = alerta['tipo'] as String;
    final stock   = alerta['stockAlMomento'];
    final matId   = alerta['materialId'];
    final cfg     = _AlertaTipoConfig.from(tipo);

    final nombre = material?['nombre'] as String? ?? 'Material #$matId';
    final codigo = material?['codigo'] as String? ?? '';
    final minimo = material?['stockMinimo'];
    final maximo = material?['stockMaximo'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: cfg.color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [

          // Ícono con fondo del color del tipo
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: cfg.bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(cfg.icon, color: cfg.color, size: 24),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Badge del tipo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cfg.bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cfg.color.withOpacity(0.4)),
              ),
              child: Text(cfg.titulo,
                  style: TextStyle(color: cfg.color, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
            ),
            const SizedBox(height: 6),

            // Nombre del material
            Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
            const SizedBox(height: 3),

            // Código + valores de stock
            Row(children: [
              if (codigo.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(codigo, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(
                _buildStockText(stock, minimo, maximo, tipo),
                style: TextStyle(color: cfg.color, fontSize: 12, fontWeight: FontWeight.w600),
              )),
            ]),
          ])),

          const SizedBox(width: 8),

          // Badge estado atendida/pendiente
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: alerta['atendida'] == true
                  ? AppTheme.stockNormal.withOpacity(0.1)
                  : cfg.bgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: alerta['atendida'] == true
                    ? AppTheme.stockNormal.withOpacity(0.4)
                    : cfg.color.withOpacity(0.3),
              ),
            ),
            child: Text(
              alerta['atendida'] == true ? 'Atendida' : 'Pendiente',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: alerta['atendida'] == true ? AppTheme.stockNormal : cfg.color,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  String _buildStockText(dynamic stock, dynamic minimo, dynamic maximo, String tipo) {
    switch (tipo) {
      case 'SIN_STOCK':
        return 'Stock: 0 · Reponer mínimo: ${minimo ?? '-'}';
      case 'STOCK_MAXIMO':
        return 'Stock: $stock · Máximo: ${maximo ?? '-'}';
      default:
        return 'Stock: $stock · Mínimo requerido: ${minimo ?? '-'}';
    }
  }
}