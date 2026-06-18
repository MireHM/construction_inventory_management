import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/material_bloc.dart';
import '../bloc/material_event_state.dart';
import '../../domain/entities/material.dart';
import '../../../../core/theme/app_theme.dart';

class CatalogoMaterialesPage extends StatelessWidget {
  const CatalogoMaterialesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Catálogo de Materiales'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MaterialBloc>().add(CargarMateriales()),
          ),
        ],
      ),
      body: Column(children: [const _SearchBar(), Expanded(child: _MaterialList())]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => context.push('/materiales/nuevo'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar();
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  int? _categoriaSeleccionada;
  String _query = '';

  static const _categorias = [
    (id: 1, nombre: 'Áridos y Pétreos'),
    (id: 2, nombre: 'Cementos'),
    (id: 3, nombre: 'Acero'),
    (id: 4, nombre: 'Maderas'),
    (id: 5, nombre: 'Eléctrica'),
    (id: 6, nombre: 'Pinturas'),
    (id: 7, nombre: 'Sanitaria'),
    (id: 8, nombre: 'Mampostería'),
  ];

  void _buscar() {
    context.read<MaterialBloc>().add(BuscarConFiltros(
      q: _query.isEmpty ? null : _query,
      categoriaId: _categoriaSeleccionada,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          Expanded(child: TextField(
            onChanged: (v) { _query = v; _buscar(); },
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o código...',
              prefixIcon: const Icon(Icons.search),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          )),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _categoriaSeleccionada != null ? AppTheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: PopupMenuButton<int?>(
              icon: Icon(Icons.filter_list,
                  color: _categoriaSeleccionada != null ? Colors.white : AppTheme.textPrimary),
              tooltip: 'Filtrar por categoría',
              onSelected: (v) {
                setState(() => _categoriaSeleccionada = v);
                _buscar();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: null, child: Text('Todas las categorías')),
                ..._categorias.map((c) => PopupMenuItem(value: c.id, child: Text(c.nombre))),
              ],
            ),
          ),
        ]),
        if (_categoriaSeleccionada != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            Chip(
              label: Text(_categorias.firstWhere((c) => c.id == _categoriaSeleccionada).nombre,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              backgroundColor: AppTheme.primary,
              deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
              onDeleted: () { setState(() => _categoriaSeleccionada = null); _buscar(); },
            ),
          ]),
        ],
      ]),
    );
  }
}

class _MaterialList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialBloc, MatBlocState>(
      builder: (context, state) {
        if (state is MaterialLoading) return const Center(child: CircularProgressIndicator());
        if (state is MaterialError) return Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const SizedBox(height: 12),
            Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: () => context.read<MaterialBloc>().add(CargarMateriales()), icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
          ],
        ));
        if (state is MaterialesLoaded) {
          if (state.filtrados.isEmpty) return const Center(child: Text('No se encontraron materiales.', style: TextStyle(color: AppTheme.textSecondary)));
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: state.filtrados.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _MaterialCard(material: state.filtrados[i]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final MaterialItem material;
  const _MaterialCard({required this.material});

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
          child: Icon(_iconoPorCategoria(material.categoriaId), color: AppTheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(material.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 2),
          Text('Cód: ${material.codigo}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          _StockBadge(estado: material.estadoStock),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(material.stockActual.toStringAsFixed(0), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _colorStock(material.estadoStock))),
          const Text('en stock', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        ]),
      ]),
    ));
  }

  IconData _iconoPorCategoria(int id) {
    const m = {1: Icons.terrain, 2: Icons.circle, 3: Icons.linear_scale, 4: Icons.forest, 5: Icons.plumbing, 6: Icons.format_paint};
    return m[id] ?? Icons.inventory_2_outlined;
  }

  Color _colorStock(EstadoStock e) {
    switch (e) {
      case EstadoStock.critico: return AppTheme.stockCritico;
      case EstadoStock.bajo:    return AppTheme.stockBajo;
      case EstadoStock.normal:  return AppTheme.stockNormal;
    }
  }
}

class _StockBadge extends StatelessWidget {
  final EstadoStock estado;
  const _StockBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    late String label; late Color color;
    switch (estado) {
      case EstadoStock.critico: label = 'Crítico'; color = AppTheme.stockCritico; break;
      case EstadoStock.bajo:    label = 'Stock bajo'; color = AppTheme.stockBajo; break;
      case EstadoStock.normal:  label = 'En stock'; color = AppTheme.stockNormal; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
