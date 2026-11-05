import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/data_session.dart';
import '../../../core/design_tokens.dart';
import '../data/supabase_word_bank_repository.dart';
import '../domain/daily_words.dart';
import '../domain/word_puzzle.dart';

class WordPuzzlePage extends StatefulWidget {
  const WordPuzzlePage({super.key, required this.onCompleted});
  final ValueChanged<Duration> onCompleted;

  @override
  State<WordPuzzlePage> createState() => _WordPuzzlePageState();
}

class _WordPuzzlePageState extends State<WordPuzzlePage> {
  final DateTime _startedAt = DateTime.now();
  List<WordPuzzle> _puzzles = wordPuzzles;
  bool _loading = false;
  String? _loadError;
  int _index = 0;
  final List<int> _selected = [];
  bool _finished = false;
  String _feedback = 'Toque nas letras para formar a palavra.';

  @override
  void initState() {
    super.initState();
    if (appDataSession.isAccount) _loadDailyWords();
  }

  Future<void> _loadDailyWords() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final entries = await SupabaseWordBankRepository(
        Supabase.instance.client,
      ).activeWords();
      final puzzles = puzzlesForDay(entries, DateTime.now());
      if (!mounted) return;
      setState(() {
        _puzzles = puzzles;
        _loading = false;
        _index = 0;
        _selected.clear();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Não foi possível carregar as palavras do dia.';
      });
    }
  }

  void _check() {
    final puzzle = _puzzles[_index];
    if (!puzzle.matches(_selected)) {
      setState(
        () => _feedback =
            'Ainda não. Você pode apagar letras e tentar novamente.',
      );
      return;
    }
    if (_index == _puzzles.length - 1) {
      widget.onCompleted(DateTime.now().difference(_startedAt));
      setState(() {
        _finished = true;
        _feedback = 'Você completou todas as palavras!';
      });
    } else {
      setState(() {
        _index++;
        _selected.clear();
        _feedback = 'Muito bem! Vamos à próxima palavra.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzles[_index];
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      appBar: AppBar(title: const Text('Complete a palavra')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_loadError!),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loadDailyWords,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
            : _buildGame(puzzle, surface),
      ),
    );
  }

  Widget _buildGame(WordPuzzle puzzle, Color surface) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _finished
                  ? 'Atividade concluída'
                  : 'Palavra ${_index + 1} de ${_puzzles.length}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _finished
                  ? 'Obrigado por jogar no seu ritmo.'
                  : 'Use a pista e organize as letras.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _feedback,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_finished)
                    const Icon(
                      Icons.celebration_outlined,
                      size: 88,
                      color: AppColors.caregiver,
                    )
                  else ...[
                    Text(
                      'Pista: ${puzzle.hint}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(puzzle.letters.length, (
                        position,
                      ) {
                        final letter = position < _selected.length
                            ? puzzle.letters[_selected[position]]
                            : ' ';
                        return Container(
                          width: 48,
                          height: 58,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.line, width: 2),
                          ),
                          child: Text(
                            letter,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(
                        puzzle.letters.length,
                        (letterIndex) => SizedBox(
                          width: 62,
                          height: 62,
                          child: OutlinedButton(
                            onPressed: _selected.contains(letterIndex)
                                ? null
                                : () => setState(() {
                                    _selected.add(letterIndex);
                                    _feedback =
                                        'Toque nas letras para formar a palavra.';
                                  }),
                            child: Text(
                              puzzle.letters[letterIndex],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton.icon(
                      onPressed: _selected.isEmpty
                          ? null
                          : () => setState(() => _selected.removeLast()),
                      icon: const Icon(Icons.backspace_outlined),
                      label: const Text('Apagar última letra'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _selected.length == puzzle.letters.length
                          ? _check
                          : null,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Conferir palavra',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_finished) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar aos jogos'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
