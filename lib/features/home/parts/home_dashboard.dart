part of '../presentation.dart';

class _HomePageCuidador extends StatelessWidget {
  const _HomePageCuidador();

  @override
  Widget build(BuildContext context) {
    return const _HomePage();
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  String _saudacao() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  String _dataFormatada() {
    const meses = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    const dias = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
    ];
    final n = DateTime.now();
    return '${dias[n.weekday % 7]}, ${n.day} de ${meses[n.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modoEscuro,
      builder: (context, escuro, _) {
        final textColor = escuro ? Colors.white : AppColors.ink;
        final subColor = escuro ? Colors.white60 : AppColors.muted;
        final cardColor = escuro ? AppColors.nightSurface : Colors.white;

        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ).copyWith(bottom: 100),
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    color: escuro ? AppColors.primarySoft : Colors.white,
                    child: Image.asset(
                      escuro
                          ? 'assets/images/logo_branca.png'
                          : 'assets/images/logo.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _saudacao(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _dataFormatada(),
                      style: TextStyle(color: subColor, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<List<Lembrete>>(
              valueListenable: lembretes,
              builder: (context, lista, _) {
                final concluidos = lista.where((l) => l.concluido).length;
                final total = lista.length;
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.splashStart,
                        AppColors.primary,
                        AppColors.splashEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progresso de hoje',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$concluidos de $total lembretes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total > 0 ? concluidos / total : 0,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Acesso rápido',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _QuickCard(
                  icon: Icons.photo_album_outlined,
                  label: 'Álbum',
                  color: AppColors.lavender,
                  escuro: escuro,
                  onTap: () {
                    context
                        .findAncestorStateOfType<_MainScreenState>()
                        ?._selectTab(3);
                  },
                ),
                const SizedBox(width: 12),
                _QuickCard(
                  icon: Icons.sports_esports_outlined,
                  label: 'Jogos',
                  color: AppColors.caregiver,
                  escuro: escuro,
                  onTap: () {
                    context
                        .findAncestorStateOfType<_MainScreenState>()
                        ?._selectTab(1);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _QuickCardWide(
              icon: Icons.notifications_outlined,
              label: 'Lembretes',
              color: AppColors.amber,
              escuro: escuro,
              onTap: () {
                context.findAncestorStateOfType<_MainScreenState>()?._selectTab(
                  2,
                );
              },
            ),
            const SizedBox(height: 12),
            _QuickCardWide(
              icon: Icons.bedtime_outlined,
              label: 'Registrar horas de sono',
              color: AppColors.berry,
              escuro: escuro,
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const _RegistrarSonoSheet(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Rotina de hoje',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<Compromisso>>(
              valueListenable: compromissos,
              builder: (context, lista, _) {
                final hoje = lista
                    .where((c) => _mesmodia(c.data, DateTime.now()))
                    .toList();
                if (hoje.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Nenhum compromisso hoje.',
                        style: TextStyle(color: subColor),
                      ),
                    ),
                  );
                }
                return Column(
                  children: hoje
                      .map(
                        (c) => _CompromissoCard(
                          c: c,
                          cardColor: cardColor,
                          textColor: textColor,
                          subColor: subColor,
                          escuro: escuro,
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Lembretes de hoje',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<Lembrete>>(
              valueListenable: lembretes,
              builder: (context, lista, _) {
                final pendentes = lista
                    .where((l) => !l.concluido)
                    .take(3)
                    .toList();
                if (pendentes.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '✓ Todos os lembretes concluídos!',
                        style: TextStyle(color: subColor),
                      ),
                    ),
                  );
                }
                return Column(
                  children: pendentes.map((l) {
                    final idx = lista.indexOf(l);
                    return GestureDetector(
                      onTap: () {
                        final nova = List<Lembrete>.from(lembretes.value);
                        nova[idx].concluido = true;
                        nova[idx].concluidoEm = DateTime.now();
                        lembretes.value = nova;
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                l.icone,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.titulo,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    l.descricao,
                                    style: TextStyle(
                                      color: subColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                l.horario,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Pessoas visitadas recentemente',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<VisitaRegistro>>(
              valueListenable: visitas,
              builder: (context, lista, _) {
                if (lista.isEmpty) {
                  return Text(
                    'Nenhuma visita registrada.',
                    style: TextStyle(color: subColor, fontSize: 13),
                  );
                }
                return Column(
                  children: lista.take(3).map((v) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.caregiver.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.people_outline,
                              color: AppColors.caregiver,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.nomePessoa,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatarData(v.data),
                                  style: TextStyle(
                                    color: subColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  bool _mesmodia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatarData(DateTime d) {
    final diff = DateTime.now().difference(d).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Ontem';
    return 'Há $diff dias';
  }
}

class _CompromissoCard extends StatelessWidget {
  final Compromisso c;
  final Color cardColor, textColor, subColor;
  final bool escuro;

  const _CompromissoCard({
    required this.c,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
    required this.escuro,
  });

  @override
  Widget build(BuildContext context) {
    final idx = compromissos.value.indexOf(c);
    return GestureDetector(
      onTap: () {
        if (idx < 0) return;
        final nova = List<Compromisso>.from(compromissos.value);
        nova[idx].realizado = !nova[idx].realizado;
        compromissos.value = nova;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.realizado
              ? AppColors.primary.withValues(alpha: 0.06)
              : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: c.realizado
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          boxShadow: c.realizado
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                c.realizado ? Icons.check_circle_outline : Icons.event_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.titulo,
                    style: TextStyle(
                      color: c.realizado ? subColor : textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: c.realizado
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  Text(
                    c.descricao,
                    style: TextStyle(color: subColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                c.horario,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
