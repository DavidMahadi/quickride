// lib/screens/admin/super_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart' show AppColors, themeNotifier;
import 'package:swiftride/screens/guest/companies_screen.dart' show RentalCompany, CompanyCar, allCompanies, CompanyRequirement, CompanyPolicy;
import 'package:swiftride/screens/admin/company_admin_screen.dart' show CompanyAdminScreen;
import 'package:swiftride/services/auth_service.dart';
import 'package:swiftride/services/app_data_store.dart';
import 'package:swiftride/services/wallet_service.dart';
import 'package:swiftride/screens/admin/wallet_tab.dart';
// ── Local dynamic company registry (self-contained) ──────────
// Grows when super admin registers a new company this session.
final List<RentalCompany> _registeredCompanies = [];

List<RentalCompany> _allCompaniesWithDynamic() =>
    [...allCompanies, ..._registeredCompanies];

// ─────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────
class _User {
  final String name, email, phone, status, since, role;
  final String? company;
  final int trips; final double spent; final bool isSuperAdmin;
  const _User(this.name, this.email, this.phone, this.status, this.trips,
      this.spent, this.since, this.isSuperAdmin, {this.role = 'Client', this.company});
}

class _Company {
  final String name, status, location;
  final int agents, cars, bookings;
  final double revenue, rating, commissionPct;
  final String adminName, adminEmail, phone, regNumber, rentalModel;
  const _Company(this.name, this.agents, this.cars, this.bookings,
      this.revenue, this.status, this.location, this.rating,
      {this.adminName = '', this.adminEmail = '', this.phone = '',
       this.regNumber = '', this.commissionPct = 10.0, this.rentalModel = 'Daily'});
}

class _Booking {
  final String ref, user, car, company, from, to, status;
  final double amount;
  const _Booking(this.ref, this.user, this.car, this.company, this.from, this.to, this.amount, this.status);
}

// ─────────────────────────────────────────────
//  MUTABLE STATE (top-level so tabs share it)
// ─────────────────────────────────────────────
List<_User> _users = [
  _User('Cameron One',    'C1@gmail.com',      '+250 788 000 001', 'Active',    12, 1240.0, 'Jan 2024', true,  role: 'Client'),
  _User('Alice Mugisha',  'alice@email.com',   '+250 788 111 222', 'Active',     8,  890.0, 'Mar 2024', false, role: 'Client'),
  _User('Bob Nkusi',      'bob@email.com',     '+250 788 333 444', 'Suspended',  2,  120.0, 'Jun 2024', false, role: 'Client'),
  _User('Diana Uwase',    'diana@email.com',   '+250 788 555 666', 'Active',    21, 3200.0, 'Nov 2023', false, role: 'Company Admin', company: 'DriveKigali'),
  _User('Eric Habimana',  'eric@email.com',    '+250 788 777 888', 'Inactive',   0,    0.0, 'Sep 2024', false, role: 'Company Staff', company: 'SafariWheels'),
  _User('Fiona Ingabire', 'fiona@email.com',   '+250 788 999 000', 'Active',     5,  670.0, 'Feb 2024', false, role: 'Client'),
];

List<_Company> _companies = [
  _Company('DriveKigali',  4, 28, 156, 18200.0, 'Active',    'KG 7 Ave, Kigali',      4.9, adminName: 'Diana Uwase',   adminEmail: 'diana@email.com',   phone: '+250 788 100 001', regNumber: 'RW-BIZ-2019-001', commissionPct: 10.0, rentalModel: 'Daily'),
  _Company('SafariWheels', 3, 12,  89, 11400.0, 'Active',    'KN 3 Rd, Remera',       4.8, adminName: 'James Doe',     adminEmail: 'james@safari.rw',   phone: '+250 788 200 002', regNumber: 'RW-BIZ-2020-042', commissionPct: 12.0, rentalModel: 'Hybrid'),
  _Company('LuxDrive',     6,  8,  44,  9800.0, 'Active',    'KG 11 Ave, Nyarutarama',4.7, adminName: 'Mary Uwimana',  adminEmail: 'mary@luxdrive.rw',  phone: '+250 788 300 003', regNumber: 'RW-BIZ-2021-017', commissionPct: 8.0,  rentalModel: 'Monthly'),
  _Company('RwandaRide',   2,  5,  21,  2400.0, 'Pending',   'KN 5 Rd, Nyamirambo',   4.5, adminName: 'Paul Ndoli',    adminEmail: 'paul@rwandaride.rw',phone: '+250 788 400 004', regNumber: 'RW-BIZ-2024-088', commissionPct: 15.0, rentalModel: 'Long-Term'),
  _Company('VanGo',        1,  6,  12,  1100.0, 'Suspended', 'KG 9 Ave, Gisozi',      3.9, adminName: 'Kevin Ishimwe', adminEmail: 'kevin@vango.rw',    phone: '+250 788 500 005', regNumber: 'RW-BIZ-2022-033', commissionPct: 10.0, rentalModel: 'Daily'),
];

List<_Booking> _bookings = [
  _Booking('SW240001', 'Cameron One',    'Toyota RAV4',   'DriveKigali',  'May 24','May 27', 135.0, 'Active'),
  _Booking('SW240002', 'Diana Uwase',    'BMW 5 Series',  'SafariWheels', 'Jun 1', 'Jun 3',  180.0, 'Upcoming'),
  _Booking('SW240003', 'Alice Mugisha',  'Range Rover',   'LuxDrive',     'Apr 10','Apr 12', 220.0, 'Completed'),
  _Booking('SW240004', 'Bob Nkusi',      'Toyota Camry',  'DriveKigali',  'Mar 5', 'Mar 7',   90.0, 'Cancelled'),
  _Booking('SW240005', 'Fiona Ingabire', 'Mercedes GLE',  'LuxDrive',     'Jun 8', 'Jun 10', 200.0, 'Active'),
  _Booking('SW240006', 'Eric Habimana',  'Honda CR-V',    'RwandaRide',   'May 1', 'May 3',   76.0, 'Completed'),
];

// ─────────────────────────────────────────────
class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});
  @override State<SuperAdminScreen> createState() => _State();
}

