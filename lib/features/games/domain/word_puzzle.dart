class WordPuzzle {
  const WordPuzzle({
    required this.hint,
    required this.answer,
    required this.letters,
  });

  final String hint;
  final String answer;
  final List<String> letters;

  bool matches(List<int> selectedIndexes) {
    if (selectedIndexes.length != letters.length) return false;
    if (selectedIndexes.toSet().length != letters.length) return false;
    if (selectedIndexes.any((index) => index < 0 || index >= letters.length)) {
      return false;
    }
    return selectedIndexes.map((index) => letters[index]).join() == answer;
  }
}

const wordPuzzles = [
  WordPuzzle(
    hint: 'Lugar onde moramos',
    answer: 'CASA',
    letters: ['A', 'S', 'C', 'A'],
  ),
  WordPuzzle(
    hint: 'Planta com pétalas',
    answer: 'FLOR',
    letters: ['R', 'O', 'F', 'L'],
  ),
  WordPuzzle(
    hint: 'Objeto para ler',
    answer: 'LIVRO',
    letters: ['V', 'O', 'R', 'I', 'L'],
  ),
];
