import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_viva/features/games/domain/color_sequence.dart';
import 'package:mente_viva/features/games/domain/game_completion.dart';
import 'package:mente_viva/features/games/domain/word_puzzle.dart';

class _RecordingRepository implements GameCompletionRepository {
  int calls = 0;
  String? title;
  Duration? elapsed;

  @override
  void recordCompletion(String title, DateTime completedAt, Duration elapsed) {
    calls++;
    this.title = title;
    this.elapsed = elapsed;
  }
}

void main() {
  test('sequência avança somente após a ordem correta', () {
    final game = ColorSequence(random: Random(7))..start();
    final first = game.visibleSequence.first;
    expect(game.choose((first + 1) % 4), isFalse);
    expect(game.position, 0);

    for (var round = 1; round <= ColorSequence.totalRounds; round++) {
      for (final color in game.visibleSequence) {
        game.choose(color);
      }
      game.advance();
      expect(game.completed, round == ColorSequence.totalRounds);
    }
  });

  test('palavras aceitam letras repetidas em posições distintas', () {
    final casa = wordPuzzles.first;
    expect(casa.matches([2, 0, 1, 3]), isTrue);
    expect(casa.matches([2, 0, 1, 0]), isFalse);
    expect(casa.matches([0, 1, 2, 3]), isFalse);
  });

  test('conclusão informa o jogo e o tempo real ao repositório', () {
    final repository = _RecordingRepository();
    CompleteGame(repository)('Sequência de cores', const Duration(minutes: 2));
    expect(repository.calls, 1);
    expect(repository.title, 'Sequência de cores');
    expect(repository.elapsed, const Duration(minutes: 2));
  });
}
