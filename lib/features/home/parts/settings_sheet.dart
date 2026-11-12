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
                  onTap: () async {
                    if (appDataSession.mode == SessionMode.account) {
                      try {
                        await authRepository.signOut();
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Não foi possível sair da conta.'),
                            ),
                          );
                        }
                        return;
                      }
                    }
                    appDataSession.chooseMode(SessionMode.guest);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const SelecaoPerfilScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                if (appDataSession.isAccount &&
                    perfilAtivo.value == 'assistida') ...[
                  _ConfigItem(
                    escuro: escuro,
                    icon: Icons.person_add_alt_1_outlined,
                    label: 'Convidar cuidador',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      try {
                        final code = await appDataSession.createInvite();
                        if (!context.mounted) return;
                        await showDialog<void>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Código de convite'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Compartilhe este código com seu cuidador. Ele vale por 24 horas e pode ser usado uma vez.',
                                ),
                                const SizedBox(height: 16),
                                SelectableText(
                                  code,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Fechar'),
                              ),
                            ],
                          ),
                        );
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Não foi possível gerar o convite.',
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                if (appDataSession.isAccount &&
                    perfilAtivo.value == 'assistida') ...[
                  _ConfigItem(
                    escuro: escuro,
                    icon: Icons.people_outline,
                    label: 'Gerenciar cuidadores',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _manageCaregivers(context),
                  ),
                  const SizedBox(height: 10),
                ],
                if (appDataSession.isAccount &&
                    perfilAtivo.value == 'cuidador') ...[
                  _ConfigItem(
                    escuro: escuro,
                    icon: Icons.person_remove_outlined,
                    label: 'Desvincular desta pessoa',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _leaveCareLink(context),
                  ),
                  const SizedBox(height: 10),
                ],
                if (reminderNotifications.supported &&
                    appDataSession.isAccount &&
                    perfilAtivo.value == 'assistida') ...[
                  ValueListenableBuilder<bool>(
                    valueListenable: reminderNotifications.enabled,
                    builder: (context, enabled, _) => _ConfigItem(
                      escuro: escuro,
                      icon: Icons.notifications_active_outlined,
                      label: 'Alertas diários neste aparelho',
                      trailing: Switch(
                        value: enabled,
                        onChanged: (value) async {
                          if (!value) {
                            await reminderNotifications.disable();
                            return;
                          }
                          final granted = await reminderNotifications.enable(
                            lembretes.value,
                          );
                          if (!granted && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Permita notificações nas configurações do aparelho.',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
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
                        items: ['Padrão', 'Serif', 'Mono']
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
                            'Versão 1.0.0 · IFPR 2026',
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

  Future<void> _manageCaregivers(BuildContext context) async {
    try {
      final ids = await appDataSession.caregiverIds();
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Cuidadores vinculados'),
          content: ids.isEmpty
              ? const Text('Nenhum cuidador vinculado ainda.')
              : SizedBox(
                  width: 340,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: ids.length,
                    itemBuilder: (_, index) => ListTile(
                      title: Text('Cuidador ${index + 1}'),
                      subtitle: Text(
                        'Conta …${ids[index].substring(ids[index].length - 6)}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Desvincular cuidador',
                        icon: const Icon(Icons.person_remove_outlined),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: dialogContext,
                            builder: (confirmContext) => AlertDialog(
                              title: const Text('Desvincular cuidador?'),
                              content: const Text(
                                'Essa conta perderá acesso aos seus dados. Você poderá gerar outro convite depois.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(confirmContext, false),
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(confirmContext, true),
                                  child: const Text('Desvincular'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true) return;
                          try {
                            await appDataSession.unlinkCaregiver(ids[index]);
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cuidador desvinculado.'),
                              ),
                            );
                          } catch (_) {
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Não foi possível desvincular.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível carregar os cuidadores.'),
          ),
        );
    }
  }

  Future<void> _leaveCareLink(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desvincular conta?'),
        content: const Text(
          'Você perderá acesso aos dados da Pessoa Assistida até receber outro convite.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Desvincular'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await appDataSession.unlinkOwnCaregiver();
      if (context.mounted) Navigator.pop(context);
    } catch (_) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível desfazer o vínculo.')),
        );
    }
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
