import 'dart:convert';

class PartidaGuardada {
  final int id;
  final List<int> tablero;
  final int puntuacion;
  final int movimientos;
  final int segundosTranscurridos;

  const PartidaGuardada({
    this.id = 1,
    required this.tablero,
    required this.puntuacion,
    required this.movimientos,
    required this.segundosTranscurridos,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tablero': jsonEncode(tablero),
      'puntuacion': puntuacion,
      'movimientos': movimientos,
      'segundos_transcurridos': segundosTranscurridos,
    };
  }

  factory PartidaGuardada.fromMap(Map<String, dynamic> map) {
    final decoded = jsonDecode(map['tablero'] as String) as List<dynamic>;
    return PartidaGuardada(
      id: map['id'] as int,
      tablero: decoded.map((e) => e as int).toList(),
      puntuacion: map['puntuacion'] as int,
      movimientos: map['movimientos'] as int,
      segundosTranscurridos: map['segundos_transcurridos'] as int,
    );
  }
}