import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/services/auth_service.dart';
import 'package:swiftride/screens/guest/sub_screens.dart';
import 'package:swiftride/screens/guest/shared_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  bool _locationServices = true;
  bool _biometricLogin = false;
  String _language = 'English';
  String _currency = 'USD';
  String _distanceUnit = 'km';

  void _go(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg      : AppColors.lightBg;
    final card    = isDark ? AppColors.darkCard    : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder  : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white           : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      drawer: const AppDrawer(activeTab: 0),
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPri, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Appearance ──
          _SectionHeader(label: 'Appearance', textSec: textSec),
          _SettingsCard(card: card, border: border, children: [
            _SwitchTile(
              icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              label: isDark ? 'Dark mode' : 'Light mode',
              subtitle: 'Toggle app theme',
              value: isDark,
              textPri: textPri, textSec: textSec, border: border,
              onChanged: (_) => themeNotifier.toggle(),
            ),
          ]),

          const SizedBox(height: 20),

          // ── Notifications ──
          _SectionHeader(label: 'Notifications', textSec: textSec),
          _SettingsCard(card: card, border: border, children: [
            _SwitchTile(
              icon: Icons.notifications_outlined,
              label: 'Push notifications',
              subtitle: 'Booking updates, offers',
              value: _pushNotifications, textPri: textPri, textSec: textSec, border: border,
              onChanged: (v) => setState(() => _pushNotifications = v),
              onTap: () => _go(const NotificationsScreen()),
            ),
            _SwitchTile(
              icon: Icons.email_outlined,
              label: 'Email notifications',
              subtitle: 'Receipts and summaries',
              value: _emailNotifications, textPri: textPri, textSec: textSec, border: border,
              onChanged: (v) => setState(() => _emailNotifications = v),
            ),
            _SwitchTile(
              icon: Icons.sms_outlined,
              label: 'SMS notifications',
              subtitle: 'Booking confirmations',
              value: _smsNotifications, textPri: textPri, textSec: textSec, border: border,
              onChanged: (v) => setState(() => _smsNotifications = v),
              isLast: true,
            ),
          ]),

          const SizedBox(height: 20),

          // ── Privacy & Security ──
          _SectionHeader(label: 'Privacy & security', textSec: textSec),
          _SettingsCard(card: card, border: border, children: [
            _SwitchTile(
              icon: Icons.location_on_outlined,
              label: 'Location services',
              subtitle: 'Used for nearby cars',
              value: _locationServices, textPri: textPri, textSec: textSec, border: border,
              onChanged: (v) => setState(() => _locationServices = v),
            ),
            _SwitchTile(
              icon: Icons.fingerprint,
              label: 'Biometric login',
              subtitle: 'Fingerprint or Face ID',
              value: _biometricLogin, textPri: textPri, textSec: textSec, border: border,
              onChanged: (v) => setState(() => _biometricLogin = v),
            ),
            _NavTile(
              icon: Icons.lock_outline,
              label: 'Change password',
              textPri: textPri, textSec: textSec, border: border,
              isLast: true,
              onTap: () => _go(const ChangePasswordScreen()),
            ),
          ]),

          const SizedBox(height: 20),

          // ── Regional ──
          _SectionHeader(label: 'Regional', textSec: textSec),
          _SettingsCard(card: card, border: border, children: [
            _NavTile(
              icon: Icons.language_outlined, label: 'Language',
              textPri: textPri, textSec: textSec, border: border,
              value: _language,
              onTap: () async {
                _go(const LanguageScreen());
                setState(() {});
              },
            ),
            _NavTile(
              icon: Icons.attach_money, label: 'Currency',
              textPri: textPri, textSec: textSec, border: border,
              value: _currency,
              onTap: () async {
                _go(const CurrencyScreen());
                setState(() {});
              },
            ),
            _DropdownTile(
              icon: Icons.straighten_outlined,
              label: 'Distance unit',
              value: _distanceUnit,
              options: const ['km', 'miles'],
              textPri: textPri, textSec: textSec, border: border, card: card,
              onChanged: (v) => setState(() => _distanceUnit = v!),
              isLast: true,
            ),
          ]),

          const SizedBox(height: 20),

          // ── About ──
          _SectionHeader(label: 'About', textSec: textSec),
          _SettingsCard(card: card, border: border, children: [
            _NavTile(icon: Icons.description_outlined, label: 'Terms of service',  textPri: textPri, textSec: textSec, border: border,   onTap: () => _go(const TermsScreen())),
            _NavTile(icon: Icons.privacy_tip_outlined, label: 'Privacy policy',    textPri: textPri, textSec: textSec, border: border,   onTap: () => _go(const PrivacyPolicyScreen())),
            _NavTile(icon: Icons.star_outline,         label: 'Rate the app',      textPri: textPri, textSec: textSec, border: border,   onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you! Rating opens in store (demo)')))),
            _NavTile(icon: Icons.info_outline,         label: 'Version',           textPri: textPri, textSec: textSec, border: border,   value: 'v1.0.0', isLast: true, onTap: () => _go(const AboutScreen())),
          ]),

          const SizedBox(height: 32),

          // ── Danger zone ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withOpacity(0.25), width: 0.5),
            ),
            child: Column(children: [
              _DangerRow(icon: Icons.logout, label: 'Log out', textSec: textSec,
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false)),
              Divider(color: Colors.redAccent.withOpacity(0.15), height: 20),
              _DangerRow(icon: Icons.delete_outline, label: 'Delete account', textSec: textSec, onTap: () => _showDeleteAccountConfirm(context)),
            ]),
          ),

          const SizedBox(height: 32),
        ]),
      ),
    );
  }
  void _showDeleteAccountConfirm(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8) : const Color(0xFF6B7280);
    showModalBottomSheet(context: context, backgroundColor: card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 36), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 28)),
        const SizedBox(height: 14),
        Text('Delete Account?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPri)),
        const SizedBox(height: 8),
        Text('This will permanently delete your account and all data. This cannot be undone.',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: textSec, height: 1.5)),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            AuthService.logout();
            Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Yes, Delete My Account', style: TextStyle(fontWeight: FontWeight.w700)))),
        const SizedBox(height: 10),
        GestureDetector(onTap: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: textSec, fontSize: 13))),
      ])));
  }
}


