import 'package:flutter/material.dart';
import '../../../core/design_tokens.dart';
import '../domain/color_sequence.dart';

class ColorSequencePage extends StatefulWidget {
  const ColorSequencePage({super.key, required this.onCompleted});
  final ValueChanged<Duration> onCompleted;

  @override
  State<ColorSequencePage> createState() => _ColorSequencePageState();
}

class _ColorSequencePageState extends State<ColorSequencePage> {
  final ColorSequence _game = ColorSequence();
  final DateTime _startedAt = DateTime.now();
  bool _revealing = true;
  bool _finished = false;
  String _feedback = 'Observe a sequência no seu ritmo.';

  static const _names = ['Azul', 'Verde', 'Amarelo', 'Vermelho'];
  static const _colors = [
    Color(0xFF2364C9),
    Color(0xFF087E8B),
    Color(0xFFE5A044),
    Color(0xFFC65159),
  ];

  @override
  void initState() {
    super.initState();
    _game.start();
  }

  void _choose(int color) {
    final roundComplete = _game.choose(color);
    if (roundComplete) {
      _game.advance();
      if (_game.completed) {
        widget.onCompleted(DateTime.now().difference(_startedAt));
        setState(() {
          _finished = true;
          _feedback = 'Você concluiu as três rodadas!';
        });
      } else {
        setState(() {
          _revealing = true;
          _feedback = 'Muito bem! Observe a próxima sequência.';
        });
      }
    } else {
      setState(() {
        _feedback = _game.position == 0
            ? 'Tudo bem. Veja a sequência e tente de novo.'
            : 'Continue: ${_game.position} de ${_game.visibleSequence.length} cores.';
        if (_game.position == 0) _revealing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      appBar: AppBar(title: const Text('Sequência de cores')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  _finished
                      ? 'Atividade concluída'
                      : 'Rodada ${_game.round} de ${ColorSequence.totalRounds}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _finished
                      ? 'Obrigado por jogar no seu ritmo.'
                      : 'Memorize a ordem e depois toque nas cores na mesma sequência.',
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
                      const SizedBox(height: 20),
                      if (_finished)
                        const Icon(
                          Icons.celebration_outlined,
                          size: 88,
                          color: AppColors.caregiver,
                        )
                      else if (_revealing) ...[
                        const Text(
                          'Sequência para lembrar',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _game.visibleSequence
                              .map(
                                (index) => Chip(
                                  avatar: CircleAvatar(
                                    backgroundColor: _colors[index],
                                    radius: 11,
                                  ),
                                  label: Text(_names[index]),
                                  padding: const EdgeInsets.all(9),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () => setState(() {
                            _revealing = false;
                            _feedback = 'Agora repita a sequência.';
                          }),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Já memorizei',
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Toque nas cores',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 2.1,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: List.generate(
                            4,
                            (index) => OutlinedButton.icon(
                              onPressed: () => _choose(index),
                              icon: CircleAvatar(
                                backgroundColor: _colors[index],
                                radius: 12,
                              ),
                              label: Text(_names[index]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => setState(() => _revealing = true),
                          child: const Text('Ver sequência novamente'),
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
        ),
      ),
    );
  }
}