class _State extends State<SuperAdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tc;
  int    _tab = 0;
  String _userSearch = '';
  String _userRoleFilter = 'All';
  String _bookingSortCompany = 'All';
  String _auditFilter = 'All';

  AppDataStore get _store => AppDataStore.instance;
  String get _actor => 'Super Admin';
  String get _actorRole => 'Super Admin';

  @override void initState() {
    super.initState();
    _tc = TabController(length: 6, vsync: this);
    _tc.addListener(() => setState(() => _tab = _tc.index));
  }
  @override void dispose() { _tc.dispose(); super.dispose(); }

  int    get _totalUsers     => _users.length;
  int    get _activeUsers    => _users.where((u) => u.status == 'Active').length;
  int    get _totalCompanies => _companies.length;
  int    get _totalBookings  => _bookings.length;
  double get _totalRevenue   => _bookings.fold(0.0, (s, b) => s + b.amount);

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);
    final card    = isDark ? const Color(0xFF141828) : Colors.white;
    final border  = isDark ? const Color(0xFF252B3E) : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white             : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8)  : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      drawer: _buildDrawer(isDark, card, border, textPri, textSec),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        leading: Builder(builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer())),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: const Text('SUPER', style: TextStyle(color: const Color(0xFFD4A017), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5))),
          const SizedBox(width: 8),
          const Text('SwiftRide Admin', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        ]),
        actions: [
          // ── Notification bell with badge ──────────────────
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () => _showNotifications(context, card, border, textPri, textSec)),
            Positioned(
              top: 8, right: 8,
              child: Container(
                width: 16, height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFD85A30),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0A0E1A), width: 1.5)),
                child: const Center(
                  child: Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
              ),
            ),
          ]),
          // ── SA avatar → account sheet ─────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showAccountSheet(context, card, border, textPri, textSec),
              child: CircleAvatar(radius: 15, backgroundColor: const Color(0xFFD4A017),
                child: const Text('SA', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w800))))),
        ],
        bottom: TabBar(
          controller: _tc,
          indicatorColor: const Color(0xFFD4A017),
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: const Color(0xFFD4A017),
          unselectedLabelColor: const Color(0xFF8B91A8),
          labelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w400),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined, size: 16),    text: 'Dashboard'),
            Tab(icon: Icon(Icons.people_outlined, size: 16),       text: 'Users'),
            Tab(icon: Icon(Icons.business_outlined, size: 16),     text: 'Companies'),
            Tab(icon: Icon(Icons.receipt_long_outlined, size: 16), text: 'Bookings'),
            Tab(icon: Icon(Icons.history_rounded, size: 16),       text: 'Audit'),
            Tab(icon: Icon(Icons.account_balance_wallet_rounded, size: 16), text: 'Wallet'),
          ],
        ),
      ),
      body: TabBarView(controller: _tc, children: [
        _dashboardTab(isDark, bg, card, border, textPri, textSec),
        _usersTab(isDark, bg, card, border, textPri, textSec),
        _companiesTab(isDark, bg, card, border, textPri, textSec),
        _bookingsTab(isDark, bg, card, border, textPri, textSec),
        _auditTab(isDark, bg, card, border, textPri, textSec),
        WalletTab(
          ownerKey: kPlatformKey,
          isSuperAdmin: true,
          card: card, border: border,
          textPri: textPri, textSec: textSec, bg: bg,
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════
  //  DASHBOARD
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
          border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.2), width: 0.8)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Good morning,', style: TextStyle(color: Color(0xFF8B91A8), fontSize: 12)),
            const Text('Super Admin', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('SwiftRide platform overview', style: TextStyle(color: const Color(0xFFD4A017).withOpacity(0.8), fontSize: 12)),
          ])),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.admin_panel_settings_rounded, color: const Color(0xFFD4A017), size: 28)),
        ])),

      const SizedBox(height: 16),
      Text('Platform Overview', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),

      // KPI cards — clickable
      Row(children: [
        Expanded(child: _KPI(
          label: 'Total Users', value: '$_totalUsers', sub: '$_activeUsers active',
          icon: Icons.people_rounded, color: const Color(0xFF3B5FD4),
          card: card, border: border, textPri: textPri, textSec: textSec,
          onTap: () { _tc.animateTo(1); setState(() => _tab = 1); })),
        const SizedBox(width: 10),
        Expanded(child: _KPI(
          label: 'Companies', value: '$_totalCompanies', sub: '${_companies.where((c) => c.status=="Active").length} active',
          icon: Icons.business_rounded, color: const Color(0xFF7F77DD),
          card: card, border: border, textPri: textPri, textSec: textSec,
          onTap: () { _tc.animateTo(2); setState(() => _tab = 2); })),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _KPI(
          label: 'Total Bookings', value: '$_totalBookings', sub: '${_bookings.where((b) => b.status=="Active").length} active now',
          icon: Icons.receipt_long_rounded, color: const Color(0xFF1D9E75),
          card: card, border: border, textPri: textPri, textSec: textSec,
          onTap: () { _tc.animateTo(3); setState(() => _tab = 3); })),
        const SizedBox(width: 10),
        Expanded(child: _KPI(
          label: 'Revenue', value: '\$${_totalRevenue.toInt()}', sub: 'all time',
          icon: Icons.attach_money_rounded, color: const Color(0xFFD4A017),
          card: card, border: border, textPri: textPri, textSec: textSec,
          onTap: () => _showAnalyticsSheet(context, card, border, textPri, textSec))),
      ]),

      const SizedBox(height: 20),
      Text('Recent Activity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),
      ...[
        (Icons.person_add_rounded,   const Color(0xFF3B5FD4), 'New user registered',     'Alice Mugisha joined',      '2 min ago',
          () {
            _tc.animateTo(1); setState(() => _tab = 1);
            WidgetsBinding.instance.addPostFrameCallback((_) =>
              _showUserDetail(context, _users[1], isDark, card, border, textPri, textSec));
          }
        ),
        (Icons.receipt_rounded,      const Color(0xFF1D9E75), 'Booking confirmed',        'SW240005 · \$200',        '15 min ago',
          () {
            _tc.animateTo(3); setState(() => _tab = 3);
            WidgetsBinding.instance.addPostFrameCallback((_) =>
              _showBookingDetail(context, _bookings[4], isDark, card, border, textPri, textSec));
          }
        ),
        (Icons.business_rounded,     const Color(0xFF7F77DD), 'Company pending approval', 'RwandaRide submitted docs', '1 hr ago',
          () {
            _tc.animateTo(2); setState(() => _tab = 2);
            WidgetsBinding.instance.addPostFrameCallback((_) =>
              _showCompanyDetail(context, 3, isDark, card, border, textPri, textSec));
          }
        ),
        (Icons.cancel_rounded,       const Color(0xFFD85A30), 'Booking cancelled',        'SW240004 by Bob Nkusi',     '2 hr ago',
          () {
            _tc.animateTo(3); setState(() => _tab = 3);
            WidgetsBinding.instance.addPostFrameCallback((_) =>
              _showBookingDetail(context, _bookings[3], isDark, card, border, textPri, textSec));
          }
        ),
        (Icons.star_rounded,         const Color(0xFFD4A017), 'Review posted',            '5★ for DriveKigali',     '3 hr ago',
          () { _tc.animateTo(2); setState(() => _tab = 2); }
        ),
      ].map((a) {
        final fn = a.$6 as VoidCallback;
        return GestureDetector(
          onTap: fn,
          child: Container(
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
              Row(children: [
                Text(a.$5 as String, style: TextStyle(fontSize: 10, color: textSec)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: textSec, size: 14),
              ]),
            ])));
      }),

      const SizedBox(height: 20),
      Text('Needs Attention', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),
      ...[
        (Icons.pending_rounded,       const Color(0xFFD85A30), 'RwandaRide approval pending', '1 company awaiting review',
          () {
            _tc.animateTo(2); setState(() => _tab = 2);
            WidgetsBinding.instance.addPostFrameCallback((_) =>
              _showCompanyDetail(context, 3, isDark, card, border, textPri, textSec));
          }
        ),
        (Icons.warning_amber_rounded, const Color(0xFFE8C04A), 'Bob Nkusi account suspended', 'Review suspension reason',
          () {
            _tc.animateTo(1); setState(() => _tab = 1);
            WidgetsBinding.instance.addPostFrameCallback((_) =>
              _showUserDetail(context, _users[2], isDark, card, border, textPri, textSec));
          }
        ),
        (Icons.support_agent_rounded, const Color(0xFF3B5FD4), '3 support tickets open',      'Respond to user queries',
          () { _tc.animateTo(1); setState(() => _tab = 1); }
        ),
      ].map((a) {
        final fn = a.$5 as VoidCallback;
        return GestureDetector(
          onTap: fn,
          child: Container(
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
            ])));
      }),
      const SizedBox(height: 16),
    ]));
  }

  // ══════════════════════════════════════════════
  //  USERS TAB  — categorised by role
  // ══════════════════════════════════════════════
  Widget _usersTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec) {
    const roles = ['All', 'Client', 'Company Admin', 'Company Staff'];
    final filtered = _users.where((u) {
      final matchRole   = _userRoleFilter == 'All' || u.role == _userRoleFilter;
      final matchSearch = _userSearch.isEmpty ||
          u.name.toLowerCase().contains(_userSearch.toLowerCase()) ||
          u.email.toLowerCase().contains(_userSearch.toLowerCase());
      return matchRole && matchSearch;
    }).toList();

    return Column(children: [
      // Search + Add
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Row(children: [
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
          child: TextField(
            onChanged: (v) => setState(() => _userSearch = v),
            style: TextStyle(color: textPri, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search users…', hintStyle: TextStyle(color: textSec, fontSize: 13),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: textSec, size: 18)),
          ))),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _showAddUser(context, card, border, textPri, textSec),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFD4A017), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.add, color: Colors.black, size: 20))),
      ])),

      // Role filter chips
      SizedBox(height: 40, child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: roles.map((r) {
          final roleColor = _roleColor(r);
          final sel = _userRoleFilter == r;
          return GestureDetector(
            onTap: () => setState(() => _userRoleFilter = r),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: sel ? roleColor : card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? roleColor : border, width: 0.8)),
              child: Center(child: Text(r,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : textSec)))));
        }).toList())),

      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text('${filtered.length} user${filtered.length != 1 ? "s" : ""}',
          style: TextStyle(fontSize: 11, color: textSec))),

      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final u = filtered[i];
          final rc = _roleColor(u.role);
          return GestureDetector(
            onTap: () => _showUserDetail(context, u, isDark, card, border, textPri, textSec),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
              child: Row(children: [
                CircleAvatar(radius: 22, backgroundColor: rc.withOpacity(0.15),
                  child: Text(u.name.split(' ').map((e) => e[0]).take(2).join(),
                    style: TextStyle(color: rc, fontSize: 13, fontWeight: FontWeight.w700))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(child: Text(u.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: rc.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
                      child: Text(u.role == 'Company Admin' ? 'CA' : u.role == 'Company Staff' ? 'CS' : 'CL',
                        style: TextStyle(color: rc, fontSize: 8, fontWeight: FontWeight.w800))),
                  ]),
                  Text(u.email, style: TextStyle(fontSize: 11, color: textSec)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Text('${u.trips} trips · \$${u.spent.toInt()} spent', style: TextStyle(fontSize: 10, color: textSec)),
                    if (u.company != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.business_outlined, size: 10, color: const Color(0xFFD4A017)),
                      const SizedBox(width: 2),
                      Text(u.company!, style: const TextStyle(fontSize: 10, color: const Color(0xFFD4A017), fontWeight: FontWeight.w600)),
                    ],
                  ]),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  _StatusBadge(u.status),
                  const SizedBox(height: 4),
                  Icon(Icons.chevron_right_rounded, color: textSec, size: 16),
                ]),
              ])));
        })),
    ]);
  }

  // ══════════════════════════════════════════════
  //  COMPANIES TAB
  // ══════════════════════════════════════════════
  Widget _companiesTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec) {
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Row(children: [
        Expanded(child: Text('${_companies.length} companies', style: TextStyle(fontSize: 13, color: textSec))),
        ElevatedButton.icon(
          onPressed: () => _showAddCompany(context, card, border, textPri, textSec),
          icon: const Icon(Icons.add, size: 14), label: const Text('Add Company'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4A017), foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0, textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
      ])),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _companies.length,
        itemBuilder: (_, i) {
          final c = _companies[i];
          final sc = _statusColor(c.status);
          return GestureDetector(
            onTap: () => _showCompanyDetail(context, i, isDark, card, border, textPri, textSec),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 46, height: 46,
                    decoration: BoxDecoration(color: const Color(0xFF3B5FD4).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text((c.name.length >= 2 ? c.name.substring(0, 2) : c.name).toUpperCase(),
                      style: const TextStyle(color: Color(0xFF3B5FD4), fontSize: 16, fontWeight: FontWeight.w800)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPri)),
                    Text(c.location, style: TextStyle(fontSize: 11, color: textSec), overflow: TextOverflow.ellipsis),
                    if (c.adminName.isNotEmpty)
                      Row(children: [
                        Icon(Icons.person_outline, size: 11, color: textSec),
                        const SizedBox(width: 3),
                        Text(c.adminName, style: TextStyle(fontSize: 11, color: textSec)),
                      ]),
                  ])),
                  _StatusBadge(c.status),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _MiniStat(label: 'Agents',   value: '${c.agents}',              textPri: textPri, textSec: textSec),
                  _MiniStat(label: 'Cars',     value: '${c.cars}',                textPri: textPri, textSec: textSec),
                  _MiniStat(label: 'Bookings', value: '${c.bookings}',            textPri: textPri, textSec: textSec),
                  _MiniStat(label: 'Revenue',  value: '\$${c.revenue.toInt()}',   textPri: textPri, textSec: textSec),
                  _MiniStat(label: 'Rating',   value: '${c.rating}\u2605',        textPri: textPri, textSec: textSec),
                  _MiniStat(label: 'Commission', value: '${c.commissionPct.toInt()}%', textPri: textPri, textSec: textSec),
                ]),
                const SizedBox(height: 8),
                // Rental model badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _rentalModelColor(c.rentalModel).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _rentalModelColor(c.rentalModel).withOpacity(0.35), width: 0.8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_rentalModelIcon(c.rentalModel), color: _rentalModelColor(c.rentalModel), size: 11),
                    const SizedBox(width: 5),
                    Text(c.rentalModel.isEmpty ? 'Daily' : c.rentalModel,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _rentalModelColor(c.rentalModel))),
                  ])),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () {
                      final match = _allCompaniesWithDynamic().where((co) => co.name.toLowerCase() == c.name.toLowerCase() || co.name.toLowerCase().contains(c.name.toLowerCase().split(' ')[0])).toList();
                      final company = match.isNotEmpty ? match.first : allCompanies.first;
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyAdminScreen(company: company)));
                    },
                    icon: const Icon(Icons.admin_panel_settings_rounded, size: 13),
                    label: const Text('Admin Panel'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: const Color(0xFFD4A017)),
                      foregroundColor: const Color(0xFFD4A017),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () => _toggleCompanyStatus(i),
                    icon: Icon(c.status == 'Active' ? Icons.block_rounded : Icons.check_circle_outline_rounded, size: 13),
                    label: Text(c.status == 'Active' ? 'Suspend' : c.status == 'Pending' ? 'Approve' : 'Activate'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: c.status == 'Active' ? const Color(0xFFD85A30) : const Color(0xFF1D9E75)),
                      foregroundColor: c.status == 'Active' ? const Color(0xFFD85A30) : const Color(0xFF1D9E75),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)))),
                ]),
              ])));
        })),
    ]);
  }

  // ══════════════════════════════════════════════
  //  BOOKINGS TAB
  // ══════════════════════════════════════════════
  // ══════════════════════════════════════════════
  //  BOOKINGS TAB — company grouped with drill-down
  // ══════════════════════════════════════════════
  Widget _bookingsTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec) {
    // Build per-company summaries
    final companyNames = _bookings.map((b) => b.company).toSet().toList()..sort();

    // Stats for fleet overview header
    final totalActive    = _bookings.where((b) => b.status == 'Active').length;
    final totalCompleted = _bookings.where((b) => b.status == 'Completed').length;
    final totalRevenue   = _bookings.fold(0.0, (s, b) => s + b.amount);

    return Column(children: [
      // ── Fleet overview summary bar ──
      Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1A1F3C), Color(0xFF252B4E)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.2), width: 0.8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.directions_car_rounded, color: const Color(0xFFD4A017), size: 16),
            const SizedBox(width: 8),
            const Text('Fleet Rental Overview',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('\$${totalRevenue.toInt()} total',
              style: const TextStyle(color: const Color(0xFFD4A017), fontSize: 13, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _OverviewStat(label: 'Rented Now',  value: '$totalActive',              color: const Color(0xFF1D9E75)),
            _OverviewStat(label: 'Companies',   value: '${companyNames.length}',    color: const Color(0xFF3B5FD4)),
            _OverviewStat(label: 'Total Trips', value: '${_bookings.length}',       color: const Color(0xFF7F77DD)),
            _OverviewStat(label: 'Completed',   value: '$totalCompleted',           color: const Color(0xFFD4A017)),
          ]),
        ])),

      // ── Company list with drill-down ──
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: companyNames.length,
        itemBuilder: (_, i) {
          final co = companyNames[i];
          final coBkgs  = _bookings.where((b) => b.company == co).toList();
          final coRev   = coBkgs.fold(0.0, (s, b) => s + b.amount);
          final coActive= coBkgs.where((b) => b.status == 'Active').length;
          final coDone  = coBkgs.where((b) => b.status == 'Completed').length;
          final compInfo = _companies.where((c) => c.name == co).toList();
          final totalFleet = compInfo.isNotEmpty ? compInfo.first.cars : 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 0.5)),
            child: Column(children: [
              // Company header — tap to expand
              GestureDetector(
                onTap: () => setState(() {
                  if (_bookingSortCompany == co) {
                    _bookingSortCompany = '';
                  } else {
                    _bookingSortCompany = co;
                  }
                }),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 42, height: 42,
                        decoration: BoxDecoration(color: const Color(0xFF3B5FD4).withOpacity(0.1), borderRadius: BorderRadius.circular(11)),
                        child: Center(child: Text(
                          (co.length >= 2 ? co.substring(0, 2) : co).toUpperCase(),
                          style: const TextStyle(color: Color(0xFF3B5FD4), fontSize: 14, fontWeight: FontWeight.w800)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(co, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPri)),
                        Text('${coBkgs.length} bookings · \$${coRev.toInt()} revenue',
                          style: TextStyle(fontSize: 11, color: textSec)),
                      ])),
                      Icon(_bookingSortCompany == co
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                        color: textSec, size: 20),
                    ]),
                    const SizedBox(height: 10),
                    // Vehicles rented summary
                    Row(children: [
                      _CoStat(label: 'Renting',   value: '$coActive',   color: const Color(0xFF1D9E75)),
                      _CoStat(label: 'Completed', value: '$coDone',     color: const Color(0xFFD4A017)),
                      _CoStat(label: 'Fleet Size',value: '$totalFleet', color: const Color(0xFF3B5FD4)),
                      _CoStat(label: 'Revenue',   value: '\$${coRev.toInt()}', color: const Color(0xFF7F77DD)),
                    ]),
                  ])),
              ),

              // Expanded booking list
              if (_bookingSortCompany == co) ...[
                Divider(color: border, height: 1),
                ...coBkgs.map((b) {
                  final sc = _statusColor(b.status);
                  return GestureDetector(
                    onTap: () => _showBookingDetail(context, b, isDark, card, border, textPri, textSec),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: border, width: 0.5))),
                      child: Row(children: [
                        Container(width: 36, height: 36,
                          decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                          child: Icon(Icons.directions_car_rounded, color: sc, size: 17)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(b.car, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
                          Row(children: [
                            Icon(Icons.person_outline_rounded, size: 10, color: textSec),
                            const SizedBox(width: 3),
                            Text(b.user, style: TextStyle(fontSize: 11, color: textSec)),
                            const SizedBox(width: 8),
                            Icon(Icons.calendar_today_outlined, size: 10, color: textSec),
                            const SizedBox(width: 3),
                            Text('${b.from} → ${b.to}', style: TextStyle(fontSize: 11, color: textSec)),
                          ]),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('\$${b.amount.toInt()}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFFD4A017))),
                          const SizedBox(height: 3),
                          _StatusBadge(b.status),
                        ]),
                      ])));
                }),
              ],
            ]));
        })),
    ]);
  }

  // ══════════════════════════════════════════════
  //  DRAWER  (with dark/light toggle)
  // ══════════════════════════════════════════════
  Widget _buildDrawer(bool isDark, Color card, Color border, Color textPri, Color textSec) {
    const navItems = [
      (Icons.dashboard_outlined,     'Dashboard',       0),
      (Icons.people_outlined,        'Users',           1),
      (Icons.business_outlined,      'Companies',       2),
      (Icons.receipt_long_outlined,  'Bookings',        3),
      (Icons.history_rounded,        'Audit',           4),
      (Icons.account_balance_wallet_rounded, 'Wallet',  5),
      (Icons.bar_chart_rounded,      'Analytics',      -1),
      (Icons.notifications_outlined, 'Notifications',  -2),
      (Icons.settings_outlined,      'System Settings',-3),
    ];

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
      child: SafeArea(child: Column(children: [

        // Profile header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF1A1F3C), Color(0xFF0D1224)]),
            border: Border(bottom: BorderSide(color: const Color(0xFFD4A017).withOpacity(0.2), width: 0.5))),
          child: Column(children: [
            Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.4), width: 2)),
                child: const Center(child: Text('SA',
                  style: TextStyle(color: const Color(0xFFD4A017), fontSize: 20, fontWeight: FontWeight.w800)))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Super Admin',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                const Text('admin@swiftride.rw',
                  style: TextStyle(color: Color(0xFF8B91A8), fontSize: 11)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.3), width: 0.5)),
                  child: const Text('SUPER ADMIN',
                    style: TextStyle(color: const Color(0xFFD4A017), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2))),
              ])),
            ]),
            const SizedBox(height: 16),
            // Quick stats row
            Row(children: [
              _DrawerStat(label: 'Users',     value: '${_users.length}'),
              _DrawerStat(label: 'Companies', value: '${_companies.length}'),
              _DrawerStat(label: 'Bookings',  value: '${_bookings.length}'),
              _DrawerStat(label: 'Wallet',    value: '\$${WalletService.instance.platformWallet.balance.toStringAsFixed(0)}'),
            ]),
          ])),

        // Theme toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141828) : const Color(0xFFF2F4F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 0.5)),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  color: const Color(0xFFD4A017), size: 16)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isDark ? 'Dark mode' : 'Light mode',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
                Text('Tap to switch', style: TextStyle(fontSize: 10, color: textSec)),
              ])),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (_, mode, __) => Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: (_) => themeNotifier.toggle(),
                  activeColor: const Color(0xFFD4A017),
                  activeTrackColor: const Color(0xFFD4A017).withOpacity(0.3),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
            ])),
        ),

        Divider(color: border, height: 20),

        // Nav items
        Expanded(child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 4),
          children: navItems.map((item) {
            final tabIdx = item.$3 as int;
            final isActive = tabIdx >= 0 && _tab == tabIdx;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFD4A017).withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(item.$1 as IconData,
                  color: isActive ? const Color(0xFFD4A017) : textSec, size: 20),
                title: Text(item.$2 as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive ? const Color(0xFFD4A017) : textPri)),
                trailing: isActive
                    ? Container(width: 4, height: 20,
                        decoration: BoxDecoration(color: const Color(0xFFD4A017), borderRadius: BorderRadius.circular(2)))
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  if (tabIdx >= 0) { _tc.animateTo(tabIdx); setState(() => _tab = tabIdx); }
                  else if (tabIdx == -1) _showAnalyticsSheet(context, card, border, textPri, textSec);
                  else if (tabIdx == -2) _showNotifications(context, card, border, textPri, textSec);
                  else if (tabIdx == -3) _showSystemSettings(context, card, border, textPri, textSec);
                },
                dense: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ));
          }).toList())),

        Divider(color: border),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // History button
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.history_rounded, color: const Color(0xFFD4A017), size: 18)),
              title: const Text('Full History', style: TextStyle(fontSize: 14, color: const Color(0xFFD4A017), fontWeight: FontWeight.w600)),
              subtitle: const Text('All platform events', style: TextStyle(color: Color(0xFF8B91A8), fontSize: 11)),
              onTap: () { Navigator.pop(context); _tc.animateTo(4); setState(() => _tab = 4); },
              dense: true),
            const SizedBox(height: 4),
            // Sign out
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFFD85A30).withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFD85A30), size: 18)),
              title: const Text('Sign Out',
                style: TextStyle(fontSize: 14, color: Color(0xFFD85A30), fontWeight: FontWeight.w600)),
              onTap: () { AuthService.logout(); Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false); },
              dense: true),
          ])),
      ])));
  }

  // ══════════════════════════════════════════════
  //  ADD USER SHEET  — with role + company
  // ══════════════════════════════════════════════
  void _showAddUser(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    final nameC   = TextEditingController();
    final emailC  = TextEditingController();
    final phoneC  = TextEditingController();
    final passC   = TextEditingController();
    String selRole = 'Client';
    String? selCompany;

    showModalBottomSheet(
      context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx2, setS) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),
          Center(child: Text('Add New User', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri))),
          const SizedBox(height: 20),

          _SField('Full Name', 'e.g. John Doe', nameC, textPri, textSec),
          const SizedBox(height: 10),
          _SField('Email Address', 'user@email.com', emailC, textPri, textSec),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _SField('Phone', '+250 7XX XXX XXX', phoneC, textPri, textSec)),
            const SizedBox(width: 10),
            Expanded(child: _SField('Password', '••••••••', passC, textPri, textSec, obscure: true)),
          ]),
          const SizedBox(height: 16),

          // Role selector
          Text('User Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textSec)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: ['Client', 'Company Admin', 'Company Staff'].map((r) {
            final rc = _roleColor(r);
            final sel = selRole == r;
            return GestureDetector(
              onTap: () => setS(() { selRole = r; if (r == 'Client') selCompany = null; }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? rc.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? rc : border, width: sel ? 1.5 : 0.8)),
                child: Text(r, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: sel ? rc : textSec))));
          }).toList()),

          // Company association (only for CA / CS)
          if (selRole != 'Client') ...[
            const SizedBox(height: 16),
            Text('Associate with Company', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textSec)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: isDark(ctx2) ? const Color(0xFF1C2236) : const Color(0xFFF2F4F8),
                borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
              child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                value: selCompany,
                hint: Text('Select company', style: TextStyle(color: textSec, fontSize: 13)),
                isExpanded: true,
                dropdownColor: card,
                style: TextStyle(color: textPri, fontSize: 13),
                items: _companies.map((c) => DropdownMenuItem(value: c.name,
                  child: Text(c.name))).toList(),
                onChanged: (v) => setS(() => selCompany = v)))),
          ],

          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (nameC.text.isEmpty || emailC.text.isEmpty) return;
              setState(() {
                _users.add(_User(nameC.text, emailC.text, phoneC.text, 'Active',
                  0, 0.0, _monthYear(), false,
                  role: selRole, company: selCompany));
              });
              Navigator.pop(ctx);
              _toast(ctx, '${nameC.text} added successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A017), foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Create User', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)))),
          const SizedBox(height: 8),
        ]))))));
  }

  // ══════════════════════════════════════════════
  //  ADD COMPANY SHEET  — with all fields + file upload note
  // ══════════════════════════════════════════════
  void _showAddCompany(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    final nameC       = TextEditingController();
    final locC        = TextEditingController();
    final phoneC      = TextEditingController();
    final regC        = TextEditingController();
    final emailC      = TextEditingController();
    final adminNameC  = TextEditingController();
    final adminEmailC = TextEditingController();
    final commissionC = TextEditingController(text: '10');
    bool   docUploaded = false;
    String rentalModel = '';

    const models = [
      ('Daily',     'Rent per day',             'Clients book by the day. Ideal for short trips, tourism, and business travel.',  Icons.today_rounded,          Color(0xFF3B5FD4)),
      ('Monthly',   'Rent per month',           'Fixed monthly rate. Best for corporate contracts and long stay clients.',         Icons.calendar_month_rounded,  Color(0xFF1D9E75)),
      ('Long-Term', 'Long-term (6 months+)',    'Discounted rates for 6-month or annual rentals. Suits expats and long projects.', Icons.event_repeat_rounded,    Color(0xFF7F77DD)),
      ('Hybrid',    'Hybrid (daily & monthly)', 'Flexible pricing — clients choose daily or monthly depending on their needs.',    Icons.swap_horiz_rounded,      Color(0xFFD4A017)),
    ];

    showModalBottomSheet(
      context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85, minChildSize: 0.4, maxChildSize: 0.95,
        builder: (_, scrollCtrl) => StatefulBuilder(builder: (ctx2, setS) => Container(
          decoration: BoxDecoration(color: card, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom + 20),
        child: SingleChildScrollView(controller: scrollCtrl, child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),
          Center(child: Text('Register Company', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri))),
          const SizedBox(height: 20),

          // Company Info
          _SectionLabel('Company Information', textSec),
          _SField('Company Name', 'e.g. DriveKigali', nameC, textPri, textSec),
          const SizedBox(height: 10),
          _SField('Location / Address', 'KG 7 Ave, Kigali', locC, textPri, textSec),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _SField('Phone Number', '+250 788 XXX XXX', phoneC, textPri, textSec)),
            const SizedBox(width: 10),
            Expanded(child: _SField('Registration No.', 'RW-BIZ-XXXX-XXX', regC, textPri, textSec)),
          ]),
          const SizedBox(height: 10),
          _SField('Business Email', 'info@company.rw', emailC, textPri, textSec),

          // Rental Model
          const SizedBox(height: 24),
          Row(children: [
            _SectionLabel('Rental Model', textSec),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFD85A30).withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: const Text('Required', style: TextStyle(color: Color(0xFFD85A30), fontSize: 9, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 4),
          Text('How does this company charge clients?', style: TextStyle(fontSize: 11, color: textSec)),
          const SizedBox(height: 10),
          ...models.map((m) {
            final sel = rentalModel == m.$1;
            return GestureDetector(
              onTap: () => setS(() => rentalModel = m.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: sel ? m.$5.withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? m.$5 : border, width: sel ? 1.5 : 0.8)),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: sel ? m.$5 : textSec, width: 1.5),
                      color: sel ? m.$5 : Colors.transparent),
                    child: sel ? const Icon(Icons.check_rounded, size: 12, color: Colors.black) : null),
                  const SizedBox(width: 10),
                  Container(width: 34, height: 34,
                    decoration: BoxDecoration(color: m.$5.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                    child: Icon(m.$4, color: m.$5, size: 17)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: sel ? m.$5 : textPri)),
                    const SizedBox(height: 2),
                    Text(m.$3, style: TextStyle(fontSize: 10, color: textSec, height: 1.3)),
                  ])),
                ]),
              ),
            );
          }),
          if (rentalModel.isEmpty) Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, size: 12, color: const Color(0xFFD85A30).withOpacity(0.7)),
              const SizedBox(width: 5),
              Text('Select a rental model to continue', style: TextStyle(fontSize: 10, color: const Color(0xFFD85A30).withOpacity(0.8))),
            ])),

          // Admin / Owner
          const SizedBox(height: 20),
          _SectionLabel('Company Admin / Owner', textSec),
          _SField('Admin Full Name', 'e.g. Jean Claude', adminNameC, textPri, textSec),
          const SizedBox(height: 10),
          _SField('Admin Email', 'admin@company.rw', adminEmailC, textPri, textSec),

          // Commission & Wallet
          const SizedBox(height: 20),
          _SectionLabel('Commission & Wallet', textSec),
          Row(children: [
            Expanded(child: _SField('Commission %', 'e.g. 10', commissionC, textPri, textSec, numeric: true)),
            const SizedBox(width: 10),
            Expanded(child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Platform cut', style: TextStyle(color: Color(0xFFD4A017), fontSize: 10, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                const Text('% of each booking\nautomatically credited\nto platform wallet',
                    style: TextStyle(color: Color(0xFF8B91A8), fontSize: 9), maxLines: 3),
              ]))),
          ]),

          // Documents
          const SizedBox(height: 20),
          _SectionLabel('Legitimacy Documents', textSec),
          GestureDetector(
            onTap: () => setS(() => docUploaded = !docUploaded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: docUploaded ? const Color(0xFF1D9E75).withOpacity(0.07) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: docUploaded ? const Color(0xFF1D9E75) : border,
                    width: docUploaded ? 1.5 : 1, style: BorderStyle.solid)),
              child: Row(children: [
                Icon(docUploaded ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                  color: docUploaded ? const Color(0xFF1D9E75) : textSec, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(docUploaded ? 'Documents uploaded' : 'Upload company documents',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: docUploaded ? const Color(0xFF1D9E75) : textPri)),
                  Text('Business registration, tax cert, ID of owner',
                    style: TextStyle(fontSize: 11, color: textSec)),
                ])),
                if (!docUploaded) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Browse', style: TextStyle(color: const Color(0xFFD4A017), fontSize: 11, fontWeight: FontWeight.w700))),
              ]))),

          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (nameC.text.isEmpty || rentalModel.isEmpty) { setS(() {}); return; }
              final pct = double.tryParse(commissionC.text) ?? 10.0;
              WalletService.instance.setCommission(nameC.text, pct);
              setState(() {
                _companies.add(_Company(
                  nameC.text, 0, 0, 0, 0, 'Pending', locC.text, 0.0,
                  adminName: adminNameC.text, adminEmail: adminEmailC.text,
                  phone: phoneC.text, regNumber: regC.text,
                  commissionPct: pct, rentalModel: rentalModel));

                // ── Sync to AppDataStore ─────────────────────
                final companyId = 'C${DateTime.now().millisecondsSinceEpoch}';
                AppDataStore.instance.addCompany(
                  SharedCompany(
                    id: companyId, name: nameC.text, status: 'Pending',
                    location: locC.text, adminName: adminNameC.text,
                    adminEmail: adminEmailC.text, phone: phoneC.text,
                    regNumber: regC.text, email: emailC.text,
                    rentalModel: rentalModel, commissionPct: pct,
                  ),
                  'Super Admin', 'Super Admin',
                );

                // ── Add to client-visible companies list ──────
                final initials = nameC.text.split(' ')
                    .map((e) => e.isEmpty ? '' : e[0]).take(2).join().toUpperCase();
                _registeredCompanies.add(RentalCompany(
                  id: companyId, name: nameC.text, initials: initials,
                  tagline: 'New to SwiftRide · Pending Approval',
                  location: locC.text, phone: phoneC.text,
                  email: emailC.text, website: '',
                  rating: 0, totalRentals: 0, reviewCount: 0, yearsActive: 0,
                  brandColor: const Color(0xFF3B5FD4),
                  categories: const ['Economy'],
                  rentalModel: rentalModel,
                  fleet: const [], requirements: const [], policies: const [],
                ));
              });
              Navigator.pop(ctx);
              _toast(ctx, '${nameC.text} registered — pending approval');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A017), foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Submit for Approval', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)))),
          const SizedBox(height: 8),
        ]))))))));
  }

  // ══════════════════════════════════════════════
  //  DETAIL SHEETS
  // ══════════════════════════════════════════════
  void _showUserDetail(BuildContext context, _User u, bool isDark, Color card, Color border, Color textPri, Color textSec) {
    final rc = _roleColor(u.role);
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
                CircleAvatar(radius: 30, backgroundColor: rc.withOpacity(0.15),
                  child: Text(u.name.split(' ').map((e) => e[0]).take(2).join(),
                    style: TextStyle(color: rc, fontSize: 18, fontWeight: FontWeight.w700))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(u.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPri)),
                  Text(u.email, style: TextStyle(fontSize: 12, color: textSec)),
                  Text(u.phone, style: TextStyle(fontSize: 12, color: textSec)),
                  const SizedBox(height: 5),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: rc.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text(u.role, style: TextStyle(color: rc, fontSize: 10, fontWeight: FontWeight.w700))),
                    if (u.company != null) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.business_outlined, size: 12, color: const Color(0xFFD4A017)),
                      const SizedBox(width: 3),
                      Text(u.company!, style: const TextStyle(fontSize: 11, color: const Color(0xFFD4A017), fontWeight: FontWeight.w600)),
                    ],
                  ]),
                ])),
                _StatusBadge(u.status),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _MiniStat(label: 'Trips',  value: '${u.trips}',           textPri: textPri, textSec: textSec),
                _MiniStat(label: 'Spent',  value: '\$${u.spent.toInt()}', textPri: textPri, textSec: textSec),
                _MiniStat(label: 'Since',  value: u.since,                textPri: textPri, textSec: textSec),
              ]),
              const SizedBox(height: 16),
              Text('Actions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 10),
              Wrap(spacing: 10, runSpacing: 10, children: [
                _ActionBtn(label: 'View Bookings', icon: Icons.receipt_long_outlined,  color: const Color(0xFF3B5FD4), onTap: () => Navigator.pop(context)),
                _ActionBtn(
                  label: u.status == 'Suspended' ? 'Unsuspend' : 'Suspend',
                  icon: u.status == 'Suspended' ? Icons.check_circle_outline : Icons.block_rounded,
                  color: u.status == 'Suspended' ? const Color(0xFF1D9E75) : const Color(0xFFD85A30),
                  onTap: () {
                    final idx = _users.indexOf(u);
                    final newStatus = u.status == 'Suspended' ? 'Active' : 'Suspended';
                    setState(() => _users[idx] = _User(u.name, u.email, u.phone,
                      newStatus, u.trips, u.spent, u.since, u.isSuperAdmin, role: u.role, company: u.company));
                    try { _store.updateUserStatus(u.email, newStatus, _actor, _actorRole); } catch(_) {}
                    Navigator.pop(context);
                  }),
                _ActionBtn(label: 'Reset Password', icon: Icons.lock_reset_rounded,  color: const Color(0xFF7F77DD), onTap: () => Navigator.pop(context)),
                _ActionBtn(label: 'Send Message',   icon: Icons.mail_outline_rounded, color: const Color(0xFFD4A017),         onTap: () => Navigator.pop(context)),
              ]),
            ])),
          ]))));
  }

  void _showCompanyDetail(BuildContext context, int idx, bool isDark, Color card, Color border, Color textPri, Color textSec) {
    final c = _companies[idx];
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.80, minChildSize: 0.5, maxChildSize: 0.95,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            Container(margin: const EdgeInsets.only(top: 12, bottom: 8), width: 40, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
            Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: [
              // Header
              Row(children: [
                Container(width: 56, height: 56,
                  decoration: BoxDecoration(color: const Color(0xFF3B5FD4).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text((c.name.length >= 2 ? c.name.substring(0, 2) : c.name).toUpperCase(),
                    style: const TextStyle(color: Color(0xFF3B5FD4), fontSize: 20, fontWeight: FontWeight.w800)))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPri)),
                  Text(c.location, style: TextStyle(fontSize: 12, color: textSec)),
                  Row(children: [
                    const Icon(Icons.star_rounded, color: const Color(0xFFD4A017), size: 13),
                    const SizedBox(width: 3),
                    Text('${c.rating}', style: const TextStyle(fontSize: 12, color: const Color(0xFFD4A017), fontWeight: FontWeight.w600)),
                  ]),
                ])),
                _StatusBadge(c.status),
              ]),
              const SizedBox(height: 16),

              // Stats
              Row(children: [
                _MiniStat(label: 'Agents',   value: '${c.agents}',           textPri: textPri, textSec: textSec),
                _MiniStat(label: 'Cars',     value: '${c.cars}',             textPri: textPri, textSec: textSec),
                _MiniStat(label: 'Bookings', value: '${c.bookings}',         textPri: textPri, textSec: textSec),
                _MiniStat(label: 'Revenue',  value: '\$${c.revenue.toInt()}',textPri: textPri, textSec: textSec),
              ]),
              const SizedBox(height: 16),

              // Company info
              _InfoCard(card: card, border: border, children: [
                _InfoRow(Icons.phone_outlined,   'Phone',       c.phone.isEmpty ? 'N/A' : c.phone,       textPri, textSec),
                _InfoRow(Icons.badge_outlined,   'Reg. Number', c.regNumber.isEmpty ? 'N/A' : c.regNumber, textPri, textSec),
                _InfoRow(_rentalModelIcon(c.rentalModel), 'Rental Model', c.rentalModel.isEmpty ? 'Daily' : c.rentalModel, textPri, textSec),
                _InfoRow(Icons.percent_rounded,  'Commission',  '${c.commissionPct.toInt()}% per booking → platform wallet', textPri, textSec),
              ]),
              const SizedBox(height: 12),

              // Admin info
              Text('Company Admin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 8),
              _InfoCard(card: card, border: border, children: [
                _InfoRow(Icons.person_outline,  'Name',  c.adminName.isEmpty  ? 'Not assigned' : c.adminName,  textPri, textSec),
                _InfoRow(Icons.email_outlined,  'Email', c.adminEmail.isEmpty ? 'N/A'          : c.adminEmail, textPri, textSec),
              ]),
              const SizedBox(height: 16),

              // Actions
              Text('Actions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 10),
              Wrap(spacing: 10, runSpacing: 10, children: [
                _ActionBtn(label: 'Admin Panel', icon: Icons.admin_panel_settings_rounded, color: const Color(0xFFD4A017),
                  onTap: () {
                    Navigator.pop(context);
                    final match = _allCompaniesWithDynamic().where((co) => co.name.toLowerCase() == c.name.toLowerCase() || co.name.toLowerCase().contains(c.name.toLowerCase().split(' ')[0])).toList();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyAdminScreen(company: match.isNotEmpty ? match.first : allCompanies.first)));
                  }),
                if (c.status == 'Pending')
                  _ActionBtn(label: 'Approve', icon: Icons.check_circle_outline, color: const Color(0xFF1D9E75),
                    onTap: () { _toggleCompanyStatus(idx); Navigator.pop(context); }),
                _ActionBtn(
                  label: c.status == 'Suspended' ? 'Unsuspend' : 'Suspend',
                  icon: c.status == 'Suspended' ? Icons.check_circle_outline : Icons.block_rounded,
                  color: c.status == 'Suspended' ? const Color(0xFF1D9E75) : const Color(0xFFD85A30),
                  onTap: () { _toggleCompanyStatus(idx); Navigator.pop(context); }),
                _ActionBtn(label: 'View Fleet', icon: Icons.directions_car_rounded, color: const Color(0xFF3B5FD4),
                  onTap: () => Navigator.pop(context)),
              ]),
            ])),
          ]))));
  }

  void _showBookingDetail(BuildContext context, _Booking b, bool isDark, Color card, Color border, Color textPri, Color textSec) {
    final sc = _statusColor(b.status);
    showModalBottomSheet(
      context: context, backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4,
          decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.directions_car_rounded, color: sc, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b.car, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
            Text(b.ref, style: TextStyle(fontSize: 12, color: textSec)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(b.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sc))),
        ]),
        const SizedBox(height: 16),
        Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.07), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.2), width: 0.5)),
          child: Row(children: [
            const Icon(Icons.business_outlined, color: const Color(0xFFD4A017), size: 16),
            const SizedBox(width: 10),
            Text('Company: ', style: TextStyle(fontSize: 13, color: textSec)),
            Text(b.company, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFD4A017))),
          ])),
        const SizedBox(height: 12),
        ...[
          (Icons.person_outline_rounded, 'Customer', b.user),
          (Icons.calendar_today_outlined,'Pick-up',  b.from),
          (Icons.event_outlined,         'Return',   b.to),
          (Icons.timeline_outlined,      'Period',   '${b.from} \u2192 ${b.to}'),
        ].map((r) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
          Icon(r.$1 as IconData, size: 15, color: textSec),
          const SizedBox(width: 10),
          Text('${r.$2}: ', style: TextStyle(fontSize: 12, color: textSec)),
          Expanded(child: Text(r.$3 as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri))),
        ]))),
        const Divider(),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
          Text('\$${b.amount.toInt()}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFFD4A017))),
        ]),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(side: BorderSide(color: border),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text('Close', style: TextStyle(color: textSec)))),
      ])));
  }

  // ══════════════════════════════════════════════
  //  EXTRA SHEETS
  // ══════════════════════════════════════════════
  void _showNotifications(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    final notifs = [
      (Icons.receipt_rounded,       'New booking confirmed',    'Cameron One booked Toyota RAV4 — \$213',    '2 min ago',  const Color(0xFF1D9E75), false),
      (Icons.business_rounded,      'Company pending approval', 'RwandaRide submitted docs for review',     '1 hr ago',   const Color(0xFFD4A017), false),
      (Icons.warning_amber_rounded, 'Account suspended',        'Bob Nkusi account suspended (ToS)',         '3 hr ago',   const Color(0xFFD85A30), false),
      (Icons.star_rounded,          'New review posted',        '5★ review for DriveKigali by Cameron One', '5 hr ago',   const Color(0xFFD4A017), true),
      (Icons.person_add_rounded,    'New user registered',      'Alice Mugisha joined SwiftRide',            'Yesterday',  const Color(0xFF3B5FD4), true),
    ];
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65, minChildSize: 0.4, maxChildSize: 0.9, expand: false,
        builder: (_, ctrl) => Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Row(children: [
              Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFD85A30).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: const Text('3 new', style: TextStyle(fontSize: 11, color: Color(0xFFD85A30), fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: const Text('Mark all read', style: TextStyle(fontSize: 11, color: Color(0xFFD4A017), fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 14),
            Expanded(child: ListView.builder(
              controller: ctrl,
              itemCount: notifs.length,
              itemBuilder: (_, i) {
                final n = notifs[i];
                final isRead = n.$6;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isRead ? card : n.$5.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isRead ? border : n.$5.withOpacity(0.25), width: isRead ? 0.5 : 1)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 36, height: 36,
                      decoration: BoxDecoration(color: n.$5.withOpacity(0.12), shape: BoxShape.circle),
                      child: Icon(n.$1, color: n.$5, size: 17)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(n.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri))),
                        if (!isRead) Container(width: 7, height: 7, decoration: BoxDecoration(color: n.$5, shape: BoxShape.circle)),
                      ]),
                      const SizedBox(height: 2),
                      Text(n.$3, style: TextStyle(fontSize: 11, color: textSec, height: 1.3)),
                      const SizedBox(height: 4),
                      Text(n.$4, style: TextStyle(fontSize: 10, color: textSec.withOpacity(0.6))),
                    ])),
                  ]),
                );
              },
            )),
          ]),
        ),
      ));
  }

  void _showAccountSheet(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        CircleAvatar(radius: 36, backgroundColor: const Color(0xFFD4A017),
          child: const Text('SA', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w800))),
        const SizedBox(height: 12),
        Text('Super Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPri)),
        const SizedBox(height: 2),
        Text('admin@swiftride.rw', style: TextStyle(fontSize: 13, color: textSec)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
          child: const Text('Super Admin · Full Access', style: TextStyle(fontSize: 11, color: Color(0xFFD4A017), fontWeight: FontWeight.w700))),
        const SizedBox(height: 20),
        Divider(color: border, height: 1),
        const SizedBox(height: 8),
        ...[
          (Icons.manage_accounts_rounded, 'Account Settings',    const Color(0xFF3B5FD4)),
          (Icons.security_rounded,        'Security & Password', const Color(0xFF7F77DD)),
          (Icons.bar_chart_rounded,       'Platform Analytics',  const Color(0xFFD4A017)),
          (Icons.settings_rounded,        'System Settings',     const Color(0xFF1D9E75)),
        ].map((item) => ListTile(
          leading: Container(width: 38, height: 38,
            decoration: BoxDecoration(color: item.$3.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(item.$1, color: item.$3, size: 19)),
          title: Text(item.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
          trailing: Icon(Icons.chevron_right_rounded, color: textSec, size: 18),
          onTap: () {
            Navigator.pop(ctx);
            if (item.$2 == 'Platform Analytics') _showAnalyticsSheet(ctx, card, border, textPri, textSec);
            if (item.$2 == 'System Settings')    _showSystemSettings(ctx, card, border, textPri, textSec);
          },
          dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        )),
        const SizedBox(height: 8),
        Divider(color: border, height: 1),
        const SizedBox(height: 8),
        ListTile(
          leading: Container(width: 38, height: 38,
            decoration: BoxDecoration(color: const Color(0xFFD85A30).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.logout_rounded, color: Color(0xFFD85A30), size: 19)),
          title: const Text('Log Out', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFD85A30))),
          onTap: () {
            Navigator.pop(ctx);
            AuthService.logout();
            Navigator.pushNamedAndRemoveUntil(ctx, '/home', (_) => false);
          },
          dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        ),
      ])));
  }

  void _showAnalyticsSheet(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    // Computed values
    final activeCompanies  = _companies.where((c) => c.status == 'Active').length;
    final pendingCompanies = _companies.where((c) => c.status == 'Pending').length;
    final activeBookings   = _bookings.where((b) => b.status == 'Active').length;
    final completedRev     = _bookings.where((b) => b.status == 'Completed').fold(0.0, (s,b) => s+b.amount);
    final activeRev        = _bookings.where((b) => b.status == 'Active').fold(0.0, (s,b) => s+b.amount);
    final upcomingRev      = _bookings.where((b) => b.status == 'Upcoming').fold(0.0, (s,b) => s+b.amount);
    final cancelledRev     = _bookings.where((b) => b.status == 'Cancelled').fold(0.0, (s,b) => s+b.amount);
    final avgRev           = _bookings.isEmpty ? 0.0 : _totalRevenue / _bookings.length;
    final userRatio        = _totalUsers == 0 ? 0.0 : _activeUsers / _totalUsers;
    final coRatio          = _companies.isEmpty ? 0.0 : activeCompanies / _companies.length;
    final bookRatio        = _bookings.isEmpty ? 0.0 : activeBookings / _bookings.length;

    // Bar chart data: revenue by booking status
    final bars = [
      _SABar('Active',    activeRev,    const Color(0xFF3B5FD4)),
      _SABar('Completed', completedRev, const Color(0xFF1D9E75)),
      _SABar('Upcoming',  upcomingRev,  const Color(0xFFD4A017)),
      _SABar('Cancelled', cancelledRev, const Color(0xFFD85A30)),
    ];
    final maxBar = bars.map((b) => b.value).fold(0.0, (a, b) => a > b ? a : b);

    // Donut data: company status breakdown
    final donutData = [
      _SASlice('Active',  activeCompanies.toDouble(),  const Color(0xFF1D9E75)),
      _SASlice('Pending', pendingCompanies.toDouble(), const Color(0xFFD4A017)),
      _SASlice('Inactive',(_companies.length - activeCompanies - pendingCompanies).toDouble(), const Color(0xFFD85A30)),
    ];

    showModalBottomSheet(
      context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.88, minChildSize: 0.4, maxChildSize: 0.97,
        builder: (__, sc) => Container(
          decoration: BoxDecoration(color: card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(controller: sc, padding: const EdgeInsets.fromLTRB(20,16,20,32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Handle + title
              Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 14),
              Center(child: Text('Platform Analytics',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri))),
              const SizedBox(height: 20),

              // ── KPI cards row ──────────────────────────────
              Row(children: [
                _SAKpi('Total Revenue', '\$${_totalRevenue.toInt()}', Icons.attach_money_rounded,    const Color(0xFFD4A017), border),
                const SizedBox(width: 10),
                _SAKpi('Avg / Booking', '\$${avgRev.toStringAsFixed(0)}', Icons.receipt_long_rounded, const Color(0xFF7F77DD), border),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _SAKpi('Total Users',    '$_totalUsers',            Icons.people_rounded,            const Color(0xFF3B5FD4), border),
                const SizedBox(width: 10),
                _SAKpi('Total Bookings', '${_bookings.length}',     Icons.calendar_today_rounded,    const Color(0xFF1D9E75), border),
              ]),
              const SizedBox(height: 20),

              // ── Revenue bar chart ──────────────────────────
              Text('Revenue by Booking Status',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017).withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border, width: 0.5)),
                child: Column(children: [
                  SizedBox(height: 150, child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: bars.map((b) {
                      final ratio = maxBar <= 0 ? 0.0 : b.value / maxBar;
                      return Expanded(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                          Text('\$${b.value.toInt()}',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: b.color)),
                          const SizedBox(height: 4),
                          Container(
                            height: ratio > 0 ? (110 * ratio).clamp(4.0, 110.0) : 4,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                colors: [b.color, b.color.withOpacity(0.4)])),
                          ),
                        ]),
                      ));
                    }).toList(),
                  )),
                  const SizedBox(height: 8),
                  Row(children: bars.map((b) => Expanded(child: Center(
                    child: Text(b.label,
                      style: TextStyle(fontSize: 9, color: textSec, fontWeight: FontWeight.w600)),
                  ))).toList()),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Platform health rings row ──────────────────
              Text('Platform Health',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _SARing('Users Active',   userRatio, _activeUsers, _totalUsers,   const Color(0xFF3B5FD4), border, textPri, textSec)),
                const SizedBox(width: 10),
                Expanded(child: _SARing('Companies Active', coRatio, activeCompanies, _companies.length, const Color(0xFF1D9E75), border, textPri, textSec)),
                const SizedBox(width: 10),
                Expanded(child: _SARing('Bookings Active', bookRatio, activeBookings, _bookings.length, const Color(0xFF7F77DD), border, textPri, textSec)),
              ]),
              const SizedBox(height: 20),

              // ── Company breakdown donut ────────────────────
              Text('Company Status Breakdown',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D9E75).withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border, width: 0.5)),
                child: Row(children: [
                  SizedBox(width: 90, height: 90,
                    child: CustomPaint(
                      painter: _SADonutPainter(donutData, border),
                      child: Center(child: Text('${_companies.length}\nTotal',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textPri, height: 1.3))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: donutData.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        Container(width: 10, height: 10,
                          decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(s.label,
                          style: TextStyle(fontSize: 12, color: textSec))),
                        Text('${s.value.toInt()}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: s.color)),
                      ]),
                    )).toList())),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Summary stat rows ──────────────────────────
              Text('Summary',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 10),
              ...[
                ('Total Revenue',      '\$${_totalRevenue.toInt()}',                                              const Color(0xFFD4A017), Icons.attach_money_rounded),
                ('Active Users',       '$_activeUsers / $_totalUsers',                                            const Color(0xFF3B5FD4), Icons.people_rounded),
                ('Active Companies',   '$activeCompanies / ${_companies.length}',                                 const Color(0xFF7F77DD), Icons.business_rounded),
                ('Active Bookings',    '$activeBookings / ${_bookings.length}',                                   const Color(0xFF1D9E75), Icons.receipt_long_rounded),
                ('Avg Revenue/Booking','\$${avgRev.toStringAsFixed(0)}',                                          const Color(0xFFD4A017), Icons.bar_chart_rounded),
                ('Completed Revenue',  '\$${completedRev.toInt()}',                                               const Color(0xFF1D9E75), Icons.check_circle_outline_rounded),
                ('Pending Companies',  '$pendingCompanies awaiting approval',                                     const Color(0xFFD4A017), Icons.pending_actions_rounded),
              ].map((r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: r.$3.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: r.$3.withOpacity(0.15), width: 0.8)),
                child: Row(children: [
                  Container(width: 32, height: 32,
                    decoration: BoxDecoration(color: r.$3.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(r.$4, color: r.$3, size: 16)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(r.$1, style: TextStyle(fontSize: 13, color: textSec))),
                  Text(r.$2, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: r.$3)),
                ]))),
            ]),
          ),
        ),
      ),
    );
  }

  void _showSystemSettings(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => _SystemSettingsScreen(card: card, border: border, textPri: textPri, textSec: textSec)));
  }

  // ── Helpers ───────────────────────────────────
  // ══════════════════════════════════════════════
  //  AUDIT LOG TAB
  // ══════════════════════════════════════════════
  Widget _auditTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec) {
    final store   = AppDataStore.instance;
    final cats    = ['All', 'Booking', 'Fleet', 'Company', 'User', 'Settings'];
    final entries = _auditFilter == 'All'
        ? store.auditLog
        : store.auditLog.where((e) => e.category == _auditFilter).toList();

    return Column(children: [
      // Filter chips
      SizedBox(height: 44, child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: cats.map((cat) {
          final sel = _auditFilter == cat;
          final catColor = _auditCatColor(cat);
          return GestureDetector(
            onTap: () => setState(() => _auditFilter = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: sel ? catColor : card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? catColor : border, width: 0.8)),
              child: Center(child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: sel ? Colors.white : textSec)))));
        }).toList())),
      // Summary
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${entries.length} entries', style: TextStyle(fontSize: 12, color: textSec)),
          Text('Tap any entry for details', style: TextStyle(fontSize: 11, color: textSec)),
        ])),
      // List
      Expanded(child: entries.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.history_rounded, size: 48, color: textSec),
            const SizedBox(height: 12),
            Text('No audit entries yet', style: TextStyle(color: textSec, fontSize: 15)),
          ]))
        : ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: entries.length,
          itemBuilder: (_, i) {
            final e = entries[i];
            final clr = _auditCatColor(e.category);
            return GestureDetector(
              onTap: () => _showAuditDetail(context, e, isDark, card, border, textPri, textSec),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border, width: 0.5)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 36, height: 36,
                    decoration: BoxDecoration(color: clr.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                    child: Icon(_auditCatIcon(e.category), color: clr, size: 17)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.action, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(e.company.isNotEmpty
                        ? '${e.actor} · ${e.company}'
                        : e.actor,
                      style: TextStyle(fontSize: 10, color: textSec),
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                    const SizedBox(height: 3),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: clr.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(e.category, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: clr))),
                      const SizedBox(width: 6),
                      Expanded(child: Text(e.timestamp,
                        style: TextStyle(fontSize: 9, color: textSec), overflow: TextOverflow.ellipsis)),
                    ]),
                  ])),
                ])));
          })),
    ]);
  }

  void _showAuditDetail(BuildContext context, AuditEntry e, bool isDark, Color card, Color border, Color textPri, Color textSec) {
    final clr = _auditCatColor(e.category);
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4,
          decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),

        // Header
        Row(children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(color: clr.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(_auditCatIcon(e.category), color: clr, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.id, style: TextStyle(fontSize: 11, color: textSec, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
            Text(e.timestamp, style: TextStyle(fontSize: 11, color: textSec)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: clr.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(e.category, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: clr))),
        ]),
        const SizedBox(height: 14),

        // Action — prominent box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: clr.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: clr.withOpacity(0.2), width: 0.5)),
          child: Text(e.action,
            style: TextStyle(fontSize: 14, color: textPri, fontWeight: FontWeight.w500, height: 1.5))),
        const SizedBox(height: 14),

        // Details
        _AuditRow(Icons.person_outline,       'Performed by', e.actor,     textPri, textSec),
        _AuditRow(Icons.shield_outlined,      'Role',         e.actorRole, textPri, textSec),
        if (e.company.isNotEmpty)
          _AuditRow(Icons.business_outlined,  'Company',      e.company,   textPri, textSec),
        _AuditRow(Icons.access_time_outlined, 'Timestamp',    e.timestamp, textPri, textSec),
        _AuditRow(Icons.tag_rounded,          'Entry ID',     e.id,        textPri, textSec),
        const SizedBox(height: 16),

        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4A017), foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
          child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)))),
      ])));
  }

  Color _auditCatColor(String cat) {
    switch (cat) {
      case 'Booking':  return const Color(0xFF1D9E75);
      case 'Fleet':    return const Color(0xFF3B5FD4);
      case 'Company':  return const Color(0xFF7F77DD);
      case 'User':     return const Color(0xFFD4A017);
      case 'Settings': return const Color(0xFF8B91A8);
      default:         return const Color(0xFF8B91A8);
    }
  }

  IconData _auditCatIcon(String cat) {
    switch (cat) {
      case 'Booking':  return Icons.receipt_long_rounded;
      case 'Fleet':    return Icons.directions_car_rounded;
      case 'Company':  return Icons.business_rounded;
      case 'User':     return Icons.person_rounded;
      case 'Settings': return Icons.settings_rounded;
      default:         return Icons.history_rounded;
    }
  }

    void _toggleCompanyStatus(int idx) {
    final c = _companies[idx];
    final next = c.status == 'Active' ? 'Suspended' : c.status == 'Pending' ? 'Active' : 'Active';
    setState(() => _companies[idx] = _Company(c.name, c.agents, c.cars, c.bookings,
      c.revenue, next, c.location, c.rating,
      adminName: c.adminName, adminEmail: c.adminEmail, phone: c.phone, regNumber: c.regNumber));
    try { _store.updateCompanyStatus(c.name, next, _actor, _actorRole); } catch(_) {}
  }

  Color _rentalModelColor(String m) {
    switch (m) {
      case 'Daily':     return const Color(0xFF3B5FD4);
      case 'Monthly':   return const Color(0xFF1D9E75);
      case 'Long-Term': return const Color(0xFF7F77DD);
      case 'Hybrid':    return const Color(0xFFD4A017);
      default:          return const Color(0xFF8B91A8);
    }
  }

  IconData _rentalModelIcon(String m) {
    switch (m) {
      case 'Daily':     return Icons.today_rounded;
      case 'Monthly':   return Icons.calendar_month_rounded;
      case 'Long-Term': return Icons.event_repeat_rounded;
      case 'Hybrid':    return Icons.swap_horiz_rounded;
      default:          return Icons.today_rounded;
    }
  }

  Color _roleColor(String r) {
    switch (r) {
      case 'Company Admin': return const Color(0xFF3B5FD4);
      case 'Company Staff': return const Color(0xFF7F77DD);
      default:              return const Color(0xFFD4A017);
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Active':    case 'Approved': return const Color(0xFF1D9E75);
      case 'Upcoming':                   return const Color(0xFF3B5FD4);
      case 'Pending':                    return const Color(0xFFE8C04A);
      case 'Suspended': case 'Cancelled':return const Color(0xFFD85A30);
      default:                           return const Color(0xFF8B91A8);
    }
  }

  void _toast(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      backgroundColor: const Color(0xFF1D9E75),
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      duration: const Duration(seconds: 2)));
  }

  String _monthYear() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[now.month - 1]} ${now.year}';
  }

  bool isDark(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark;
}

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────
class _KPI extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color, card, border, textPri, textSec;
  final VoidCallback? onTap;
  const _KPI({required this.label, required this.value, required this.icon,
    required this.color, required this.sub, required this.card, required this.border,
    required this.textPri, required this.textSec, this.onTap});
  @override
  Widget build(BuildContext c) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Container(width: 30, height: 30,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 15)),
          const Spacer(),
          if (onTap != null) Icon(Icons.arrow_forward_ios_rounded, color: color, size: 11),
        ]),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPri),
          overflow: TextOverflow.ellipsis, maxLines: 1),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: textSec), overflow: TextOverflow.ellipsis, maxLines: 1),
        Text(sub,   style: TextStyle(fontSize: 9,  color: color),   overflow: TextOverflow.ellipsis, maxLines: 1),
      ])));
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);
  Color get _c {
    switch (status) {
      case 'Active':case 'Approved': return const Color(0xFF1D9E75);
      case 'Upcoming':               return const Color(0xFF3B5FD4);
      case 'Pending':                return const Color(0xFFE8C04A);
      case 'Suspended':case 'Cancelled': return const Color(0xFFD85A30);
      default:                       return const Color(0xFF8B91A8);
    }
  }
  @override Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(color: _c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _c)));
}

