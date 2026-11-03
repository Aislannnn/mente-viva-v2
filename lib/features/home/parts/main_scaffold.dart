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
      ? const [
          _HomePageCuidador(),
          _JogosPage(),
          _LembretesPage(),
          _AlbumPage(),
        ]
      : const [_HomePage(), _JogosPage(), _LembretesPage(), _AlbumPage()];

  void _abrirConfiguracoes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ConfigSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modoEscuro,
      builder: (context, escuro, _) {
        final navBg = escuro ? AppColors.nightBackground : Colors.white;
        final iconColor = escuro ? Colors.white70 : Colors.black54;
        const selectedColor = AppColors.primary;
        final bgColor = escuro ? Colors.black : AppColors.paper;

        return Scaffold(
          backgroundColor: bgColor,
          extendBody: true,
          body: SafeArea(child: _pages[_currentIndex]),
          floatingActionButton: _buildFab(),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: navBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Início',
                      index: 0,
                      currentIndex: _currentIndex,
                      selectedColor: selectedColor,
                      iconColor: iconColor,
                      onTap: (i) => setState(() => _currentIndex = i),
                    ),
                    _NavItem(
                      icon: Icons.sports_esports_outlined,
                      activeIcon: Icons.sports_esports,
                      label: 'Jogos',
                      index: 1,
                      currentIndex: _currentIndex,
                      selectedColor: selectedColor,
                      iconColor: iconColor,
                      onTap: (i) => setState(() => _currentIndex = i),
                    ),
                    _NavItem(
                      icon: Icons.notifications_outlined,
                      activeIcon: Icons.notifications,
                      label: 'Lembretes',
                      index: 2,
                      currentIndex: _currentIndex,
                      selectedColor: selectedColor,
                      iconColor: iconColor,
                      onTap: (i) => setState(() => _currentIndex = i),
                    ),
                    _NavItem(
                      icon: Icons.photo_album_outlined,
                      activeIcon: Icons.photo_album,
                      label: 'Álbum',
                      index: 3,
                      currentIndex: _currentIndex,
                      selectedColor: selectedColor,
                      iconColor: iconColor,
                      onTap: (i) => setState(() => _currentIndex = i),
                    ),
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
