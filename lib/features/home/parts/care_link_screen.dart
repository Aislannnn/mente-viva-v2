part of '../presentation.dart';

class _CareLinkScreen extends StatefulWidget {
  const _CareLinkScreen();

  @override
  State<_CareLinkScreen> createState() => _CareLinkScreenState();
}

class _CareLinkScreenState extends State<_CareLinkScreen> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    if (_code.text.trim().isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await appDataSession.redeemInvite(_code.text);
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Código inválido ou vencido. Confira e tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leave() async {
    try {
      await authRepository.signOut();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível sair da conta.')),
        );
      }
      return;
    }
    appDataSession.chooseMode(SessionMode.guest);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SelecaoPerfilScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vincular cuidador')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 68,
                  color: AppColors.caregiver,
                ),
                const SizedBox(height: 20),
                Text(
                  'Conecte-se à Pessoa Assistida',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Peça à Pessoa Assistida o código de convite gerado nas configurações dela. O código vale por 24 horas e só pode ser usado uma vez.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _code,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 16,
                  decoration: const InputDecoration(
                    labelText: 'Código de convite',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _busy ? null : _redeem,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(_busy ? 'Vinculando...' : 'Vincular conta'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _busy ? null : _leave,
                  child: const Text('Voltar à escolha de perfil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