class _MiniStat extends StatelessWidget {
  final String label, value; final Color textPri, textSec;
  const _MiniStat({required this.label, required this.value, required this.textPri, required this.textSec});
  @override Widget build(BuildContext c) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri), overflow: TextOverflow.ellipsis),
    Text(label, style: TextStyle(fontSize: 9,  color: textSec)),
  ]));
}

class _ActionBtn extends StatelessWidget {
  final String label; final IconData icon; final Color color; final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});
  @override Widget build(BuildContext c) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ])));
}

class _DrawerStat extends StatelessWidget {
  final String label, value;
  const _DrawerStat({required this.label, required this.value});
  @override Widget build(BuildContext c) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
    Text(label,  style: const TextStyle(color: Color(0xFF8B91A8), fontSize: 10)),
  ]));
}

Widget _SField(String label, String hint, TextEditingController ctrl, Color textPri, Color textSec,
    {bool obscure = false, bool numeric = false}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 11, color: textSec, fontWeight: FontWeight.w600)),
    const SizedBox(height: 4),
    TextField(
      controller: ctrl, obscureText: obscure,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      style: TextStyle(fontSize: 13, color: textPri),
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(color: textSec, fontSize: 13),
        filled: true, fillColor: const Color(0xFF1C2236),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
  ]);
}

