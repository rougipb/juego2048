import 'package:flutter/material.dart';
import '../data/partida_guardada_dao.dart';
import '../models/partida_guardada.dart';
import '../routes.dart';
import '../services/preferencias_service.dart';
import '../theme/app_theme.dart';
import '../widgets/score_card.dart';

class HomeScreen extends StatefulWidget {
  final PreferenciasService prefs;

  const HomeScreen({super.key, required this.prefs});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _guardadaDao = PartidaGuardadaDao();
  PartidaGuardada? _partidaEnCurso;

  @override
  void initState() {
    super.initState();
    _comprobarPartidaGuardada();
  }

  Future<void> _comprobarPartidaGuardada() async {
    final guardada = await _guardadaDao.obtenerPartidaGuardada();
    if (mounted) {
      setState(() => _partidaEnCurso = guardada);
    }
  }

  Future<void> _abrirJuego({PartidaGuardada? continuar}) async {
    if (continuar == null) {
      await _guardadaDao.borrarPartidaGuardada();
    }
    if (!mounted) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.game,
      arguments: continuar,
    );
    _comprobarPartidaGuardada();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048'),
        actions: [
          IconButton(
            tooltip: 'Cambiar usuario',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.login),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hola, ${widget.prefs.ultimoJugador}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              ListenableBuilder(
                listenable: widget.prefs,
                builder: (context, _) {
                  return ScoreCard(
                    label: 'MEJOR PUNTUACIÓN',
                    value: widget.prefs.mejorPuntuacion,
                  );
                },
              ),
              const SizedBox(height: AppConstants.paddingLarge * 1.5),
              SizedBox(
                width: 240,
                child: FilledButton.icon(
                  onPressed: () => _abrirJuego(),
                  icon: const Icon(Icons.play_arrow),
                  label: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Nueva Partida'),
                  ),
                ),
              ),
              if (_partidaEnCurso != null) ...[
                const SizedBox(height: AppConstants.paddingMedium),
                SizedBox(
                  width: 240,
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirJuego(continuar: _partidaEnCurso),
                    icon: const Icon(Icons.restore),
                    label: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Continuar (${_partidaEnCurso!.puntuacion} pts)'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}