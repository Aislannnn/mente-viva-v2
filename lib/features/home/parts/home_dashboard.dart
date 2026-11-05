part of '../presentation.dart';

class _HomePageCuidador extends StatelessWidget {
  const _HomePageCuidador();

  @override
  Widget build(BuildContext context) {
    return const _HomePage(caregiver: true);
  }
}

class _DailyOverview extends StatelessWidget {
  const _DailyOverview({
    required this.greeting,
    required this.date,
    required this.showProgress,
  });

  final String greeting;
  final String date;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Lembrete>>(
      valueListenable: lembretes,
      builder: (context, lista, _) {
        final total = lista.length;
        final concluidos = lista.where((l) => l.concluido).length;
        final progresso = total == 0 ? 0.0 : concluidos / total;
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.splashStart,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -45,
                top: -58,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12, width: 28),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Image.asset('assets/images/logo_branca.png'),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                date,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (showProgress) ...[
                      const SizedBox(height: 25),
                      Divider(color: Colors.white.withValues(alpha: 0.16)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Progresso de hoje',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '$concluidos de $total lembretes',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 76,
                            height: 76,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox.expand(
                                  child: CircularProgressIndicator(
                                    value: progresso,
                                    strokeWidth: 7,
                                    strokeCap: StrokeCap.round,
                                    backgroundColor: Colors.white24,
                                    valueColor: const AlwaysStoppedAnimation(
                                      Color(0xFF71D5DF),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(progresso * 100).round()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Seu dia, no seu ritmo.',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({this.caregiver = false});

  final bool caregiver;

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
            _DailyOverview(
              greeting: _saudacao(),
              date: _dataFormatada(),
              showProgress: caregiver,
            ),
            const SizedBox(height: 28),
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
            Row(
              children: [
                _QuickCard(
                  icon: Icons.notifications_outlined,
                  label: 'Lembretes',
                  color: AppColors.amber,
                  escuro: escuro,
                  onTap: () => context
                      .findAncestorStateOfType<_MainScreenState>()
                      ?._selectTab(2),
                ),
                const SizedBox(width: 12),
                _QuickCard(
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
              ],
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
