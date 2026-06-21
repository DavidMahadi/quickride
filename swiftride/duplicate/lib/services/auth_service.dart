// lib/services/auth_service.dart
// ─── Hardcoded credentials for UI demo ───────────────────────
// User      → C1@gmail.com       / 123123
// Staff     → staff@company.com  / staff123
// Co-Admin  → admin@company.com  / admin123
// SuperAdmin→ super@swiftride.com / super123

enum UserRole { guest, user, companyStaff, companyAdmin, superAdmin }

class AuthService {
  // ── Credentials ─────────────────────────────────────────────
  static const _accounts = [
    {'email': 'c1@gmail.com',         'password': '123123',   'role': UserRole.user},
    {'email': 'staff@company.com',    'password': 'staff123', 'role': UserRole.companyStaff},
    {'email': 'admin@company.com',    'password': 'admin123', 'role': UserRole.companyAdmin},
    {'email': 'super@swiftride.com',  'password': 'super123', 'role': UserRole.superAdmin},
  ];

  // ── State ────────────────────────────────────────────────────
  static bool     _loggedIn = false;
  static UserRole _role     = UserRole.guest;
  static String   _userId   = '';
  static String?  _pendingRoute;
  static Object?  _pendingArgs;

  // ── Getters ──────────────────────────────────────────────────
  static bool     get isLoggedIn    => _loggedIn;
  static UserRole get role          => _role;
  static String   get currentUserId => _userId;
  static String?  get pendingRoute  => _pendingRoute;
  static Object?  get pendingArgs   => _pendingArgs;

  /// Route to redirect to after a successful login — must match app_router.dart
  static String get postLoginRoute {
    switch (_role) {
      case UserRole.superAdmin:   return '/admin/super';
      case UserRole.companyAdmin: return '/admin/company';
      case UserRole.companyStaff: return '/admin/staff';
      case UserRole.user:         return '/user/home';
      default:                    return '/home';
    }
  }

  // ── Pending route ────────────────────────────────────────────
  static void setPending(String route, {Object? args}) {
    _pendingRoute = route;
    _pendingArgs  = args;
  }

  static void clearPending() {
    _pendingRoute = null;
    _pendingArgs  = null;
  }

  // ── Login ────────────────────────────────────────────────────
  /// Returns null on success, error string on failure.
  static String? login(String email, String password) {
    final match = _accounts.firstWhere(
      (a) =>
          a['email'].toString().toLowerCase() == email.trim().toLowerCase() &&
          a['password'] == password,
      orElse: () => {},
    );
    if (match.isEmpty) return 'Invalid email or password.';
    _loggedIn = true;
    _role     = match['role'] as UserRole;
    _userId   = 'U_${email.trim().toLowerCase().hashCode.abs()}';
    return null;
  }

  static void logout() {
    _loggedIn = false;
    _role     = UserRole.guest;
    _userId   = '';
    clearPending();
  }

  // ── Fake user data (regular user) ───────────────────────────
  static const String userName      = 'Cameron One';
  static const String userEmail     = 'C1@gmail.com';
  static const String userPhone     = '+250 788 000 001';
  static const String memberSince   = 'January 2024';
  static const String driverLicense = 'RW-DL-2021-004521';

  // ── Fake staff data ──────────────────────────────────────────
  static const String staffName     = 'Jordan Smith';
  static const String staffRole     = 'Fleet Manager';
  static const String staffCompany  = 'DriveKigali';
}