class _SectionHeader extends StatelessWidget {
  final String label; final Color textSec;
  const _SectionHeader({required this.label, required this.textSec});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSec, letterSpacing: .5)),
  );
}

class _SettingsCard extends StatelessWidget {
  final Color card, border; final List<Widget> children;
  const _SettingsCard({required this.card, required this.border, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
        color: card, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.5)),
    child: Column(children: children),
  );
}

class _SwitchTile extends StatelessWidget {
  final IconData icon; final String label, subtitle;
  final bool value, isLast; final Color textPri, textSec, border;
  final ValueChanged<bool> onChanged; final VoidCallback? onTap;
  const _SwitchTile({required this.icon, required this.label, required this.subtitle,
    required this.value, required this.textPri, required this.textSec,
    required this.border, required this.onChanged, this.isLast = false, this.onTap});

  @override
  Widget build(BuildContext context) => Column(children: [
    ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.gold, size: 18),
      ),
      title: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPri)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: textSec)),
      trailing: Switch(
        value: value, onChanged: onChanged,
        activeColor: AppColors.gold, activeTrackColor: AppColors.gold.withOpacity(0.3),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    ),
    if (!isLast) Divider(color: border, height: 1, indent: 68),
  ]);
}

class _NavTile extends StatelessWidget {
  final IconData icon; final String label; final String? value;
  final bool isLast; final Color textPri, textSec, border;
  final VoidCallback? onTap;
  const _NavTile({required this.icon, required this.label, required this.textPri,
    required this.textSec, required this.border, this.value, this.isLast = false, this.onTap});

  @override
  Widget build(BuildContext context) => Column(children: [
    ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.gold, size: 18),
      ),
      title: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPri)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (value != null) Text(value!, style: TextStyle(fontSize: 12, color: textSec)),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right, color: textSec, size: 18),
      ]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    ),
    if (!isLast) Divider(color: border, height: 1, indent: 68),
  ]);
}

class _DropdownTile extends StatelessWidget {
  final IconData icon; final String label, value; final List<String> options;
  final bool isLast; final Color textPri, textSec, border, card;
  final ValueChanged<String?> onChanged;
  const _DropdownTile({required this.icon, required this.label, required this.value,
    required this.options, required this.textPri, required this.textSec,
    required this.border, required this.card, required this.onChanged, this.isLast = false});

  @override
  Widget build(BuildContext context) => Column(children: [
    ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.gold, size: 18),
      ),
      title: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPri)),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: TextStyle(fontSize: 12, color: textPri)))).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, color: textSec, size: 16),
        dropdownColor: card,
        style: TextStyle(fontSize: 12, color: textSec),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    ),
    if (!isLast) Divider(color: border, height: 1, indent: 68),
  ]);
}

class _DangerRow extends StatelessWidget {
  final IconData icon; final String label; final Color textSec;
  final VoidCallback? onTap;
  const _DangerRow({required this.icon, required this.label, required this.textSec, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(children: [
      Icon(icon, color: Colors.redAccent, size: 18),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.w500)),
    ]),
  );
}
