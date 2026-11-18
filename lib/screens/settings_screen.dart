import 'package:flutter/material.dart';
import '../data/partida_dao.dart';
import '../services/preferencias_service.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_dialog.dart';

class SettingsScreen extends StatelessWidget {
  final PreferenciasService prefs;

  const SettingsScreen({super.key, required this.prefs});

  Future<void> _borrarHistorial(BuildContext context) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Borrar todo el historial',
      message: 'Esta acción eliminará todas las partidas guardadas y no se puede deshacer. ¿Continuar?',
      confirmText: 'Borrar todo',
    );
    if (confirm) {
      await PartidaDao().eliminarTodoHistorial();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historial borrado por completo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListenableBuilder(
        listenable: prefs,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            children: [
              Text(
                'Tema de la aplicación',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Claro'),
                    icon: Icon(Icons.light_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Oscuro'),
                    icon: Icon(Icons.dark_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('Sistema'),
                    icon: Icon(Icons.brightness_auto),
                  ),
                ],
                selected: {prefs.themeMode},
                onSelectionChanged: (set) => prefs.guardarModoTema(set.first),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              Text(
                'Color de las fichas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...AppTheme.colorSchemes.map(
                (scheme) => RadioListTile<String>(
                  title: Text(scheme),
                  value: scheme,
                  groupValue: prefs.tileScheme,
                  onChanged: (val) {
                    if (val != null) prefs.guardarEsquemaFichas(val);
                  },
                ),
              ),
              const Divider(height: 32),
              Text(
                'Gestión de datos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: () => _borrarHistorial(context),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text('Borrar todo el historial'),
              ),
            ],
          );
        },
      ),
    );
  }
}