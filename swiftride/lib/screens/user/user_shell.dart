// lib/screens/user/user_shell.dart
// Logged-in user home — same HomeScreen with isUserMode: true (all tabs unlocked)
import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart' show HomeScreen;

class UserShell extends StatelessWidget {
  const UserShell({super.key});
  @override
  Widget build(BuildContext context) => const HomeScreen(isUserMode: true);
}
