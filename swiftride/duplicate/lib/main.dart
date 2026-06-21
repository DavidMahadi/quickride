// lib/main.dart
// ─────────────────────────────────────────────────────────────
//  SwiftRide — App Entry Point
//
//  Wires:
//    • ValueListenableBuilder on themeNotifier (dark/light)
//    • AppRouter.onGenerateRoute for all named routes
//    • WalletService.seed() at startup
//    • AppDataStore singleton initialised at startup
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swiftride/app_router.dart';
import 'package:swiftride/screens/guest/home_screen.dart' show themeNotifier;
import 'package:swiftride/services/wallet_service.dart';
import 'package:swiftride/services/app_data_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar, white icons
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0E1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialise singletons so seed data is ready before first frame
  AppDataStore.instance;
  WalletService.instance.seed();

  runApp(const SwiftRideApp());
}

class SwiftRideApp extends StatelessWidget {
  const SwiftRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'SwiftRide',
          debugShowCheckedModeBanner: false,
          themeMode: mode,

          // ── Dark theme ───────────────────────────────────────
          darkTheme: _buildDarkTheme(),

          // ── Light theme ──────────────────────────────────────
          theme: _buildLightTheme(),

          // ── Navigation ───────────────────────────────────────
          initialRoute: AppRouter.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,

