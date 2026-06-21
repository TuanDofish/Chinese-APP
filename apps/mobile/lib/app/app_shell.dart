part of '../main.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget?> _screens = List<Widget?>.filled(5, null);
  final GlobalKey<_HomeScreenState> _homeKey = GlobalKey<_HomeScreenState>();

  @override
  void initState() {
    super.initState();
    _screens[0] = _buildScreen(0);
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreen(key: _homeKey, onOpenTab: _selectTab);
      case 1:
        return const VocabularyScreen();
      case 2:
        return const GrammarScreen();
      case 3:
        return const ReadingPracticeScreen();
      case 4:
        return ProfileScreen(onLogout: widget.onLogout);
      default:
        return const SizedBox.shrink();
    }
  }

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
      _screens[index] ??= _buildScreen(index);
    });
    if (index == 0) _homeKey.currentState?._refresh();
  }

  @override
  Widget build(BuildContext context) {
    _screens[_selectedIndex] ??= _buildScreen(_selectedIndex);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(
          _screens.length,
          (index) => _screens[index] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Hôm nay',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Từ vựng',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Ngữ pháp',
          ),
          NavigationDestination(
            icon: Icon(Icons.record_voice_over_outlined),
            selectedIcon: Icon(Icons.record_voice_over),
            label: 'Đọc',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
