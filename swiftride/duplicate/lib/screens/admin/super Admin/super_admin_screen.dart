// lib/screens/admin/super_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart' show AppColors;
import 'package:swiftride/screens/guest/companies_screen.dart' show RentalCompany, CompanyCar, allCompanies;
import 'package:swiftride/screens/admin/company_admin_screen.dart' show CompanyAdminScreen;
import 'package:swiftride/services/auth_service.dart';

// ── Fake data ─────────────────────────────────────────────────
final _kUsers = [
  _User('Cameron One',    'C1@gmail.com',      '+250 788 000 001', 'Active',   12, 1240.0, 'Jan 2024', true),
  _User('Alice Mugisha',  'alice@email.com',   '+250 788 111 222', 'Active',    8,  890.0, 'Mar 2024', false),
  _User('Bob Nkusi',      'bob@email.com',     '+250 788 333 444', 'Suspended', 2,  120.0, 'Jun 2024', false),
  _User('Diana Uwase',    'diana@email.com',   '+250 788 555 666', 'Active',   21, 3200.0, 'Nov 2023', false),
  _User('Eric Habimana',  'eric@email.com',    '+250 788 777 888', 'Inactive',  0,    0.0, 'Sep 2024', false),
  _User('Fiona Ingabire', 'fiona@email.com',   '+250 788 999 000', 'Active',    5,  670.0, 'Feb 2024', false),
];

final _kCompanies = [
  _Company('DriveKigali',   4, 28, 156, 18200.0, 'Active',  'KG 7 Ave, Kigali',    4.9),
  _Company('SafariWheels',  3, 12,  89, 11400.0, 'Active',  'KN 3 Rd, Remera',     4.8),
  _Company('LuxDrive',      6,  8,  44,  9800.0, 'Active',  'KG 11 Ave, Nyarutarama',4.7),
  _Company('RwandaRide',    2,  5,  21,  2400.0, 'Pending', 'KN 5 Rd, Nyamirambo', 4.5),
  _Company('VanGo',         1,  6,  12,  1100.0, 'Suspended','KG 9 Ave, Gisozi',   3.9),
];

final _kBookings = [
  _Booking('SW240001', 'Cameron One',   'Toyota RAV4',   'DriveKigali',  'May 24','May 27', 135.0, 'Active'),
  _Booking('SW240002', 'Diana Uwase',   'BMW 5 Series',  'SafariWheels', 'Jun 1', 'Jun 3',  180.0, 'Upcoming'),
  _Booking('SW240003', 'Alice Mugisha', 'Range Rover',   'LuxDrive',     'Apr 10','Apr 12', 220.0, 'Completed'),
  _Booking('SW240004', 'Bob Nkusi',     'Toyota Camry',  'DriveKigali',  'Mar 5', 'Mar 7',   90.0, 'Cancelled'),
  _Booking('SW240005', 'Fiona Ingabire','Mercedes GLE',  'LuxDrive',     'Jun 8', 'Jun 10', 200.0, 'Active'),
  _Booking('SW240006', 'Eric Habimana', 'Honda CR-V',    'RwandaRide',   'May 1', 'May 3',   76.0, 'Completed'),
];

// ─────────────────────────────────────────────────────────────
class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});
  @override State<SuperAdminScreen> createState() => _State();
}

