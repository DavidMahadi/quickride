// lib/app_router.dart
// ─────────────────────────────────────────────────────────────
//  SwiftRide — Central Route Registry
//
//  ROUTE MAP
//  ─────────────────────────────────────────────────────────────
//  /                     → SplashScreen
//  /home                 → HomeScreen (guest, isUserMode: false)
//  /login                → LoginScreen
//  /register             → RegisterScreen
//
//  /user/home            → HomeScreen (logged-in, isUserMode: true)  [auth guard]
//  /user/car-detail      → UserCarDetailScreen  (arg: Map car)       [auth guard]
//  /user/booking-flow    → BookingFlowScreen    (arg: Map car)       [auth guard]
//  /user/booking         → BookingScreen        (arg: Map car)       [auth guard]
//  /user/payment         → PaymentScreen        (arg: _PaymentArgs)  [auth guard]
//  /user/booking-confirm → BookingConfirmationScreen (arg: _ConfirmArgs) [auth guard]
//  /user/my-bookings     → UserBookingsScreen                        [auth guard]
//  /user/messages        → MessagesScreen                            [auth guard]
//  /user/profile         → ProfileScreen                             [auth guard]
//  /user/settings        → UserSettingsScreen                        [auth guard]
//
//  /admin/staff          → CompanyStaffScreen                        [staff guard]
//  /admin/company        → CompanyAdminScreen   (arg: RentalCompany) [company-admin guard]
//  /admin/super          → SuperAdminScreen                          [super-admin guard]
//
//  Fallback              → 404 page
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:swiftride/services/auth_service.dart';

// ── Guest screens
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/screens/guest/auth_screens.dart';
import 'package:swiftride/screens/guest/splash_screen.dart';
import 'package:swiftride/screens/guest/settings_screen.dart';
import 'package:swiftride/screens/guest/profile_screen.dart';
import 'package:swiftride/screens/guest/messages_screen.dart';

// ── User screens
import 'package:swiftride/screens/user/user_shell.dart';
import 'package:swiftride/screens/user/user_car_detail_screen.dart';
import 'package:swiftride/screens/user/booking_flow_screen.dart';
import 'package:swiftride/screens/user/user_bookings_screen.dart';
import 'package:swiftride/screens/user/user_settings_screen.dart';
import 'package:swiftride/screens/user/booking_confirmation_screen.dart';

// ── Admin screens
import 'package:swiftride/screens/admin/company_staff_screen.dart';
import 'package:swiftride/screens/admin/company_admin_screen.dart';
import 'package:swiftride/screens/admin/super_admin_screen.dart';

// ── Data
import 'package:swiftride/screens/guest/companies_screen.dart' show RentalCompany, allCompanies;

// ─────────────────────────────────────────────────────────────
//  ARG WRAPPERS  (typed containers for pushNamed arguments)
// ─────────────────────────────────────────────────────────────

/// Passed to /user/payment
class PaymentArgs {
  final String carName, company, pickupDate, returnDate,
               pickupLocation, dropoffLocation, paymentMethod;
  final int    days;
  final double total;
  const PaymentArgs({
    required this.carName,
    required this.company,
    required this.pickupDate,
    required this.returnDate,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.days,
    required this.total,
    this.paymentMethod = '',
  });
}

/// Passed to /user/booking-confirm
class ConfirmArgs {
  final String carName, company, pickupDate, returnDate,
               pickupLocation, dropoffLocation, paymentMethod;
  final int    days;
  final double total;
  const ConfirmArgs({
    required this.carName,
    required this.company,
    required this.pickupDate,
    required this.returnDate,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.paymentMethod,
    required this.days,
    required this.total,
  });
}

// ─────────────────────────────────────────────────────────────
//  ROUTER
// ─────────────────────────────────────────────────────────────
class AppRouter {
  AppRouter._();

  static const String splash         = '/';
  static const String home           = '/home';
  static const String login          = '/login';
  static const String register       = '/register';

  static const String userHome       = '/user/home';
  static const String userCarDetail  = '/user/car-detail';
  static const String userBookingFlow= '/user/booking-flow';
  static const String userBooking    = '/user/booking';
  static const String userPayment    = '/user/payment';
  static const String userConfirm    = '/user/booking-confirm';
  static const String userMyBookings = '/user/my-bookings';
  static const String userMessages   = '/user/messages';
  static const String userProfile    = '/user/profile';
  static const String userSettings   = '/user/settings';

  static const String adminStaff     = '/admin/staff';
  static const String adminCompany   = '/admin/company';
  static const String adminSuper     = '/admin/super';

