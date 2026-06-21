import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
//  GLOBAL TAB NOTIFIER  — HomeScreen listens to this
// ═══════════════════════════════════════════════════════════════
final ValueNotifier<int> _shellTabNotifier = ValueNotifier<int>(0);
ValueNotifier<int> get shellTabNotifier => _shellTabNotifier;

// ═══════════════════════════════════════════════════════════════
//  APP BOTTOM NAV  — drop into any Scaffold.bottomNavigationBar
//  Import: import 'package:swiftride/screens/guest/app_shell.dart';
//  Usage:  bottomNavigationBar: AppBottomNav(activeIndex: 0),
// ═══════════════════════════════════════════════════════════════
class AppBottomNav extends StatelessWidget {
  final int activeIndex;
  const AppBottomNav({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final textSec = isDark ? const Color(0xFF8B91A8) : const Color(0xFF6B7280);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141828) : Colors.white,
        border: Border(top: BorderSide(
          color: isDark ? const Color(0xFF252B3E) : const Color(0xFFDDE1EE),
          width: 0.5,
        )),
      ),
      child: BottomNavigationBar(
        currentIndex: activeIndex,
        onTap: (i) {
          if (i == activeIndex) return;
          Navigator.of(context).popUntil((r) => r.isFirst);
          _shellTabNotifier.value = i;
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFFD4A017),
        unselectedItemColor: textSec,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),           activeIcon: Icon(Icons.home),           label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined),  activeIcon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline),        activeIcon: Icon(Icons.favorite),       label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline),     activeIcon: Icon(Icons.chat_bubble),    label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),          activeIcon: Icon(Icons.person),         label: 'Profile'),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  APP SHELL  — wraps a screen with AppBottomNav
//  Usage: AppShell.push(context, const SomeScreen());
// ═══════════════════════════════════════════════════════════════
class AppShell extends StatelessWidget {
  final Widget child;
  final int activeIndex;
  const AppShell({super.key, required this.child, this.activeIndex = 0});

  static void push(BuildContext context, Widget screen, {int activeIndex = 0}) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => AppShell(child: screen, activeIndex: activeIndex),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: AppBottomNav(activeIndex: activeIndex),
  );
}