class _State extends State<SuperAdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tc;
  int _tab = 0;

  @override void initState() { super.initState(); _tc = TabController(length: 4, vsync: this); _tc.addListener(() => setState(() => _tab = _tc.index)); }
  @override void dispose()   { _tc.dispose(); super.dispose(); }

  // Stats
  int    get _totalUsers     => _kUsers.length;
  int    get _activeUsers    => _kUsers.where((u) => u.status == 'Active').length;
  int    get _totalCompanies => _kCompanies.length;
  int    get _totalBookings  => _kBookings.length;
  double get _totalRevenue   => _kBookings.fold(0.0, (s, b) => s + b.amount);

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);
    final card    = isDark ? const Color(0xFF141828) : Colors.white;
    final border  = isDark ? const Color(0xFF252B3E) : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      drawer: _buildDrawer(isDark, card, border, textPri, textSec),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        leading: Builder(builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        )),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: const Text('SUPER', style: TextStyle(color: AppColors.gold, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ),
          const SizedBox(width: 8),
          const Text('SwiftRide Admin', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () => _showNotifications(context, card, border, textPri, textSec)),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(radius: 15, backgroundColor: AppColors.gold,
              child: const Text('SA', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w800))),
          ),
        ],
        bottom: TabBar(
          controller: _tc,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: const Color(0xFF8B91A8),
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined, size: 18), text: 'Dashboard'),
            Tab(icon: Icon(Icons.people_outlined, size: 18),    text: 'Users'),
            Tab(icon: Icon(Icons.business_outlined, size: 18),  text: 'Companies'),
            Tab(icon: Icon(Icons.receipt_long_outlined, size: 18), text: 'Bookings'),
          ],
        ),
      ),
      body: TabBarView(controller: _tc, children: [
        _dashboardTab(isDark, bg, card, border, textPri, textSec),
        _usersTab(isDark, bg, card, border, textPri, textSec),
        _companiesTab(isDark, bg, card, border, textPri, textSec),
        _bookingsTab(isDark, bg, card, border, textPri, textSec),
      ]),
    );
  }

  // ══════════════════════════════════════════════
  // DASHBOARD TAB
  // ══════════════════════════════════════════════
  Widget _dashboardTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Welcome
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1A1F3C), Color(0xFF252B4E)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withOpacity(0.2), width: 0.8)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Good morning,', style: TextStyle(color: Color(0xFF8B91A8), fontSize: 12)),
            const Text('Super Admin', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('SwiftRide platform overview', style: TextStyle(color: AppColors.gold.withOpacity(0.8), fontSize: 12)),
          ])),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.gold, size: 28)),
        ]),
      ),

      const SizedBox(height: 16),

      // KPI grid
      Text('Platform Overview', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),
      GridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.5,
        children: [
          _KPI(label: 'Total Users',     value: '$_totalUsers',     icon: Icons.people_rounded,          color: const Color(0xFF3B5FD4), sub: '$_activeUsers active', card: card, border: border, textPri: textPri, textSec: textSec),
          _KPI(label: 'Companies',       value: '$_totalCompanies', icon: Icons.business_rounded,        color: const Color(0xFF7F77DD), sub: '4 active',             card: card, border: border, textPri: textPri, textSec: textSec),
          _KPI(label: 'Total Bookings',  value: '$_totalBookings',  icon: Icons.receipt_long_rounded,    color: const Color(0xFF1D9E75), sub: '2 active now',        card: card, border: border, textPri: textPri, textSec: textSec),
          _KPI(label: 'Revenue',         value: '\$${_totalRevenue.toInt()}', icon: Icons.attach_money_rounded, color: AppColors.gold,   sub: 'all time',            card: card, border: border, textPri: textPri, textSec: textSec),
        ],
      ),

      const SizedBox(height: 20),

      // Recent activity
      Text('Recent Activity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),
      ...[
        (Icons.person_add_rounded,      const Color(0xFF3B5FD4), 'New user registered',       'Alice Mugisha joined',        '2 min ago'),
        (Icons.receipt_rounded,         const Color(0xFF1D9E75), 'Booking confirmed',          'SW240005 · \$200',            '15 min ago'),
        (Icons.business_rounded,        const Color(0xFF7F77DD), 'Company pending approval',  'RwandaRide submitted docs',   '1 hr ago'),
        (Icons.cancel_rounded,          const Color(0xFFD85A30), 'Booking cancelled',          'SW240004 by Bob Nkusi',       '2 hr ago'),
        (Icons.star_rounded,            AppColors.gold,          'Review posted',              '5★ for DriveKigali',          '3 hr ago'),
      ].map((a) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
        child: Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: (a.$2 as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
            child: Icon(a.$1 as IconData, color: a.$2 as Color, size: 17)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.$3 as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
            Text(a.$4 as String, style: TextStyle(fontSize: 11, color: textSec)),
          ])),
          Text(a.$5 as String, style: TextStyle(fontSize: 10, color: textSec)),
        ]),
      )),

      const SizedBox(height: 20),

      // Pending actions
      Text('Needs Attention', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),
      ...[
        (Icons.pending_rounded,         const Color(0xFFD85A30), 'RwandaRide approval pending', '1 company awaiting review'),
        (Icons.warning_amber_rounded,   const Color(0xFFE8C04A), 'Bob Nkusi account suspended', 'Review suspension reason'),
        (Icons.support_agent_rounded,   const Color(0xFF3B5FD4), '3 support tickets open',      'Respond to user queries'),
      ].map((a) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: (a.$2 as Color).withOpacity(0.3), width: 0.8)),
        child: Row(children: [
          Icon(a.$1 as IconData, color: a.$2 as Color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.$3 as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
            Text(a.$4 as String, style: TextStyle(fontSize: 11, color: textSec)),
          ])),
          Icon(Icons.chevron_right_rounded, color: textSec, size: 18),
        ]),
      )),

      const SizedBox(height: 16),
    ]));
  }

  // ══════════════════════════════════════════════
  // USERS TAB
  // ══════════════════════════════════════════════
  Widget _usersTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec) {
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
          child: TextField(
            style: TextStyle(color: textPri, fontSize: 13),
            decoration: InputDecoration(hintText: 'Search users…', hintStyle: TextStyle(color: textSec, fontSize: 13),
              border: InputBorder.none, prefixIcon: Icon(Icons.search, color: textSec, size: 18)),
          ),
        )),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.add, color: Colors.black, size: 20)),
      ])),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _kUsers.length,
        itemBuilder: (_, i) {
          final u = _kUsers[i];
          return GestureDetector(
            onTap: () => _showUserDetail(context, u, isDark, card, border, textPri, textSec),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
              child: Row(children: [
                CircleAvatar(radius: 22, backgroundColor: AppColors.gold.withOpacity(0.15),
                  child: Text(u.name.split(' ').map((e) => e[0]).take(2).join(),
                    style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w700))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(u.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
                    if (u.isSuperAdmin) ...[
                      const SizedBox(width: 6),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(5)),
                        child: const Text('SUPER', style: TextStyle(color: AppColors.gold, fontSize: 8, fontWeight: FontWeight.w800))),
                    ],
                  ]),
                  Text(u.email, style: TextStyle(fontSize: 11, color: textSec)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text('${u.trips} trips', style: TextStyle(fontSize: 10, color: textSec)),
                    const SizedBox(width: 8),
                    Text('· \$${u.spent.toInt()} spent', style: TextStyle(fontSize: 10, color: textSec)),
                  ]),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  _StatusBadge(u.status),
                  const SizedBox(height: 6),
                  Icon(Icons.chevron_right_rounded, color: textSec, size: 16),
                ]),
              ]),
            ),
          );
        },
      )),
    ]);
  }

  // ══════════════════════════════════════════════
  // COMPANIES TAB
  // ══════════════════════════════════════════════
  Widget _companiesTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${_kCompanies.length} companies', style: TextStyle(fontSize: 13, color: textSec)),
          ElevatedButton.icon(
            onPressed: () => _showAddCompany(context, card, border, textPri, textSec),
            icon: const Icon(Icons.add, size: 14), label: const Text('Add Company'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold, foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0, textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
        ])),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _kCompanies.length,
        itemBuilder: (_, i) {
          final c = _kCompanies[i];
          final statusColor = c.status == 'Active'
              ? const Color(0xFF1D9E75)
              : c.status == 'Pending' ? const Color(0xFFE8C04A) : const Color(0xFFD85A30);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
            child: Column(children: [
              Row(children: [
                Container(width: 46, height: 46,
                  decoration: BoxDecoration(color: const Color(0xFF3B5FD4).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(c.name.substring(0,2).toUpperCase(),
                    style: const TextStyle(color: Color(0xFF3B5FD4), fontSize: 16, fontWeight: FontWeight.w800)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPri)),
                  Text(c.location, style: TextStyle(fontSize: 11, color: textSec), overflow: TextOverflow.ellipsis),
                ])),
                GestureDetector(
                  onTap: () => _showCompanyDetail(context, c, isDark, card, border, textPri, textSec),
                  child: _StatusBadge(c.status)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _MiniStat(label: 'Agents',   value: '\${c.agents}',   textPri: textPri, textSec: textSec),
                _MiniStat(label: 'Cars',     value: '\${c.cars}',     textPri: textPri, textSec: textSec),
                _MiniStat(label: 'Bookings', value: '\${c.bookings}', textPri: textPri, textSec: textSec),
                _MiniStat(label: 'Revenue',  value: '\$\${c.revenue.toInt()}', textPri: textPri, textSec: textSec),
                _MiniStat(label: 'Rating',   value: '\${c.rating}★',  textPri: textPri, textSec: textSec),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to company admin panel for this company
                    final match = allCompanies.where((co) => co.name.toLowerCase().contains(c.name.toLowerCase().split(' ')[0])).toList();
                    final company = match.isNotEmpty ? match.first : allCompanies.first;
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyAdminScreen(company: company)));
                  },
                  icon: const Icon(Icons.admin_panel_settings_rounded, size: 13),
                  label: const Text('Admin Panel'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gold),
                    foregroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _showCompanyDetail(context, c, isDark, card, border, textPri, textSec),
                  icon: Icon(c.status == 'Active' ? Icons.block_rounded : Icons.check_circle_outline_rounded, size: 13),
                  label: Text(c.status == 'Active' ? 'Suspend' : c.status == 'Pending' ? 'Approve' : 'Activate'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: c.status == 'Active' ? const Color(0xFFD85A30) : const Color(0xFF1D9E75)),
                    foregroundColor: c.status == 'Active' ? const Color(0xFFD85A30) : const Color(0xFF1D9E75),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)))),
              ]),
            ]),
          );
        },
      )),
    ]);
  }

  // ══════════════════════════════════════════════
  // BOOKINGS TAB
  // ══════════════════════════════════════════════
  Widget _bookingsTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _kBookings.length,
      itemBuilder: (_, i) {
        final b = _kBookings[i];
        final sc = _statusColor(b.status);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
          child: Column(children: [
            Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.directions_car_rounded, color: sc, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.car, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
                Text('${b.user} · ${b.company}', style: TextStyle(fontSize: 11, color: textSec)),
              ])),
              _StatusBadge(b.status),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.confirmation_number_outlined, size: 12, color: textSec),
              const SizedBox(width: 5),
              Text(b.ref, style: TextStyle(fontSize: 11, color: textSec)),
              const Spacer(),
              Icon(Icons.calendar_today_outlined, size: 12, color: textSec),
              const SizedBox(width: 5),
              Text('${b.from} → ${b.to}', style: TextStyle(fontSize: 11, color: textSec)),
              const Spacer(),
              Text('\$${b.amount.toInt()}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.gold)),
            ]),
          ]),
        );
      },
    );
  }

  // ── Side drawer ───────────────────────────────────────────────
  Widget _buildDrawer(bool isDark, Color card, Color border, Color textPri, Color textSec) {
    return Drawer(backgroundColor: const Color(0xFF0A0E1A), child: SafeArea(child: Column(children: [
      const SizedBox(height: 20),
      CircleAvatar(radius: 32, backgroundColor: AppColors.gold.withOpacity(0.15),
        child: const Text('SA', style: TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.w800))),
      const SizedBox(height: 10),
      const Text('Super Admin', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      const Text('admin@swiftride.rw', style: TextStyle(color: Color(0xFF8B91A8), fontSize: 12)),
      const SizedBox(height: 6),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: const Text('SUPER ADMIN', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2))),
      const SizedBox(height: 20),
      const Divider(color: Color(0xFF252B3E)),
      ...[
        (Icons.dashboard_outlined,        'Dashboard',       0),
        (Icons.people_outlined,           'Users',           1),
        (Icons.business_outlined,         'Companies',       2),
        (Icons.receipt_long_outlined,     'Bookings',        3),
        (Icons.bar_chart_rounded,         'Analytics',      -1),
        (Icons.notifications_outlined,    'Notifications',  -1),
        (Icons.settings_outlined,         'System Settings',-1),
      ].map((i) => ListTile(
        leading: Icon(i.$1 as IconData, color: _tab == i.$3 ? AppColors.gold : const Color(0xFF8B91A8), size: 20),
        title: Text(i.$2 as String, style: TextStyle(color: _tab == i.$3 ? AppColors.gold : Colors.white, fontSize: 14,
          fontWeight: _tab == i.$3 ? FontWeight.w700 : FontWeight.w400)),
        onTap: () {
          Navigator.pop(context);
          if ((i.$3 as int) >= 0) { _tc.animateTo(i.$3 as int); setState(() => _tab = i.$3 as int); }
        },
        selected: _tab == i.$3,
        selectedTileColor: AppColors.gold.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        dense: true,
      )),
      const Spacer(),
      const Divider(color: Color(0xFF252B3E)),
      ListTile(
        leading: const Icon(Icons.logout_rounded, color: Color(0xFFD85A30), size: 20),
        title: const Text('Sign Out', style: TextStyle(color: Color(0xFFD85A30), fontSize: 14)),
        onTap: () => { AuthService.logout(); { AuthService.logout(); Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false); }; },
        dense: true,
      ),
      const SizedBox(height: 16),
    ])));
  }

  // ── Detail sheets ──────────────────────────────────────────────
  void _showUserDetail(BuildContext context, _User u, bool isDark, Color card, Color border, Color textPri, Color textSec) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75, minChildSize: 0.4, maxChildSize: 0.92,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            Container(margin: const EdgeInsets.only(top: 12, bottom: 8), width: 40, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
            Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: [
              Row(children: [
                CircleAvatar(radius: 28, backgroundColor: AppColors.gold.withOpacity(0.15),
                  child: Text(u.name.split(' ').map((e) => e[0]).take(2).join(),
                    style: const TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.w700))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(u.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPri)),
                  Text(u.email, style: TextStyle(fontSize: 12, color: textSec)),
                  Text(u.phone, style: TextStyle(fontSize: 12, color: textSec)),
                ])),
                _StatusBadge(u.status),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _MiniStat(label: 'Trips',  value: '${u.trips}',          textPri: textPri, textSec: textSec),
                _MiniStat(label: 'Spent',  value: '\$${u.spent.toInt()}',textPri: textPri, textSec: textSec),
                _MiniStat(label: 'Since',  value: u.since,               textPri: textPri, textSec: textSec),
              ]),
              const SizedBox(height: 16),
              Text('Actions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 10),
              Wrap(spacing: 10, runSpacing: 10, children: [
                _ActionBtn(label: 'View Bookings', icon: Icons.receipt_long_outlined,  color: const Color(0xFF3B5FD4), onTap: () {}),
                _ActionBtn(label: u.status == 'Suspended' ? 'Unsuspend' : 'Suspend',
                  icon: u.status == 'Suspended' ? Icons.check_circle_outline : Icons.block_rounded,
                  color: u.status == 'Suspended' ? const Color(0xFF1D9E75) : const Color(0xFFD85A30), onTap: () => Navigator.pop(context)),
                _ActionBtn(label: 'Reset Password', icon: Icons.lock_reset_rounded, color: const Color(0xFF7F77DD), onTap: () {}),
                _ActionBtn(label: 'Send Message',   icon: Icons.mail_outline_rounded, color: AppColors.gold,         onTap: () {}),
              ]),
            ])),
          ]),
        ),
      ),
    );
  }

  void _showCompanyDetail(BuildContext context, _Company c, bool isDark, Color card, Color border, Color textPri, Color textSec) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75, minChildSize: 0.4, maxChildSize: 0.92,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            Container(margin: const EdgeInsets.only(top: 12, bottom: 8), width: 40, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
            Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: [
              Row(children: [
                Container(width: 52, height: 52,
                  decoration: BoxDecoration(color: const Color(0xFF3B5FD4).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(c.name.substring(0,2).toUpperCase(),
                    style: const TextStyle(color: Color(0xFF3B5FD4), fontSize: 18, fontWeight: FontWeight.w800)))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPri)),
                  Text(c.location, style: TextStyle(fontSize: 12, color: textSec)),
                  Text('Rating: ${c.rating}★', style: const TextStyle(fontSize: 12, color: AppColors.gold)),
                ])),
                _StatusBadge(c.status),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _MiniStat(label: 'Agents',   value: '${c.agents}',         textPri: textPri, textSec: textSec),
                _MiniStat(label: 'Cars',     value: '${c.cars}',           textPri: textPri, textSec: textSec),
                _MiniStat(label: 'Bookings', value: '${c.bookings}',       textPri: textPri, textSec: textSec),
                _MiniStat(label: 'Revenue',  value: '\$${c.revenue.toInt()}', textPri: textPri, textSec: textSec),
              ]),
              const SizedBox(height: 16),
              Text('Actions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 10),
              Wrap(spacing: 10, runSpacing: 10, children: [
                if (c.status == 'Pending')
                  _ActionBtn(label: 'Approve',   icon: Icons.check_circle_outline, color: const Color(0xFF1D9E75), onTap: () => Navigator.pop(context)),
                _ActionBtn(label: c.status == 'Suspended' ? 'Unsuspend' : 'Suspend',
                  icon: c.status == 'Suspended' ? Icons.check_circle_outline : Icons.block_rounded,
                  color: c.status == 'Suspended' ? const Color(0xFF1D9E75) : const Color(0xFFD85A30), onTap: () => Navigator.pop(context)),
                _ActionBtn(label: 'View Fleet',    icon: Icons.directions_car_rounded,  color: const Color(0xFF3B5FD4), onTap: () {}),
                _ActionBtn(label: 'View Bookings', icon: Icons.receipt_long_outlined,   color: const Color(0xFF7F77DD), onTap: () {}),
              ]),
            ])),
          ]),
        ),
      ),
    );
  }

  void _showAddCompany(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    final nameC = TextEditingController();
    final locC  = TextEditingController();
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Text('Register Company', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
          const SizedBox(height: 16),
          _SuperField('Company Name', 'e.g. DriveKigali', nameC, textPri, textSec),
          const SizedBox(height: 10),
          _SuperField('Location', 'KG 7 Ave, Kigali', locC, textPri, textSec),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(backgroundColor: const Color(0xFF1D9E75), content: Text('Company ${nameC.text} registered'))); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Register', style: TextStyle(fontWeight: FontWeight.w700)))),
        ]))));
  }

    void _showNotifications(BuildContext context, Color card, Color border, Color textPri, Color textSec) {
    showModalBottomSheet(context: context, backgroundColor: card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Row(children: [
          Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPri)),
          const Spacer(),
          Text('Mark all read', style: const TextStyle(color: AppColors.gold, fontSize: 12)),
        ])),
        Divider(color: border, height: 1),
        ...[
          (Icons.person_add_rounded,      const Color(0xFF3B5FD4), 'New user: Alice Mugisha',         '2 min ago'),
          (Icons.business_rounded,        const Color(0xFFE8C04A), 'RwandaRide pending approval',     '1 hr ago'),
          (Icons.receipt_rounded,         const Color(0xFF1D9E75), 'Booking SW240005 confirmed',      '15 min ago'),
        ].map((n) => ListTile(
          leading: Container(width: 36, height: 36,
            decoration: BoxDecoration(color: (n.$2 as Color).withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(n.$1 as IconData, color: n.$2 as Color, size: 17)),
          title: Text(n.$3 as String, style: TextStyle(fontSize: 13, color: textPri)),
          subtitle: Text(n.$4 as String, style: TextStyle(fontSize: 11, color: textSec)),
          dense: true,
        )),
        const SizedBox(height: 16),
      ]),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Active':    return const Color(0xFF1D9E75);
      case 'Upcoming':  return const Color(0xFF3B5FD4);
      case 'Completed': return const Color(0xFF8B91A8);
      case 'Cancelled': return const Color(0xFFD85A30);
      case 'Suspended': return const Color(0xFFD85A30);
      case 'Pending':   return const Color(0xFFE8C04A);
      default:          return const Color(0xFF8B91A8);
    }
  }
}

