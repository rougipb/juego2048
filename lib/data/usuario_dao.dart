import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/usuario.dart';
import 'database_helper.dart';

class UsuarioDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String _hashPassword(String password) {
    // Encriptación básica con sal y codificación Base64/XOR para cumplir el requisito
    final bytes = utf8.encode('2048_salt_$password');
    final encoded = bytes.map((b) => (b ^ 0x5A)).toList();
    return base64Encode(encoded);
  }

  Future<int> registrarUsuario(String usuario, String email, String password) async {
    final db = await _dbHelper.database;
    final nuevo = Usuario(
      usuario: usuario.trim(),
      fechaRegistro: DateTime.now().toIso8601String(),
      email: email.trim(),
      contrasena: _hashPassword(password),
    );
    return await db.insert(
      'usuarios',
      nuevo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<Usuario?> login(String usuario, String password) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'usuarios',
      where: 'usuario = ? AND contraseña = ?',
      whereArgs: [usuario.trim(), _hashPassword(password)],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }
}