Widget _SectionLabel(String text, Color textSec) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Row(children: [
    Container(width: 3, height: 14, decoration: BoxDecoration(color: const Color(0xFFD4A017), borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFD4A017), letterSpacing: 0.3)),
  ]));

Widget _InfoCard({required Color card, required Color border, required List<Widget> children}) =>
  Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
    child: Column(children: children));

Widget _InfoRow(IconData icon, String label, String value, Color textPri, Color textSec) =>
  Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
    Icon(icon, size: 14, color: textSec),
    const SizedBox(width: 10),
    Text('$label: ', style: TextStyle(fontSize: 12, color: textSec)),
    Expanded(child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri), overflow: TextOverflow.ellipsis)),
  ]));

// ─────────────────────────────────────────────
//  BOOKING TAB HELPER WIDGETS
// ─────────────────────────────────────────────
class _OverviewStat extends StatelessWidget {
  final String label, value; final Color color;
  const _OverviewStat({required this.label, required this.value, required this.color});
  @override Widget build(BuildContext c) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
    Text(label,  style: const TextStyle(fontSize: 9, color: Color(0xFF8B91A8))),
  ]));
}

class _CoStat extends StatelessWidget {
  final String label, value; final Color color;
  const _CoStat({required this.label, required this.value, required this.color});
  @override Widget build(BuildContext c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 6),
    margin: const EdgeInsets.only(right: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(8)),
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
      Text(label,  style: TextStyle(fontSize: 8,  color: color.withOpacity(0.7))),
    ])));
}