  // ── onGenerateRoute ─────────────────────────────────────────
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {

      // ── Public ──────────────────────────────────────────────
      case splash:
        return _slide(const SplashScreen());

      case home:
        return _slide(const HomeScreen(isUserMode: false));

      case login:
        return _slide(const LoginScreen());

      case register:
        return _slide(const RegisterScreen());

      // ── User (auth required) ─────────────────────────────────
      case userHome:
        return _guardUser(
          const UserShell(),
          settings,
        );

      case userCarDetail: {
        final car = args as Map<String, dynamic>? ?? {};
        return _guardUser(UserCarDetailScreen(car: car), settings);
      }

      case userBookingFlow: {
        final car = args as Map<String, dynamic>? ?? {};
        return _guardUser(BookingFlowScreen(car: car), settings);
      }

      case userBooking: {
        // Legacy route — redirect to booking flow
        final car = args as Map<String, dynamic>? ?? {};
        return _guardUser(BookingFlowScreen(car: car), settings);
      }

      case userMyBookings:
        return _guardUser(const UserBookingsScreen(), settings);

      case userMessages:
        return _guardUser(const MessagesScreen(), settings);

      case userProfile:
        return _guardUser(const ProfileScreen(), settings);

      case userSettings:
        return _guardUser(const UserSettingsScreen(), settings);

      case userConfirm: {
        if (args is ConfirmArgs) {
          return _guardUser(
            BookingConfirmationScreen(
              carName:         args.carName,
              company:         args.company,
              pickupDate:      args.pickupDate,
              returnDate:      args.returnDate,
              pickupLocation:  args.pickupLocation,
              dropoffLocation: args.dropoffLocation,
              days:            args.days,
              total:           args.total,
              paymentMethod:   args.paymentMethod,
            ),
            settings,
          );
        }
        return _error('Missing booking confirmation data');
      }

      // ── Admin ────────────────────────────────────────────────
      case adminStaff:
        return _guardRole(
          const CompanyStaffScreen(),
          settings,
          UserRole.companyStaff,
        );

      case adminCompany: {
        // arg may be a RentalCompany or null (fall back to first company)
        final company = args is RentalCompany
            ? args
            : allCompanies.first;
        return _guardRole(
          CompanyAdminScreen(company: company),
          settings,
          UserRole.companyAdmin,
        );
      }

      case adminSuper:
        return _guardRole(
          const SuperAdminScreen(),
          settings,
          UserRole.superAdmin,
        );

      // ── 404 ─────────────────────────────────────────────────
      default:
        return _error('Page not found: ${settings.name}');
    }
  }

  // ── Guards ───────────────────────────────────────────────────

  /// Redirects to /login (saving pending route) if not logged in.
  static Route<dynamic> _guardUser(Widget screen, RouteSettings settings) {
    if (!AuthService.isLoggedIn) {
      AuthService.setPending(settings.name ?? userHome, args: settings.arguments);
      return _slide(const LoginScreen());
    }
    return _slide(screen);
  }

  /// Redirects to /login if not logged in, or to /home if wrong role.
  static Route<dynamic> _guardRole(
      Widget screen, RouteSettings settings, UserRole required) {
    if (!AuthService.isLoggedIn) {
      AuthService.setPending(settings.name ?? home, args: settings.arguments);
      return _slide(const LoginScreen());
    }
    if (AuthService.role != required) {
      // Wrong role — send to their correct destination
      return _slide(_roleHome());
    }
    return _slide(screen);
  }

  static Widget _roleHome() {
    switch (AuthService.role) {
      case UserRole.companyStaff: return const CompanyStaffScreen();
      case UserRole.companyAdmin: return CompanyAdminScreen(company: allCompanies.first);
      case UserRole.superAdmin:   return const SuperAdminScreen();
      default:                    return const UserShell();
    }
  }

  // ── Transition builders ──────────────────────────────────────

  static PageRouteBuilder<dynamic> _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  static Route<dynamic> _error(String message) {
    return MaterialPageRoute(
      builder: (_) => _NotFoundScreen(message: message),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  404 SCREEN
// ─────────────────────────────────────────────────────────────
class _NotFoundScreen extends StatelessWidget {
  final String message;
  const _NotFoundScreen({required this.message});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A0E1A),
    body: Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wrong_location_rounded,
            color: Color(0xFFD4A017), size: 64),
        const SizedBox(height: 20),
        const Text('Page Not Found',
            style: TextStyle(color: Colors.white,
                fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8B91A8), fontSize: 13)),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, AppRouter.home, (_) => false),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4A017),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Go Home',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ]),
    )),
  );
}
