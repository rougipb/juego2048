import 'package:flutter/material.dart';
import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/async_data_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/partida_list_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _partidaDao = PartidaDao();
  final _searchController = TextEditingController();
  int _minTileFilter = 0;
  late Future<List<Partida>> _futurePartidas;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futurePartidas = _partidaDao.obtenerHistorial(
        filtroUsuario: _searchController.text,
        filtroFichaMinima: _minTileFilter,
      );
    });
  }

  Future<void> _eliminarConDeshacer(Partida partida) async {
    if (partida.id == null) return;
    await _partidaDao.eliminarPartida(partida.id!);
    _loadData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partida de ${partida.usuario} eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () async {
            await _partidaDao.insertarPartida(partida);
            _loadData();
          },
        ),
      ),
    );
  }

  Future<void> _navegarADetalle(int id) async {
    final deleted = await Navigator.pushNamed(
      context,
      AppRoutes.detail,
      arguments: id,
    );
    if (deleted == true) {
      _loadData();
    }
  }

  void _mostrarMenuContextual(Partida partida) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Ver detalle'),
              onTap: () {
                Navigator.pop(ctx);
                if (partida.id != null) _navegarADetalle(partida.id!);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar partida'),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await ConfirmDialog.show(
                  context,
                  title: 'Eliminar partida',
                  message: '¿Seguro que deseas borrar esta partida?',
                );
                if (ok) _eliminarConDeshacer(partida);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Partidas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por jugador',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _loadData(),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                DropdownButton<int>(
                  value: _minTileFilter,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Todas')),
                    DropdownMenuItem(value: 128, child: Text('>= 128')),
                    DropdownMenuItem(value: 512, child: Text('>= 512')),
                    DropdownMenuItem(value: 1024, child: Text('>= 1024')),
                    DropdownMenuItem(value: 2048, child: Text('>= 2048')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      _minTileFilter = val;
                      _loadData();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: AsyncDataView<List<Partida>>(
              future: _futurePartidas,
              onRetry: _loadData,
              builder: (context, partidas) {
                if (partidas.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.history_toggle_off,
                    message: 'No hay partidas registradas con estos filtros.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    itemCount: partidas.length,
                    itemBuilder: (context, index) {
                      final p = partidas[index];
                      return Dismissible(
                        key: ValueKey(p.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _eliminarConDeshacer(p),
                        child: PartidaListItem(
                          partida: p,
                          onTap: () {
                            if (p.id != null) _navegarADetalle(p.id!);
                          },
                          onLongPress: () => _mostrarMenuContextual(p),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}