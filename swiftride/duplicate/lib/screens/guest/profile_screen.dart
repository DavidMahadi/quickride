import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/services/auth_service.dart';
import 'package:swiftride/screens/guest/settings_screen.dart';
import 'package:swiftride/screens/guest/sub_screens.dart';
import 'package:swiftride/screens/guest/shared_drawer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg      : AppColors.lightBg;
    final card    = isDark ? AppColors.darkCard    : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder  : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white           : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    void go(Widget screen) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    return Scaffold(
      backgroundColor: bg,
      drawer: const AppDrawer(activeTab: 4),
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu, size: 22), onPressed: () => Scaffold.of(ctx).openDrawer())),
        title: Text('Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => go(const PersonalInfoScreen()),
              child: Icon(Icons.edit_outlined, color: textPri, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Avatar + name ──
          Center(
            child: Column(children: [
              GestureDetector(
                onTap: () => go(const PersonalInfoScreen()),
                child: Stack(children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.gold.withOpacity(0.15),
                    child: const Text('A',
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.gold)),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.gold, shape: BoxShape.circle,
                        border: Border.all(color: bg, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, size: 13, color: Colors.black),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              Text('Alex Johnson',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 4),
              Text('alex@email.com', style: TextStyle(fontSize: 13, color: textSec)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D9E75).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Verified',
                    style: TextStyle(fontSize: 11, color: Color(0xFF1D9E75), fontWeight: FontWeight.w600)),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Stats row ──
          Row(children: [
            _StatBox(label: 'Total Trips', value: '12', card: card, border: border, textPri: textPri, textSec: textSec),
            const SizedBox(width: 12),
            _StatBox(label: 'Favorites',   value: '5',  card: card, border: border, textPri: textPri, textSec: textSec),
            const SizedBox(width: 12),
            _StatBox(label: 'Reviews',     value: '8',  card: card, border: border, textPri: textPri, textSec: textSec),
          ]),

          const SizedBox(height: 24),

          // ── Account ──
          _SectionLabel(label: 'Account', textSec: textSec),
          _SettingsGroup(card: card, border: border, items: [
            _SettingItem(icon: Icons.person_outline,       label: 'Personal Info',   textPri: textPri, textSec: textSec, onTap: () => go(const PersonalInfoScreen())),
            _SettingItem(icon: Icons.credit_card_outlined, label: 'Payment Methods', textPri: textPri, textSec: textSec, onTap: () => go(const PaymentMethodsScreen())),
            _SettingItem(icon: Icons.badge_outlined,       label: 'My Documents',   textPri: textPri, textSec: textSec, onTap: () => go(const MyDocumentsScreen())),
            _SettingItem(icon: Icons.location_on_outlined, label: 'Saved Addresses', textPri: textPri, textSec: textSec, onTap: () => go(const SavedAddressesScreen())),
          ]),

          const SizedBox(height: 16),

          // ── Preferences ──
          _SectionLabel(label: 'Preferences', textSec: textSec),
          _SettingsGroup(card: card, border: border, items: [
            _SettingItem(
              icon: Icons.notifications_outlined, label: 'Notifications',
              textPri: textPri, textSec: textSec,
              onTap: () => go(const NotificationsScreen()),
              trailing: _toggle(true),
            ),
            _SettingItem(
              icon: Icons.language_outlined, label: 'Language',
              textPri: textPri, textSec: textSec,
              value: 'English',
              onTap: () => go(const LanguageScreen()),
            ),
            _SettingItem(
              icon: Icons.attach_money, label: 'Currency',
              textPri: textPri, textSec: textSec,
              value: 'USD',
              onTap: () => go(const CurrencyScreen()),
            ),
            _SettingItem(
              icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              label: isDark ? 'Dark mode' : 'Light mode',
              textPri: textPri, textSec: textSec,
              trailing: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (_, mode, __) => Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: (_) => themeNotifier.toggle(),
                  activeColor: AppColors.gold,
                  activeTrackColor: AppColors.gold.withOpacity(0.3),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // ── Support ──
          _SectionLabel(label: 'Support', textSec: textSec),
          _SettingsGroup(card: card, border: border, items: [
            _SettingItem(icon: Icons.help_outline,          label: 'Help Center',    textPri: textPri, textSec: textSec, onTap: () => go(const HelpCenterScreen())),
            _SettingItem(icon: Icons.privacy_tip_outlined,  label: 'Privacy Policy', textPri: textPri, textSec: textSec, onTap: () => go(const PrivacyPolicyScreen())),
            _SettingItem(icon: Icons.info_outline,          label: 'About',          textPri: textPri, textSec: textSec, value: 'v1.0.0', onTap: () => go(const AboutScreen())),
          ]),

          const SizedBox(height: 16),

          // ── Logout ──
          GestureDetector(
            onTap: () => _confirmLogout(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 0.5),
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.logout, color: Colors.redAccent, size: 18),
                SizedBox(width: 8),
                Text('Log out',
                    style: TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _toggle(bool val) => Transform.scale(
    scale: 0.8,
    child: Switch(
      value: val, onChanged: (_) {},
      activeColor: AppColors.gold,
      activeTrackColor: AppColors.gold.withOpacity(0.3),
    ),
  );

  void _confirmLogout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card   = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8) : const Color(0xFF6B7280);

    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.logout, color: Colors.redAccent, size: 26),
          ),
          const SizedBox(height: 16),
          Text('Log out?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
          const SizedBox(height: 6),
          Text('You\'ll need to sign in again to access your bookings.',
              style: TextStyle(fontSize: 13, color: textSec, height: 1.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                AuthService.logout(); Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Log out', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 13, color: textSec)),
          ),
        ]),
      ),
    );
  }
}

// ── Local widgets ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textSec;
  const _SectionLabel({required this.label, required this.textSec});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSec, letterSpacing: .5)),
  );
}

class _SettingsGroup extends StatelessWidget {
  final Color card, border;
  final List<_SettingItem> items;
  const _SettingsGroup({required this.card, required this.border, required this.items});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
        color: card, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.5)),
    child: Column(
      children: items.asMap().entries.map((e) {
        final isLast = e.key == items.length - 1;
        return Column(children: [
          e.value,
          if (!isLast) Divider(color: border, height: 1, indent: 48),
        ]);
      }).toList(),
    ),
  );
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color textPri, textSec;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingItem({
    required this.icon, required this.label,
    required this.textPri, required this.textSec,
    this.value, this.trailing, this.onTap,
  });
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.gold, size: 20),
    title: Text(label, style: TextStyle(fontSize: 13, color: textPri)),
    trailing: trailing ?? Row(mainAxisSize: MainAxisSize.min, children: [
      if (value != null) Text(value!, style: TextStyle(fontSize: 12, color: textSec)),
      const SizedBox(width: 4),
      Icon(Icons.chevron_right, color: textSec, size: 18),
    ]),
    onTap: onTap,
    dense: true,
    horizontalTitleGap: 4,
  );
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color card, border, textPri, textSec;
  const _StatBox({required this.label, required this.value, required this.card, required this.border, required this.textPri, required this.textSec});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
        color: card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.5)),
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gold)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: textSec)),
    ]),
  ));
}
