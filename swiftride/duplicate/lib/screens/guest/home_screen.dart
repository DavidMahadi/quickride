import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/car_detail_screen.dart';
import 'package:swiftride/screens/guest/auth_screens.dart';
import 'package:swiftride/screens/guest/bookings_screen.dart';
import 'package:swiftride/screens/guest/favorites_screen.dart';
import 'package:swiftride/screens/guest/messages_screen.dart';
import 'package:swiftride/screens/guest/profile_screen.dart';
import 'package:swiftride/screens/guest/search_screen.dart';
import 'package:swiftride/screens/guest/settings_screen.dart';
import 'package:swiftride/screens/guest/category_screen.dart';
import 'package:swiftride/screens/guest/sub_screens.dart';
import 'package:swiftride/screens/guest/companies_screen.dart';
import 'package:swiftride/screens/guest/app_shell.dart';
import 'package:swiftride/screens/guest/shared_drawer.dart';
import 'package:swiftride/services/auth_service.dart';
import 'package:swiftride/services/app_data_store.dart';
import 'package:swiftride/screens/user/user_messages_screen.dart' show UserMessagesScreen;
import 'package:swiftride/screens/user/user_bookings_screen.dart';
import 'package:swiftride/screens/user/user_favorites_screen.dart';

// ─────────────────────────────────────────────
//  THEME NOTIFIER
// ─────────────────────────────────────────────
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.dark);
  void toggle() { value = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark; }
}
final themeNotifier = ThemeNotifier();

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
class AppColors {
  static const gold        = const Color(0xFFD4A017);
  static const goldLight   = Color(0xFFEAB93D);
  static const darkBg      = Color(0xFF0A0E1A);
  static const darkCard    = Color(0xFF141828);
  static const darkSurface = Color(0xFF1C2236);
  static const darkBorder  = Color(0xFF252B3E);
  static const white       = Colors.white;
  static const lightBg     = Color(0xFFF2F4F8);
  static const lightCard   = Color(0xFFFFFFFF);
  static const lightSurface= Color(0xFFE8EBF2);
}


// ─────────────────────────────────────────────
//  GUEST GATE
// ─────────────────────────────────────────────
class GuestGate {
  static void show(BuildContext context, {String? reason, String? pendingRoute, Object? pendingArgs}) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GuestGateSheet(reason: reason, pendingRoute: pendingRoute, pendingArgs: pendingArgs),
    );
  }
}

