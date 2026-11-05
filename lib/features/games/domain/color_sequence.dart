import 'dart:math';

/// Regras do jogo; não depende de widgets ou de armazenamento.
class ColorSequence {
  ColorSequence({Random? random}) : _random = random ?? Random();

  final Random _random;
  final List<int> _sequence = [];
  int _round = 0;
  int _position = 0;

  static const totalRounds = 3;
  int get round => _round + 1;
  int get position => _position;
  bool get completed => _round >= totalRounds;
  List<int> get visibleSequence => List.unmodifiable(_sequence);

  void start() {
    _round = 0;
    _sequence.clear();
    _nextRound();
  }

  void _nextRound() {
    _position = 0;
    _sequence.add(_random.nextInt(4));
    if (_sequence.length == 1) _sequence.add(_random.nextInt(4));
  }

  /// Retorna true quando a rodada termina. Uma tentativa incorreta reinicia
  /// a posição da rodada, permitindo tentar novamente sem punição.
  bool choose(int color) {
    if (completed || color < 0 || color > 3) return false;
    if (_sequence[_position] != color) {
      _position = 0;
      return false;
    }
    _position++;
    return _position == _sequence.length;
  }

  void advance() {
    if (completed || _position != _sequence.length) return;
    _round++;
    if (!completed) _nextRound();
  }
}
