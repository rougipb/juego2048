import 'package:flutter/material.dart';
import 'models/partida_guardada.dart';
import 'screens/detail_screen.dart';
import 'screens/game_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell_screen.dart';
import 'services/preferencias_service.dart';

class AppRoutes {
  static const String login = '/login';
  static const String shell = '/shell';
  static const String game = '/game';
  static const String detail = '/detail';

  static Route<dynamic> onGenerateRoute(
      RouteSettings settings,
      PreferenciasService prefs,
      ) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(prefs: prefs),
        );
      case shell:
        return MaterialPageRoute(
          builder: (_) => MainShellScreen(prefs: prefs),
        );
      case game:
        final partidaGuardada = settings.arguments as PartidaGuardada?;
        return MaterialPageRoute(
          builder: (_) => GameScreen(
            prefs: prefs,
            partidaInicial: partidaGuardada,
          ),
        );
      case detail:
        final partidaId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => DetailScreen(partidaId: partidaId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(prefs: prefs),
        );
    }
  }
}