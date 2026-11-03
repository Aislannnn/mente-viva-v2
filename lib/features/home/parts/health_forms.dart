part of '../presentation.dart';

class _RegistrarSonoSheet extends StatefulWidget {
  const _RegistrarSonoSheet();
  @override
  State<_RegistrarSonoSheet> createState() => _RegistrarSonoSheetState();
}

class _RegistrarSonoSheetState extends State<_RegistrarSonoSheet> {
  double _horas = 7;

  void _salvar() {
    registrosSono.value = [
      RegistroSono(data: DateTime.now(), horas: _horas),
      ...registrosSono.value,
    ];
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sono registrado: ${_horas}h'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modoEscuro,
      builder: (context, escuro, _) {
        final bg = escuro ? AppColors.nightBackground : Colors.white;
        final textColor = escuro ? Colors.white : Colors.black87;
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
              const Icon(
                Icons.bedtime_outlined,
                color: AppColors.berry,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'Quantas horas você dormiu?',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${_horas.toStringAsFixed(1)}h',
                style: const TextStyle(
                  color: AppColors.berry,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: _horas,
                min: 1,
                max: 12,
                divisions: 22,
                activeColor: AppColors.berry,
                onChanged: (v) => setState(() => _horas = (v * 2).round() / 2),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.berry,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Registrar',
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

class _RegistrarEsquecimentoSheet extends StatefulWidget {
  const _RegistrarEsquecimentoSheet();
  @override
  State<_RegistrarEsquecimentoSheet> createState() =>
      _RegistrarEsquecimentoSheetState();
}

class _RegistrarEsquecimentoSheetState
    extends State<_RegistrarEsquecimentoSheet> {
  final _desc = TextEditingController();

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_desc.text.trim().isEmpty) return;
    esquecimentos.value = [
      EsquecimentoRegistro(data: DateTime.now(), descricao: _desc.text.trim()),
      ...esquecimentos.value,
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
                'Registrar episódio de esquecimento',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _desc,
                style: TextStyle(color: textColor),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descreva o que aconteceu',
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Registrar',
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

class _RegistrarVisitaSheet extends StatefulWidget {
  const _RegistrarVisitaSheet();
  @override
  State<_RegistrarVisitaSheet> createState() => _RegistrarVisitaSheetState();
}

class _RegistrarVisitaSheetState extends State<_RegistrarVisitaSheet> {
  final _nome = TextEditingController();

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_nome.text.trim().isEmpty) return;
    visitas.value = [
      VisitaRegistro(data: DateTime.now(), nomePessoa: _nome.text.trim()),
      ...visitas.value,
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
        final pessoasCad = pessoas.value;
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
                'Registrar visita',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nome,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Nome da pessoa visitada',
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (pessoasCad.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Ou selecione do álbum:',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: pessoasCad.map((p) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => _nome.text = p.nome);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: p.cor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          p.nome,
                          style: TextStyle(
                            color: p.cor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.caregiver,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Registrar visita',
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