// ─────────────────────────────────────────────
//  SYSTEM SETTINGS FULL SCREEN
// ─────────────────────────────────────────────
class _SystemSettingsScreen extends StatefulWidget {
  final Color card, border, textPri, textSec;
  const _SystemSettingsScreen({required this.card, required this.border, required this.textPri, required this.textSec});
  @override State<_SystemSettingsScreen> createState() => _SystemSettingsState();
}

class _SystemSettingsState extends State<_SystemSettingsScreen> {
  // Toggles
  bool _maintenance  = false;
  bool _emailNotifs  = true;
  bool _smsNotifs    = false;
  bool _autoApprove  = false;
  bool _twoFactor    = true;
  bool _auditLog     = true;
  // Values
  String _language   = 'English';
  String _currency   = 'USD';
  String _commission = '10';
  String _timezone   = 'Africa/Kigali';
  final _commCtrl    = TextEditingController(text: '10');

  @override
  Widget build(BuildContext ctx) {
    final isDark  = Theme.of(ctx).brightness == Brightness.dark;
    final bg      = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);
    final card    = isDark ? const Color(0xFF141828) : Colors.white;
    final border  = isDark ? const Color(0xFF252B3E) : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white             : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8)  : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
        title: const Text('System Settings', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // ── Platform ──────────────────────────────────────────
        _SettSection('Platform', textSec),
        _SettCard(card, border, [
          _DropRow(Icons.language_outlined,     'Language',         _language,  ['English','French','Kinyarwanda','Swahili'], textPri, textSec, (v) => setState(() => _language = v!)),
          _DivRow(border),
          _DropRow(Icons.attach_money_rounded,  'Default Currency', _currency,  ['USD','EUR','RWF','GBP'],                   textPri, textSec, (v) => setState(() => _currency = v!)),
          _DivRow(border),
          _DropRow(Icons.public_rounded,        'Timezone',         _timezone,  ['Africa/Kigali','UTC','Europe/Paris','America/New_York'], textPri, textSec, (v) => setState(() => _timezone = v!)),
        ]),

        const SizedBox(height: 16),

        // ── Business Rules ────────────────────────────────────
        _SettSection('Business Rules', textSec),
        _SettCard(card, border, [
          _TogRow(Icons.percent_rounded,        'Auto-approve companies', 'New companies approved instantly', _autoApprove, textPri, textSec, (v) => setState(() => _autoApprove = v)),
          _DivRow(border),
          // Commission input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.monetization_on_outlined, color: const Color(0xFFD4A017), size: 18)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Platform Commission (%)', style: TextStyle(fontSize: 13, color: textPri)),
                Text('Percentage taken per booking', style: TextStyle(fontSize: 11, color: textSec)),
              ])),
              SizedBox(width: 60, child: TextField(
                controller: _commCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri),
                onChanged: (v) => _commission = v,
                decoration: InputDecoration(
                  filled: true, fillColor: isDark ? const Color(0xFF1C2236) : const Color(0xFFF2F4F8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8)),
              )),
            ])),
        ]),

        const SizedBox(height: 16),

        // ── Notifications ─────────────────────────────────────
        _SettSection('Notifications', textSec),
        _SettCard(card, border, [
          _TogRow(Icons.email_outlined,         'Email Notifications', 'Send alerts via email', _emailNotifs, textPri, textSec, (v) => setState(() => _emailNotifs = v)),
          _DivRow(border),
          _TogRow(Icons.sms_outlined,           'SMS Notifications',   'Send alerts via SMS',  _smsNotifs,  textPri, textSec, (v) => setState(() => _smsNotifs = v)),
        ]),

        const SizedBox(height: 16),

        // ── Security ──────────────────────────────────────────
        _SettSection('Security', textSec),
        _SettCard(card, border, [
          _TogRow(Icons.shield_outlined,        'Two-Factor Auth',     'Require 2FA for admins',      _twoFactor,   textPri, textSec, (v) => setState(() => _twoFactor = v)),
          _DivRow(border),
          _TogRow(Icons.history_outlined,       'Audit Log',           'Log all admin actions',       _auditLog,    textPri, textSec, (v) => setState(() => _auditLog = v)),
          _DivRow(border),
          _TogRow(Icons.build_outlined,         'Maintenance Mode',    'Take platform offline briefly',_maintenance, textPri, textSec, (v) => setState(() => _maintenance = v),
            activeColor: const Color(0xFFD85A30)),
        ]),

        const SizedBox(height: 16),

        // ── Data & Legal ──────────────────────────────────────
        _SettSection('Data & Legal', textSec),
        _SettCard(card, border, [
          _NavRow(Icons.download_rounded,       'Export Platform Data',  'Download CSV / JSON backup', textPri, textSec, onTap: () => _toast(ctx, 'Preparing export...')),
          _DivRow(border),
          _NavRow(Icons.delete_sweep_outlined,  'Clear Cached Data',     'Free up server storage',    textPri, textSec, onTap: () => _toast(ctx, 'Cache cleared')),
          _DivRow(border),
          _NavRow(Icons.policy_outlined,        'Privacy Policy',        'View & edit policy doc',    textPri, textSec, onTap: () => _showInfoSheet(ctx, 'Privacy Policy', 'SwiftRide collects only the data needed to operate the platform. Data is never sold. Users may request deletion at any time.', textPri, textSec, card, border)),
          _DivRow(border),
          _NavRow(Icons.description_outlined,   'Terms of Service',      'View & edit terms',         textPri, textSec, onTap: () => _showInfoSheet(ctx, 'Terms of Service', 'By using SwiftRide you agree to our rental terms. Companies must maintain valid insurance and comply with Rwandan transport regulations.', textPri, textSec, card, border)),
        ]),

        const SizedBox(height: 16),

        // ── About ─────────────────────────────────────────────
        _SettSection('About', textSec),
        _SettCard(card, border, [
          _NavRow(Icons.info_outline_rounded,   'App Version',     'SwiftRide Admin v1.0.0', textPri, textSec, trailing: 'v1.0.0', onTap: () => _showInfoSheet(ctx, 'App Version', 'SwiftRide Admin Panel\nVersion: 1.0.0\nBuild: 2026.06\nEnvironment: Demo', textPri, textSec, card, border)),
          _DivRow(border),
          _NavRow(Icons.support_agent_rounded,  'Support',         'Contact dev team',       textPri, textSec, onTap: () => _showInfoSheet(ctx, 'Support', 'For technical support contact:\n\nEmail: support@swiftride.rw\nPhone: +250 788 000 000\nHours: Mon–Fri 8AM–6PM', textPri, textSec, card, border)),
        ]),

        const SizedBox(height: 24),

        // ── Save button ───────────────────────────────────────
        ElevatedButton(
          onPressed: () { _toast(ctx, 'Settings saved successfully'); Navigator.pop(ctx); },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4A017), foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
          child: const Text('Save Settings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
        const SizedBox(height: 30),
      ]),
    );
  }

  void _toast(BuildContext ctx, String msg) => ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(backgroundColor: const Color(0xFF1D9E75), duration: const Duration(seconds: 2),
      content: Text(msg, style: const TextStyle(color: Colors.white))));
}

