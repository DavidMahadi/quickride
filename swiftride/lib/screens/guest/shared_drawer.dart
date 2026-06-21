import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/services/auth_service.dart';
import 'package:swiftride/screens/guest/app_shell.dart';
import 'package:swiftride/screens/guest/search_screen.dart';
import 'package:swiftride/screens/guest/settings_screen.dart';
import 'package:swiftride/screens/guest/companies_screen.dart';
import 'package:swiftride/screens/guest/category_screen.dart';
import 'package:swiftride/screens/guest/sub_screens.dart';

// ═══════════════════════════════════════════════════════════════
//  SHARED APP DRAWER
//  Use in any top-level Scaffold: drawer: const AppDrawer()
// ═══════════════════════════════════════════════════════════════
class AppDrawer extends StatelessWidget {
  final int activeTab; // which bottom nav tab is currently active
  const AppDrawer({super.key, this.activeTab = 0});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkCard   : Colors.white;
    final surface = isDark ? AppColors.darkSurface: AppColors.lightSurface;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white          : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    // Close drawer then navigate
    void go(Widget screen) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }

    // Close drawer then switch HomeScreen tab
    void goTab(int tab) {
      Navigator.pop(context);
      Navigator.of(context).popUntil((r) => r.isFirst);
      shellTabNotifier.value = tab;
    }

    final navItems = [
      _Item(icon: Icons.home_outlined,            label: 'Home',           active: activeTab == 0, onTap: () => goTab(0)),
      _Item(icon: Icons.search_outlined,           label: 'Search Cars',   active: false,          onTap: () { Navigator.pop(context); go(const SearchScreen()); }),
      _Item(icon: Icons.business_outlined,         label: 'Companies',     active: false,          onTap: () { Navigator.pop(context); go(const CompaniesScreen()); }),
      _Item(icon: Icons.calendar_today_outlined,   label: 'My Bookings',   active: activeTab == 1, onTap: () => goTab(1)),
      _Item(icon: Icons.favorite_outline,          label: 'Favorites',     active: activeTab == 2, onTap: () => goTab(2)),
      _Item(icon: Icons.chat_bubble_outline,       label: 'Messages',      active: activeTab == 3, onTap: () => goTab(3)),
      _Item(icon: Icons.person_outline,            label: 'Profile',       active: activeTab == 4, onTap: () => goTab(4)),
      _Item(icon: Icons.settings_outlined,         label: 'Settings',      active: false,          onTap: () { Navigator.pop(context); go(const SettingsScreen()); }),
      _Item(icon: Icons.help_outline,              label: 'Help & Support',active: false,          onTap: () { Navigator.pop(context); go(const HelpCenterScreen()); }),
    ];

    final deals = [
      _Deal(title: '20% OFF',    sub: 'Economy cars',    color: const Color(0xFF1D9E75), icon: Icons.local_offer_outlined,  cat: 'Economy'),
      _Deal(title: 'FREE GPS',   sub: 'On SUV bookings', color: const Color(0xFF3B5FD4), icon: Icons.gps_fixed,             cat: 'SUV'),
      _Deal(title: 'CHAUFFEUR',  sub: 'Luxury + driver', color: const Color(0xFF7F77DD), icon: Icons.drive_eta_outlined,    cat: 'Luxury'),
      _Deal(title: 'GROUP DEAL', sub: 'Vans & minibuses',color: const Color(0xFFD85A30), icon: Icons.group_outlined,        cat: 'Van'),
    ];

    return Drawer(
      backgroundColor: bg,
      child: SafeArea(child: Column(children: [

        // ── Profile header ──────────────────────────────────────
        GestureDetector(
          onTap: () => goTab(4),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border, width: 0.5))),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 1.5),
                ),
                child: Center(child: Text(AuthService.userName.isNotEmpty ? AuthService.userName[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.gold))),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AuthService.userName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPri)),
                const SizedBox(height: 2),
                Text(AuthService.userEmail, style: TextStyle(fontSize: 12, color: textSec)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D9E75).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Verified', style: TextStyle(fontSize: 10, color: Color(0xFF1D9E75), fontWeight: FontWeight.w600)),
                ),
              ])),
              Icon(Icons.chevron_right, color: textSec, size: 18),
            ]),
          ),
        ),

        // ── Theme toggle ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 0.5),
            ),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: AppColors.gold, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isDark ? 'Dark mode' : 'Light mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
                Text('Tap to switch', style: TextStyle(fontSize: 10, color: textSec)),
              ])),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (_, mode, __) => Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: (_) => themeNotifier.toggle(),
                  activeColor: AppColors.gold,
                  activeTrackColor: AppColors.gold.withOpacity(0.3),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ]),
          ),
        ),

        // ── Deals & Offers ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Deals & Offers', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri)),
              GestureDetector(
                onTap: () { Navigator.pop(context); go(const SearchScreen()); },
                child: const Text('See All >', style: TextStyle(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 8),
            SizedBox(
              height: 66,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: deals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final d = deals[i];
                  return GestureDetector(
                    onTap: () { Navigator.pop(context); go(CategoryScreen(initialCategory: d.cat, fromDeal: true)); },
                    child: Container(
                      width: 114,
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                      decoration: BoxDecoration(
                        color: d.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: d.color.withOpacity(0.28), width: 0.8),
                      ),
                      child: Row(children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(color: d.color.withOpacity(0.15), shape: BoxShape.circle),
                          child: Icon(d.icon, color: d.color, size: 13),
                        ),
                        const SizedBox(width: 6),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(d.title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: d.color)),
                          const SizedBox(height: 2),
                          Text(d.sub, style: TextStyle(fontSize: 8, color: d.color.withOpacity(0.75), height: 1.2), maxLines: 2),
                        ])),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Divider(color: border, height: 1),
          ]),
        ),

        // ── Nav items ───────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: navItems.length,
            itemBuilder: (_, i) {
              final item = navItems[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                decoration: BoxDecoration(
                  color: item.active ? AppColors.gold.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(item.icon, color: item.active ? AppColors.gold : textSec, size: 20),
                  title: Text(item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: item.active ? FontWeight.w600 : FontWeight.w400,
                        color: item.active ? AppColors.gold : textPri,
                      )),
                  trailing: item.active
                      ? Container(width: 4, height: 20,
                          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2)))
                      : null,
                  onTap: item.onTap,
                  dense: true,
                  horizontalTitleGap: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
        ),

        // ── Log out ─────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.redAccent.withOpacity(0.2), width: 0.5),
          ),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
            title: const Text('Log out',
                style: TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.w500)),
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
            dense: true,
          ),
        ),
      ])),
    );
  }
}

// ── Internal data classes ─────────────────────────────────────
class _Item {
  final IconData icon; final String label; final bool active; final VoidCallback onTap;
  const _Item({required this.icon, required this.label, required this.active, required this.onTap});
}

class _Deal {
  final String title, sub, cat; final Color color; final IconData icon;
  const _Deal({required this.title, required this.sub, required this.cat, required this.color, required this.icon});
}
