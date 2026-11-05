import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/design_tokens.dart';
import '../home.dart';
import 'domain/access_role.dart';

/// Prévia do fluxo de acesso. Nenhuma opção conecta uma conta nesta versão.
class LoginPreviewScreen extends StatelessWidget {
  const LoginPreviewScreen({super.key, required this.role});

  final AccessRole role;

  bool get _caregiver => role == AccessRole.caregiver;
  String get _roleName => _caregiver ? 'Cuidador' : 'Pessoa Assistida';
  Color get _roleColor => _caregiver ? AppColors.caregiver : AppColors.primary;

  void _enterDemo(BuildContext context) {
    perfilAtivo.value = role.profileId;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainScreen()),
      (_) => false,
    );
  }

  void _showProviderPreview(BuildContext context, String provider) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_outline_rounded, color: _roleColor, size: 42),
              const SizedBox(height: 16),
              Text(
                'Acesso com $provider em preparação',
                textAlign: TextAlign.center,
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nenhuma conta foi conectada. Você pode explorar o aplicativo no modo demonstração.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Entendi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? AppColors.nightSurface : Colors.white;
    final mutedColor = dark ? Colors.white70 : AppColors.muted;

    return Scaffold(
      backgroundColor: dark ? AppColors.nightBackground : AppColors.paper,
      appBar: AppBar(
        title: const Text('Acesso ao Mente Viva'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: _roleColor,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _caregiver
                            ? Icons.medical_services_outlined
                            : Icons.person_outline_rounded,
                        size: 42,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Acesso de $_roleName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _caregiver
                            ? 'Organize e acompanhe a rotina.'
                            : 'Veja sua rotina, jogos e memórias.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => _enterDemo(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: _roleColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Entrar sem conta (demonstração)'),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: dark ? AppColors.nightCard : AppColors.line,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Formas de acesso em preparação',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Google, Apple e e-mail ainda não conectam contas.',
                        style: TextStyle(color: mutedColor, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      _ProviderButton(
                        label: 'Continuar com Google',
                        icon: const Text(
                          'G',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onPressed: () =>
                            _showProviderPreview(context, 'Google'),
                      ),
                      const SizedBox(height: 10),
                      _ProviderButton(
                        label: 'Continuar com Apple',
                        icon: const Icon(Icons.apple_rounded),
                        onPressed: () => _showProviderPreview(context, 'Apple'),
                      ),
                      const SizedBox(height: 10),
                      _ProviderButton(
                        label: 'Continuar com e-mail',
                        icon: const Icon(Icons.mail_outline_rounded),
                        onPressed: () =>
                            _showProviderPreview(context, 'e-mail'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Escolher outro perfil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: SizedBox(width: 28, child: Center(child: icon)),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(58),
      alignment: Alignment.centerLeft,
      side: BorderSide(color: Theme.of(context).dividerColor),
    ),
  );
}