// ── Data models ───────────────────────────────────────────────
class _User {
  final String name, email, phone, status, since;
  final int trips; final double spent; final bool isSuperAdmin;
  const _User(this.name, this.email, this.phone, this.status, this.trips, this.spent, this.since, this.isSuperAdmin);
}

class _Company {
  final String name, status, location; final int agents, cars, bookings; final double revenue, rating;
  const _Company(this.name, this.agents, this.cars, this.bookings, this.revenue, this.status, this.location, this.rating);
}

class _Booking {
  final String ref, user, car, company, from, to, status; final double amount;
  const _Booking(this.ref, this.user, this.car, this.company, this.from, this.to, this.amount, this.status);
}

// ── Reusable widgets ──────────────────────────────────────────
class _KPI extends StatelessWidget {
  final String label, value, sub; final IconData icon; final Color color, card, border, textPri, textSec;
  const _KPI({required this.label, required this.value, required this.icon, required this.color,
    required this.sub, required this.card, required this.border, required this.textPri, required this.textSec});
  @override Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 17)),
        const Spacer(),
        Icon(Icons.trending_up_rounded, color: color, size: 14),
      ]),
      const Spacer(),
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPri)),
      Text(label,  style: TextStyle(fontSize: 11, color: textSec)),
      Text(sub,    style: TextStyle(fontSize: 9,  color: color)),
    ]),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);
  Color get _color {
    switch (status) {
      case 'Active':    return const Color(0xFF1D9E75);
      case 'Upcoming':  return const Color(0xFF3B5FD4);
      case 'Completed': return const Color(0xFF8B91A8);
      case 'Cancelled': case 'Suspended': return const Color(0xFFD85A30);
      case 'Inactive':  return const Color(0xFF8B91A8);
      case 'Pending':   return const Color(0xFFE8C04A);
      default:          return const Color(0xFF8B91A8);
    }
  }
  @override Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _color)));
}