class _GuestGateSheet extends StatelessWidget {
  final String? reason;
  final String? pendingRoute;
  final Object? pendingArgs;
  const _GuestGateSheet({this.reason, this.pendingRoute, this.pendingArgs});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
          decoration: BoxDecoration(color: AppColors.darkBorder, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 24),
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.12), shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1.5)),
          child: const Icon(Icons.lock_outline_rounded, color: AppColors.gold, size: 34),
        ),
        const SizedBox(height: 18),
        const Text('Sign In Required',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(reason ?? 'Sign in to access this feature.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF8B91A8), fontSize: 14, height: 1.5)),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
          onPressed: () {
            if (pendingRoute != null) AuthService.setPending(pendingRoute!, args: pendingArgs);
            Navigator.pop(context);
            Navigator.pushNamed(context, '/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold, foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
          child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        )),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 52, child: OutlinedButton(
          onPressed: () {
            if (pendingRoute != null) AuthService.setPending(pendingRoute!, args: pendingArgs);
            Navigator.pop(context);
            Navigator.pushNamed(context, '/register');
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.gold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Create Account',
            style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
        )),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Continue as Guest',
            style: TextStyle(color: Color(0xFF8B91A8), fontSize: 13)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  DUMMY DATA
// ─────────────────────────────────────────────
class CarCategory {
  final String name, price;
  final IconData icon;
  final Color iconBg;
  const CarCategory({required this.name, required this.price, required this.icon, required this.iconBg});
}

class CarItem {
  final String name, price, transmission, fuel;
  final int seats;
  bool isFavorite;
  CarItem({required this.name, required this.price, required this.seats, required this.transmission, required this.fuel, this.isFavorite = false});
}

final List<CarCategory> dummyCategories = [
  CarCategory(name: 'Economy', price: 'From \$30/day', icon: Icons.directions_car,         iconBg: Color(0xFF1D9E75)),
  CarCategory(name: 'SUV',     price: 'From \$50/day', icon: Icons.airport_shuttle,        iconBg: Color(0xFF3B5FD4)),
  CarCategory(name: 'Luxury',  price: 'From \$80/day', icon: Icons.star_outline,           iconBg: Color(0xFF7F77DD)),
  CarCategory(name: 'Van',     price: 'From \$60/day', icon: Icons.local_shipping_outlined, iconBg: Color(0xFFD85A30)),
];

final List<CarItem> dummyCars = [
  CarItem(name: 'Toyota Camry', price: '\$45 / day', seats: 5, transmission: 'Automatic', fuel: 'Petrol'),
  CarItem(name: 'Toyota RAV4',  price: '\$60 / day', seats: 5, transmission: 'Automatic', fuel: 'Petrol'),
  CarItem(name: 'BMW 5 Series', price: '\$90 / day', seats: 5, transmission: 'Automatic', fuel: 'Petrol'),
  CarItem(name: 'Mercedes C',   price: '\$95 / day', seats: 5, transmission: 'Automatic', fuel: 'Diesel'),
];

// ─────────────────────────────────────────────
//  PROMO BANNER DATA
// ─────────────────────────────────────────────
class _PromoBanner {
  final String tag, title, subtitle, cta;
  final Color color;
  final IconData icon;
  final Widget Function(BuildContext) destination;
  const _PromoBanner({required this.tag, required this.title, required this.subtitle, required this.cta, required this.color, required this.icon, required this.destination});
}

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final bool isUserMode;
  const HomeScreen({super.key, this.isUserMode = false});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  int _bannerIndex = 0;
  final List<CarItem> _cars = List.from(dummyCars);

  @override
  void initState() {
    super.initState();
    shellTabNotifier.addListener(_onShellTab);
  }

  @override
  void dispose() {
    shellTabNotifier.removeListener(_onShellTab);
    super.dispose();
  }

  void _onShellTab() {
    if (mounted) setState(() => _selectedTab = shellTabNotifier.value);
  }

  final List<_PromoBanner> _banners = [
    _PromoBanner(
      tag: 'FAST · EASY · RELIABLE',
      title: 'Drive Your\nDream Car',
      subtitle: 'Explore a wide range of cars\nand book in just a few taps.',
      cta: 'Explore Cars',
      color: AppColors.gold,
      icon: Icons.directions_car,
      destination: (_) => const CategoryScreen(),
    ),
    _PromoBanner(
      tag: 'NEW  ·  COMPANIES',
      title: 'Top Rental\nCompanies',
      subtitle: 'Compare trusted companies,\nread reviews & requirements.',
      cta: 'View Companies',
      color: Color(0xFF3B5FD4),
      icon: Icons.business,
      destination: (_) => const CompaniesScreen(),
    ),
    _PromoBanner(
      tag: '🔥 HOT DEAL',
      title: 'Luxury Cars\nfrom \$80/day',
      subtitle: 'Premium fleet available now.\nLimited slots — book fast.',
      cta: 'Book Luxury',
      color: Color(0xFF7F77DD),
      icon: Icons.star,
      destination: (_) => CategoryScreen(initialCategory: 'Luxury',  fromDeal: true),
    ),
    _PromoBanner(
      tag: '👥 GROUP TRAVEL',
      title: 'Need a Van\nor Minibus?',
      subtitle: 'Seats for 12–35 passengers.\nPerfect for events & tours.',
      cta: 'See Vans',
      color: Color(0xFF0D7EA8),
      icon: Icons.airport_shuttle,
      destination: (_) => CategoryScreen(initialCategory: 'Van',     fromDeal: true),
    ),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined),          activeIcon: Icon(Icons.home),          label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Bookings'),
    BottomNavigationBarItem(icon: Icon(Icons.favorite_outline),       activeIcon: Icon(Icons.favorite),      label: 'Favorites'),
    BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline),    activeIcon: Icon(Icons.chat_bubble),   label: 'Messages'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline),         activeIcon: Icon(Icons.person),        label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg      : AppColors.lightBg;
    final cardBg  = isDark ? AppColors.darkCard    : AppColors.lightCard;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border  = isDark ? AppColors.darkBorder  : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white           : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      drawer: _buildDrawer(isDark, textPri, textSec, cardBg, border),
      bottomNavigationBar: _buildBottomNav(isDark, textSec),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          // Tab 0 — Home
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (!widget.isUserMode) _buildGuestBanner(context),
                _buildTopBar(isDark, textPri, textSec, context),
                _buildHeroCarousel(isDark),
                _buildQuickActions(isDark, textPri, textSec, cardBg, border),
                _buildCategorySection(isDark, textPri, textSec, cardBg),
                _buildCompaniesSection(isDark, textPri, textSec, cardBg, border),
                _buildPopularCars(isDark, textPri, textSec, cardBg, border),
                _buildWhyUsSection(isDark, textPri, textSec, cardBg, border),
                if (widget.isUserMode) _buildActivitySection(isDark, textPri, textSec, cardBg, border),
                const SizedBox(height: 24),
              ]),
            ),
          ),
          widget.isUserMode ? const UserBookingsScreen() : _GuestLockTab(icon: Icons.calendar_today_outlined, title: 'My Bookings', reason: 'Sign in to view your booking history.', pendingRoute: '/user/home'),
          widget.isUserMode ? const UserFavoritesScreen()  : _GuestLockTab(icon: Icons.favorite_outline,          title: 'Favorites',   reason: 'Sign in to save your favourite cars.',  pendingRoute: '/user/home'),
          widget.isUserMode ? const UserMessagesScreen() : _GuestLockTab(icon: Icons.chat_bubble_outline,       title: 'Messages',    reason: 'Sign in to chat with rental companies.', pendingRoute: '/user/home'),
          widget.isUserMode ? const ProfileScreen()    : _GuestLockTab(icon: Icons.person_outline,            title: 'Profile',     reason: 'Sign in to manage your profile.',       pendingRoute: '/user/home'),
        ],
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────
  Widget _buildTopBar(bool isDark, Color textPri, Color textSec, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(children: [
        Builder(builder: (ctx) => GestureDetector(
          onTap: () => Scaffold.of(ctx).openDrawer(),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE), width: 0.5),
            ),
            child: Icon(Icons.menu, color: textPri, size: 20),
          ),
        )),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(
              widget.isUserMode ? 'Hello, ${r'$'}{AuthService.userName.split(" ").first} ' : 'Hello, Alex ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri),
              overflow: TextOverflow.ellipsis)),
            const Text('👋', style: TextStyle(fontSize: 18)),
          ]),
          Text('Where are you driving today?', style: TextStyle(fontSize: 12, color: textSec)),
        ])),
        const SizedBox(width: 10),
        // Search icon → SearchScreen
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE), width: 0.5),
            ),
            child: Icon(Icons.search, color: textPri, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        // Notification icon
        Stack(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE), width: 0.5),
            ),
            child: Icon(Icons.notifications_outlined, color: textPri, size: 20),
          ),
          Positioned(right: 6, top: 6,
            child: Container(width: 10, height: 10,
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              child: const Center(child: Text('1', style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold))),
            )),
        ]),
      ]),
    );
  }

  // ── Hero carousel (auto-swipeable promos) ────────────────────
  Widget _buildHeroCarousel(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(children: [
        SizedBox(
          height: 185,
          child: PageView.builder(
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (context, i) {
              final b = _banners[i];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: b.destination)),
                child: Container(
                  margin: const EdgeInsets.only(right: 0),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : const Color(0xFF1C2236),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(fit: StackFit.expand, children: [
                    // Glow
                    Positioned(right: 0, top: 0, bottom: 0,
                      child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(18), bottomRight: Radius.circular(18)),
                          gradient: LinearGradient(colors: [Colors.transparent, b.color.withOpacity(0.18)]),
                        ),
                      ),
                    ),
                    // Big icon bg
                    Positioned(right: 12, bottom: 10,
                      child: Icon(b.icon, size: 95, color: b.color.withOpacity(0.12))),
                    // Content
                    Positioned.fill(child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: b.color.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(b.tag, style: TextStyle(fontSize: 9, color: b.color, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                        ),
                        const SizedBox(height: 8),
                        Text(b.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
                        const SizedBox(height: 5),
                        Text(b.subtitle, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.55), height: 1.4)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: b.color, borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(b.cta, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                            const SizedBox(width: 5),
                            const Icon(Icons.arrow_forward, size: 12, color: Colors.black),
                          ]),
                        ),
                      ]),
                    )),
                  ]),
                ),
              );
            },
          ),
        ),
        // Dots
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_banners.length, (i) =>
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: _bannerIndex == i ? 18 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: _bannerIndex == i ? AppColors.gold : AppColors.gold.withOpacity(0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        )),
      ]),
    );
  }

  // ── Quick actions row ─────────────────────────────────────────
  Widget _buildQuickActions(bool isDark, Color textPri, Color textSec, Color cardBg, Color border) {
    final actions = [
      {'icon': Icons.search,             'label': 'Search',    'color': const Color(0xFF1D9E75),   'dest': (_) => const SearchScreen()},
      {'icon': Icons.business_outlined,  'label': 'Companies', 'color': const Color(0xFF3B5FD4),   'dest': (_) => const CompaniesScreen()},
      {'icon': Icons.favorite_outline,   'label': 'Saved',     'color': const Color(0xFFD85A30),   'dest': null},  // → Favorites tab
      {'icon': Icons.chat_bubble_outline,'label': 'Messages',  'color': const Color(0xFF7F77DD),   'dest': null},  // → Messages tab
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(children: actions.asMap().entries.map((e) {
        final i = e.key; final a = e.value;
        final color = a['color'] as Color;
        return Expanded(child: GestureDetector(
          onTap: () {
            if (a['dest'] != null) {
              Navigator.push(context, MaterialPageRoute(builder: a['dest'] as Widget Function(BuildContext)));
            } else {
              if (widget.isUserMode) {
                setState(() => _selectedTab = i == 2 ? 2 : 3);
              } else {
                GuestGate.show(context, reason: i == 2
                    ? 'Sign in to save your favourite cars.'
                    : 'Sign in to chat with rental companies.');
              }
            }
          },
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 0.5),
            ),
            child: Column(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(a['icon'] as IconData, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(a['label'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textPri)),
            ]),
          ),
        ));
      }).toList()),
    );
  }

  // ── Categories ────────────────────────────────────────────────
  Widget _buildCategorySection(bool isDark, Color textPri, Color textSec, Color cardBg) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Browse by Category', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPri)),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen())),
            child: const Text('View All >', style: TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w500)),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: dummyCategories.map((cat) => Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(initialCategory: cat.name))),
            child: _CategoryCard(cat: cat, isDark: isDark, textPri: textPri, textSec: textSec, cardBg: cardBg),
          ),
        ))).toList()),
      ]),
    );
  }

  // ── Companies strip ───────────────────────────────────────────
  Widget _buildCompaniesSection(bool isDark, Color textPri, Color textSec, Color cardBg, Color border) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Rental Companies', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPri)),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompaniesScreen())),
            child: const Text('View All >', style: TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w500)),
          ),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: allCompanies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final company = allCompanies[i];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyDetailScreen(company: company))),
                child: Container(
                  width: 130,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE), width: 0.5),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: company.brandColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: company.brandColor.withOpacity(0.3), width: 0.8),
                        ),
                        child: Center(child: Text(company.initials, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: company.brandColor))),
                      ),
                      const Spacer(),
                      Row(children: [
                        const Icon(Icons.star, color: AppColors.gold, size: 11),
                        const SizedBox(width: 2),
                        Text(company.rating.toStringAsFixed(1), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textPri)),
                      ]),
                    ]),
                    const SizedBox(height: 8),
                    Text(company.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('${company.fleet.length} cars · ${company.categories.first}', style: TextStyle(fontSize: 10, color: textSec), overflow: TextOverflow.ellipsis),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  // ── Popular Cars ──────────────────────────────────────────────
  Widget _buildPopularCars(bool isDark, Color textPri, Color textSec, Color cardBg, Color border) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Popular Cars', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPri)),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen())),
            child: const Text('View All >', style: TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w500)),
          ),
        ]),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cars.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.88, crossAxisSpacing: 12, mainAxisSpacing: 12,
          ),
          itemBuilder: (_, i) => _CarCard(
            car: _cars[i],
            isDark: isDark,
            textPri: textPri, textSec: textSec,
            cardBg: cardBg, border: border,
            onFavTap: () => setState(() => _cars[i].isFavorite = !_cars[i].isFavorite),
          ),
        ),
      ]),
    );
  }

  // ── Why Us section ────────────────────────────────────────────
  Widget _buildWhyUsSection(bool isDark, Color textPri, Color textSec, Color cardBg, Color border) {
    final points = [
      {'icon': Icons.verified_outlined,         'title': 'Verified Companies',  'sub': 'All partners are vetted\nand licensed.',           'color': const Color(0xFF1D9E75)},
      {'icon': Icons.support_agent_outlined,    'title': '24/7 Support',        'sub': 'Help whenever\nyou need it.',                      'color': const Color(0xFF3B5FD4)},
      {'icon': Icons.payment_outlined,          'title': 'Secure Payment',      'sub': 'Card & mobile money\naccepted.',                   'color': const Color(0xFF7F77DD)},
      {'icon': Icons.cancel_outlined,           'title': 'Free Cancellation',   'sub': 'Cancel 24 hrs before\nfor a full refund.',         'color': const Color(0xFFD85A30)},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Why Choose SwiftRide?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPri)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10, mainAxisSpacing: 10,
          childAspectRatio: 2.1,
          children: points.map((p) {
            final color = p['color'] as Color;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: 0.5),
              ),
              child: Row(children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
                  child: Icon(p['icon'] as IconData, color: color, size: 17),
                ),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(p['title'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textPri), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(p['sub'] as String, style: TextStyle(fontSize: 9, color: textSec, height: 1.3), maxLines: 2),
                ])),
              ]),
            );
          }).toList(),
        ),
      ]),
    );
  }

  // ── Activity Section (logged-in users only) ───────────────────
  Widget _buildActivitySection(bool isDark, Color textPri, Color textSec, Color cardBg, Color border) {
    final userId = AuthService.currentUserId;
    final activities = AppDataStore.instance.activitiesForUser(userId);
    if (activities.isEmpty) return const SizedBox.shrink();

    const catColors = {
      'Booking': Color(0xFF1D9E75),
      'Message': Color(0xFF3B5FD4),
      'Payment': Color(0xFFD4A017),
      'Review':  Color(0xFF7F77DD),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPri)),
          Text('${activities.length} events', style: TextStyle(fontSize: 12, color: textSec)),
        ]),
        const SizedBox(height: 14),
        ...activities.take(5).map((a) {
          final color = catColors[a.category] ?? AppColors.gold;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 0.5),
            ),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(a.icon, style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
                const SizedBox(height: 2),
                Text(a.subtitle, style: TextStyle(fontSize: 11, color: textSec),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(a.timeAgo, style: TextStyle(fontSize: 10, color: textSec)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(a.category, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
                ),
              ]),
            ]),
          );
        }),
      ]),
    );
  }

  // ── Activity History sheet ────────────────────────────────────
  void _showActivityHistory(BuildContext context, bool isDark, Color textPri, Color textSec, Color cardBg, Color border) {
    final userId = AuthService.currentUserId;
    final activities = AppDataStore.instance.activitiesForUser(userId);
    const catColors = {
      'Booking': Color(0xFF1D9E75),
      'Message': Color(0xFF3B5FD4),
      'Payment': Color(0xFFD4A017),
      'Review':  Color(0xFF7F77DD),
    };
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
        builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(children: [
              Text('Activity History', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: textPri)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text('${activities.length} events', style: const TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 16),
            activities.isEmpty
              ? Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.history, size: 48, color: textSec),
                  const SizedBox(height: 12),
                  Text('No activity yet', style: TextStyle(color: textSec, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text('Your bookings, messages and more will appear here', style: TextStyle(color: textSec, fontSize: 12), textAlign: TextAlign.center),
                ])))
              : Expanded(child: ListView.builder(
                  controller: ctrl,
                  itemCount: activities.length,
                  itemBuilder: (_, i) {
                    final a = activities[i];
                    final color = catColors[a.category] ?? AppColors.gold;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A2035) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border, width: 0.5),
                      ),
                      child: Row(children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text(a.icon, style: const TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(a.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
                          const SizedBox(height: 2),
                          Text(a.subtitle, style: TextStyle(fontSize: 11, color: textSec),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        ])),
                        const SizedBox(width: 8),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(a.timeAgo, style: TextStyle(fontSize: 10, color: textSec)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(a.category, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
                          ),
                        ]),
                      ]),
                    );
                  },
                )),
          ]),
        ),
      ),
    );
  }

  // ── Drawer ────────────────────────────────────────────────────
  Widget _buildDrawer(bool isDark, Color textPri, Color textSec, Color cardBg, Color border) {
    void go(Widget screen) { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => screen)); }

    final navItems = [
      _DrawerItem(icon: Icons.home_outlined,             label: 'Home',           onTap: () { Navigator.pop(context); setState(() => _selectedTab = 0); }),
      _DrawerItem(icon: Icons.search_outlined,           label: 'Search Cars',    onTap: () => go(const SearchScreen())),
      _DrawerItem(icon: Icons.business_outlined,         label: 'Companies',      onTap: () => go(const CompaniesScreen())),
      _DrawerItem(icon: Icons.calendar_today_outlined,   label: 'My Bookings',    onTap: () { Navigator.pop(context); widget.isUserMode ? setState(() => _selectedTab = 1) : GuestGate.show(context, reason: 'Sign in to view your bookings.'); }),
      _DrawerItem(icon: Icons.favorite_outline,          label: 'Favorites',      onTap: () { Navigator.pop(context); widget.isUserMode ? setState(() => _selectedTab = 2) : GuestGate.show(context, reason: 'Sign in to view your favourites.'); }),
      _DrawerItem(icon: Icons.chat_bubble_outline,       label: 'Messages',       onTap: () { Navigator.pop(context); widget.isUserMode ? setState(() => _selectedTab = 3) : GuestGate.show(context, reason: 'Sign in to access messages.'); }),
      _DrawerItem(icon: Icons.person_outline,            label: 'Profile',        onTap: () { Navigator.pop(context); widget.isUserMode ? setState(() => _selectedTab = 4) : GuestGate.show(context, reason: 'Sign in to view your profile.'); }),
      if (widget.isUserMode) _DrawerItem(icon: Icons.history_rounded,  label: 'Activity History', onTap: () { Navigator.pop(context); _showActivityHistory(context, isDark, textPri, textSec, cardBg, border); }),
      _DrawerItem(icon: Icons.settings_outlined,         label: 'Settings',       onTap: () => go(const SettingsScreen())),
      _DrawerItem(icon: Icons.help_outline,              label: 'Help & Support', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen())); }),
    ];

    return Drawer(
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: SafeArea(child: Column(children: [
        // Profile header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border, width: 0.5))),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 1.5),
              ),
              child: const Center(child: Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.gold))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Alex Johnson', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 2),
              Text('alex@email.com', style: TextStyle(fontSize: 12, color: textSec)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF1D9E75).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: const Text('Verified', style: TextStyle(fontSize: 10, color: Color(0xFF1D9E75), fontWeight: FontWeight.w600)),
              ),
            ])),
          ]),
        ),
        // Theme toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
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
        // ── Deals strip in drawer ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Deals & Offers', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri)),
              GestureDetector(
                onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())); },
                child: const Text('See All >', style: TextStyle(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _DrawerDealChip(title: '20% OFF',    sub: 'Economy cars',   color: const Color(0xFF1D9E75), icon: Icons.local_offer_outlined,  onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(initialCategory: 'Economy', fromDeal: true))); }),
                  const SizedBox(width: 8),
                  _DrawerDealChip(title: 'FREE GPS',   sub: 'On SUV bookings',color: const Color(0xFF3B5FD4), icon: Icons.gps_fixed,             onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(initialCategory: 'SUV',     fromDeal: true))); }),
                  const SizedBox(width: 8),
                  _DrawerDealChip(title: 'CHAUFFEUR',  sub: 'Luxury with driver', color: const Color(0xFF7F77DD), icon: Icons.drive_eta_outlined, onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(initialCategory: 'Luxury',  fromDeal: true))); }),
                  const SizedBox(width: 8),
                  _DrawerDealChip(title: 'GROUP DEAL', sub: 'Vans & minibuses',color: const Color(0xFFD85A30), icon: Icons.group_outlined,        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(initialCategory: 'Van',     fromDeal: true))); }),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: border, height: 1),
          ]),
        ),

        // Nav items
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: navItems.length,
          itemBuilder: (_, i) {
            final item = navItems[i];
            final isActive = (i == 0 && _selectedTab == 0) ||
                (i == 3 && _selectedTab == 1) ||
                (i == 4 && _selectedTab == 2) ||
                (i == 5 && _selectedTab == 3) ||
                (i == 6 && _selectedTab == 4);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
              decoration: BoxDecoration(
                color: isActive ? AppColors.gold.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(item.icon, color: isActive ? AppColors.gold : textSec, size: 20),
                title: Text(item.label, style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, color: isActive ? AppColors.gold : textPri)),
                trailing: isActive ? Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2))) : null,
                onTap: item.onTap,
                dense: true,
                horizontalTitleGap: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
        )),
        // Logout
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.redAccent.withOpacity(0.2), width: 0.5),
          ),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
            title: const Text('Log out', style: TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.w500)),
            onTap: () { AuthService.logout(); Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false); },
            dense: true,
          ),
        ),
      ])),
    );
  }

  // ── Bottom nav ─────────────────────────────────────────────────
  Widget _buildBottomNav(bool isDark, Color textSec) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE), width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (i) {
          if (!widget.isUserMode && i > 0) {
            GuestGate.show(context, reason: _gateReason(i));
          } else {
            setState(() => _selectedTab = i);
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: textSec,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        type: BottomNavigationBarType.fixed,
        items: _navItems,
      ),
    );
  }
}

  // ── Guest login banner ────────────────────────────────────────
  Widget _buildGuestBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/login'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1F3C), Color(0xFF252B4E)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.8),
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_open_rounded, color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('You\'re browsing as guest',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            SizedBox(height: 2),
            Text('Sign in to book, save cars & more',
              style: TextStyle(color: Color(0xFF8B91A8), fontSize: 11)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Log In',
              style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }


// ─────────────────────────────────────────────
//  CATEGORY CARD
// ─────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final CarCategory cat;
  final bool isDark;
  final Color textPri, textSec, cardBg;
  const _CategoryCard({required this.cat, required this.isDark, required this.textPri, required this.textSec, required this.cardBg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
    decoration: BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE), width: 0.5),
    ),
    child: Column(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: cat.iconBg.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
        child: Icon(cat.icon, color: cat.iconBg, size: 22),
      ),
      const SizedBox(height: 8),
      Text(cat.name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textPri)),
      const SizedBox(height: 2),
      Text(cat.price, style: TextStyle(fontSize: 9, color: textSec)),
    ]),
  );
}

