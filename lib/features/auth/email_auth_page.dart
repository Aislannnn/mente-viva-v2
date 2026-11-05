import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/design_tokens.dart';
import '../home.dart';
import 'domain/access_role.dart';
import 'domain/auth_repository.dart';

class EmailAuthPage extends StatefulWidget {
  const EmailAuthPage({
    super.key,
    required this.role,
    required this.repository,
  });

  final AccessRole role;
  final AuthRepository repository;

  @override
  State<EmailAuthPage> createState() => _EmailAuthPageState();
}

class _EmailAuthPageState extends State<EmailAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _creatingAccount = false;
  bool _busy = false;
  bool _showPassword = false;
  String? _feedback;

  bool get _caregiver => widget.role == AccessRole.caregiver;
  Color get _roleColor => _caregiver ? AppColors.caregiver : AppColors.primary;
  String get _roleName => _caregiver ? 'Cuidador' : 'Pessoa Assistida';

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _feedback = null;
    });
    try {
      final result = _creatingAccount
          ? await widget.repository.signUp(
              email: _email.text.trim(),
              password: _password.text,
              role: widget.role,
            )
          : await widget.repository.signIn(
              email: _email.text.trim(),
              password: _password.text,
              role: widget.role,
            );
      if (!mounted) return;
      if (result == AuthResult.confirmationRequired) {
        setState(() {
          _creatingAccount = false;
          _password.clear();
          _feedback =
              'Enviamos uma confirmação para seu e-mail. Depois de confirmar, volte e entre.';
        });
        return;
      }
      perfilAtivo.value = widget.role.profileId;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const MainScreen()),
        (_) => false,
      );
    } on AuthFailure catch (error) {
      if (mounted) setState(() => _feedback = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? AppColors.nightBackground : AppColors.paper,
      appBar: AppBar(
        title: Text(_creatingAccount ? 'Criar conta' : 'Entrar com e-mail'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 36),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.nightSurface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: dark ? AppColors.nightCard : AppColors.line,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          _caregiver
                              ? Icons.medical_services_outlined
                              : Icons.person_outline_rounded,
                          color: _roleColor,
                          size: 42,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _creatingAccount
                              ? 'Nova conta de $_roleName'
                              : 'Acesso de $_roleName',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _creatingAccount
                              ? 'Use um e-mail que você pode confirmar.'
                              : 'Entre com o e-mail e a senha desta conta.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          autocorrect: false,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: (value) {
                            final input = value?.trim() ?? '';
                            if (input.isEmpty ||
                                !RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                ).hasMatch(input)) {
                              return 'Digite um e-mail válido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _password,
                          obscureText: !_showPassword,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.done,
                          autofillHints: [
                            _creatingAccount
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _showPassword
                                  ? 'Ocultar senha'
                                  : 'Mostrar senha',
                              onPressed: () => setState(
                                () => _showPassword = !_showPassword,
                              ),
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if ((value ?? '').length < 6) {
                              return 'Use pelo menos 6 caracteres.';
                            }
                            return null;
                          },
                        ),
                        if (_feedback != null) ...[
                          const SizedBox(height: 16),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              _feedback!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: dark ? Colors.white : AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _busy ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: _roleColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: _busy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _creatingAccount ? 'Criar conta' : 'Entrar',
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => setState(() {
                                  _creatingAccount = !_creatingAccount;
                                  _feedback = null;
                                }),
                          child: Text(
                            _creatingAccount
                                ? 'Já tenho uma conta'
                                : 'Criar uma conta',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
