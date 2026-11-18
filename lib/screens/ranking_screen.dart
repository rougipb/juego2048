import 'package:flutter/material.dart';
import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../theme/app_theme.dart';
import '../widgets/async_data_view.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/partida_list_item.dart';
import '../widgets/stat_card.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final _partidaDao = PartidaDao();
  late Future<EstadisticasRow> _futureData;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    setState(() {
      _futureData = _fetchRankingData();
    });
  }

  Future<EstadisticasRow> _fetchRankingData() async {
    final top10 = await _partidaDao.obtenerTop10();
    final globales = await _partidaDao.obtenerEstadisticasGlobales();
    final porJugador = await _partidaDao.obtenerEstadisticasPorJugador();
    return {
      'top10': top10,
      'globales': globales,
      'porJugador': porJugador,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking y Estadísticas')),
      body: AsyncDataView<EstadisticasRow>(
        future: _futureData,
        onRetry: _loadAll,
        builder: (context, data) {
          final top10 = data['top10'] as List<Partida>;
          final globales = data['globales'] as EstadisticasRow;
          final porJugador = data['porJugador'] as List<EstadisticasRow>;

          if (top10.isEmpty) {
            return const EmptyStateView(
              icon: Icons.leaderboard_outlined,
              message: 'Aún no hay partidas suficientes para mostrar estadísticas.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadAll(),
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              children: [
                Text(
                  'Estadísticas Globales',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      title: 'Partidas Jugadas',
                      value: '${globales['total_partidas']}',
                      icon: Icons.sports_esports,
                    ),
                    StatCard(
                      title: 'Récord Global',
                      value: '${globales['max_puntuacion']}',
                      icon: Icons.emoji_events,
                    ),
                    StatCard(
                      title: 'Media Puntos',
                      value: (globales['media_puntuacion'] as num).toStringAsFixed(0),
                      icon: Icons.analytics,
                    ),
                    StatCard(
                      title: 'Tiempo Total',
                      value: '${globales['tiempo_total']}s',
                      icon: Icons.timer,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  'Por Jugador',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...porJugador.map(
                      (j) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('${j['usuario']}'),
                      subtitle: Text('Partidas: ${j['total_partidas']}'),
                      trailing: Text(
                        'Mejor: ${j['mejor_puntuacion']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  'Top 10 Mejores Partidas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  top10.length,
                      (i) => PartidaListItem(
                    partida: top10[i],
                    rankPosition: i + 1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}