// ─────────────────────────────────────────────
//  CAR CARD
// ─────────────────────────────────────────────
class _CarCard extends StatelessWidget {
  final CarItem car;
  final bool isDark;
  final Color textPri, textSec, cardBg, border;
  final VoidCallback onFavTap;
  const _CarCard({required this.car, required this.isDark, required this.textPri, required this.textSec, required this.cardBg, required this.border, required this.onFavTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailScreen(
        carName: car.name, company: 'DriveKigali',
        price: car.price.replaceAll(' / day', ''),
        category: 'SUV', rating: 4.8, reviews: 24,
        seats: car.seats, fuel: car.fuel, transmission: car.transmission,
      ))),
      child: Container(
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            Container(
              height: 76,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(child: Icon(Icons.directions_car, size: 48, color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06))),
            ),
            Positioned(top: 8, right: 8,
              child: GestureDetector(
                onTap: onFavTap,
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: isDark ? AppColors.darkCard : Colors.white, shape: BoxShape.circle, border: Border.all(color: border, width: 0.5)),
                  child: Icon(car.isFavorite ? Icons.favorite : Icons.favorite_outline, size: 15, color: car.isFavorite ? Colors.redAccent : textSec),
                ),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(car.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(car.price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
              const SizedBox(height: 6),
              Row(children: [
                _SpecChip(icon: Icons.people_outline,             label: '${car.seats}',                      textSec: textSec),
                const SizedBox(width: 6),
                _SpecChip(icon: Icons.settings_outlined,          label: car.transmission.substring(0, 4),    textSec: textSec),
                const SizedBox(width: 6),
                _SpecChip(icon: Icons.local_gas_station_outlined, label: car.fuel.substring(0, 3),            textSec: textSec),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final IconData icon; final String label; final Color textSec;
  const _SpecChip({required this.icon, required this.label, required this.textSec});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 11, color: textSec),
    const SizedBox(width: 2),
    Text(label, style: TextStyle(fontSize: 10, color: textSec)),
  ]);
}

class _DrawerItem {
  final IconData icon; final String label; final VoidCallback onTap;
  const _DrawerItem({required this.icon, required this.label, required this.onTap});
}

// ── Drawer deal chip ──────────────────────────────────────────
class _DrawerDealChip extends StatelessWidget {
  final String title, sub;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _DrawerDealChip({required this.title, required this.sub, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 0.8),
        ),
        child: Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 7),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 9, color: color.withOpacity(0.7), height: 1.2), maxLines: 2),
          ])),
        ]),
      ),
    );
  }
}

