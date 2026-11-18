import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  static const String _dbName = 'game2048.db';
  static const int _dbVersion = 2;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT NOT NULL UNIQUE,
        fecha_registro TEXT NOT NULL,
        email TEXT NOT NULL,
        contraseña TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE partidas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT NOT NULL,
        puntuacion INTEGER NOT NULL,
        ficha_maxima INTEGER NOT NULL,
        movimientos INTEGER NOT NULL,
        duracion_segundos INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        tamano_tablero INTEGER NOT NULL DEFAULT 4
      )
    ''');

    await db.execute('''
      CREATE TABLE partida_guardada (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        tablero TEXT NOT NULL,
        puntuacion INTEGER NOT NULL,
        movimientos INTEGER NOT NULL,
        segundos_transcurridos INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE partidas ADD COLUMN tamano_tablero INTEGER NOT NULL DEFAULT 4',
      );
    }
  }
}