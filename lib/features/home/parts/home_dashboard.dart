part of '../presentation.dart';

class _HomePageCuidador extends StatelessWidget {
  const _HomePageCuidador();

  @override
  Widget build(BuildContext context) {
    return const _CaregiverDashboard();
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
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: showProgress ? 13 : 16,
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

class _AssistedReminderCard extends StatelessWidget {
  const _AssistedReminderCard();

  void _concluir(BuildContext context, Lembrete item) {
    final index = lembretes.value.indexOf(item);
    if (index < 0) return;
    final updated = List<Lembrete>.from(lembretes.value);
    updated[index].concluido = true;
    updated[index].concluidoEm = DateTime.now();
    lembretes.value = updated;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.titulo} marcado como feito'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            if (!lembretes.value.contains(item)) return;
            item.concluido = false;
            item.concluidoEm = null;
            lembretes.value = List<Lembrete>.from(lembretes.value);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final textColor = escuro ? Colors.white : AppColors.ink;
    final subColor = escuro ? Colors.white70 : AppColors.muted;
    return ValueListenableBuilder<List<Lembrete>>(
      valueListenable: lembretes,
      builder: (context, items, _) {
        final pending = items.where((item) => !item.concluido).toList()
          ..sort((a, b) => a.horario.compareTo(b.horario));
        final next = pending.isEmpty ? null : pending.first;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: escuro ? AppColors.nightSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: escuro ? AppColors.nightCard : AppColors.line,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Agora',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (next == null)
                Text(
                  'Nenhum lembrete pendente.',
                  style: TextStyle(color: subColor, fontSize: 17),
                )
              else ...[
                Text(
                  next.horario,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  next.titulo,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  next.descricao,
                  style: TextStyle(color: subColor, fontSize: 16),
                ),
              ],
              if (next != null) ...[
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => _concluir(context, next),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Já fiz'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
              TextButton(
                onPressed: () => context
                    .findAncestorStateOfType<_MainScreenState>()
                    ?._selectTab(2),
                child: const Text('Ver todos os lembretes'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  String _saudacao() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
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
    final now = DateTime.now();
    return '${dias[now.weekday % 7]}, ${now.day} de ${meses[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modoEscuro,
      builder: (context, dark, _) {
        final foreground = dark ? Colors.white : AppColors.ink;
        final muted = dark ? Colors.white70 : AppColors.muted;
        final card = dark ? AppColors.nightSurface : Colors.white;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            _DailyOverview(
              greeting: _saudacao(),
              date: _dataFormatada(),
              showProgress: false,
            ),
            const SizedBox(height: 24),
            const _AssistedReminderCard(),
            const SizedBox(height: 24),
            Text(
              'Compromissos de hoje',
              style: TextStyle(
                color: foreground,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<Compromisso>>(
              valueListenable: compromissos,
              builder: (context, items, _) {
                final now = DateTime.now();
                final today =
                    items
                        .where(
                          (item) =>
                              item.data.year == now.year &&
                              item.data.month == now.month &&
                              item.data.day == now.day,
                        )
                        .toList()
                      ..sort((a, b) => a.horario.compareTo(b.horario));
                if (today.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Nenhum compromisso hoje.',
                      style: TextStyle(color: muted, fontSize: 16),
                    ),
                  );
                }
                return Column(
                  children: today
                      .map(
                        (item) => _CompromissoCard(
                          c: item,
                          cardColor: card,
                          textColor: foreground,
                          subColor: muted,
                          escuro: dark,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        );
      },
    );
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                c.realizado ? Icons.check_circle_outline : Icons.event_outlined,
                color: AppColors.primary,
                size: 26,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      decoration: c.realizado
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  Text(
                    c.descricao,
                    style: TextStyle(color: subColor, fontSize: 16),
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
                  fontSize: 16,
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

