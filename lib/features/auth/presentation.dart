import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/auth_dependencies.dart';
import '../../app/biometric_unlock.dart';
import '../../app/pending_care_invite.dart';
import '../../app/data_session.dart';
import '../../core/design_tokens.dart';
import '../../core/app_state.dart';
import '../home.dart';
import 'domain/access_role.dart';
import 'login_preview_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class BiometricGateScreen extends StatefulWidget {
  const BiometricGateScreen({super.key});
  @override
  State<BiometricGateScreen> createState() => _BiometricGateScreenState();
}

class _BiometricGateScreenState extends State<BiometricGateScreen> {
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final enabled = await biometricUnlock.enabled();
    final allowed = !enabled || await biometricUnlock.authenticate();
    if (!mounted) return;
    if (allowed) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainScreen()),
      );
      return;
    }
    setState(() {
      _busy = false;
      _message = 'Não foi possível confirmar a biometria neste aparelho.';
    });
  }

  Future<void> _useAccountLogin() async {
    try {
      await authRepository.signOut();
    } catch (_) {
      if (mounted)
        setState(() => _message = 'Não foi possível sair. Tente novamente.');
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
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fingerprint, size: 72, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Proteja sua conta',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                _message ?? 'Confirme sua identidade para continuar.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _unlock,
                child: Text(
                  _busy ? 'Aguarde...' : 'Tentar biometria novamente',
                ),
              ),
              TextButton(
                onPressed: _busy ? null : _useAccountLogin,
                child: const Text('Entrar com a conta'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _resumeSession();
  }

  Future<void> _resumeSession() async {
    try {
      await pendingCareInvite.rememberFromUrl();
    } catch (_) {
      // Storage failures must not prevent the app from opening.
    }
    await Future<void>.delayed(const Duration(seconds: 2));
    AccessRole? role;
    var needsRole = false;
    if (authConfigured && authRepository.hasSession) {
      try {
        role = await authRepository.loadRole();
        needsRole = role == null;
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Não foi possível carregar sua conta. Tente entrar novamente.',
              ),
            ),
          );
        }
      }
    }
    if (!mounted) return;
    if (role != null) {
      perfilAtivo.value = role.profileId;
      appDataSession.chooseMode(SessionMode.account);
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => role != null
            ? const BiometricGateScreen()
            : SelecaoPerfilScreen(completeAccount: needsRole),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) => DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [
                    AppColors.splashStart,
                    AppColors.primary,
                    AppColors.splashEnd,
                  ],
                  transform: GradientRotation(_ctrl.value * 2 * math.pi),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.splashStart,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo_branca.png',
                    width: 152,
                    height: 152,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mente Viva',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'CARREGANDO...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SelecaoPerfilScreen extends StatelessWidget {
  const SelecaoPerfilScreen({super.key, this.completeAccount = false});

  final bool completeAccount;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modoEscuro,
      builder: (context, escuro, _) {
        final bg = escuro ? AppColors.nightBackground : AppColors.splashStart;
        const textColor = Colors.white;
        return Scaffold(
          backgroundColor: bg,
          body: _SlowRotatingBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                width: 80,
                                height: 80,
                                alignment: Alignment.center,
                                color: Colors.white.withValues(alpha: 0.14),
                                child: Image.asset(
                                  'assets/images/logo_branca.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'Mente Viva',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              completeAccount
                                  ? 'Escolha o perfil desta conta'
                                  : 'Quem está usando o aplicativo?',
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.6),
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          _CardPerfil(
                            icone: Icons.person_outline,
                            titulo: 'Pessoa Assistida',
                            descricao:
                                'Visualize sua rotina, lembretes\ne álbum de memórias',
                            cor: AppColors.primary,
                            escuro: escuro,
                            onTap: () =>
                                _openLogin(context, AccessRole.assisted),
                          ),
                          const SizedBox(height: 20),
                          _CardPerfil(
                            icone: Icons.medical_services_outlined,
                            titulo: 'Cuidador',
                            descricao:
                                'Gerencie lembretes, álbum,\nprogresso e estatísticas',
                            cor: AppColors.caregiver,
                            escuro: escuro,
                            onTap: () =>
                                _openLogin(context, AccessRole.caregiver),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openLogin(BuildContext context, AccessRole role) async {
    if (completeAccount) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      try {
        await authRepository.completeRole(role);
        if (!context.mounted) return;
        Navigator.of(context).pop();
        perfilAtivo.value = role.profileId;
        appDataSession.chooseMode(SessionMode.account);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const MainScreen()),
          (_) => false,
        );
      } catch (_) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível concluir o perfil. Tente novamente.',
            ),
          ),
        );
      }
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LoginPreviewScreen(role: role)),
    );
  }
}

class _SlowRotatingBackground extends StatefulWidget {
  const _SlowRotatingBackground({required this.child});

  final Widget child;

  @override
  State<_SlowRotatingBackground> createState() =>
      _SlowRotatingBackgroundState();
}

class _SlowRotatingBackgroundState extends State<_SlowRotatingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 16),
      vsync: this,
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) => Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            AppColors.splashStart,
            AppColors.primary,
            AppColors.splashEnd,
          ],
          transform: GradientRotation(_controller.value * 2 * math.pi),
        ),
      ),
      child: child,
    ),
  );
}

class _CardPerfil extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final Color cor;
  final bool escuro;
  final VoidCallback onTap;

  const _CardPerfil({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.cor,
    required this.escuro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = escuro ? AppColors.nightSurface : Colors.white;
    final textColor = escuro ? Colors.white : AppColors.ink;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.splashStart.withValues(alpha: 0.22),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icone, color: cor, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cor),
          ],
        ),
      ),
    );
  }
}
