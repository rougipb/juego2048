class Partida {
  final int? id;
  final String usuario;
  final int puntuacion;
  final int fichaMaxima;
  final int movimientos;
  final int duracionSegundos;
  final String fecha;
  final int tamanoTablero;

  const Partida({
    this.id,
    required this.usuario,
    required this.puntuacion,
    required this.fichaMaxima,
    required this.movimientos,
    required this.duracionSegundos,
    required this.fecha,
    this.tamanoTablero = 4,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'usuario': usuario,
      'puntuacion': puntuacion,
      'ficha_maxima': fichaMaxima,
      'movimientos': movimientos,
      'duracion_segundos': duracionSegundos,
      'fecha': fecha,
      'tamano_tablero': tamanoTablero,
    };
  }

  factory Partida.fromMap(Map<String, dynamic> map) {
    return Partida(
      id: map['id'] as int?,
      usuario: map['usuario'] as String,
      puntuacion: map['puntuacion'] as int,
      fichaMaxima: map['ficha_maxima'] as int,
      movimientos: map['movimientos'] as int,
      duracionSegundos: map['duracion_segundos'] as int,
      fecha: map['fecha'] as String,
      tamanoTablero: (map['tamano_tablero'] as int?) ?? 4,
    );
  }
}