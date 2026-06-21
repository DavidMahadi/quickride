import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/services/auth_service.dart';

// ─────────────────────────────────────────────
//  LOGIN SCREEN
// ─────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); _passwordCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 600));
    final err = AuthService.login(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    // Redirect based on role
    final pending = AuthService.pendingRoute;
    AuthService.clearPending();
    Navigator.pushNamedAndRemoveUntil(
      context,
      pending ?? AuthService.postLoginRoute,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg     : AppColors.lightBg;
    final card    = isDark ? AppColors.darkCard   : AppColors.lightCard;
    final surface = isDark ? AppColors.darkSurface: AppColors.lightSurface;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white         : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
              child: Icon(Icons.arrow_back, color: textPri, size: 20),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.directions_car, color: AppColors.gold, size: 28),
          ),
          const SizedBox(height: 20),
          Text('Welcome back', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textPri)),
          const SizedBox(height: 6),
          Text('Sign in to continue your journey', style: TextStyle(fontSize: 14, color: textSec)),
          const SizedBox(height: 36),

          // Email / Username
          _Label(text: 'Email or username', textSec: textSec),
          const SizedBox(height: 8),
          _InputField(
            controller: _emailCtrl,
            hint: 'e.g. c1@gmail.com',
            icon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            surface: surface, border: border, textPri: textPri, textSec: textSec,
          ),
          const SizedBox(height: 18),

          // Password
          _Label(text: 'Password', textSec: textSec),
          const SizedBox(height: 8),
          _InputField(
            controller: _passwordCtrl,
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscure: _obscure,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: textSec, size: 18),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            surface: surface, border: border, textPri: textPri, textSec: textSec,
          ),
          const SizedBox(height: 12),

          // Error
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 0.5),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
              ]),
            ),

          Align(alignment: Alignment.centerRight,
            child: Text('Forgot password?', style: const TextStyle(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w500))),
          const SizedBox(height: 28),

          SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold, foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          )),
          const SizedBox(height: 24),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Don't have an account? ", style: TextStyle(color: textSec, fontSize: 13)),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/register'),
              child: const Text('Create one', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600))),
          ]),

          // ── Demo accounts (tap to autofill) ──
          const SizedBox(height: 32),
          Text('Tap to autofill', style: TextStyle(fontSize: 11, color: textSec, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          ...[
            ('Normal User',    'c1@gmail.com',        '123123',   const Color(0xFF1D9E75)),
            ('Company Staff',  'staff@company.com',  'staff123', const Color(0xFF7F77DD)),
            ('Company Admin',  'admin@company.com',  'admin123', const Color(0xFF3B5FD4)),
            ('Super Admin',    'super@swiftride.com', 'super123', AppColors.gold),
          ].map((acc) => GestureDetector(
            onTap: () {
              _emailCtrl.text    = acc.$2 as String;
              _passwordCtrl.text = acc.$3 as String;
              setState(() => _error = null);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: (acc.$4 as Color).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (acc.$4 as Color).withOpacity(0.25), width: 0.8),
              ),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: (acc.$4 as Color).withOpacity(0.12), shape: BoxShape.circle),
                  child: Icon(Icons.person_rounded, color: acc.$4 as Color, size: 16)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(acc.$1 as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: acc.$4 as Color)),
                  const SizedBox(height: 2),
                  Text('${acc.$2}  ·  ${acc.$3}', style: TextStyle(fontSize: 11, color: textSec, fontFamily: 'monospace')),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: (acc.$4 as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.touch_app_rounded, color: acc.$4 as Color, size: 12),
                    const SizedBox(width: 4),
                    Text('Fill', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: acc.$4 as Color)),
                  ])),
              ]),
            ),
          )),
        ]),
      )),
    );
  }
}


// ─────────────────────────────────────────────
//  REGISTER SCREEN
// ─────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _agreed  = false;
  bool _loading = false;

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _passwordCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg     : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface: AppColors.lightSurface;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white         : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
              child: Icon(Icons.arrow_back, color: textPri, size: 20),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.person_add_outlined, color: AppColors.gold, size: 28),
          ),
          const SizedBox(height: 20),
          Text('Create account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textPri)),
          const SizedBox(height: 6),
          Text('Start exploring cars in Kigali', style: TextStyle(fontSize: 14, color: textSec)),
          const SizedBox(height: 36),

          _Label(text: 'Full name', textSec: textSec),
          const SizedBox(height: 8),
          _InputField(controller: _nameCtrl, hint: 'Your full name', icon: Icons.person_outline,
            surface: surface, border: border, textPri: textPri, textSec: textSec),
          const SizedBox(height: 18),

          _Label(text: 'Email address', textSec: textSec),
          const SizedBox(height: 8),
          _InputField(controller: _emailCtrl, hint: 'you@email.com', icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            surface: surface, border: border, textPri: textPri, textSec: textSec),
          const SizedBox(height: 18),

          _Label(text: 'Password', textSec: textSec),
          const SizedBox(height: 8),
          _InputField(
            controller: _passwordCtrl, hint: '••••••••', icon: Icons.lock_outline,
            obscure: _obscure,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: textSec, size: 18),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            surface: surface, border: border, textPri: textPri, textSec: textSec),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: Row(children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: _agreed ? AppColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _agreed ? AppColors.gold : border, width: 1.5),
                ),
                child: _agreed ? const Icon(Icons.check, size: 13, color: Colors.black) : null,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text.rich(TextSpan(children: [
                TextSpan(text: 'I agree to the ', style: TextStyle(color: textSec, fontSize: 13)),
                const TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600)),
                TextSpan(text: ' and ', style: TextStyle(color: textSec, fontSize: 13)),
                const TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600)),
              ]))),
            ]),
          ),
          const SizedBox(height: 28),

          SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
            onPressed: (_agreed && !_loading) ? () async {
              setState(() => _loading = true);
              await Future.delayed(const Duration(milliseconds: 600));
              AuthService.login('c1@gmail.com', '123123');
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/user/home', (_) => false);
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold, foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          )),
          const SizedBox(height: 24),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Already have an account? ', style: TextStyle(color: textSec, fontSize: 13)),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Sign in', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600))),
          ]),
        ]),
      )),
    );
  }
}

// ─── Shared input widgets ─────────────────────────────────────
class _Label extends StatelessWidget {
  final String text; final Color textSec;
  const _Label({required this.text, required this.textSec});
  @override
  Widget build(BuildContext context) =>
    Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSec));
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Color surface, border, textPri, textSec;
  const _InputField({
    required this.controller, required this.hint, required this.icon,
    required this.surface, required this.border, required this.textPri, required this.textSec,
    this.obscure = false, this.keyboardType, this.suffixIcon,
  });
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboardType,
    style: TextStyle(color: textPri, fontSize: 15),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: textSec, fontSize: 14),
      prefixIcon: Icon(icon, color: textSec, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
