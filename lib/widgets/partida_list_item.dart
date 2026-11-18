import 'package:flutter/material.dart';
import '../models/partida.dart';
import '../theme/app_theme.dart';

class PartidaListItem extends StatelessWidget {
  final Partida partida;
  final int? rankPosition;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PartidaListItem({
    super.key,
    required this.partida,
    this.rankPosition,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final fechaCorta = partida.fecha.split('T').first;
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: 6,
      ),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            rankPosition != null ? '#$rankPosition' : '${partida.fichaMaxima}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          '${partida.usuario} • ${partida.puntuacion} pts',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Ficha máx: ${partida.fichaMaxima} | Movs: ${partida.movimientos} | $fechaCorta',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}