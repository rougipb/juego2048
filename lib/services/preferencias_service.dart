import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasService extends ChangeNotifier {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyTileScheme = 'tile_color_scheme';
  static const String _keyLastPlayer = 'last_player';
  static const String _keyBestScore = 'best_score';

  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  String _tileScheme = 'Clásico';
  String _ultimoJugador = '';
  int _mejorPuntuacion = 0;

  ThemeMode get themeMode => _themeMode;
  String get tileScheme => _tileScheme;
  String get ultimoJugador => _ultimoJugador;
  int get mejorPuntuacion => _mejorPuntuacion;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _themeMode = leerModoTema();
    _tileScheme = _prefs.getString(_keyTileScheme) ?? 'Clásico';
    _ultimoJugador = _prefs.getString(_keyLastPlayer) ?? '';
    _mejorPuntuacion = _prefs.getInt(_keyBestScore) ?? 0;
  }

  ThemeMode leerModoTema() {
    final value = _prefs.getString(_keyThemeMode);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> guardarModoTema(ThemeMode modo) async {
    _themeMode = modo;
    String value = 'system';
    if (modo == ThemeMode.light) value = 'light';
    if (modo == ThemeMode.dark) value = 'dark';
    await _prefs.setString(_keyThemeMode, value);
    notifyListeners();
  }

  Future<void> guardarEsquemaFichas(String scheme) async {
    _tileScheme = scheme;
    await _prefs.setString(_keyTileScheme, scheme);
    notifyListeners();
  }

  Future<void> guardarUltimoJugador(String nombre) async {
    _ultimoJugador = nombre;
    await _prefs.setString(_keyLastPlayer, nombre);
    notifyListeners();
  }

  Future<void> actualizarMejorPuntuacion(int puntuacion) async {
    if (puntuacion > _mejorPuntuacion) {
      _mejorPuntuacion = puntuacion;
      await _prefs.setInt(_keyBestScore, puntuacion);
      notifyListeners();
    }
  }
}