// ── Settings screen helper widgets ────────────────────────
Widget _SettSection(String label, Color textSec) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Row(children: [
    Container(width: 3, height: 14, decoration: BoxDecoration(color: const Color(0xFFD4A017), borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFFD4A017), letterSpacing: 1)),
  ]));

Widget _SettCard(Color card, Color border, List<Widget> children) => Container(
  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
  child: Column(children: children));

Widget _DivRow(Color border) => Divider(color: border, height: 1, indent: 64);

Widget _TogRow(IconData icon, String label, String sub, bool val, Color textPri, Color textSec,
    ValueChanged<bool> onChanged, {Color activeColor = const Color(0xFFD4A017)}) =>
  ListTile(
    leading: Container(width: 36, height: 36,
      decoration: BoxDecoration(color: activeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, color: activeColor, size: 18)),
    title: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPri)),
    subtitle: Text(sub, style: TextStyle(fontSize: 11, color: textSec)),
    trailing: Switch(value: val, onChanged: onChanged, activeColor: activeColor,
      activeTrackColor: activeColor.withOpacity(0.3), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
    dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2));

Widget _NavRow(IconData icon, String label, String sub, Color textPri, Color textSec,
    {String? trailing, required VoidCallback onTap}) =>
  ListTile(
    onTap: onTap,
    leading: Container(width: 36, height: 36,
      decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, color: const Color(0xFFD4A017), size: 18)),
    title: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPri)),
    subtitle: Text(sub, style: TextStyle(fontSize: 11, color: textSec)),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      if (trailing != null) Text(trailing, style: TextStyle(fontSize: 12, color: textSec)),
      const SizedBox(width: 4),
      Icon(Icons.chevron_right_rounded, color: textSec, size: 16),
    ]),
    dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2));

