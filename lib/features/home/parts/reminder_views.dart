part of '../presentation.dart';

class _LembretesPage extends StatelessWidget {
  const _LembretesPage();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modoEscuro,
      builder: (context, escuro, _) {
        final textColor = escuro ? Colors.white : Colors.black87;
        final subColor = escuro ? Colors.white60 : Colors.black45;
        final cardColor = escuro ? AppColors.nightSurface : Colors.white;
        final eCuidador = perfilAtivo.value == 'cuidador';

        return ValueListenableBuilder<List<Lembrete>>(
          valueListenable: lembretes,
          builder: (context, lista, _) {
            final pendentes = lista.where((l) => !l.concluido).toList();
            final concluidos = lista.where((l) => l.concluido).toList();

            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ).copyWith(top: 20, bottom: 100),
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.amber,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lembretes',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${pendentes.length} pendente(s) · ${concluidos.length} concluído(s)',
                          style: TextStyle(color: subColor, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (pendentes.isNotEmpty) ...[
                  Text(
                    'Pendentes',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...pendentes.map(
                    (l) => _LembreteCard(
                      lembrete: l,
                      indice: lista.indexOf(l),
                      cardColor: cardColor,
                      textColor: textColor,
                      subColor: subColor,
                      eCuidador: eCuidador,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (concluidos.isNotEmpty) ...[
                  Text(
                    'Concluídos hoje',
                    style: TextStyle(
                      color: subColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...concluidos.map(
                    (l) => _LembreteCard(
                      lembrete: l,
                      indice: lista.indexOf(l),
                      cardColor: cardColor,
                      textColor: textColor,
                      subColor: subColor,
                      eCuidador: eCuidador,
                    ),
                  ),
                ],
                if (lista.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            color: subColor,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhum lembrete ainda.\nToque no + para adicionar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: subColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _LembreteCard extends StatelessWidget {
  final Lembrete lembrete;
  final int indice;
  final Color cardColor, textColor, subColor;
  final bool eCuidador;

  const _LembreteCard({
    required this.lembrete,
    required this.indice,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
    required this.eCuidador,
  });

  String _fmtHora(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l = lembrete;
    return Dismissible(
      key: UniqueKey(),
      direction: eCuidador
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        final nova = List<Lembrete>.from(lembretes.value);
        nova.removeAt(indice);
        lembretes.value = nova;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lembrete "${l.titulo}" removido'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                lembretes.value = [...lembretes.value, l];
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          final nova = List<Lembrete>.from(lembretes.value);
          nova[indice].concluido = !nova[indice].concluido;
          if (nova[indice].concluido) {
            nova[indice].concluidoEm = DateTime.now();
          } else {
            nova[indice].concluidoEm = null;
          }
          lembretes.value = nova;
        },
        onLongPress: eCuidador
            ? () => _editarLembrete(context, l, indice)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: l.concluido
                ? AppColors.primary.withValues(alpha: 0.08)
                : cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: l.concluido
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
            boxShadow: l.concluido
                ? []
                : [
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
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: l.concluido ? 0.15 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      l.concluido ? Icons.check_circle_outline : l.icone,
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
                            color: l.concluido ? subColor : textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: l.concluido
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        Text(
                          l.descricao,
                          style: TextStyle(color: subColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
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
                      if (l.concluido && l.concluidoEm != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Concluído às ${_fmtHora(l.concluidoEm!)}',
                          style: TextStyle(color: subColor, fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (eCuidador)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Segure para editar · Deslize para excluir',
                    style: TextStyle(color: subColor, fontSize: 10),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _editarLembrete(BuildContext context, Lembrete l, int idx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditarLembreteSheet(lembrete: l, indice: idx),
    );
  }
}

class _EditarLembreteSheet extends StatefulWidget {
  final Lembrete lembrete;
  final int indice;
  const _EditarLembreteSheet({required this.lembrete, required this.indice});
  @override
  State<_EditarLembreteSheet> createState() => _EditarLembreteSheetState();
}

class _EditarLembreteSheetState extends State<_EditarLembreteSheet> {
  late TextEditingController _titulo, _desc;
  late TimeOfDay _horario;
  late IconData _icone;

  final _icones = [
    Icons.medication_outlined,
    Icons.local_drink_outlined,
    Icons.psychology_outlined,
    Icons.directions_walk_outlined,
    Icons.restaurant_outlined,
    Icons.people_outline,
    Icons.notifications_outlined,
    Icons.bedtime_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _titulo = TextEditingController(text: widget.lembrete.titulo);
    _desc = TextEditingController(text: widget.lembrete.descricao);
    final parts = widget.lembrete.horario.split(':');
    _horario = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    _icone = widget.lembrete.icone;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_titulo.text.trim().isEmpty) return;
    final nova = List<Lembrete>.from(lembretes.value);
    nova[widget.indice].titulo = _titulo.text.trim();
    nova[widget.indice].descricao = _desc.text.trim().isEmpty
        ? 'Sem descrição'
        : _desc.text.trim();
    nova[widget.indice].horario =
        '${_horario.hour.toString().padLeft(2, '0')}:${_horario.minute.toString().padLeft(2, '0')}';
    nova[widget.indice].icone = _icone;
    lembretes.value = nova;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modoEscuro,
      builder: (context, escuro, _) {
        final bg = escuro ? AppColors.nightBackground : Colors.white;
        final textColor = escuro ? Colors.white : Colors.black87;
        final subColor = escuro ? Colors.white60 : Colors.black45;
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  'Editar lembrete',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titulo,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Título',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _desc,
                  style: TextStyle(color: textColor),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final p = await showTimePicker(
                      context: context,
                      initialTime: _horario,
                    );
                    if (p != null) setState(() => _horario = p);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${_horario.hour.toString().padLeft(2, '0')}:${_horario.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                        const Spacer(),
                        Text(
                          'Alterar horário',
                          style: TextStyle(color: subColor, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Ícone', style: TextStyle(color: subColor, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _icones.map((ic) {
                    final sel = ic == _icone;
                    return GestureDetector(
                      onTap: () => setState(() => _icone = ic),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          ic,
                          color: sel ? Colors.white : AppColors.primary,
                          size: 22,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _salvar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Salvar alterações',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CriarLembreteSheet extends StatefulWidget {
  const _CriarLembreteSheet();
  @override
  State<_CriarLembreteSheet> createState() => _CriarLembreteSheetState();
}

class _CriarLembreteSheetState extends State<_CriarLembreteSheet> {
  final _titulo = TextEditingController();
  final _desc = TextEditingController();
  TimeOfDay _horario = TimeOfDay.now();
  IconData _icone = Icons.notifications_outlined;

  final _icones = [
    Icons.medication_outlined,
    Icons.local_drink_outlined,
    Icons.psychology_outlined,
    Icons.directions_walk_outlined,
    Icons.restaurant_outlined,
    Icons.people_outline,
    Icons.notifications_outlined,
    Icons.bedtime_outlined,
  ];

  @override
  void dispose() {
    _titulo.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_titulo.text.trim().isEmpty) return;
    final h = _horario.hour.toString().padLeft(2, '0');
    final m = _horario.minute.toString().padLeft(2, '0');
    lembretes.value = [
      ...lembretes.value,
      Lembrete(
        titulo: _titulo.text.trim(),
        descricao: _desc.text.trim().isEmpty
            ? 'Sem descrição'
            : _desc.text.trim(),
        horario: '$h:$m',
        icone: _icone,
      ),
    ];
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modoEscuro,
      builder: (context, escuro, _) {
        final bg = escuro ? AppColors.nightBackground : Colors.white;
        final textColor = escuro ? Colors.white : Colors.black87;
        final subColor = escuro ? Colors.white60 : Colors.black45;
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(
                'Novo lembrete',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titulo,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Título *',
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _desc,
                style: TextStyle(color: textColor),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final p = await showTimePicker(
                    context: context,
                    initialTime: _horario,
                  );
                  if (p != null) setState(() => _horario = p);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_horario.hour.toString().padLeft(2, '0')}:${_horario.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                      const Spacer(),
                      Text(
                        'Alterar horário',
                        style: TextStyle(color: subColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Ícone', style: TextStyle(color: subColor, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _icones.map((ic) {
                  final sel = ic == _icone;
                  return GestureDetector(
                    onTap: () => setState(() => _icone = ic),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        ic,
                        color: sel ? Colors.white : AppColors.primary,
                        size: 22,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Salvar lembrete',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
