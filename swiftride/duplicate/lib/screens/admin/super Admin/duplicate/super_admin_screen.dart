// lib/screens/admin/super_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart' show AppColors, themeNotifier;
import 'package:swiftride/screens/guest/companies_screen.dart' show RentalCompany, CompanyCar, allCompanies;
import 'package:swiftride/screens/admin/company_admin_screen.dart' show CompanyAdminScreen;
import 'package:swiftride/services/auth_service.dart';

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
  final double revenue, rating;
  final String adminName, adminEmail, phone, regNumber;
  const _Company(this.name, this.agents, this.cars, this.bookings,
      this.revenue, this.status, this.location, this.rating,
      {this.adminName = '', this.adminEmail = '', this.phone = '', this.regNumber = ''});
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
  _Company('DriveKigali',  4, 28, 156, 18200.0, 'Active',    'KG 7 Ave, Kigali',      4.9, adminName: 'Diana Uwase',   adminEmail: 'diana@email.com',   phone: '+250 788 100 001', regNumber: 'RW-BIZ-2019-001'),
  _Company('SafariWheels', 3, 12,  89, 11400.0, 'Active',    'KN 3 Rd, Remera',       4.8, adminName: 'James Doe',     adminEmail: 'james@safari.rw',   phone: '+250 788 200 002', regNumber: 'RW-BIZ-2020-042'),
  _Company('LuxDrive',     6,  8,  44,  9800.0, 'Active',    'KG 11 Ave, Nyarutarama',4.7, adminName: 'Mary Uwimana',  adminEmail: 'mary@luxdrive.rw',  phone: '+250 788 300 003', regNumber: 'RW-BIZ-2021-017'),
  _Company('RwandaRide',   2,  5,  21,  2400.0, 'Pending',   'KN 5 Rd, Nyamirambo',   4.5, adminName: 'Paul Ndoli',    adminEmail: 'paul@rwandaride.rw',phone: '+250 788 400 004', regNumber: 'RW-BIZ-2024-088'),
  _Company('VanGo',        1,  6,  12,  1100.0, 'Suspended', 'KG 9 Ave, Gisozi',      3.9, adminName: 'Kevin Ishimwe', adminEmail: 'kevin@vango.rw',    phone: '+250 788 500 005', regNumber: 'RW-BIZ-2022-033'),
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

  @override void initState() {
    super.initState();
    _tc = TabController(length: 4, vsync: this);
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
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: const Text('SUPER', style: TextStyle(color: AppColors.gold, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5))),
          const SizedBox(width: 8),
          const Text('SwiftRide Admin', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => _showNotifications(context, card, border, textPri, textSec)),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(radius: 15, backgroundColor: AppColors.gold,
              child: const Text('SA', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w800)))),
        ],
        bottom: TabBar(
          controller: _tc,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: const Color(0xFF8B91A8),
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined, size: 18),    text: 'Dashboard'),
            Tab(icon: Icon(Icons.people_outlined, size: 18),       text: 'Users'),
            Tab(icon: Icon(Icons.business_outlined, size: 18),     text: 'Companies'),
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
          icon: Icons.attach_money_rounded, color: AppColors.gold,
          card: card, border: border, textPri: textPri, textSec: textSec,
          onTap: () => _showAnalyticsSheet(context, card, border, textPri, textSec))),
      ]),

      const SizedBox(height: 20),
      Text('Recent Activity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),
      ...[
        (Icons.person_add_rounded,   const Color(0xFF3B5FD4), 'New user registered',      'Alice Mugisha joined',       '2 min ago',  1),
        (Icons.receipt_rounded,      const Color(0xFF1D9E75), 'Booking confirmed',         'SW240005 · \$200',           '15 min ago', 3),
        (Icons.business_rounded,     const Color(0xFF7F77DD), 'Company pending approval',  'RwandaRide submitted docs',  '1 hr ago',   2),
        (Icons.cancel_rounded,       const Color(0xFFD85A30), 'Booking cancelled',         'SW240004 by Bob Nkusi',      '2 hr ago',   3),
        (Icons.star_rounded,         AppColors.gold,          'Review posted',             '5★ for DriveKigali',         '3 hr ago',   2),
      ].map((a) => GestureDetector(
        onTap: () { _tc.animateTo(a.$6 as int); setState(() => _tab = a.$6 as int); },
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
          ])))),

      const SizedBox(height: 20),
      Text('Needs Attention', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),
      ...[
        (Icons.pending_rounded,       const Color(0xFFD85A30), 'RwandaRide approval pending', '1 company awaiting review',  2),
        (Icons.warning_amber_rounded, const Color(0xFFE8C04A), 'Bob Nkusi account suspended', 'Review suspension reason',    1),
        (Icons.support_agent_rounded, const Color(0xFF3B5FD4), '3 support tickets open',      'Respond to user queries',     1),
      ].map((a) => GestureDetector(
        onTap: () { _tc.animateTo(a.$5 as int); setState(() => _tab = a.$5 as int); },
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
          ])))),
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
            decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(12)),
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
                      Icon(Icons.business_outlined, size: 10, color: AppColors.gold),
                      const SizedBox(width: 2),
                      Text(u.company!, style: const TextStyle(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.w600)),
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
            backgroundColor: AppColors.gold, foregroundColor: Colors.black,
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
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () {
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
          border: Border.all(color: AppColors.gold.withOpacity(0.2), width: 0.8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.directions_car_rounded, color: AppColors.gold, size: 16),
            const SizedBox(width: 8),
            const Text('Fleet Rental Overview',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('\$${totalRevenue.toInt()} total',
              style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _OverviewStat(label: 'Rented Now',  value: '$totalActive',              color: const Color(0xFF1D9E75)),
            _OverviewStat(label: 'Companies',   value: '${companyNames.length}',    color: const Color(0xFF3B5FD4)),
            _OverviewStat(label: 'Total Trips', value: '${_bookings.length}',       color: const Color(0xFF7F77DD)),
            _OverviewStat(label: 'Completed',   value: '$totalCompleted',           color: AppColors.gold),
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
                      _CoStat(label: 'Completed', value: '$coDone',     color: AppColors.gold),
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
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.gold)),
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
            border: Border(bottom: BorderSide(color: AppColors.gold.withOpacity(0.2), width: 0.5))),
          child: Column(children: [
            Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 2)),
                child: const Center(child: Text('SA',
                  style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w800)))),
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
                    color: AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5)),
                  child: const Text('SUPER ADMIN',
                    style: TextStyle(color: AppColors.gold, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2))),
              ])),
            ]),
            const SizedBox(height: 16),
            // Quick stats row
            Row(children: [
              _DrawerStat(label: 'Users',     value: '${_users.length}'),
              _DrawerStat(label: 'Companies', value: '${_companies.length}'),
              _DrawerStat(label: 'Bookings',  value: '${_bookings.length}'),
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
                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  color: AppColors.gold, size: 16)),
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
                  activeColor: AppColors.gold,
                  activeTrackColor: AppColors.gold.withOpacity(0.3),
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
                color: isActive ? AppColors.gold.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(item.$1 as IconData,
                  color: isActive ? AppColors.gold : textSec, size: 20),
                title: Text(item.$2 as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive ? AppColors.gold : textPri)),
                trailing: isActive
                    ? Container(width: 4, height: 20,
                        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2)))
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
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFFD85A30).withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFD85A30), size: 18)),
            title: const Text('Sign Out',
              style: TextStyle(fontSize: 14, color: Color(0xFFD85A30), fontWeight: FontWeight.w600)),
            onTap: () { AuthService.logout(); Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false); },
            dense: true)),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black,
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
    final nameC    = TextEditingController();
    final locC     = TextEditingController();
    final phoneC   = TextEditingController();
    final regC     = TextEditingController();
    final emailC   = TextEditingController();
    final adminNameC  = TextEditingController();
    final adminEmailC = TextEditingController();
    bool docUploaded = false;

    showModalBottomSheet(
      context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx2, setS) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),
          Center(child: Text('Register Company', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri))),
          const SizedBox(height: 20),

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

          const SizedBox(height: 20),
          _SectionLabel('Company Admin / Owner', textSec),
          _SField('Admin Full Name', 'e.g. Jean Claude', adminNameC, textPri, textSec),
          const SizedBox(height: 10),
          _SField('Admin Email', 'admin@company.rw', adminEmailC, textPri, textSec),

          const SizedBox(height: 20),
          _SectionLabel('Legitimacy Documents', textSec),
          GestureDetector(
            onTap: () => setS(() => docUploaded = !docUploaded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: docUploaded ? const Color(0xFF1D9E75).withOpacity(0.07) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: docUploaded ? const Color(0xFF1D9E75) : border,
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
                  decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Browse', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w700))),
              ])),
          ),

          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (nameC.text.isEmpty) return;
              setState(() {
                _companies.add(_Company(
                  nameC.text, 0, 0, 0, 0, 'Pending', locC.text, 0.0,
                  adminName: adminNameC.text, adminEmail: adminEmailC.text,
                  phone: phoneC.text, regNumber: regC.text));
              });
              Navigator.pop(ctx);
              _toast(ctx, '${nameC.text} registered — pending approval');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Submit for Approval', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)))),
          const SizedBox(height: 8),
        ]))))));
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
                      Icon(Icons.business_outlined, size: 12, color: AppColors.gold),
                      const SizedBox(width: 3),
                      Text(u.company!, style: const TextStyle(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600)),
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
                    setState(() => _users[idx] = _User(u.name, u.email, u.phone,
                      u.status == 'Suspended' ? 'Active' : 'Suspended',
                      u.trips, u.spent, u.since, u.isSuperAdmin, role: u.role, company: u.company));
                    Navigator.pop(context);
                  }),
                _ActionBtn(label: 'Reset Password', icon: Icons.lock_reset_rounded,  color: const Color(0xFF7F77DD), onTap: () => Navigator.pop(context)),
                _ActionBtn(label: 'Send Message',   icon: Icons.mail_outline_rounded, color: AppColors.gold,         onTap: () => Navigator.pop(context)),
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
                    const Icon(Icons.star_rounded, color: AppColors.gold, size: 13),
                    const SizedBox(width: 3),
                    Text('${c.rating}', style: const TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600)),
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
                _ActionBtn(label: 'Admin Panel', icon: Icons.admin_panel_settings_rounded, color: AppColors.gold,
                  onTap: () {
                    Navigator.pop(context);
                    final match = allCompanies.where((co) => co.name.toLowerCase().contains(c.name.toLowerCase().split(' ')[0])).toList();
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
          decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.07), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withOpacity(0.2), width: 0.5)),
          child: Row(children: [
            const Icon(Icons.business_outlined, color: AppColors.gold, size: 16),
            const SizedBox(width: 10),
            Text('Company: ', style: TextStyle(fontSize: 13, color: textSec)),
            Text(b.company, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
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
          Text('\$${b.amount.toInt()}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.gold)),
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
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 14),
        Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
        const SizedBox(height: 16),
        ...[
          ('New booking: Cameron One', '2 min ago', const Color(0xFF1D9E75)),
          ('RwandaRide approval pending', '1 hr ago', AppColors.gold),
          ('Bob Nkusi suspended', '3 hr ago', const Color(0xFFD85A30)),
        ].map((n) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: n.$3.withOpacity(0.07), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: n.$3.withOpacity(0.2), width: 0.5)),
          child: Row(children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(color: n.$3.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(Icons.notifications_outlined, color: n.$3, size: 16)),
            const SizedBox(width: 10),
            Expanded(child: Text(n.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri))),
            Text(n.$2, style: TextStyle(fontSize: 10, color: textSec)),
          ]))),
      ])));
  }

  void _showAnalyticsSheet(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 14),
        Text('Platform Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
        const SizedBox(height: 16),
        ...[
          ('Total Revenue',     '\$${_totalRevenue.toInt()}',           AppColors.gold),
          ('Active Users',      '$_activeUsers / $_totalUsers',         const Color(0xFF3B5FD4)),
          ('Active Companies',  '${_companies.where((c) => c.status == "Active").length} / ${_companies.length}', const Color(0xFF7F77DD)),
          ('Active Bookings',   '${_bookings.where((b) => b.status == "Active").length} / ${_bookings.length}',   const Color(0xFF1D9E75)),
          ('Avg Revenue/Booking','\$${(_totalRevenue / _bookings.length).toStringAsFixed(0)}',                     AppColors.gold),
        ].map((r) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: r.$3.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
            child: Icon(Icons.bar_chart_rounded, color: r.$3, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(r.$1, style: TextStyle(fontSize: 13, color: textSec))),
          Text(r.$2, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: r.$3)),
        ]))),
      ])));
  }

  void _showSystemSettings(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => _SystemSettingsScreen(card: card, border: border, textPri: textPri, textSec: textSec)));
  }

  // ── Helpers ───────────────────────────────────
  void _toggleCompanyStatus(int idx) {
    final c = _companies[idx];
    final next = c.status == 'Active' ? 'Suspended' : c.status == 'Pending' ? 'Active' : 'Active';
    setState(() => _companies[idx] = _Company(c.name, c.agents, c.cars, c.bookings,
      c.revenue, next, c.location, c.rating,
      adminName: c.adminName, adminEmail: c.adminEmail, phone: c.phone, regNumber: c.regNumber));
  }

  Color _roleColor(String r) {
    switch (r) {
      case 'Company Admin': return const Color(0xFF3B5FD4);
      case 'Company Staff': return const Color(0xFF7F77DD);
      default:              return AppColors.gold;
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
    Container(width: 3, height: 14, decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 0.3)),
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
                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.monetization_on_outlined, color: AppColors.gold, size: 18)),
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
          _NavRow(Icons.policy_outlined,        'Privacy Policy',        'View & edit policy doc',    textPri, textSec, onTap: () {}),
          _DivRow(border),
          _NavRow(Icons.description_outlined,   'Terms of Service',      'View & edit terms',         textPri, textSec, onTap: () {}),
        ]),

        const SizedBox(height: 16),

        // ── About ─────────────────────────────────────────────
        _SettSection('About', textSec),
        _SettCard(card, border, [
          _NavRow(Icons.info_outline_rounded,   'App Version',     'SwiftRide Admin v1.0.0', textPri, textSec, trailing: 'v1.0.0', onTap: () {}),
          _DivRow(border),
          _NavRow(Icons.support_agent_rounded,  'Support',         'Contact dev team',       textPri, textSec, onTap: () {}),
        ]),

        const SizedBox(height: 24),

        // ── Save button ───────────────────────────────────────
        ElevatedButton(
          onPressed: () { _toast(ctx, 'Settings saved successfully'); Navigator.pop(ctx); },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold, foregroundColor: Colors.black,
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
    Container(width: 3, height: 14, decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 1)),
  ]));

Widget _SettCard(Color card, Color border, List<Widget> children) => Container(
  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
  child: Column(children: children));

Widget _DivRow(Color border) => Divider(color: border, height: 1, indent: 64);

Widget _TogRow(IconData icon, String label, String sub, bool val, Color textPri, Color textSec,
    ValueChanged<bool> onChanged, {Color activeColor = AppColors.gold}) =>
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
      decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, color: AppColors.gold, size: 18)),
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
      decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, color: AppColors.gold, size: 18)),
    title: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPri)),
    trailing: DropdownButton<String>(
      value: val, items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o, style: TextStyle(fontSize: 12, color: textPri)))).toList(),
      onChanged: onChanged,
      underline: const SizedBox(), icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSec, size: 18),
      dropdownColor: const Color(0xFF141828)),
    dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2));
