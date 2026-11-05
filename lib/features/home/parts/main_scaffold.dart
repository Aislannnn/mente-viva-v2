part of '../presentation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

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
                            if (_currentIndex == 2)
                              IconButton(
                                tooltip: 'Voltar para Hoje',
                                onPressed: () => _selectTab(0),
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                            Expanded(
                              child: Text(
                                _currentIndex == 2 ? 'Lembretes' : 'Mente Viva',
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
                          currentIndex: _currentIndex == 2 && !eCuidador
                              ? 0
                              : _currentIndex,
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
                        if (eCuidador)
                          _NavItem(
                            icon: Icons.notifications_outlined,
                            activeIcon: Icons.notifications,
                            label: 'Lembretes',
                            index: 2,
                            currentIndex: _currentIndex,
                            selectedColor: selectedColor,
                            iconColor: iconColor,
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
    if (_currentIndex == 0 && perfilAtivo.value == 'assistida') {
      return FloatingActionButton.small(
        onPressed: () => _registrarVisita(context),
        backgroundColor: AppColors.caregiver,
        tooltip: 'Registrar visita',
        child: const Icon(Icons.people_outline, color: Colors.white, size: 20),
      );
    }
    return null;
  }

  void _registrarVisita(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RegistrarVisitaSheet(),
    );
  }
}
