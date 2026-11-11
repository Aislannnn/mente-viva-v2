part of '../presentation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appDataSession.start(perfilAtivo.value);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      appDataSession.refreshDailyCompletions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }

  List<Widget> get _pages => perfilAtivo.value == 'cuidador'
      ? const [_HomePageCuidador(), JogosPage(), _LembretesPage(), _AlbumPage()]
      : const [_HomePage(), JogosPage(), _LembretesPage(), _AlbumPage()];

  void _abrirConfiguracoes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ConfigSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SessionPhase>(
      valueListenable: appDataSession.phase,
      builder: (context, phase, _) {
        if (phase == SessionPhase.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (phase == SessionPhase.needsLink) return const _CareLinkScreen();
        if (phase == SessionPhase.error) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    appDataSession.message.value ??
                        'Não foi possível carregar.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => appDataSession.start(perfilAtivo.value),
                    child: const Text('Tentar novamente'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (appDataSession.mode == SessionMode.account) {
                        try {
                          await authRepository.signOut();
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Não foi possível sair da conta.',
                                ),
                              ),
                            );
                          }
                          return;
                        }
                      }
                      appDataSession.chooseMode(SessionMode.guest);
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => const SelecaoPerfilScreen(),
                        ),
                        (_) => false,
                      );
                    },
                    child: const Text('Voltar à escolha de perfil'),
                  ),
                ],
              ),
            ),
          );
        }
        return _buildReady(context);
      },
    );
  }

  Widget _buildReady(BuildContext context) {
    final eCuidador = perfilAtivo.value == 'cuidador';
    return ValueListenableBuilder<bool>(
      valueListenable: modoEscuro,
      builder: (context, escuro, _) {
        final navBg = escuro ? AppColors.nightSurface : Colors.white;
        final iconColor = escuro ? Colors.white70 : AppColors.muted;
        final selectedColor = escuro
            ? const Color(0xFF86B5FF)
            : AppColors.primary;
        final bgColor = escuro ? AppColors.nightBackground : AppColors.paper;

        return Scaffold(
          backgroundColor: bgColor,
          extendBody: true,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  children: [
                    if (!eCuidador)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Mente Viva',
                                style: TextStyle(
                                  color: escuro ? Colors.white : AppColors.ink,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Configurações',
                              onPressed: _abrirConfiguracoes,
                              icon: const Icon(Icons.settings_outlined),
                              iconSize: 27,
                            ),
                          ],
                        ),
                      ),
                    if (appDataSession.mode == SessionMode.preview)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        color: AppColors.amber.withValues(alpha: 0.25),
                        child: const Text(
                          'PRÉVIA · Dados simulados. Nada será salvo.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (appDataSession.isAccount)
                      ValueListenableBuilder<String?>(
                        valueListenable: appDataSession.message,
                        builder: (context, message, _) => message == null
                            ? const SizedBox.shrink()
                            : MaterialBanner(
                                content: Text(message),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      if (!appDataSession.needsReload) {
                                        appDataSession.retrySave();
                                        return;
                                      }
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          title: const Text(
                                            'Recarregar dados?',
                                          ),
                                          content: const Text(
                                            'As alterações que ainda não foram salvas neste aparelho serão descartadas.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                dialogContext,
                                                false,
                                              ),
                                              child: const Text('Cancelar'),
                                            ),
                                            FilledButton(
                                              onPressed: () => Navigator.pop(
                                                dialogContext,
                                                true,
                                              ),
                                              child: const Text('Recarregar'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        appDataSession.start(perfilAtivo.value);
                                      }
                                    },
                                    child: Text(
                                      appDataSession.needsReload
                                          ? 'Recarregar'
                                          : 'Tentar novamente',
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    Expanded(child: _pages[_currentIndex]),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: _buildFab(),
          bottomNavigationBar: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                decoration: BoxDecoration(
                  color: navBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: escuro ? AppColors.nightCard : AppColors.line,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.splashStart.withValues(alpha: 0.13),
                      blurRadius: 22,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home,
                          label: eCuidador ? 'Início' : 'Hoje',
                          index: 0,
                          currentIndex: _currentIndex,
                          selectedColor: selectedColor,
                          iconColor: iconColor,
                          large: !eCuidador,
                          onTap: _selectTab,
                        ),
                        _NavItem(
                          icon: Icons.sports_esports_outlined,
                          activeIcon: Icons.sports_esports,
                          label: 'Jogos',
                          index: 1,
                          currentIndex: _currentIndex,
                          selectedColor: selectedColor,
                          iconColor: iconColor,
                          large: !eCuidador,
                          onTap: _selectTab,
                        ),
                        _NavItem(
                          icon: Icons.notifications_outlined,
                          activeIcon: Icons.notifications,
                          label: 'Lembretes',
                          index: 2,
                          currentIndex: _currentIndex,
                          selectedColor: selectedColor,
                          iconColor: iconColor,
                          large: !eCuidador,
                          onTap: _selectTab,
                        ),
                        _NavItem(
                          icon: Icons.photo_album_outlined,
                          activeIcon: Icons.photo_album,
                          label: 'Álbum',
                          index: 3,
                          currentIndex: _currentIndex,
                          selectedColor: selectedColor,
                          iconColor: iconColor,
                          large: !eCuidador,
                          onTap: _selectTab,
                        ),
                        if (eCuidador)
                          _NavItem(
                            icon: Icons.settings_outlined,
                            activeIcon: Icons.settings,
                            label: 'Config.',
                            index: 4,
                            currentIndex: _currentIndex,
                            selectedColor: selectedColor,
                            iconColor: iconColor,
                            onTap: (_) => _abrirConfiguracoes(),
                          ),
                      ],
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

  Widget? _buildFab() {
    final eCuidador = perfilAtivo.value == 'cuidador';
    if (_currentIndex == 2 && eCuidador) {
      return FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _CriarLembreteSheet(),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    if (_currentIndex == 3 && eCuidador) {
      return FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _AdicionarPessoaSheet(),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_outlined, color: Colors.white),
      );
    }
    return null;
  }
}