Widget _DropRow(IconData icon, String label, String val, List<String> opts,
    Color textPri, Color textSec, ValueChanged<String?> onChanged) =>
  ListTile(
    leading: Container(width: 36, height: 36,
      decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, color: const Color(0xFFD4A017), size: 18)),
    title: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPri)),
    trailing: DropdownButton<String>(
      value: val, items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o, style: TextStyle(fontSize: 12, color: textPri)))).toList(),
      onChanged: onChanged,
      underline: const SizedBox(), icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSec, size: 18),
      dropdownColor: const Color(0xFF141828)),
    dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2));

Widget _AuditRow(IconData icon, String label, String value, Color textPri, Color textSec) =>
  Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
    Icon(icon, size: 15, color: textSec), const SizedBox(width: 10),
    Text('$label: ', style: TextStyle(fontSize: 12, color: textSec)),
    Expanded(child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri),
      overflow: TextOverflow.ellipsis)),
  ]));

void _showInfoSheet(BuildContext ctx, String title, String body,
    Color textPri, Color textSec, Color card, Color border) {
  showModalBottomSheet(context: ctx, backgroundColor: card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 36), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 16),
      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
      const SizedBox(height: 16),
      Container(width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.06),
          borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.2))),
        child: Text(body, style: TextStyle(fontSize: 13, color: textSec, height: 1.6))),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: () => Navigator.pop(ctx),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A017), foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)))),
    ])));
}

