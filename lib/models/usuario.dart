class Usuario {
  final int? id;
  final String usuario;
  final String fechaRegistro;
  final String email;
  final String contrasena;

  const Usuario({
    this.id,
    required this.usuario,
    required this.fechaRegistro,
    required this.email,
    required this.contrasena,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'usuario': usuario,
      'fecha_registro': fechaRegistro,
      'email': email,
      'contraseña': contrasena,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      usuario: map['usuario'] as String,
      fechaRegistro: map['fecha_registro'] as String,
      email: map['email'] as String,
      contrasena: map['contraseña'] as String,
    );
  }
}