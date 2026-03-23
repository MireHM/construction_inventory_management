import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/proforma_bloc.dart';
import '../../domain/entities/proforma.dart';
import '../../../../core/theme/app_theme.dart';

/// Pantalla Gestión de Proformas – Pantalla 6 del wireframe.
class ProformasPage extends StatefulWidget {
  final int proyectoId;
  const ProformasPage({super.key, required this.proyectoId});

  @override
  State<ProformasPage> createState() => _ProformasPageState();
}

class _ProformasPageState extends State<ProformasPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProformaBloc>().add(CargarProformas(widget.proyectoId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Proformas por Proyecto'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<ProformaBloc, ProformaState>(
        builder: (context, state) {
          if (state is ProformaLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProformaError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<ProformaBloc>()
                        .add(CargarProformas(widget.proyectoId)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is ProformasLoaded) {
            if (state.proformas.isEmpty) {
              return const Center(
                child: Text('No hay proformas registradas.',
                    style: TextStyle(color: AppTheme.textSecondary)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.proformas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ProformaCard(proforma: state.proformas[i]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProformaCard extends StatefulWidget {
  final Proforma proforma;
  const _ProformaCard({required this.proforma});

  @override
  State<_ProformaCard> createState() => _ProformaCardState();
}

class _ProformaCardState extends State<_ProformaCard> {
  bool _expandida = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.proforma;
    return Card(
      child: Column(
        children: [
          // Cabecera
          InkWell(
            onTap: () => setState(() => _expandida = !_expandida),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.esVigente ? AppTheme.stockNormal : AppTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${p.codigo} · ${p.nombre}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          '${p.partidas.length} partidas',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Icon(_expandida
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_right,
                      color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),

          // Partidas expandidas
          if (_expandida) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: const [
                  Expanded(flex: 4, child: Text('PARTIDA / APU',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary, letterSpacing: 0.5))),
                  Text('CANT. EJEC.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary, letterSpacing: 0.5)),
                ],
              ),
            ),
            ...p.partidas.map((partida) => Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partida.descripcion ?? 'APU-${partida.apuId}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          'APU ID: ${partida.apuId}',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      partida.cantidadObra.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  backgroundColor: AppTheme.primary,
                ),
                onPressed: () {
                  context.read<ProformaBloc>()
                      .add(EjecutarCalculoAPU(p.id));
                  context.push('/proformas/${p.id}/requerimientos');
                },
                icon: const Icon(Icons.calculate_outlined, size: 18),
                label: const Text('Calcular Requerimientos'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
