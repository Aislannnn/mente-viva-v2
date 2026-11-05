part of '../presentation.dart';

class _CaregiverDashboard extends StatelessWidget {
  const _CaregiverDashboard();

  void _openForm(BuildContext context, Widget form) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => form,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? Colors.white : AppColors.ink;
    final muted = dark ? Colors.white70 : AppColors.muted;
    final surface = dark ? AppColors.nightSurface : Colors.white;

    return AnimatedBuilder(
      animation: Listenable.merge([
        lembretes,
        registrosSono,
        esquecimentos,
        visitas,
      ]),
      builder: (context, _) {
        final now = DateTime.now();
        final currentTime =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        final completed = lembretes.value
            .where((item) => item.concluido)
            .length;
        final pending = lembretes.value
            .where((item) => !item.concluido)
            .toList();
        final overdue = pending
            .where((item) => item.horario.compareTo(currentTime) < 0)
            .toList();
        final sleep = registrosSono.value.toList()
          ..sort((a, b) => a.data.compareTo(b.data));
        final events = <_CaregiverEvent>[
          ...visitas.value.map(
            (item) => _CaregiverEvent(
              date: item.data,
              title: 'Visita de ${item.nomePessoa}',
              icon: Icons.people_outline,
            ),
          ),
          ...esquecimentos.value.map(
            (item) => _CaregiverEvent(
              date: item.data,
              title: item.descricao,
              icon: Icons.psychology_outlined,
            ),
          ),
        ]..sort((a, b) => b.date.compareTo(a.date));

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
          children: [
            const SectionHero(
              icon: Icons.monitor_heart_outlined,
              title: 'Acompanhamento',
              subtitle: 'Rotina e registros da pessoa assistida',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: dark ? AppColors.nightCard : AppColors.neutralSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Dados de demonstração. Os registros ainda não são salvos entre sessões.',
                style: TextStyle(color: muted, fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Lembretes de hoje', foreground),
            const SizedBox(height: 10),
            _panel(
              surface,
              Column(
                children: [
                  _metric(
                    'Concluídos',
                    completed,
                    Icons.check_circle_outline,
                    AppColors.caregiver,
                    foreground,
                  ),
                  const Divider(height: 20),
                  _metric(
                    'Pendentes',
                    pending.length,
                    Icons.notifications_outlined,
                    AppColors.primary,
                    foreground,
                  ),
                  const Divider(height: 20),
                  _metric(
                    'Atrasados',
                    overdue.length,
                    Icons.schedule,
                    AppColors.amberText,
                    foreground,
                  ),
                ],
              ),
            ),
            if (overdue.isNotEmpty) ...[
              const SizedBox(height: 12),
              _panel(
                surface,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedem atenção',
                      style: TextStyle(
                        color: foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...overdue
                        .take(3)
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '${item.horario} · ${item.titulo}',
                              style: TextStyle(color: muted, fontSize: 15),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            _sectionTitle('Sono registrado', foreground),
            const SizedBox(height: 10),
            _panel(
              surface,
              sleep.isEmpty
                  ? Text(
                      'Ainda não há registros de sono.',
                      style: TextStyle(color: muted, fontSize: 15),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Últimos ${sleep.length > 7 ? 7 : sleep.length} registros',
                          style: TextStyle(color: muted, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: sleep.reversed
                              .take(7)
                              .toList()
                              .reversed
                              .map((item) {
                                final height =
                                    item.horas.clamp(0, 10).toDouble() * 8;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${item.horas.toStringAsFixed(1)}h',
                                          style: TextStyle(
                                            color: foreground,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        SizedBox(
                                          height: 80,
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              height: height,
                                              decoration: BoxDecoration(
                                                color: AppColors.berryText,
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${item.data.day}/${item.data.month}',
                                          style: TextStyle(
                                            color: muted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Registrar', foreground),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _openForm(context, const _RegistrarSonoSheet()),
              icon: const Icon(Icons.bedtime_outlined),
              label: const Text('Horas de sono'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  _openForm(context, const _RegistrarEsquecimentoSheet()),
              icon: const Icon(Icons.psychology_outlined),
              label: const Text('Esquecimento'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  _openForm(context, const _RegistrarVisitaSheet()),
              icon: const Icon(Icons.people_outline),
              label: const Text('Visita'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Registros recentes', foreground),
            const SizedBox(height: 10),
            _panel(
              surface,
              events.isEmpty
                  ? Text(
                      'Nenhum registro recente.',
                      style: TextStyle(color: muted, fontSize: 15),
                    )
                  : Column(
                      children: events.take(5).map((event) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(event.icon, color: AppColors.caregiver),
                          title: Text(
                            event.title,
                            style: TextStyle(color: foreground, fontSize: 16),
                          ),
                          subtitle: Text(
                            '${event.date.day}/${event.date.month}/${event.date.year}',
                            style: TextStyle(color: muted, fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String title, Color color) => Text(
    title,
    style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800),
  );

  Widget _panel(Color color, Widget child) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );

  Widget _metric(
    String label,
    int value,
    IconData icon,
    Color accent,
    Color foreground,
  ) => Row(
    children: [
      Icon(icon, color: accent),
      const SizedBox(width: 12),
      Expanded(
        child: Text(label, style: TextStyle(color: foreground, fontSize: 16)),
      ),
      Text(
        '$value',
        style: TextStyle(
          color: foreground,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _CaregiverEvent {
  const _CaregiverEvent({
    required this.date,
    required this.title,
    required this.icon,
  });

  final DateTime date;
  final String title;
  final IconData icon;
}

