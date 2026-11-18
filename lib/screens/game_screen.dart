import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/partida_dao.dart';
import '../data/partida_guardada_dao.dart';
import '../models/partida.dart';
import '../models/partida_guardada.dart';
import '../services/preferencias_service.dart';
import '../theme/app_theme.dart';
import '../widgets/board_widget.dart';
import '../widgets/score_card.dart';

class GameScreen extends StatefulWidget {
  final PreferenciasService prefs;
  final PartidaGuardada? partidaInicial;

  const GameScreen({
    super.key,
    required this.prefs,
    this.partidaInicial,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final _partidaDao = PartidaDao();
  final _guardadaDao = PartidaGuardadaDao();
  final _random = Random();
  final _focusNode = FocusNode();

  late List<int> _board;
  int _score = 0;
  int _moves = 0;
  int _seconds = 0;
  bool _gameOver = false;
  bool _showDetails = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.partidaInicial != null) {
      _board = List<int>.from(widget.partidaInicial!.tablero);
      _score = widget.partidaInicial!.puntuacion;
      _moves = widget.partidaInicial!.movimientos;
      _seconds = widget.partidaInicial!.segundosTranscurridos;
    } else {
      _initNewGame();
    }
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  // Guardado automático al pasar la aplicación a segundo plano
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (!_gameOver) {
        _saveCurrentState();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_gameOver && mounted) {
        setState(() => _seconds++);
      }
    });
  }

  void _initNewGame() {
    _board = List.filled(16, 0);
    _score = 0;
    _moves = 0;
    _seconds = 0;
    _gameOver = false;
    _spawnTile();
    _spawnTile();
  }

  void _spawnTile() {
    final emptyIndices = <int>[];
    for (int i = 0; i < 16; i++) {
      if (_board[i] == 0) emptyIndices.add(i);
    }
    if (emptyIndices.isNotEmpty) {
      final index = emptyIndices[_random.nextInt(emptyIndices.length)];
      _board[index] = _random.nextInt(10) == 0 ? 4 : 2;
    }
  }

  List<int> _mergeLine(List<int> line) {
    final nonZero = line.where((v) => v != 0).toList();
    final merged = <int>[];
    int i = 0;
    while (i < nonZero.length) {
      if (i + 1 < nonZero.length && nonZero[i] == nonZero[i + 1]) {
        final newVal = nonZero[i] * 2;
        merged.add(newVal);
        _score += newVal;
        i += 2;
      } else {
        merged.add(nonZero[i]);
        i++;
      }
    }
    while (merged.length < 4) {
      merged.add(0);
    }
    return merged;
  }

  void _move(SwipeDirection dir) {
    if (_gameOver) return;
    final oldBoard = List<int>.from(_board);

    for (int i = 0; i < 4; i++) {
      List<int> line = [];
      for (int j = 0; j < 4; j++) {
        switch (dir) {
          case SwipeDirection.left:
            line.add(_board[i * 4 + j]);
            break;
          case SwipeDirection.right:
            line.add(_board[i * 4 + (3 - j)]);
            break;
          case SwipeDirection.up:
            line.add(_board[j * 4 + i]);
            break;
          case SwipeDirection.down:
            line.add(_board[(3 - j) * 4 + i]);
            break;
        }
      }

      final merged = _mergeLine(line);

      for (int j = 0; j < 4; j++) {
        switch (dir) {
          case SwipeDirection.left:
            _board[i * 4 + j] = merged[j];
            break;
          case SwipeDirection.right:
            _board[i * 4 + (3 - j)] = merged[j];
            break;
          case SwipeDirection.up:
            _board[j * 4 + i] = merged[j];
            break;
          case SwipeDirection.down:
            _board[(3 - j) * 4 + i] = merged[j];
            break;
        }
      }
    }

    bool changed = false;
    for (int i = 0; i < 16; i++) {
      if (oldBoard[i] != _board[i]) {
        changed = true;
        break;
      }
    }

    if (changed) {
      setState(() {
        _moves++;
        _spawnTile();
      });
      widget.prefs.actualizarMejorPuntuacion(_score);
      if (!_canMove()) {
        _onGameOver();
      }
    }
  }

  bool _canMove() {
    if (_board.contains(0)) return true;
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        final val = _board[r * 4 + c];
        if (c + 1 < 4 && val == _board[r * 4 + c + 1]) return true;
        if (r + 1 < 4 && val == _board[(r + 1) * 4 + c]) return true;
      }
    }
    return false;
  }

  Future<void> _saveCurrentState() async {
    await _guardadaDao.guardarPartida(
      PartidaGuardada(
        tablero: _board,
        puntuacion: _score,
        movimientos: _moves,
        segundosTranscurridos: _seconds,
      ),
    );
  }

  Future<void> _onGameOver() async {
    setState(() => _gameOver = true);
    _timer?.cancel();

    final maxTile = _board.reduce(max);
    final partida = Partida(
      usuario: widget.prefs.ultimoJugador.isEmpty
          ? 'Invitado'
          : widget.prefs.ultimoJugador,
      puntuacion: _score,
      fichaMaxima: maxTile,
      movimientos: _moves,
      duracionSegundos: _seconds,
      fecha: DateTime.now().toIso8601String(),
    );

    await _partidaDao.finalizarPartidaTransaccion(partida);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Fin de la partida!'),
        content: Text(
          'Puntuación final: $_score\nFicha máxima: $maxTile\nMovimientos: $_moves',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Volver al inicio'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _initNewGame();
                _startTimer();
              });
            },
            child: const Text('Jugar de nuevo'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBackNavigation() async {
    if (_gameOver || _moves == 0) {
      Navigator.of(context).pop();
      return;
    }

    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Salir de la partida'),
        content: const Text('¿Qué deseas hacer con la partida en curso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('cancel'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('discard'),
            child: const Text('Salir sin guardar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('save'),
            child: const Text('Guardar y salir'),
          ),
        ],
      ),
    );

    if (action == 'save') {
      await _saveCurrentState();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partida guardada correctamente')),
      );
      Navigator.of(context).pop();
    } else if (action == 'discard') {
      await _guardadaDao.borrarPartidaGuardada();
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBackNavigation();
      },
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _move(SwipeDirection.up);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _move(SwipeDirection.down);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _move(SwipeDirection.left);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _move(SwipeDirection.right);
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('2048'),
            actions: [
              IconButton(
                tooltip: 'Reiniciar partida',
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() {
                  _initNewGame();
                  _startTimer();
                }),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                children: [
                  // Doble toque en la puntuación para mostrar/ocultar detalles
                  GestureDetector(
                    onDoubleTap: () =>
                        setState(() => _showDetails = !_showDetails),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ScoreCard(label: 'PUNTOS', value: _score),
                        ScoreCard(
                          label: 'MEJOR',
                          value: widget.prefs.mejorPuntuacion,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  if (_showDetails)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Movimientos: $_moves  •  Tiempo: ${_seconds}s  •  Ficha máx: ${_board.reduce(max)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    Text(
                      'Movimientos: $_moves  •  Tiempo: ${_seconds}s (Doble toque arriba para detalles)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: BoardWidget(
                      board: _board,
                      colorSchemeName: widget.prefs.tileScheme,
                      onSwipe: _move,
                    ),
                  ),
                  const Spacer(),
                  // Botones accesibles alternativos al gesto swipe
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => _move(SwipeDirection.left),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => _move(SwipeDirection.up),
                            icon: const Icon(Icons.arrow_upward),
                          ),
                          const SizedBox(height: 8),
                          IconButton.filledTonal(
                            onPressed: () => _move(SwipeDirection.down),
                            icon: const Icon(Icons.arrow_downward),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () => _move(SwipeDirection.right),
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ],
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