part of '../presentation.dart';

class _AlbumPage extends StatelessWidget {
  const _AlbumPage();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modoEscuro,
      builder: (context, escuro, _) {
        final textColor = escuro ? Colors.white : Colors.black87;
        final subColor = escuro ? Colors.white60 : AppColors.muted;
        final eCuidador = perfilAtivo.value == 'cuidador';

        return ValueListenableBuilder<List<Pessoa>>(
          valueListenable: pessoas,
          builder: (context, lista, _) {
            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ).copyWith(top: 20, bottom: 100),
              children: [
                _SectionHero(
                  icon: Icons.photo_album_outlined,
                  title: 'Álbum de memórias',
                  subtitle: '${lista.length} pessoa(s) cadastrada(s)',
                ),
                const SizedBox(height: 20),
                if (lista.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_add_outlined,
                            color: subColor,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            eCuidador
                                ? 'Nenhuma pessoa.\nToque no + para adicionar.'
                                : 'Nenhuma pessoa cadastrada.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: subColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...lista.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final p = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: escuro ? AppColors.nightSurface : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: BorderSide(
                            color: escuro
                                ? AppColors.nightCard
                                : AppColors.line,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () =>
                              _verDetalhes(context, p, idx, escuro, eCuidador),
                          child: Row(
                            children: [
                              Container(
                                width: 90,
                                height: 94,
                                decoration: BoxDecoration(
                                  color: p.cor.withValues(alpha: 0.14),
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(22),
                                  ),
                                ),
                                child: Icon(p.icone, color: p.cor, size: 42),
                              ),
                              const SizedBox(width: 17),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.nome,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      p.relacao,
                                      style: TextStyle(
                                        color: p.cor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: subColor,
                                size: 14,
                              ),
                              const SizedBox(width: 17),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }

  void _verDetalhes(
    BuildContext context,
    Pessoa p,
    int idx,
    bool escuro,
    bool eCuidador,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DetalhesPessoaSheet(
        pessoa: p,
        indice: idx,
        escuro: escuro,
        eCuidador: eCuidador,
      ),
    );
  }
}

class _DetalhesPessoaSheet extends StatelessWidget {
  final Pessoa pessoa;
  final int indice;
  final bool escuro, eCuidador;

  const _DetalhesPessoaSheet({
    required this.pessoa,
    required this.indice,
    required this.escuro,
    required this.eCuidador,
  });

  @override
  Widget build(BuildContext context) {
    final bg = escuro ? AppColors.nightBackground : Colors.white;
    final textColor = escuro ? Colors.white : Colors.black87;
    final subColor = escuro ? Colors.white60 : AppColors.muted;
    final p = pessoa;

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
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: p.cor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(p.icone, color: p.cor, size: 46),
          ),
          const SizedBox(height: 16),
          Text(
            p.nome,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: p.cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              p.relacao,
              style: TextStyle(
                color: p.cor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: escuro ? AppColors.nightCard : AppColors.neutralSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              p.descricao,
              style: TextStyle(color: subColor, fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (eCuidador) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _EditarPessoaSheet(
                          pessoa: p,
                          indice: indice,
                          escuro: escuro,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'Editar',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _confirmarExclusao(context, p);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      'Remover',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Fechar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, Pessoa p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover pessoa'),
        content: Text('Deseja remover ${p.nome} do álbum?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final nova = List<Pessoa>.from(pessoas.value);
              nova.removeAt(indice);
              pessoas.value = nova;
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${p.nome} removido do álbum'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AdicionarPessoaSheet extends StatefulWidget {
  const _AdicionarPessoaSheet();
  @override
  State<_AdicionarPessoaSheet> createState() => _AdicionarPessoaSheetState();
}

class _AdicionarPessoaSheetState extends State<_AdicionarPessoaSheet> {
  final _nome = TextEditingController();
  final _relacao = TextEditingController();
  final _desc = TextEditingController();

  final _cores = [
    AppColors.primary,
    AppColors.lavender,
    AppColors.caregiver,
    AppColors.amber,
    AppColors.berry,
    AppColors.amberDark,
  ];
  Color _cor = AppColors.primary;

  @override
  void dispose() {
    _nome.dispose();
    _relacao.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_nome.text.trim().isEmpty) return;
    pessoas.value = [
      ...pessoas.value,
      Pessoa(
        nome: _nome.text.trim(),
        relacao: _relacao.text.trim().isEmpty
            ? 'Familiar'
            : _relacao.text.trim(),
        descricao: _desc.text.trim().isEmpty
            ? 'Sem descrição'
            : _desc.text.trim(),
        icone: Icons.person,
        cor: _cor,
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
        final subColor = escuro ? Colors.white60 : AppColors.muted;
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
                  'Adicionar pessoa ao álbum',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nome,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Nome *',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _relacao,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Relação (ex: Filha, Médico)',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(
                      Icons.people_outline,
                      color: AppColors.primary,
                    ),
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
                    labelText: 'Descrição / como reconhecer',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Cor do cartão',
                  style: TextStyle(color: subColor, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _cores.map((c) {
                    final sel = c == _cor;
                    return GestureDetector(
                      onTap: () => setState(() => _cor = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        width: sel ? 40 : 34,
                        height: sel ? 40 : 34,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: sel
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: sel
                              ? [
                                  BoxShadow(
                                    color: c.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
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
                      'Adicionar ao álbum',
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

class _EditarPessoaSheet extends StatefulWidget {
  final Pessoa pessoa;
  final int indice;
  final bool escuro;
  const _EditarPessoaSheet({
    required this.pessoa,
    required this.indice,
    required this.escuro,
  });
  @override
  State<_EditarPessoaSheet> createState() => _EditarPessoaSheetState();
}

class _EditarPessoaSheetState extends State<_EditarPessoaSheet> {
  late TextEditingController _nome, _relacao, _desc;
  final _cores = [
    AppColors.primary,
    AppColors.lavender,
    AppColors.caregiver,
    AppColors.amber,
    AppColors.berry,
    AppColors.amberDark,
  ];
  late Color _cor;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: widget.pessoa.nome);
    _relacao = TextEditingController(text: widget.pessoa.relacao);
    _desc = TextEditingController(text: widget.pessoa.descricao);
    _cor = widget.pessoa.cor;
  }

  @override
  void dispose() {
    _nome.dispose();
    _relacao.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_nome.text.trim().isEmpty) return;
    final nova = List<Pessoa>.from(pessoas.value);
    nova[widget.indice] = Pessoa(
      nome: _nome.text.trim(),
      relacao: _relacao.text.trim().isEmpty ? 'Familiar' : _relacao.text.trim(),
      descricao: _desc.text.trim().isEmpty
          ? 'Sem descrição'
          : _desc.text.trim(),
      icone: Icons.person,
      cor: _cor,
    );
    pessoas.value = nova;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final escuro = widget.escuro;
    final bg = escuro ? AppColors.nightBackground : Colors.white;
    final textColor = escuro ? Colors.white : Colors.black87;
    final subColor = escuro ? Colors.white60 : AppColors.muted;
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
              'Editar pessoa',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nome,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Nome *',
                labelStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _relacao,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Relação',
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
                labelText: 'Descrição / como reconhecer',
                labelStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Cor do cartão',
              style: TextStyle(color: subColor, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: _cores.map((c) {
                final sel = c == _cor;
                return GestureDetector(
                  onTap: () => setState(() => _cor = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    width: sel ? 40 : 34,
                    height: sel ? 40 : 34,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: sel
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: c.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
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
  }
}
