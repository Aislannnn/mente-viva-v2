part of '../presentation.dart';

class _JogoModel {
  final String titulo, descricao, duracao;
  final IconData icone;
  final Color cor;
  final int duracaoMin;
  const _JogoModel({
    required this.titulo,
    required this.descricao,
    required this.duracao,
    required this.icone,
    required this.cor,
    required this.duracaoMin,
  });
}

const _jogosData = [
  _JogoModel(
    titulo: 'Sequência de cores',
    descricao: 'Memorize e repita a sequência.',
    duracao: '5 min',
    icone: Icons.color_lens_outlined,
    cor: AppColors.lavender,
    duracaoMin: 5,
  ),
  _JogoModel(
    titulo: 'Complete a palavra',
    descricao: 'Forme palavras com letras embaralhadas.',
    duracao: '10 min',
    icone: Icons.text_fields_outlined,
    cor: AppColors.primary,
    duracaoMin: 10,
  ),
  _JogoModel(
    titulo: 'Encontre o par',
    descricao: 'Jogo da memória com figuras do cotidiano.',
    duracao: '8 min',
    icone: Icons.grid_view_outlined,
    cor: AppColors.caregiver,
    duracaoMin: 8,
  ),
  _JogoModel(
    titulo: 'Calendário da memória',
    descricao: 'Treine sua memória episódica.',
    duracao: '5 min',
    icone: Icons.calendar_today_outlined,
    cor: AppColors.amber,
    duracaoMin: 5,
  ),
  _JogoModel(
    titulo: 'Respiração guiada',
    descricao: 'Exercício de relaxamento.',
    duracao: '5 min',
    icone: Icons.air_outlined,
    cor: AppColors.berry,
    duracaoMin: 5,
  ),
  _JogoModel(
    titulo: 'Leitura em voz alta',
    descricao: 'Leia e responda perguntas simples.',
    duracao: '15 min',
    icone: Icons.menu_book_outlined,
    cor: AppColors.amberDark,
    duracaoMin: 15,
  ),
];

class _JogosPage extends StatelessWidget {
  const _JogosPage();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modoEscuro,
      builder: (context, escuro, _) {
        final textColor = escuro ? Colors.white : Colors.black87;
        final subColor = escuro ? Colors.white60 : Colors.black45;

        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ).copyWith(top: 20, bottom: 80),
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.caregiver.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.sports_esports_outlined,
                    color: AppColors.caregiver,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jogos interativos',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Exercite a memória com diversão',
                      style: TextStyle(color: subColor, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dica do dia',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Exercícios cognitivos diários ajudam a retardar a progressão do Alzheimer.',
                          style: TextStyle(color: subColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Atividades disponíveis',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.92,
              children: _jogosData.map((j) {
                return GestureDetector(
                  onTap: () => _mostrarDetalhes(context, j, escuro),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: escuro ? AppColors.nightSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: j.cor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(j.icone, color: j.cor, size: 26),
                        ),
                        const Spacer(),
                        Text(
                          j.titulo,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          j.descricao,
                          style: TextStyle(color: subColor, fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, color: j.cor, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              j.duracao,
                              style: TextStyle(
                                color: j.cor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDetalhes(BuildContext context, _JogoModel jogo, bool escuro) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetalhesJogoSheet(jogo: jogo, escuro: escuro),
    );
  }
}

class _DetalhesJogoSheet extends StatelessWidget {
  final _JogoModel jogo;
  final bool escuro;
  const _DetalhesJogoSheet({required this.jogo, required this.escuro});

  @override
  Widget build(BuildContext context) {
    final bg = escuro ? AppColors.nightBackground : Colors.white;
    final textColor = escuro ? Colors.white : Colors.black87;
    final subColor = escuro ? Colors.white60 : Colors.black45;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: jogo.cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(jogo.icone, color: jogo.cor, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            jogo.titulo,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            jogo.descricao,
            style: TextStyle(color: subColor, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined, color: jogo.cor, size: 18),
              const SizedBox(width: 6),
              Text(
                'Duração: ${jogo.duracao}',
                style: TextStyle(color: jogo.cor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final stats = List<JogoStat>.from(jogoStats.value);
                final idx = stats.indexWhere((s) => s.titulo == jogo.titulo);
                if (idx >= 0) {
                  stats[idx].vezes++;
                  stats[idx].minutosTotais += jogo.duracaoMin;
                  stats[idx].ultimaVez = DateTime.now();
                  jogoStats.value = stats;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${jogo.titulo} — em breve!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'Iniciar atividade',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: jogo.cor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