          // Unknown routes handled inside onGenerateRoute (fallback 404)
          onUnknownRoute: (settings) => AppRouter.onGenerateRoute(
              RouteSettings(name: settings.name, arguments: settings.arguments)),
        );
      },
    );
  }

  // ── Theme definitions ────────────────────────────────────────

  ThemeData _buildDarkTheme() {
    const gold   = Color(0xFFD4A017);
    const navy   = Color(0xFF0A0E1A);
    const navy2  = Color(0xFF141828);
    const surf   = Color(0xFF1C2236);
    const text   = Color(0xFFEEEEF5);
    const textSec= Color(0xFF8B91A8);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: navy,
      primaryColor: gold,
      colorScheme: const ColorScheme.dark(
        primary:   gold,
        secondary: gold,
        surface:   navy2,
        onSurface: text,
        onPrimary: Colors.black,
      ),
      fontFamily: 'Inter',

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: text),
      ),

      // Bottom nav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: navy2,
        selectedItemColor: gold,
        unselectedItemColor: textSec,
        selectedLabelStyle: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'Inter'),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Tab bar
      tabBarTheme: const TabBarTheme(
        indicatorColor: gold,
        labelColor: gold,
        unselectedLabelColor: textSec,
        labelStyle: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'Inter'),
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gold,
          side: const BorderSide(color: gold),
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: gold,
          textStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: navy2,
        hintStyle: const TextStyle(color: textSec, fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF252B3E), width: 0.8)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF252B3E), width: 0.8)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: gold, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD85A30), width: 1)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD85A30), width: 1.5)),
        errorStyle: const TextStyle(color: Color(0xFFD85A30), fontSize: 11),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFF252B3E),
        thickness: 0.5,
        space: 0,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? gold : textSec),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? gold.withOpacity(0.35)
                : surf),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? gold : Colors.transparent),
        checkColor: WidgetStateProperty.all(Colors.black),
        side: const BorderSide(color: textSec, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surf,
        contentTextStyle: const TextStyle(color: text, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      // Card
      cardTheme: CardTheme(
        color: navy2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF252B3E), width: 0.5),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: surf,
        selectedColor: gold.withOpacity(0.15),
        labelStyle: const TextStyle(color: text, fontSize: 12),
        side: const BorderSide(color: Color(0xFF252B3E), width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: navy2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
            color: text, fontSize: 17, fontWeight: FontWeight.w700),
        contentTextStyle: const TextStyle(color: textSec, fontSize: 13),
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: navy2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        elevation: 0,
      ),

      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: Colors.black,
        elevation: 2,
      ),

      // Icon
      iconTheme: const IconThemeData(color: textSec, size: 22),
      primaryIconTheme: const IconThemeData(color: gold, size: 22),

      // List tile
      listTileTheme: const ListTileThemeData(
        iconColor: textSec,
        textColor: text,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),

      // Drawer
      drawerTheme: const DrawerThemeData(
        backgroundColor: navy,
        elevation: 0,
      ),

      // Text
      textTheme: const TextTheme(
        displayLarge:  TextStyle(color: text, fontFamily: 'Inter', fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: text, fontFamily: 'Inter', fontWeight: FontWeight.w700),
        headlineMedium:TextStyle(color: text, fontFamily: 'Inter', fontWeight: FontWeight.w700),
        titleLarge:    TextStyle(color: text, fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 17),
        titleMedium:   TextStyle(color: text, fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15),
        bodyLarge:     TextStyle(color: text, fontFamily: 'Inter', fontSize: 14),
        bodyMedium:    TextStyle(color: textSec, fontFamily: 'Inter', fontSize: 13),
        labelLarge:    TextStyle(color: Colors.black, fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    const gold    = Color(0xFFD4A017);
    const bg      = Color(0xFFF2F4F8);
    const white   = Colors.white;
    const text    = Color(0xFF0A0E1A);
    const textSec = Color(0xFF6B7280);
    const border  = Color(0xFFDDE1EE);

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      primaryColor: gold,
      colorScheme: const ColorScheme.light(
        primary:   gold,
        secondary: gold,
        surface:   white,
        onSurface: text,
        onPrimary: Colors.black,
      ),
      fontFamily: 'Inter',

      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: text),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: gold,
        unselectedItemColor: textSec,
        selectedLabelStyle: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'Inter'),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      tabBarTheme: const TabBarTheme(
        indicatorColor: gold,
        labelColor: gold,
        unselectedLabelColor: textSec,
        labelStyle: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'Inter'),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gold,
          side: const BorderSide(color: gold),
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: gold,
          textStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        hintStyle: const TextStyle(color: textSec, fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: border, width: 0.8)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: border, width: 0.8)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: gold, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD85A30), width: 1)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD85A30), width: 1.5)),
        errorStyle: const TextStyle(color: Color(0xFFD85A30), fontSize: 11),
      ),

      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 0.5,
        space: 0,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? gold : textSec),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? gold.withOpacity(0.35)
                : border),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? gold : Colors.transparent),
        checkColor: WidgetStateProperty.all(Colors.black),
        side: const BorderSide(color: textSec, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: text,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      cardTheme: CardTheme(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 0.5),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: bg,
        selectedColor: gold.withOpacity(0.12),
        labelStyle: const TextStyle(color: text, fontSize: 12),
        side: const BorderSide(color: border, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
            color: text, fontSize: 17, fontWeight: FontWeight.w700),
        contentTextStyle: const TextStyle(color: textSec, fontSize: 13),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        elevation: 0,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: Colors.black,
        elevation: 2,
      ),

      iconTheme: const IconThemeData(color: textSec, size: 22),
      primaryIconTheme: const IconThemeData(color: gold, size: 22),

      listTileTheme: const ListTileThemeData(
        iconColor: textSec,
        textColor: text,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: white,
        elevation: 0,
      ),

      textTheme: const TextTheme(
        displayLarge:  TextStyle(color: text, fontFamily: 'Inter', fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: text, fontFamily: 'Inter', fontWeight: FontWeight.w700),
        headlineMedium:TextStyle(color: text, fontFamily: 'Inter', fontWeight: FontWeight.w700),
        titleLarge:    TextStyle(color: text, fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 17),
        titleMedium:   TextStyle(color: text, fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15),
        bodyLarge:     TextStyle(color: text, fontFamily: 'Inter', fontSize: 14),
        bodyMedium:    TextStyle(color: textSec, fontFamily: 'Inter', fontSize: 13),
        labelLarge:    TextStyle(color: Colors.black, fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }
}
