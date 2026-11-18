import 'package:flutter/material.dart';
import 'routes.dart';
import 'services/preferencias_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = PreferenciasService();
  await prefs.init();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final PreferenciasService prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) {
        return MaterialApp(
          title: '2048 Flutter',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: prefs.themeMode,
          initialRoute: prefs.ultimoJugador.isNotEmpty
              ? AppRoutes.shell
              : AppRoutes.login,
          onGenerateRoute: (settings) =>
              AppRoutes.onGenerateRoute(settings, prefs),
        );
      },
    );
  }
}