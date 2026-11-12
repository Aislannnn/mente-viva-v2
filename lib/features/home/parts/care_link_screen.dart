part of '../presentation.dart';

class _CareLinkScreen extends StatefulWidget {
  const _CareLinkScreen();
  @override
  State<_CareLinkScreen> createState() => _CareLinkScreenState();
}

class _CareLinkScreenState extends State<_CareLinkScreen> {
  Timer? _linkTimer;
  bool _busy = false;
  String? _code;
  String? _error;
  String get _link =>
      'https://aislannnn.github.io/mente-viva-v2/?care_invite=$_code';

  @override
  void initState() {
    super.initState();
    _linkTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => unawaited(appDataSession.checkCaregiverLink()),
    );
  }

  @override
  void dispose() {
    _linkTimer?.cancel();
    super.dispose();
  }

  Future<void> _createInvite() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final code = await appDataSession.createCaregiverInvite();
      if (mounted) setState(() => _code = code);
    } catch (_) {
      if (mounted)
        setState(
          () => _error = 'Não foi possível criar o convite. Tente novamente.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copiado. Envie à Pessoa Assistida.')),
      );
  }

  Future<void> _leave() async {
    try {
      await authRepository.signOut();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível sair da conta.')),
        );
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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AppBar(title: const Text('Convidar Pessoa Assistida')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(
                Icons.favorite_outline,
                size: 64,
                color: AppColors.caregiver,
              ),
              const SizedBox(height: 18),
              Text(
                'Convide a pessoa que você cuida',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Gere um convite e envie o link à Pessoa Assistida. Ela entrará na própria conta e decidirá se aceita compartilhar a rotina com você.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_code != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Código de uso único · válido por 24 horas'),
                        const SizedBox(height: 12),
                        SelectableText(
                          _code!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _copy(_code!),
                          icon: const Icon(Icons.copy_outlined),
                          label: const Text('Copiar código'),
                        ),
                        const Divider(height: 28),
                        const Text('Link para abrir o convite'),
                        SelectableText(_link),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => _copy(_link),
                          icon: const Icon(Icons.link),
                          label: const Text('Copiar link'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_error != null) Text(_error!, textAlign: TextAlign.center),
              FilledButton(
                onPressed: _busy ? null : _createInvite,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    _busy
                        ? 'Gerando...'
                        : _code == null
                        ? 'Gerar convite'
                        : 'Gerar novo convite',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Gerar outro convite cancela o código anterior. O vínculo só começa depois da aceitação.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: appDataSession.checkCaregiverLink,
                child: const Text('Verificar se o convite foi aceito'),
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