String _gateReason(int tab) {
  switch (tab) {
    case 1: return 'Sign in to view your booking history.';
    case 2: return 'Sign in to save your favourite cars.';
    case 3: return 'Sign in to chat with rental companies.';
    case 4: return 'Sign in to manage your profile.';
    default: return 'Sign in to access this feature.';
  }
}

// ── Guest lock tab placeholder ───────────────────────────────
class _GuestLockTab extends StatelessWidget {
  final IconData icon;
  final String title, reason;
  final String pendingRoute;
  const _GuestLockTab({required this.icon, required this.title, required this.reason, required this.pendingRoute});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg   : AppColors.lightBg;
    final textPri = isDark ? Colors.white        : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8) : const Color(0xFF6B7280);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, automaticallyImplyLeading: false,
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
      ),
      body: Center(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1), shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1.5)),
            child: Icon(icon, color: AppColors.gold, size: 36),
          ),
          const SizedBox(height: 20),
          Text('Sign in required',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
          const SizedBox(height: 8),
          Text(reason, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: textSec, height: 1.5)),
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              AuthService.setPending(pendingRoute);
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold, foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          )),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              AuthService.setPending(pendingRoute);
              Navigator.pushNamed(context, '/register');
            },
            child: const Text('Create Account',
              style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ]),
      )),
    );
  }
}

