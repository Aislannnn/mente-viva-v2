import 'dart:math';

import 'word_puzzle.dart';

class WordEntry {
  const WordEntry({required this.id, required this.hint, required this.answer});
  final int id;
  final String hint;
  final String answer;
}

abstract class WordBankRepository {
  Future<List<WordEntry>> activeWords();
}

List<WordPuzzle> puzzlesForDay(List<WordEntry> words, DateTime day) {
  if (words.length < 4)
    throw StateError('O banco precisa ter ao menos 4 palavras.');
  final sorted = [...words]..sort((a, b) => a.id.compareTo(b.id));
  final ordinal = DateTime.utc(
    day.year,
    day.month,
    day.day,
  ).difference(DateTime.utc(2020, 1, 1)).inDays;
  final start = sorted.length % 3 == 0
      ? (ordinal % (sorted.length ~/ 3)) * 3
      : ordinal % sorted.length;
  return [
    for (var i = 0; i < 3; i++)
      WordPuzzle(
        hint: sorted[(start + i) % sorted.length].hint,
        answer: sorted[(start + i) % sorted.length].answer,
        letters: _shuffle(
          sorted[(start + i) % sorted.length].answer,
          ordinal + sorted[(start + i) % sorted.length].id,
        ),
      ),
  ];
}

List<String> _shuffle(String answer, int seed) {
  final letters = answer.split('');
  letters.shuffle(Random(seed));
  if (letters.join() == answer) {
    final first = letters.removeAt(0);
    letters.add(first);
  }
  return letters;
}
