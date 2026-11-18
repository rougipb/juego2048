import 'package:sqflite/sqflite.dart';
import '../models/partida_guardada.dart';
import 'database_helper.dart';

class PartidaGuardadaDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> guardarPartida(PartidaGuardada partida) async {
    final db = await _dbHelper.database;
    await db.insert(
      'partida_guardada',
      partida.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PartidaGuardada?> obtenerPartidaGuardada() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'partida_guardada',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return PartidaGuardada.fromMap(maps.first);
    }
    return null;
  }

  Future<void> borrarPartidaGuardada() async {
    final db = await _dbHelper.database;
    await db.delete(
      'partida_guardada',
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}