// ── Super Admin Analytics helpers ────────────────────────────────────────────

class _SABar {
  final String label; final double value; final Color color;
  const _SABar(this.label, this.value, this.color);
}

class _SASlice {
  final String label; final double value; final Color color;
  const _SASlice(this.label, this.value, this.color);
}

class _SADonutPainter extends CustomPainter {
  final List<_SASlice> data; final Color track;
  const _SADonutPainter(this.data, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r  = (size.width / 2) - 6;
    final sw = 12.0;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final total = data.fold(0.0, (s, d) => s + d.value);

    // Track
    canvas.drawArc(rect, 0, 6.2832, false,
      Paint()..color = track..strokeWidth = sw..style = PaintingStyle.stroke);

    if (total <= 0) return;
    double start = -1.5708;
    for (final s in data) {
      if (s.value <= 0) continue;
      final sweep = 6.2832 * (s.value / total);
      canvas.drawArc(rect, start, sweep, false,
        Paint()..color = s.color..strokeWidth = sw..style = PaintingStyle.stroke
               ..strokeCap = StrokeCap.butt);
      start += sweep;
    }
  }

  @override bool shouldRepaint(_SADonutPainter o) => true;
}

class _SAKpi extends StatelessWidget {
  final String label, value; final IconData icon; final Color color, border;
  const _SAKpi(this.label, this.value, this.icon, this.color, this.border);
  @override Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.2), width: 0.8)),
    child: Row(children: [
      Container(width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 9, color: color.withOpacity(0.7), fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
      ])),
    ]),
  ));
}

class _SARing extends StatelessWidget {
  final String label; final double ratio;
  final int active, total; final Color color, border, textPri, textSec;
  const _SARing(this.label, this.ratio, this.active, this.total,
    this.color, this.border, this.textPri, this.textSec);

  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.05),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.2), width: 0.8)),
    child: Column(children: [
      SizedBox(width: 64, height: 64,
        child: CustomPaint(
          painter: _SASimpleRing(ratio, color, border),
          child: Center(child: Text('${(ratio * 100).toInt()}%',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color))),
        ),
      ),
      const SizedBox(height: 6),
      Text('$active/$total', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 2),
      Text(label, textAlign: TextAlign.center,
        style: TextStyle(fontSize: 9, color: textSec), maxLines: 2),
    ]),
  );
}

class _SASimpleRing extends CustomPainter {
  final double ratio; final Color fill, track;
  const _SASimpleRing(this.ratio, this.fill, this.track);
  @override void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 6;
    final rect = Rect.fromCircle(center: Offset(size.width/2, size.height/2), radius: r);
    final sw = 8.0;
    canvas.drawArc(rect, 0, 6.2832, false,
      Paint()..color = track..strokeWidth = sw..style = PaintingStyle.stroke);
    if (ratio > 0) canvas.drawArc(rect, -1.5708, 6.2832 * ratio.clamp(0.0, 1.0), false,
      Paint()..color = fill..strokeWidth = sw..style = PaintingStyle.stroke
             ..strokeCap = StrokeCap.round);
  }
  @override bool shouldRepaint(_SASimpleRing o) => o.ratio != ratio;
}
