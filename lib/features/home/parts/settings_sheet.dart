part of '../presentation.dart';

class _ConfigSheet extends StatelessWidget {
  const _ConfigSheet();

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
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: SingleChildScrollView(
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
                  'Configurações',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _ConfigItem(
                  escuro: escuro,
                  icon: Icons.swap_horiz_outlined,
                  label: 'Trocar perfil',
                  trailing: Text(
                    perfilAtivo.value == 'cuidador'
                        ? 'Cuidador'
                        : 'Pessoa Assistida',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const SelecaoPerfilScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _ConfigItem(
                  escuro: escuro,
                  icon: Icons.dark_mode_outlined,
                  label: 'Modo escuro',
                  trailing: Switch(
                    value: escuro,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => modoEscuro.value = v,
                  ),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<double>(
                  valueListenable: escalaFonte,
                  builder: (context, escala, _) {
                    return _ConfigItem(
                      escuro: escuro,
                      icon: Icons.text_fields_outlined,
                      label: 'Tamanho da fonte',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (escalaFonte.value > 0.8) {
                                escalaFonte.value -= 0.1;
                              }
                            },
                            icon: const Icon(Icons.remove, size: 18),
                            color: AppColors.primary,
                          ),
                          Text(
                            '${(escala * 100).round()}%',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (escalaFonte.value < 1.5) {
                                escalaFonte.value += 0.1;
                              }
                            },
                            icon: const Icon(Icons.add, size: 18),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<String>(
                  valueListenable: tipoFonte,
                  builder: (context, fonte, _) {
                    return _ConfigItem(
                      escuro: escuro,
                      icon: Icons.font_download_outlined,
                      label: 'Tipo de fonte',
                      trailing: DropdownButton<String>(
                        value: fonte,
                        dropdownColor: bg,
                        underline: const SizedBox(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        items: ['Padrão', 'Serif', 'Leitura']
                            .map(
                              (f) => DropdownMenuItem(value: f, child: Text(f)),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) tipoFonte.value = v;
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<double>(
                  valueListenable: escalaFonte,
                  builder: (context, escala, _) {
                    return _ConfigItem(
                      escuro: escuro,
                      icon: Icons.aspect_ratio_outlined,
                      label: 'Tamanho dos elementos',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (escalaFonte.value > 0.8) {
                                escalaFonte.value -= 0.1;
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.remove,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            escala <= 0.9
                                ? 'Pequeno'
                                : escala <= 1.1
                                ? 'Normal'
                                : 'Grande',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              if (escalaFonte.value < 1.5) {
                                escalaFonte.value += 0.1;
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _ConfigItem(
                  escuro: escuro,
                  icon: Icons.cleaning_services_outlined,
                  label: 'Limpar lembretes concluídos',
                  trailing: Icon(
                    Icons.chevron_right,
                    color: escuro ? Colors.white38 : Colors.black26,
                  ),
                  onTap: () {
                    lembretes.value = lembretes.value
                        .where((l) => !l.concluido)
                        .toList();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Lembretes concluídos removidos'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: escuro
                        ? AppColors.nightCard
                        : AppColors.neutralSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mente Viva',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'Versão 1.0.0 · IFPR 2025',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _ConfigItem extends StatelessWidget {
  final bool escuro;
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  const _ConfigItem({
    required this.escuro,
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = escuro ? Colors.white : Colors.black87;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: escuro ? AppColors.nightCard : AppColors.neutralSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: textColor, fontSize: 15),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

