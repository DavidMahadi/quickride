// lib/services/auth_service.dart
// ─────────────────────────────────────────────────────────────
//  Authentication — connects to Django REST backend
//  Falls back to demo credentials if server unreachable
// ─────────────────────────────────────────────────────────────
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swiftride/services/api_service.dart';

enum UserRole { guest, user, companyStaff, companyAdmin, superAdmin }

class AuthService {
  static bool     _loggedIn  = false;
  static UserRole _role      = UserRole.guest;
  static String   _userId    = '';
  static String   _userName  = '';
  static String   _userEmail = '';
  static String   _userPhone = '';
  static String?  _companyId;
  static String?  _pendingRoute;
  static Object?  _pendingArgs;

  static bool     get isLoggedIn    => _loggedIn;
  static UserRole get role          => _role;
  static String   get currentUserId => _userId;
  static String   get userName      => _userName.isNotEmpty  ? _userName  : 'Cameron One';
  static String   get userEmail     => _userEmail.isNotEmpty ? _userEmail : 'C1@gmail.com';
  static String   get userPhone     => _userPhone.isNotEmpty ? _userPhone : '+250 788 000 001';
  static String?  get companyId     => _companyId;
  static String?  get pendingRoute  => _pendingRoute;
  static Object?  get pendingArgs   => _pendingArgs;
  static String   get firstName      => _userName.isNotEmpty
      ? _userName.split(' ').first
      : 'User';
  static String   get staffName     => _userName.isNotEmpty  ? _userName  : 'Jordan Smith';
  static String   get staffRole     => 'Fleet Manager';
  static String   get staffCompany  => 'DriveKigali';
  static const    String memberSince   = 'January 2024';
  static const    String driverLicense = 'RW-DL-2021-004521';

  static String get postLoginRoute {
    switch (_role) {
      case UserRole.superAdmin:   return '/admin/super';
      case UserRole.companyAdmin: return '/admin/company';
      case UserRole.companyStaff: return '/admin/staff';
      case UserRole.user:         return '/user/home';
      default:                    return '/home';
    }
  }

  static void setPending(String route, {Object? args}) {
    _pendingRoute = route; _pendingArgs = args;
  }
  static void clearPending() { _pendingRoute = null; _pendingArgs = null; }

  // ── Login ─────────────────────────────────────────────────────
  static Future<String?> login(String email, String password) async {
    try {
      final data = await ApiService.instance.post('/auth/login/', body: {
        'email': email.trim(), 'password': password,
      });
      await ApiService.instance.saveTokens(
        data['access'] as String, data['refresh'] as String,
      );
      _setFromUser(data['user'] as Map<String, dynamic>);
      _loggedIn = true;
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == null) return _demoLogin(email, password);
      return e.message;
    } catch (_) {
      return _demoLogin(email, password);
    }
  }

  // ── Demo fallback (works without server) ──────────────────────
  static const _demo = [
    {'email':'c1@gmail.com',        'password':'123123',   'role':'customer',      'name':'Cameron One'},
    {'email':'staff@company.com',   'password':'staff123', 'role':'company_staff', 'name':'Jordan Smith'},
    {'email':'admin@company.com',   'password':'admin123', 'role':'company_admin', 'name':'Admin User'},
    {'email':'super@swiftride.com', 'password':'super123', 'role':'super_admin',   'name':'Super Admin'},
  ];

  static String? _demoLogin(String email, String password) {
    final m = _demo.firstWhere(
      (a) => a['email']!.toLowerCase() == email.trim().toLowerCase()
          && a['password'] == password,
      orElse: () => {},
    );
    if (m.isEmpty) return 'Invalid email or password.';
    _loggedIn  = true;
    _role      = _roleFrom(m['role']!);
    _userId    = 'demo_${m['email']!.hashCode.abs()}';
    _userName  = m['name']!;
    _userEmail = m['email']!;
    return null;
  }

  // ── Register ──────────────────────────────────────────────────
  static Future<String?> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final data = await ApiService.instance.post('/auth/register/', body: {
        'full_name': fullName, 'email': email.trim(),
        'phone': phone, 'password': password, 'password2': password,
      });
      await ApiService.instance.saveTokens(data['access'], data['refresh']);
      _setFromUser(data['user'] as Map<String, dynamic>);
      _loggedIn = true;
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  // ── Logout ────────────────────────────────────────────────────
  static Future<void> logout() async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final refresh = prefs.getString('refresh_token');
      if (refresh != null) {
        await ApiService.instance.post('/auth/logout/', body: {'refresh': refresh});
      }
    } catch (_) {}
    await ApiService.instance.clearTokens();
    _loggedIn = false; _role = UserRole.guest;
    _userId = ''; _userName = ''; _userEmail = ''; _userPhone = '';
    clearPending();
  }

  // ── Restore session on app start ──────────────────────────────
  static Future<bool> restoreSession() async {
    await ApiService.instance.loadTokens();
    if (!ApiService.instance.hasToken) return false;
    try {
      final data = await ApiService.instance.get('/auth/profile/');
      _setFromUser(data as Map<String, dynamic>);
      _loggedIn = true;
      return true;
    } catch (_) {
      await ApiService.instance.clearTokens();
      return false;
    }
  }

  static void _setFromUser(Map<String, dynamic> u) {
    _userId    = u['id']?.toString()        ?? '';
    _userName  = (u['full_name'] ?? u['name'] ?? '').toString().trim();
    _userEmail = u['email']?.toString()     ?? '';
    _userPhone = u['phone']?.toString()     ?? '';
    _companyId = u['company']?.toString();
    _role      = _roleFrom(u['role']?.toString() ?? 'customer');
    // Debug
    assert(() { print('[AuthService] user set: $_userName <$_userEmail> role=$_role'); return true; }());
  }

  static UserRole _roleFrom(String r) => switch (r) {
    'company_staff' => UserRole.companyStaff,
    'company_admin' => UserRole.companyAdmin,
    'super_admin'   => UserRole.superAdmin,
    'customer'      => UserRole.user,
    _               => UserRole.guest,
  };
}
