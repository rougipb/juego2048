import 'package:sqflite/sqflite.dart';
import '../models/partida.dart';
import 'database_helper.dart';

typedef EstadisticasRow = Map<String, Object?>;

class PartidaDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> finalizarPartidaTransaccion(Partida partida) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      final id = await txn.insert('partidas', partida.toMap());
      await txn.delete(
        'partida_guardada',
        where: 'id = ?',
        whereArgs: [1],
      );
      return id;
    });
  }

  Future<int> insertarPartida(Partida partida) async {
    final db = await _dbHelper.database;
    return await db.insert('partidas', partida.toMap());
  }

  Future<List<Partida>> obtenerHistorial({
    String? filtroUsuario,
    int? filtroFichaMinima,
  }) async {
    final db = await _dbHelper.database;
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (filtroUsuario != null && filtroUsuario.trim().isNotEmpty) {
      whereClauses.add('usuario LIKE ?');
      whereArgs.add('%${filtroUsuario.trim()}%');
    }
    if (filtroFichaMinima != null && filtroFichaMinima > 0) {
      whereClauses.add('ficha_maxima >= ?');
      whereArgs.add(filtroFichaMinima);
    }

    final maps = await db.query(
      'partidas',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'fecha DESC',
    );
    return maps.map((m) => Partida.fromMap(m)).toList();
  }

  Future<Partida?> obtenerPorId(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'partidas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Partida.fromMap(maps.first);
    }
    return null;
  }

  Future<int> eliminarPartida(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'partidas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminarTodoHistorial() async {
    final db = await _dbHelper.database;
    return await db.delete('partidas');
  }

  Future<List<Partida>> obtenerTop10() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'partidas',
      orderBy: 'puntuacion DESC',
      limit: 10,
    );
    return maps.map((m) => Partida.fromMap(m)).toList();
  }

  Future<EstadisticasRow> obtenerEstadisticasGlobales() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as total_partidas,
        COALESCE(MAX(puntuacion), 0) as max_puntuacion,
        COALESCE(AVG(puntuacion), 0) as media_puntuacion,
        COALESCE(MAX(ficha_maxima), 0) as max_ficha,
        COALESCE(SUM(duracion_segundos), 0) as tiempo_total
      FROM partidas
    ''');
    return result.first;
  }

  Future<List<EstadisticasRow>> obtenerEstadisticasPorJugador() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT
        usuario,
        COUNT(*) as total_partidas,
        MAX(puntuacion) as mejor_puntuacion
      FROM partidas
      GROUP BY usuario
      ORDER BY mejor_puntuacion DESC
    ''');
  }
}