class _MiniStat extends StatelessWidget {
  final String label, value; final Color textPri, textSec;
  const _MiniStat({required this.label, required this.value, required this.textPri, required this.textSec});
  @override Widget build(BuildContext c) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPri)),
    Text(label,  style: TextStyle(fontSize: 9, color: textSec)),
  ]));
}

class _ActionBtn extends StatelessWidget {
  final String label; final IconData icon; final Color color; final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});
  @override Widget build(BuildContext c) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    ),
  );
}

Widget _SuperField(String label, String hint, TextEditingController ctrl, Color textPri, Color textSec) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 11, color: textSec, fontWeight: FontWeight.w500)),
    const SizedBox(height: 4),
    TextField(
      controller: ctrl,
      style: TextStyle(fontSize: 13, color: textPri),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textSec, fontSize: 13),
        filled: true, fillColor: const Color(0xFF1C2236),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
  ]);
}


// ─────────────────────────────────────────────
//  SUPER ADMIN EXTENSIONS
//  Extra methods patched in below the main class
// ─────────────────────────────────────────────

// Mixin-style global helpers used by SuperAdminScreen
// (These are standalone functions so the existing file compiles without edits)

Widget buildSuperAdminCompanyTile({
  required BuildContext context,
  required Map<String, dynamic> c,
  required bool isDark,
  required Color card,
  required Color border,
  required Color textPri,
  required Color textSec,
  required VoidCallback onStatusToggle,
  required VoidCallback onViewAdmin,
}) {
  final statusColor = c['status'] == 'Active'
      ? const Color(0xFF1D9E75)
      : c['status'] == 'Pending'
          ? const Color(0xFFE8C04A)
          : const Color(0xFFD85A30);

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(
            (c['name'] as String).substring(0, 2).toUpperCase(),
            style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w800)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c['name'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPri)),
          Text('${c['cars']} cars · ${c['bookings']} bookings', style: TextStyle(fontSize: 11, color: textSec)),
        ])),
        GestureDetector(
          onTap: onStatusToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(c['status'] as String,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)))),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: OutlinedButton.icon(
          onPressed: onViewAdmin,
          icon: const Icon(Icons.admin_panel_settings_rounded, size: 14),
          label: const Text('Admin Panel'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.gold),
            foregroundColor: AppColors.gold,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)))),
        const SizedBox(width: 10),
        Expanded(child: OutlinedButton.icon(
          onPressed: onStatusToggle,
          icon: Icon(c['status'] == 'Active' ? Icons.block_rounded : Icons.check_circle_outline_rounded, size: 14),
          label: Text(c['status'] == 'Active' ? 'Suspend' : 'Activate'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: c['status'] == 'Active' ? const Color(0xFFD85A30) : const Color(0xFF1D9E75)),
            foregroundColor: c['status'] == 'Active' ? const Color(0xFFD85A30) : const Color(0xFF1D9E75),
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)))),
      ]),
    ]),
  );
}
