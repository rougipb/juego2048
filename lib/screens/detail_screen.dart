import 'package:flutter/material.dart';
import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../theme/app_theme.dart';
import '../widgets/async_data_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/stat_card.dart';

class DetailScreen extends StatefulWidget {
  final int partidaId;

  const DetailScreen({super.key, required this.partidaId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _partidaDao = PartidaDao();
  late Future<Partida?> _futurePartida;

  @override
  void initState() {
    super.initState();
    _loadPartida();
  }

  void _loadPartida() {
    setState(() {
      _futurePartida = _partidaDao.obtenerPorId(widget.partidaId);
    });
  }

  Future<void> _borrar() async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Eliminar partida',
      message: '¿Deseas eliminar definitivamente esta partida del historial?',
    );
    if (confirm) {
      await _partidaDao.eliminarPartida(widget.partidaId);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Partida'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _borrar,
          ),
        ],
      ),
      body: AsyncDataView<Partida?>(
        future: _futurePartida,
        onRetry: _loadPartida,
        builder: (context, partida) {
          if (partida == null) {
            return const EmptyStateView(
              icon: Icons.error_outline,
              message: 'No se encontró la partida solicitada.',
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      children: [
                        Text(
                          partida.usuario,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text('Fecha: ${partida.fecha.replaceFirst('T', ' ').substring(0, 16)}'),
                        Text('Tablero: ${partida.tamanoTablero}x${partida.tamanoTablero}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  children: [
                    StatCard(
                      title: 'Puntuación',
                      value: '${partida.puntuacion}',
                      icon: Icons.emoji_events,
                    ),
                    StatCard(
                      title: 'Ficha Máxima',
                      value: '${partida.fichaMaxima}',
                      icon: Icons.grid_4x4,
                    ),
                    StatCard(
                      title: 'Movimientos',
                      value: '${partida.movimientos}',
                      icon: Icons.swipe,
                    ),
                    StatCard(
                      title: 'Duración',
                      value: '${partida.duracionSegundos}s',
                      icon: Icons.timer,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}