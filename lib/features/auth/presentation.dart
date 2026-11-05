import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../core/app_state.dart';
import 'domain/access_role.dart';
import 'login_preview_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
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

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SelecaoPerfilScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final a = _ctrl.value * 2 * math.pi;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  AppColors.splashStart,
                  AppColors.primary,
                  AppColors.splashEnd,
                ],
                begin: Alignment(math.cos(a), math.sin(a)),
                end: Alignment(-math.cos(a), -math.sin(a)),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white24),
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
          );
        },
      ),
    );
  }
}

class SelecaoPerfilScreen extends StatelessWidget {
  const SelecaoPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modoEscuro,
      builder: (context, escuro, _) {
        final bg = escuro ? AppColors.nightBackground : AppColors.splashStart;
        const textColor = Colors.white;
        return Scaffold(
          backgroundColor: bg,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.splashStart,
                  AppColors.primary,
                  AppColors.splashEnd,
                ],
              ),
            ),
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
                              'Quem está usando o aplicativo?',
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

  void _openLogin(BuildContext context, AccessRole role) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LoginPreviewScreen(role: role)),
    );
  }
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
