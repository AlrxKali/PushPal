import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainAppShell extends StatefulWidget {
  final Widget child;

  const MainAppShell({super.key, required this.child});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0; // Default to Home

  void _onItemTapped(int index, BuildContext context) {
    // Do not navigate if already on the selected tab, unless it's a refresh action (not implemented here)
    // if (index == _currentIndex) return;

    // It's often better to let GoRouter handle the state of _currentIndex via route matching
    // setState(() { _currentIndex = index; }); // This will be handled by didChangeDependencies

    switch (index) {
      case 0: // Home
        context.go('/');
        break;
      case 1: // Match (was Search)
        context.go('/match');
        break;
      case 2: // Profile
        context.go('/profile-tab');
        break;
      case 3: // Chat
        context.go('/chat');
        break;
      case 4: // Settings
        context.go('/settings-tab');
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String location = GoRouterState.of(context).matchedLocation;
    int newIndex = 0; // Default to home

    // Determine current index based on the current route
    if (location.startsWith('/match')) {
      newIndex = 1;
    } else if (location.startsWith('/profile-tab')) {
      newIndex = 2;
    } else if (location.startsWith('/chat')) {
      newIndex = 3;
    } else if (location.startsWith('/settings-tab')) {
      newIndex = 4;
    } else if (location.startsWith('/')) {
      newIndex = 0;
    }
    // No 'else' needed as newIndex is already defaulted to 0

    if (newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures all labels are visible
        currentIndex: _currentIndex,
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot_outlined), // Flame icon for Match
            activeIcon: Icon(Icons.whatshot),
            label: 'Match',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        // Optional: Apply theme colors
        // selectedItemColor: Theme.of(context).colorScheme.primary,
        // unselectedItemColor: Theme.of(context).unselectedWidgetColor, // A bit more standard than direct Colors.grey
      ),
    );
  }
}
