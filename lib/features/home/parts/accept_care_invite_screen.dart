part of '../presentation.dart';

class _AcceptCareInviteScreen extends StatefulWidget {
  const _AcceptCareInviteScreen({this.initialCode});
  final String? initialCode;

  @override
  State<_AcceptCareInviteScreen> createState() =>
      _AcceptCareInviteScreenState();
}

class _AcceptCareInviteScreenState extends State<_AcceptCareInviteScreen> {
  late final TextEditingController _code;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _code = TextEditingController(text: widget.initialCode ?? '');
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    final code = _code.text.trim().toUpperCase();
    if (_busy) return;
    if (!RegExp(r'^[A-F0-9]{16}$').hasMatch(code)) {
      setState(
        () =>
            _error = 'Digite o código de 16 caracteres enviado pelo cuidador.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await appDataSession.acceptCaregiverInvite(code);
      await pendingCareInvite.accepted(code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cuidador vinculado. Você pode encerrar o vínculo nas configurações.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted)
        setState(
          () => _error =
              'Não foi possível aceitar. Confira se o convite ainda é válido.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AppBar(title: const Text('Convite do cuidador')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(
                Icons.people_alt_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Você recebeu um convite?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Ao aceitar, esse cuidador poderá ver e organizar seus lembretes, compromissos e registros. Você poderá removê-lo depois em Configurações.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _code,
                textCapitalization: TextCapitalization.characters,
                maxLength: 16,
                decoration: const InputDecoration(
                  labelText: 'Código enviado pelo cuidador',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key_outlined),
                ),
              ),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy ? null : _accept,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(_busy ? 'Vinculando...' : 'Aceitar convite'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                child: const Text('Agora não'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
