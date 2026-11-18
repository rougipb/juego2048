import 'package:flutter/material.dart';
import '../data/usuario_dao.dart';
import '../routes.dart';
import '../services/preferencias_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final PreferenciasService prefs;

  const LoginScreen({super.key, required this.prefs});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _usuarioDao = UsuarioDao();

  bool _isRegister = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefs.ultimoJugador.isNotEmpty) {
      _userController.text = widget.prefs.ultimoJugador;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      if (_isRegister) {
        await _usuarioDao.registrarUsuario(
          _userController.text,
          _emailController.text,
          _passController.text,
        );
        await widget.prefs.guardarUltimoJugador(_userController.text.trim());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario registrado correctamente')),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.shell);
      } else {
        final user = await _usuarioDao.login(
          _userController.text,
          _passController.text,
        );
        if (user != null) {
          await widget.prefs.guardarUltimoJugador(user.usuario);
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, AppRoutes.shell);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario o contraseña incorrectos')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: El usuario ya existe o datos inválidos ($e)')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '2048',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRegister ? 'Crear cuenta' : 'Iniciar sesión',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  TextFormField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Introduce un usuario' : null,
                  ),
                  if (_isRegister) ...[
                    const SizedBox(height: AppConstants.paddingMedium),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (v) {
                        if (v == null || !v.contains('@') || !v.contains('.')) {
                          return 'Introduce un email válido con @';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    controller: _passController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (v) =>
                    (v == null || v.length < 4) ? 'Mínimo 4 caracteres' : null,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(_isRegister ? 'Registrarse' : 'Entrar'),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isRegister = !_isRegister),
                    child: Text(
                      _isRegister
                          ? '¿Ya tienes cuenta? Inicia sesión'
                          : '¿No tienes cuenta? Regístrate',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}