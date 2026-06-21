// lib/screens/admin/company_staff_screen.dart
//
// Company Staff Panel — restricted access:
//  ✓ View fleet status & toggle availability
//  ✓ View assigned bookings & update status
//  ✓ View & reply to customer messages
//  ✗ Cannot add/delete cars
//  ✗ Cannot manage team members
//  ✗ Cannot access financials / analytics
//  ✗ Cannot change company settings
//  ✗ Cannot see other staff accounts
import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart' show AppColors, themeNotifier;
import 'package:swiftride/services/auth_service.dart';

// ─────────────────────────────────────────────
//  SEED DATA
// ─────────────────────────────────────────────
class _StaffBooking {
  final String ref, customer, car, from, to, status, phone;
  final double amount; final int days;
  const _StaffBooking(this.ref, this.customer, this.car, this.from, this.to, this.days, this.amount, this.status, this.phone);
}

class _StaffCar {
  final String name, category, fuel, transmission;
  final int seats; final double price; bool available;
  _StaffCar(this.name, this.category, this.price, this.seats, this.transmission, this.fuel, {this.available = true});
}

class _StaffMessage {
  final String customer, lastMsg, time, initials;
  final int unread; final Color avatarColor;
  const _StaffMessage(this.customer, this.initials, this.lastMsg, this.time, this.unread, this.avatarColor);
}

// ─────────────────────────────────────────────
class CompanyStaffScreen extends StatefulWidget {
  const CompanyStaffScreen({super.key});
  @override State<CompanyStaffScreen> createState() => _StaffState();
}

class _StaffState extends State<CompanyStaffScreen> with SingleTickerProviderStateMixin {
  late TabController _tc;
  int _tab = 0;

  late List<_StaffBooking> _bookings;
  late List<_StaffCar>     _fleet;
  late List<_StaffMessage> _messages;

  String _bookingFilter = 'All';
  String _notifMsg = '';
  bool   _showNotif = false;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
    _tc.addListener(() => setState(() => _tab = _tc.index));

    _bookings = [
      _StaffBooking('SW240001', 'Cameron One',    'Toyota RAV4',      'May 24', 'May 27', 3, 135.0, 'Active',    '+250 788 000 001'),
      _StaffBooking('SW240002', 'Diana Uwase',    'BMW 5 Series',     'Jun 1',  'Jun 3',  2, 180.0, 'Upcoming',  '+250 788 111 002'),
      _StaffBooking('SW240003', 'Alice Mugisha',  'Hyundai Tucson',   'Apr 10', 'Apr 12', 2, 116.0, 'Completed', '+250 788 222 003'),
      _StaffBooking('SW240004', 'Bob Nkusi',      'Mitsubishi Pajero','Mar 5',  'Mar 7',  2, 130.0, 'Cancelled', '+250 788 333 004'),
      _StaffBooking('SW240005', 'Fiona Ingabire', 'Toyota RAV4',      'Jun 8',  'Jun 10', 2, 120.0, 'Active',    '+250 788 444 005'),
    ];

    _fleet = [
      _StaffCar('Toyota RAV4',       'SUV',      60,  5, 'Auto',   'Petrol',  available: true),
      _StaffCar('Hyundai Tucson',     'SUV',      55,  5, 'Auto',   'Petrol',  available: false),
      _StaffCar('BMW 5 Series',       'Luxury',   90,  5, 'Auto',   'Petrol',  available: true),
      _StaffCar('Mitsubishi Pajero',  '4x4',      80,  7, 'Manual', 'Diesel',  available: true),
      _StaffCar('Volkswagen Golf',    'Economy',  38,  5, 'Manual', 'Petrol',  available: false),
    ];

    _messages = const [
      _StaffMessage('Cameron One',   'CO', 'When can I pick up the car?',          '10:32 AM', 2, Color(0xFF1D9E75)),
      _StaffMessage('Diana Uwase',   'DU', 'Thank you for the confirmation!',       'Yesterday',0, Color(0xFF3B5FD4)),
      _StaffMessage('Alice Mugisha', 'AM', 'Do you have a sedan available?',        'Mon',      1, Color(0xFF7F77DD)),
      _StaffMessage('Fiona Ingabire','FI', 'I need to extend my rental by 1 day.', 'Sun',      0, Color(0xFFD85A30)),
    ];
  }

  @override void dispose() { _tc.dispose(); super.dispose(); }

  void _notify(String msg) {
    setState(() { _notifMsg = msg; _showNotif = true; });
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _showNotif = false); });
  }

  List<_StaffBooking> get _filtered =>
    _bookingFilter == 'All' ? _bookings : _bookings.where((b) => b.status == _bookingFilter).toList();

  int get _activeCount    => _bookings.where((b) => b.status == 'Active').length;
  int get _availableCount => _fleet.where((c) => c.available).length;
  int get _unreadCount    => _messages.fold(0, (s, m) => s + m.unread);

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);
    final card    = isDark ? const Color(0xFF141828) : Colors.white;
    final border  = isDark ? const Color(0xFF252B3E) : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white             : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8)  : const Color(0xFF6B7280);
    const brand   = Color(0xFF1D9E75);

    return Scaffold(
      backgroundColor: bg,
      drawer: _buildDrawer(isDark, card, border, textPri, textSec),
      appBar: AppBar(
        backgroundColor: brand,
        elevation: 0,
        toolbarHeight: 56,
        leading: Builder(builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer())),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('DriveKigali', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          const Text('Staff Panel', style: TextStyle(color: Colors.white70, fontSize: 11)),
        ]),
        actions: [
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () => _showNotifSheet(context, card, border, textPri, textSec)),
            if (_unreadCount > 0)
              Positioned(right: 8, top: 8,
                child: Container(width: 8, height: 8,
                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle))),
          ]),
          Padding(padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showProfile(context, card, border, textPri, textSec),
              child: CircleAvatar(radius: 15, backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(AuthService.staffName.split(' ').map((e) => e[0]).take(2).join(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))))),
        ],
        bottom: TabBar(
          controller: _tc,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          isScrollable: false,
          labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          tabs: [
            const Tab(icon: Icon(Icons.dashboard_outlined, size: 18), text: 'Dashboard'),
            const Tab(icon: Icon(Icons.directions_car_outlined, size: 18), text: 'Fleet'),
            Tab(icon: Stack(clipBehavior: Clip.none, children: [
              const Icon(Icons.receipt_long_outlined, size: 18),
              if (_activeCount > 0) Positioned(right: -4, top: -4, child: Container(width: 8, height: 8,
                decoration: const BoxDecoration(color: const Color(0xFFD4A017), shape: BoxShape.circle))),
            ]), text: 'Bookings'),
          ],
        ),
      ),
      floatingActionButton: Column(mainAxisSize: MainAxisSize.min, children: [
        FloatingActionButton.small(
          heroTag: 'history',
          onPressed: () => _showStaffHistory(context, card, border, textPri, textSec),
          backgroundColor: const Color(0xFFD4A017),
          child: const Icon(Icons.history_rounded, color: Colors.white, size: 18)),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'messages',
          onPressed: () => _openMessagesScreen(context, card, border, textPri, textSec),
          backgroundColor: const Color(0xFF1D9E75),
        child: Stack(children: [
          const Icon(Icons.chat_rounded, color: Colors.white),
          if (_unreadCount > 0)
            Positioned(right: 0, top: 0,
              child: Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1D9E75), width: 1.5)),
                child: Center(child: Text('$_unreadCount',
                  style: const TextStyle(fontSize: 7, color: Colors.black, fontWeight: FontWeight.w800))))),
        ])),
      ]),
      body: Stack(children: [
        TabBarView(controller: _tc, children: [
          _dashTab(isDark, bg, card, border, textPri, textSec, brand),
          _fleetTab(isDark, bg, card, border, textPri, textSec, brand),
          _bookingsTab(isDark, bg, card, border, textPri, textSec, brand),
        ]),
        if (_showNotif)
          Positioned(bottom: 20, left: 16, right: 16,
            child: Material(color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: brand, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_notifMsg,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
                ])))),
      ]),
    );
  }

  // ══════════════════════════════════════════
  //  DASHBOARD
  // ══════════════════════════════════════════
  Widget _dashTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec, Color brand) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Staff welcome card
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [brand, brand.withOpacity(0.6)]),
          borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          CircleAvatar(radius: 26, backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(AuthService.staffName.split(' ').map((e) => e[0]).take(2).join(),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hi, ${AuthService.staffName.split(' ').first}!',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text('${AuthService.staffRole} · ${AuthService.staffCompany}',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(20)),
            child: const Text('STAFF', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1))),
        ])),

      const SizedBox(height: 16),

      // KPI row — no revenue shown (restricted)
      Row(children: [
        _SKpi('$_activeCount', 'Active Bookings', Icons.directions_car_rounded, brand, card, border, textPri, textSec,
          onTap: () { _tc.animateTo(2); setState(() => _bookingFilter = 'Active'); }),
        const SizedBox(width: 10),
        _SKpi('$_availableCount', 'Cars Available', Icons.garage_rounded, const Color(0xFF3B5FD4), card, border, textPri, textSec,
          onTap: () => _tc.animateTo(1)),
        const SizedBox(width: 10),
        _SKpi('${_messages.fold(0,(s,m)=>s+m.unread)}', 'Unread Msgs', Icons.chat_bubble_outline, const Color(0xFFD4A017), card, border, textPri, textSec,
          onTap: () => _openMessagesScreen(context, card, border, textPri, textSec)),
      ]),

      const SizedBox(height: 20),

      // Restriction notice
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8C04A).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8C04A).withOpacity(0.3), width: 0.8)),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFE8C04A), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Staff Account', style: TextStyle(color: Color(0xFFE8C04A), fontSize: 12, fontWeight: FontWeight.w700)),
            Text('You can view & update bookings and fleet status. Contact your manager for admin actions.',
              style: TextStyle(color: textSec, fontSize: 11, height: 1.4)),
          ])),
        ])),

      const SizedBox(height: 20),
      Text("Today's Bookings", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),

      ..._bookings.where((b) => b.status == 'Active' || b.status == 'Upcoming').map((b) =>
        GestureDetector(
          onTap: () => _showBookingDetail(context, b, isDark, card, border, textPri, textSec),
          child: _SBookingTile(b: b, card: card, border: border, textPri: textPri, textSec: textSec))),

      const SizedBox(height: 20),
      Text('Fleet Quick Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),

      ..._fleet.asMap().entries.take(3).map((entry) {
        final idx = entry.key;
        final car = entry.value;
        return GestureDetector(
          onTap: () => _showCarDetail(context, car, idx, isDark, card, border, textPri, textSec, brand),
          child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
          child: Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: brand.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
              child: Icon(Icons.directions_car_rounded, color: brand, size: 17)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(car.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
              Text('${car.category} · ${car.fuel}', style: TextStyle(fontSize: 11, color: textSec)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              GestureDetector(
                onTap: () {
                  setState(() => car.available = !car.available);
                  _notify('${car.name} marked as ${car.available ? "Available" : "Rented"}');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: car.available ? const Color(0xFF1D9E75).withOpacity(0.1) : const Color(0xFFD85A30).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(car.available ? '● Available' : '✗ Rented',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: car.available ? const Color(0xFF1D9E75) : const Color(0xFFD85A30))))),
              const SizedBox(height: 2),
              Icon(Icons.chevron_right_rounded, size: 14, color: textSec),
            ]),
          ])));
      }),

      const SizedBox(height: 20),
      Text('Customer Messages', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),

      ..._messages.take(3).map((m) => GestureDetector(
        onTap: () => _openMessagesScreen(context, card, border, textPri, textSec),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
          child: Row(children: [
            CircleAvatar(radius: 18, backgroundColor: m.avatarColor.withOpacity(0.15),
              child: Text(m.initials, style: TextStyle(color: m.avatarColor, fontSize: 11, fontWeight: FontWeight.w700))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.customer, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
              Text(m.lastMsg, style: TextStyle(fontSize: 11, color: textSec), overflow: TextOverflow.ellipsis),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(m.time, style: TextStyle(fontSize: 10, color: textSec)),
              if (m.unread > 0) ...[
                const SizedBox(height: 4),
                Container(width: 18, height: 18,
                  decoration: const BoxDecoration(color: const Color(0xFFD4A017), shape: BoxShape.circle),
                  child: Center(child: Text('${m.unread}',
                    style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w700)))),
              ],
            ]),
          ]))),
      ),
      const SizedBox(height: 16),
    ]));
  }

  // ══════════════════════════════════════════
  //  FLEET TAB  (view + toggle only, no add/delete)
  // ══════════════════════════════════════════
  Widget _fleetTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec, Color brand) {
    final avail  = _fleet.where((c) => c.available).length;
    final rented = _fleet.length - avail;
    return Column(children: [
      // Summary bar
      Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${_fleet.length} Total Vehicles', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
            const SizedBox(height: 4),
            Row(children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF1D9E75), shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('$avail available', style: TextStyle(fontSize: 11, color: textSec)),
              const SizedBox(width: 12),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFD85A30), shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('$rented rented', style: TextStyle(fontSize: 11, color: textSec)),
            ]),
          ])),
          // Staff restriction badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8C04A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE8C04A).withOpacity(0.3), width: 0.8)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.visibility_outlined, size: 12, color: Color(0xFFE8C04A)),
              SizedBox(width: 4),
              Text('View & Toggle', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFE8C04A))),
            ])),
        ])),

      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _fleet.length,
        itemBuilder: (_, i) {
          final car = _fleet[i];
          final availColor = car.available ? const Color(0xFF1D9E75) : const Color(0xFFD85A30);
          return GestureDetector(
            onTap: () => _showCarDetail(context, car, i, isDark, card, border, textPri, textSec, brand),
            child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: brand.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.directions_car_rounded, color: brand, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(car.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPri)),
                    const SizedBox(height: 3),
                    Row(children: [
                      _SChip(car.category, textSec, isDark),
                      const SizedBox(width: 6),
                      _SChip(car.fuel, textSec, isDark),
                      const SizedBox(width: 6),
                      _SChip('${car.seats} seats', textSec, isDark),
                    ]),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('\$${car.price.toInt()}/day', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFFD4A017))),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() => car.available = !car.available);
                        _notify('${car.name} → ${car.available ? "Available" : "Rented Out"}');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: availColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: availColor.withOpacity(0.3), width: 0.8)),
                        child: Text(car.available ? '● Available' : '✗ Rented',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: availColor)))),
                  ]),
                ])),
              // Bottom bar
              Container(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Row(children: [
                  Icon(Icons.info_outline_rounded, size: 12, color: textSec.withOpacity(0.5)),
                  const SizedBox(width: 5),
                  Text('Tap for details · Tap status to toggle',
                    style: TextStyle(fontSize: 10, color: textSec.withOpacity(0.5))),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, size: 16, color: textSec.withOpacity(0.4)),
                ])),
            ])));
        })),
    ]);
  }

  // ══════════════════════════════════════════
  //  BOOKINGS TAB
  // ══════════════════════════════════════════
  Widget _bookingsTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec, Color brand) {
    final filters = ['All', 'Active', 'Upcoming', 'Completed', 'Cancelled'];
    return Column(children: [
      SizedBox(height: 48, child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: filters.map((s) {
          final sel = _bookingFilter == s;
          return GestureDetector(
            onTap: () => setState(() => _bookingFilter = s),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: sel ? brand : card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? brand : border, width: 0.8)),
              child: Center(child: Text(s, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: sel ? Colors.white : textSec)))));
        }).toList())),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${_filtered.length} booking${_filtered.length != 1 ? "s" : ""}',
            style: TextStyle(fontSize: 12, color: textSec)),
          // Staff cannot see total revenue
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE8C04A).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.lock_outline, size: 11, color: Color(0xFFE8C04A)),
              SizedBox(width: 4),
              Text('Revenue restricted', style: TextStyle(fontSize: 10, color: Color(0xFFE8C04A), fontWeight: FontWeight.w600)),
            ])),
        ])),
      Expanded(child: _filtered.isEmpty
        ? Center(child: Text('No $_bookingFilter bookings', style: TextStyle(color: textSec)))
        : ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: _filtered.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => _showBookingDetail(context, _filtered[i], isDark, card, border, textPri, textSec),
            child: _SBookingTile(b: _filtered[i], card: card, border: border, textPri: textPri, textSec: textSec)))),
    ]);
  }

  // ══════════════════════════════════════════
  //  DRAWER
  // ══════════════════════════════════════════
  Widget _buildDrawer(bool isDark, Color card, Color border, Color textPri, Color textSec) {
    const brand = Color(0xFF1D9E75);
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
      child: SafeArea(child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [brand, Color(0xFF16835E)]),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 26, backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(AuthService.staffName.split(' ').map((e) => e[0]).take(2).join(),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AuthService.staffName,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(AuthService.staffRole,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))),
              ])),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Icon(Icons.business_outlined, color: Colors.white.withOpacity(0.7), size: 13),
              const SizedBox(width: 5),
              Text(AuthService.staffCompany, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
            ]),
          ])),

        // Theme toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141828) : const Color(0xFFF2F4F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 0.5)),
            child: Row(children: [
              Container(width: 30, height: 30,
                decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: const Color(0xFFD4A017), size: 15)),
              const SizedBox(width: 10),
              Expanded(child: Text(isDark ? 'Dark mode' : 'Light mode',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri))),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (_, mode, __) => Transform.scale(scale: 0.8, child: Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: (_) => themeNotifier.toggle(),
                  activeColor: const Color(0xFFD4A017),
                  activeTrackColor: const Color(0xFFD4A017).withOpacity(0.3),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap))),
            ])),
        ),

        Divider(color: border, height: 16),

        // Nav items
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(vertical: 2), children: [
          ...[
            {'icon': Icons.dashboard_outlined,     'label': 'Dashboard',  'tab': 0},
            {'icon': Icons.directions_car_outlined,'label': 'Fleet',      'tab': 1},
            {'icon': Icons.receipt_long_outlined,  'label': 'Bookings',   'tab': 2},
            {'icon': Icons.chat_bubble_outline,    'label': 'Messages',   'tab': -1},
          ].map((item) {
            final isTab   = (item['tab'] as int) >= 0;
            final active  = isTab && _tab == item['tab'] as int;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: active ? brand.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(item['icon'] as IconData, color: active ? brand : textSec, size: 20),
                title: Text(item['label'] as String, style: TextStyle(fontSize: 14,
                  color: active ? brand : textPri,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
                trailing: active ? Container(width: 4, height: 20,
                  decoration: BoxDecoration(color: brand, borderRadius: BorderRadius.circular(2))) : null,
                onTap: () {
                  Navigator.pop(context);
                  if (isTab) { _tc.animateTo(item['tab'] as int); }
                  else { _openMessagesScreen(context, card, border, textPri, textSec); }
                },
                dense: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
          }),

          // Locked items
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Text('RESTRICTED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
              color: textSec.withOpacity(0.4), letterSpacing: 1))),
          ...[
            (Icons.people_outline,  'Team Management'),
            (Icons.bar_chart_rounded, 'Analytics & Revenue'),
            (Icons.settings_outlined, 'Company Settings'),
          ].map((item) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: ListTile(
              leading: Icon(item.$1, color: textSec.withOpacity(0.3), size: 20),
              title: Text(item.$2, style: TextStyle(fontSize: 14, color: textPri.withOpacity(0.3))),
              trailing: Icon(Icons.lock_outline, color: textSec.withOpacity(0.3), size: 15),
              onTap: () { Navigator.pop(context); _showRestricted(context, card, border, textPri, textSec); },
              dense: true))),

          // ── Account History ──────────────────────────
          const SizedBox(height: 8),
          Divider(color: border, height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A017).withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.2), width: 0.8)),
            child: ListTile(
              leading: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.history_rounded, color: Color(0xFFD4A017), size: 17)),
              title: const Text('Account History',
                style: TextStyle(fontSize: 14, color: Color(0xFFD4A017), fontWeight: FontWeight.w600)),
              subtitle: const Text('View all your activity logs',
                style: TextStyle(fontSize: 10, color: Color(0xFF8B91A8))),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFD4A017), size: 18),
              onTap: () {
                Navigator.pop(context);
                _showStaffHistory(context, card, border, textPri, textSec);
              },
              dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
        ])),

        Divider(color: border, height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            leading: Container(width: 34, height: 34,
              decoration: BoxDecoration(color: const Color(0xFFD85A30).withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFD85A30), size: 17)),
            title: const Text('Sign Out',
              style: TextStyle(fontSize: 14, color: Color(0xFFD85A30), fontWeight: FontWeight.w600)),
            onTap: () { AuthService.logout(); Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false); },
            dense: true)),
      ])));
  }

  // ══════════════════════════════════════════
  //  SHEETS
  // ══════════════════════════════════════════
  void _showBookingDetail(BuildContext ctx, _StaffBooking b, bool isDark, Color card, Color border, Color textPri, Color textSec) {
    final sc = _statusColor(b.status);
    showModalBottomSheet(
      context: ctx,
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.directions_car_rounded, color: sc, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b.ref, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textPri)),
            Text(b.car, style: TextStyle(fontSize: 12, color: textSec)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(b.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sc))),
        ]),
        const SizedBox(height: 16),
        _SDRow(Icons.person_outline,          'Customer', b.customer,  textPri, textSec),
        _SDRow(Icons.phone_outlined,          'Phone',    b.phone,     textPri, textSec),
        _SDRow(Icons.directions_car_outlined, 'Vehicle',  b.car,       textPri, textSec),
        _SDRow(Icons.calendar_today_outlined, 'Pick-up',  b.from,      textPri, textSec),
        _SDRow(Icons.event_outlined,          'Return',   b.to,        textPri, textSec),
        _SDRow(Icons.access_time_outlined,    'Duration', '${b.days} days', textPri, textSec),
        const Divider(),
        // Amount — visible but not editable
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Booking Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPri)),
          Row(children: [
            Text('\$${b.amount.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFFD4A017))),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFE8C04A).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.lock_outline, size: 10, color: Color(0xFFE8C04A)),
                SizedBox(width: 3),
                Text('view only', style: TextStyle(fontSize: 9, color: Color(0xFFE8C04A), fontWeight: FontWeight.w600)),
              ])),
          ]),
        ]),
        const SizedBox(height: 16),
        if (b.status == 'Upcoming') Row(children: [
          Expanded(child: ElevatedButton(
            onPressed: () {
              final idx = _bookings.indexOf(b);
              if (idx >= 0) setState(() => _bookings[idx] = _StaffBooking(b.ref, b.customer, b.car, b.from, b.to, b.days, b.amount, 'Active', b.phone));
              Navigator.pop(ctx);
              _notify('Booking ${b.ref} confirmed');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D9E75), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Confirm Pickup'))),
        ]),
        if (b.status == 'Active') SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () {
            final idx = _bookings.indexOf(b);
            if (idx >= 0) setState(() => _bookings[idx] = _StaffBooking(b.ref, b.customer, b.car, b.from, b.to, b.days, b.amount, 'Completed', b.phone));
            Navigator.pop(ctx);
            _notify('Booking ${b.ref} marked as Completed');
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B5FD4), foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
          child: const Text('Mark as Returned'))),
      ])));
  }

  void _openMessagesScreen(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => _StaffMessagesScreen(
        messages: _messages, card: card, border: border, textPri: textPri, textSec: textSec)));
  }

  void _showNotifSheet(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    final notifs = <Map<String, dynamic>>[
      {'msg': 'New booking: Cameron One – RAV4', 'time': '5 min ago',  'color': const Color(0xFF1D9E75)},
      {'msg': 'Fiona Ingabire wants to extend',  'time': '1 hr ago',  'color': const Color(0xFFD4A017)},
      {'msg': 'Alice Mugisha: Car returned',     'time': '2 hr ago',  'color': const Color(0xFF3B5FD4)},
    ];
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 14),
        Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
        const SizedBox(height: 16),
        ...notifs.map((n) {
          final clr = n['color'] as Color;
          return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: clr.withOpacity(0.07), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: clr.withOpacity(0.2), width: 0.5)),
            child: Row(children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: clr.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(Icons.notifications_outlined, color: clr, size: 16)),
              const SizedBox(width: 10),
              Expanded(child: Text(n['msg'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri))),
              Text(n['time'] as String, style: TextStyle(fontSize: 10, color: textSec)),
            ]));
        }),
      ])));
  }

  void _showProfile(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        CircleAvatar(radius: 34, backgroundColor: const Color(0xFF1D9E75).withOpacity(0.15),
          child: Text(AuthService.staffName.split(' ').map((e) => e[0]).take(2).join(),
            style: const TextStyle(color: Color(0xFF1D9E75), fontSize: 22, fontWeight: FontWeight.w800))),
        const SizedBox(height: 12),
        Text(AuthService.staffName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPri)),
        const SizedBox(height: 4),
        Text(AuthService.staffRole, style: TextStyle(fontSize: 13, color: textSec)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFF1D9E75).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(AuthService.staffCompany, style: const TextStyle(fontSize: 12, color: Color(0xFF1D9E75), fontWeight: FontWeight.w600))),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8C04A).withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8C04A).withOpacity(0.25), width: 0.8)),
          child: Row(children: [
            const Icon(Icons.shield_outlined, color: Color(0xFFE8C04A), size: 16),
            const SizedBox(width: 10),
            Expanded(child: Text('Staff permissions · Cannot access financials, team, or settings',
              style: TextStyle(fontSize: 11, color: textSec, height: 1.4))),
          ])),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () { Navigator.pop(ctx); AuthService.logout(); Navigator.pushNamedAndRemoveUntil(ctx, '/home', (_) => false); },
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD85A30)),
            padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Sign Out', style: TextStyle(color: Color(0xFFD85A30), fontWeight: FontWeight.w700)))),
      ])));
  }

  void _showRestricted(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    showModalBottomSheet(context: ctx, backgroundColor: card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Container(width: 60, height: 60,
          decoration: BoxDecoration(color: const Color(0xFFE8C04A).withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.lock_rounded, color: Color(0xFFE8C04A), size: 28)),
        const SizedBox(height: 14),
        Text('Access Restricted', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPri)),
        const SizedBox(height: 8),
        Text('This feature is only available to Company Admins and above. Please contact your manager.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: textSec, height: 1.5)),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D9E75), foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 13)),
          child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.w700)))),
      ])));
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Active':    return const Color(0xFF1D9E75);
      case 'Upcoming':  return const Color(0xFF3B5FD4);
      case 'Completed': return const Color(0xFF8B91A8);
      case 'Cancelled': return const Color(0xFFD85A30);
      default:          return const Color(0xFF8B91A8);
    }
  }
}

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────
class _SKpi extends StatelessWidget {
  final String value, label; final IconData icon; final Color color, card, border, textPri, textSec;
  final VoidCallback onTap;
  const _SKpi(this.value, this.label, this.icon, this.color, this.card, this.border, this.textPri, this.textSec, {required this.onTap});
  @override Widget build(BuildContext c) => Expanded(child: GestureDetector(onTap: onTap, child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 30, height: 30, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 15)),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPri)),
      Text(label,  style: TextStyle(fontSize: 9,  color: textSec), overflow: TextOverflow.ellipsis),
    ]))));
}

class _SBookingTile extends StatelessWidget {
  final _StaffBooking b; final Color card, border, textPri, textSec;
  const _SBookingTile({required this.b, required this.card, required this.border, required this.textPri, required this.textSec});
  Color get _sc { switch(b.status){case'Active':return const Color(0xFF1D9E75);case'Upcoming':return const Color(0xFF3B5FD4);case'Cancelled':return const Color(0xFFD85A30);default:return const Color(0xFF8B91A8);} }
  @override Widget build(BuildContext c) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
    child: Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: _sc.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
        child: Icon(Icons.directions_car_rounded, color: _sc, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${b.car} · ${b.customer}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
        Text('${b.from} → ${b.to} · ${b.days} days', style: TextStyle(fontSize: 11, color: textSec)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: _sc.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text(b.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _sc))),
        const SizedBox(height: 4),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFF8B91A8), size: 16),
      ]),
    ]));
}

Widget _SDRow(IconData icon, String label, String value, Color textPri, Color textSec) =>
  Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
    Icon(icon, size: 15, color: textSec), const SizedBox(width: 10),
    Text('$label: ', style: TextStyle(fontSize: 12, color: textSec)),
    Expanded(child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri), overflow: TextOverflow.ellipsis)),
  ]));

Widget _SChip(String label, Color textSec, bool isDark) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
  decoration: BoxDecoration(
    color: isDark ? const Color(0xFF1C2236) : const Color(0xFFF0F2F8),
    borderRadius: BorderRadius.circular(6)),
  child: Text(label, style: TextStyle(fontSize: 9, color: textSec)));

// ─────────────────────────────────────────────
//  CAR DETAIL SHEET (fleet tap)
// ─────────────────────────────────────────────
extension _StaffFleetExt on _StaffState {
  void _showStaffHistory(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => _StaffHistoryScreen(
      staffName: AuthService.staffName, staffRole: AuthService.staffRole,
      card: card, border: border, textPri: textPri, textSec: textSec)));
  }

  void _showCarDetail(BuildContext ctx, _StaffCar car, int idx,
      bool isDark, Color card, Color border, Color textPri, Color textSec, Color brand) {
    final availColor = car.available ? const Color(0xFF1D9E75) : const Color(0xFFD85A30);
    // Find active booking for this car
    final booking = _bookings.where((b) =>
      b.car == car.name && (b.status == 'Active' || b.status == 'Upcoming')).toList();

    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65, minChildSize: 0.4, maxChildSize: 0.88,
        expand: false,
        builder: (__, ctrl) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),

            // Hero
            Container(
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [brand.withOpacity(0.15), brand.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(16)),
              child: Stack(children: [
                Center(child: Icon(Icons.directions_car_rounded, size: 80, color: brand.withOpacity(0.2))),
                Positioned(top: 12, left: 12, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: brand.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(car.category, style: TextStyle(color: brand, fontSize: 11, fontWeight: FontWeight.w700)))),
                Positioned(top: 12, right: 12,
                  child: Text('\$${car.price.toInt()}/day',
                    style: const TextStyle(color: const Color(0xFFD4A017), fontSize: 20, fontWeight: FontWeight.w800))),
                Positioned(bottom: 12, right: 12,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => car.available = !car.available);
                      _notify('${car.name} → ${car.available ? "Available" : "Rented Out"}');
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: availColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: availColor, width: 1)),
                      child: Text(car.available ? '● Available' : '✗ Rented',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: availColor))))),
              ])),
            const SizedBox(height: 16),

            Text(car.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPri)),
            const SizedBox(height: 4),
            Text('${car.category} · ${car.fuel} · ${car.transmission}',
              style: TextStyle(fontSize: 13, color: textSec)),
            const SizedBox(height: 16),

            // Spec grid
            Row(children: [
              _SSpecBox('Seats',       '${car.seats}',       Icons.event_seat_outlined,        textPri, textSec, isDark),
              const SizedBox(width: 8),
              _SSpecBox('Fuel',        car.fuel,             Icons.local_gas_station_outlined,  textPri, textSec, isDark),
              const SizedBox(width: 8),
              _SSpecBox('Trans.',      car.transmission,     Icons.settings_outlined,           textPri, textSec, isDark),
              const SizedBox(width: 8),
              _SSpecBox('Category',   car.category,         Icons.category_outlined,           textPri, textSec, isDark),
            ]),
            const SizedBox(height: 16),

            // Active booking info
            if (booking.isNotEmpty) ...[
              Text('Current Booking', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D9E75).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1D9E75).withOpacity(0.2), width: 0.8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    CircleAvatar(radius: 16, backgroundColor: const Color(0xFF1D9E75).withOpacity(0.15),
                      child: Text(booking.first.customer[0],
                        style: const TextStyle(color: Color(0xFF1D9E75), fontWeight: FontWeight.w700))),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(booking.first.customer, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
                      Text(booking.first.ref, style: TextStyle(fontSize: 11, color: textSec)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D9E75).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(booking.first.status,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1D9E75)))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: textSec),
                    const SizedBox(width: 5),
                    Text('${booking.first.from} → ${booking.first.to}',
                      style: TextStyle(fontSize: 12, color: textSec)),
                    const Spacer(),
                    Icon(Icons.phone_outlined, size: 12, color: textSec),
                    const SizedBox(width: 5),
                    Text(booking.first.phone, style: TextStyle(fontSize: 11, color: textSec)),
                  ]),
                ])),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: border.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.event_available_rounded, color: textSec, size: 16),
                  const SizedBox(width: 8),
                  Text('No active booking for this vehicle', style: TextStyle(fontSize: 12, color: textSec)),
                ])),
              const SizedBox(height: 16),
            ],

            // Toggle button
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () {
                setState(() => car.available = !car.available);
                _notify('${car.name} → ${car.available ? "Available" : "Rented Out"}');
                Navigator.pop(ctx);
              },
              icon: Icon(car.available ? Icons.block_rounded : Icons.check_circle_outline_rounded, size: 16),
              label: Text(car.available ? 'Mark as Rented Out' : 'Mark as Available'),
              style: ElevatedButton.styleFrom(
                backgroundColor: car.available ? const Color(0xFFD85A30) : const Color(0xFF1D9E75),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8C04A).withOpacity(0.07),
                borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.lock_outline, size: 12, color: Color(0xFFE8C04A)),
                const SizedBox(width: 6),
                Text('Editing car details is restricted to managers', style: TextStyle(fontSize: 11, color: textSec)),
              ])),
            const SizedBox(height: 16),
          ]))));
  }
}

Widget _SSpecBox(String label, String value, IconData icon, Color textPri, Color textSec, bool isDark) =>
  Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF141828) : const Color(0xFFF2F4F8),
      borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Icon(icon, color: const Color(0xFFD4A017), size: 16),
      const SizedBox(height: 5),
      Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textPri),
        overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
      Text(label, style: TextStyle(fontSize: 9, color: textSec)),
    ])));

// ─────────────────────────────────────────────
//  MESSAGES FULL SCREEN  (with reply)
// ─────────────────────────────────────────────
class _StaffMessagesScreen extends StatefulWidget {
  final List<_StaffMessage> messages;
  final Color card, border, textPri, textSec;
  const _StaffMessagesScreen({
    required this.messages, required this.card, required this.border,
    required this.textPri, required this.textSec});
  @override State<_StaffMessagesScreen> createState() => _StaffMsgState();
}

class _StaffMsgState extends State<_StaffMessagesScreen> {
  _StaffMessage? _selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D9E75),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _selected != null
          ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => setState(() => _selected = null))
          : IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context)),
        title: Text(_selected?.customer ?? 'Messages',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          if (_selected != null)
            IconButton(icon: const Icon(Icons.phone_outlined, color: Colors.white), onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calling customer... (demo)'), backgroundColor: Color(0xFF1D9E75)));
          })
        ],
      ),
      body: _selected == null
        ? _messagesList(isDark)
        : _chatView(_selected!, isDark),
    );
  }

  Widget _messagesList(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: widget.messages.length,
      separatorBuilder: (_, __) => Divider(color: widget.border, height: 1),
      itemBuilder: (_, i) {
        final m = widget.messages[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Stack(children: [
            CircleAvatar(radius: 24, backgroundColor: m.avatarColor.withOpacity(0.15),
              child: Text(m.initials, style: TextStyle(color: m.avatarColor, fontSize: 14, fontWeight: FontWeight.w700))),
            if (m.unread > 0) Positioned(right: 0, top: 0,
              child: Container(width: 12, height: 12,
                decoration: BoxDecoration(color: const Color(0xFFD4A017), shape: BoxShape.circle,
                  border: Border.all(color: widget.card, width: 2)))),
          ]),
          title: Row(children: [
            Expanded(child: Text(m.customer,
              style: TextStyle(fontSize: 14, fontWeight: m.unread > 0 ? FontWeight.w800 : FontWeight.w600, color: widget.textPri))),
            Text(m.time, style: TextStyle(fontSize: 11, color: widget.textSec)),
          ]),
          subtitle: Row(children: [
            Expanded(child: Text(m.lastMsg,
              style: TextStyle(fontSize: 12, color: m.unread > 0 ? widget.textPri : widget.textSec,
                fontWeight: m.unread > 0 ? FontWeight.w500 : FontWeight.w400),
              overflow: TextOverflow.ellipsis)),
            if (m.unread > 0) ...[
              const SizedBox(width: 6),
              Container(width: 20, height: 20,
                decoration: const BoxDecoration(color: const Color(0xFFD4A017), shape: BoxShape.circle),
                child: Center(child: Text('${m.unread}',
                  style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w700)))),
            ],
          ]),
          onTap: () => setState(() => _selected = m),
        );
      });
  }

  Widget _chatView(_StaffMessage m, bool isDark) {
    return _StaffChatView(message: m, isDark: isDark, card: widget.card,
      border: widget.border, textPri: widget.textPri, textSec: widget.textSec);
  }
}

class _StaffChatView extends StatefulWidget {
  final _StaffMessage message;
  final bool isDark;
  final Color card, border, textPri, textSec;
  const _StaffChatView({required this.message, required this.isDark, required this.card,
    required this.border, required this.textPri, required this.textSec});
  @override State<_StaffChatView> createState() => _StaffChatViewState();
}

class _StaffChatViewState extends State<_StaffChatView> {
  final _ctrl = TextEditingController();
  final List<Map<String, dynamic>> _msgs = [];

  @override
  void initState() {
    super.initState();
    // Seed with the existing message
    _msgs.add({'text': widget.message.lastMsg, 'isMe': false, 'time': widget.message.time});
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _send() {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() {
      _msgs.add({'text': _ctrl.text.trim(), 'isMe': true, 'time': 'Now'});
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);
    return Column(children: [
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _msgs.length,
        itemBuilder: (_, i) {
          final msg   = _msgs[i];
          final isMe  = msg['isMe'] as bool;
          final color = isMe ? const Color(0xFF1D9E75) : widget.card;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMe) ...[
                  CircleAvatar(radius: 14, backgroundColor: widget.message.avatarColor.withOpacity(0.15),
                    child: Text(widget.message.initials,
                      style: TextStyle(color: widget.message.avatarColor, fontSize: 10, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 8),
                ],
                Flexible(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(16),
                      topRight:    const Radius.circular(16),
                      bottomLeft:  Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16)),
                    border: isMe ? null : Border.all(color: widget.border, width: 0.5)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(msg['text'] as String,
                      style: TextStyle(fontSize: 13, color: isMe ? Colors.white : widget.textPri)),
                    const SizedBox(height: 3),
                    Text(msg['time'] as String,
                      style: TextStyle(fontSize: 9, color: isMe ? Colors.white70 : widget.textSec)),
                  ]))),
                if (isMe) const SizedBox(width: 4),
              ]));
        })),

      // Input bar
      Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: widget.card,
          border: Border(top: BorderSide(color: widget.border, width: 0.5))),
        child: Row(children: [
          Expanded(child: Container(
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1C2236) : const Color(0xFFF0F2F8),
              borderRadius: BorderRadius.circular(24)),
            child: TextField(
              controller: _ctrl,
              style: TextStyle(fontSize: 13, color: widget.textPri),
              decoration: InputDecoration(
                hintText: 'Type a reply…',
                hintStyle: TextStyle(color: widget.textSec, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
              onSubmitted: (_) => _send()))),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 42, height: 42,
              decoration: const BoxDecoration(color: Color(0xFF1D9E75), shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18))),
        ])),
    ]);
  }
}

// ─────────────────────────────────────────────
//  STAFF HISTORY SCREEN  (item 10)
// ─────────────────────────────────────────────
class _StaffHistoryScreen extends StatefulWidget {
  final String staffName, staffRole;
  final Color card, border, textPri, textSec;
  const _StaffHistoryScreen({required this.staffName, required this.staffRole,
    required this.card, required this.border, required this.textPri, required this.textSec});
  @override State<_StaffHistoryScreen> createState() => _StaffHistoryState();
}
class _StaffHistoryState extends State<_StaffHistoryScreen> {
  String _filter = 'All';

  // Seed history entries for this staff member
  final List<Map<String, dynamic>> _history = [
    {'action': 'Logged in to Staff Panel',                          'cat': 'Login',   'time': '14/06/2026 08:30', 'icon': Icons.login_rounded,              'color': const Color(0xFF1D9E75)},
    {'action': 'Toyota RAV4 marked as Available',                   'cat': 'Fleet',   'time': '14/06/2026 09:15', 'icon': Icons.directions_car_rounded,     'color': const Color(0xFFD4A017)},
    {'action': 'Booking SW240001 confirmed pickup – Cameron One',   'cat': 'Booking', 'time': '14/06/2026 10:00', 'icon': Icons.receipt_long_rounded,       'color': const Color(0xFF7F77DD)},
    {'action': 'Replied to Cameron One: "Car ready at gate 2"',     'cat': 'Message', 'time': '14/06/2026 10:32', 'icon': Icons.chat_bubble_outline_rounded,'color': const Color(0xFF0D7EA8)},
    {'action': 'Hyundai Tucson marked as Rented Out',               'cat': 'Fleet',   'time': '14/06/2026 11:00', 'icon': Icons.directions_car_rounded,     'color': const Color(0xFFD4A017)},
    {'action': 'Booking SW240003 marked as Completed – Alice M.',   'cat': 'Booking', 'time': '13/06/2026 15:30', 'icon': Icons.receipt_long_rounded,       'color': const Color(0xFF7F77DD)},
    {'action': 'Replied to Alice Mugisha: "Thank you!"',            'cat': 'Message', 'time': '13/06/2026 15:45', 'icon': Icons.chat_bubble_outline_rounded,'color': const Color(0xFF0D7EA8)},
    {'action': 'Logged in to Staff Panel',                          'cat': 'Login',   'time': '13/06/2026 08:00', 'icon': Icons.login_rounded,              'color': const Color(0xFF1D9E75)},
    {'action': 'BMW 5 Series marked as Available',                  'cat': 'Fleet',   'time': '12/06/2026 14:00', 'icon': Icons.directions_car_rounded,     'color': const Color(0xFFD4A017)},
    {'action': 'Booking SW240005 confirmed – Fiona Ingabire',       'cat': 'Booking', 'time': '12/06/2026 09:00', 'icon': Icons.receipt_long_rounded,       'color': const Color(0xFF7F77DD)},
    {'action': 'Account created as Fleet Agent at DriveKigali',     'cat': 'Account', 'time': '01/01/2024 09:00', 'icon': Icons.person_add_rounded,         'color': const Color(0xFFD4A017)},
  ];

  List<Map<String, dynamic>> get _filtered => _filter == 'All'
      ? _history : _history.where((e) => e['cat'] == _filter).toList();

  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);
    final cats   = ['All','Booking','Fleet','Message','Login','Account'];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D9E75), foregroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('My History', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          Text(widget.staffRole, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
        ])),
      body: Column(children: [
        // Stats strip
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFF1D9E75).withOpacity(0.15), const Color(0xFF1D9E75).withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1D9E75).withOpacity(0.2), width: 0.8)),
          child: Row(children: [
            _SHistStat('${_history.length}',                                            'Total Events', const Color(0xFFD4A017), active: _filter=='All',     onTap: () => setState(() => _filter = 'All')),
            _SHistStat('${_history.where((e)=>e['cat']=='Booking').length}',            'Bookings',    const Color(0xFF7F77DD), active: _filter=='Booking',  onTap: () => setState(() => _filter = 'Booking')),
            _SHistStat('${_history.where((e)=>e['cat']=='Fleet').length}',              'Fleet',       const Color(0xFF1D9E75), active: _filter=='Fleet',    onTap: () => setState(() => _filter = 'Fleet')),
            _SHistStat('${_history.where((e)=>e['cat']=='Message').length}',            'Messages',    const Color(0xFF0D7EA8), active: _filter=='Message',  onTap: () => setState(() => _filter = 'Message')),
          ])),
        // Filter chips
        SizedBox(height: 42, child: ListView(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          children: cats.map((cat) {
            final sel = _filter == cat;
            return GestureDetector(
              onTap: () => setState(() => _filter = cat),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF1D9E75) : widget.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? const Color(0xFF1D9E75) : widget.border, width: 0.8)),
                child: Center(child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : widget.textSec)))));
          }).toList())),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${_filtered.length} events', style: TextStyle(fontSize: 12, color: widget.textSec)),
            const Row(children: [
              Icon(Icons.lock_outline, size: 11, color: Color(0xFFD4A017)),
              SizedBox(width: 4),
              Text('Permanent record', style: TextStyle(fontSize: 11, color: Color(0xFFD4A017), fontWeight: FontWeight.w600)),
            ]),
          ])),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: _filtered.length,
          itemBuilder: (_, i) {
            final e   = _filtered[i];
            final clr = e['color'] as Color;
            return GestureDetector(
              onTap: () => _showDetail(context, e, clr),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: widget.card, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.border, width: 0.5)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 34, height: 34,
                    decoration: BoxDecoration(color: clr.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                    child: Icon(e['icon'] as IconData, color: clr, size: 16)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e['action'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.textPri),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: clr.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(e['cat'] as String, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: clr))),
                      const SizedBox(width: 6),
                      Text(e['time'] as String, style: TextStyle(fontSize: 9, color: widget.textSec)),
                    ]),
                  ])),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF8B91A8)),
                ])));
          })),
      ]));
  }
  void _showDetail(BuildContext ctx, Map<String, dynamic> e, Color clr) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final card   = isDark ? const Color(0xFF141828) : Colors.white;
    final border = isDark ? const Color(0xFF252B3E) : const Color(0xFFDDE1EE);
    final textPri= isDark ? Colors.white : const Color(0xFF0A0E1A);
    final textSec= isDark ? const Color(0xFF8B91A8) : const Color(0xFF6B7280);

    showModalBottomSheet(
      context: ctx,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Handle
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),

          // Icon + category
          Row(children: [
            Container(width: 48, height: 48,
              decoration: BoxDecoration(color: clr.withOpacity(0.12), borderRadius: BorderRadius.circular(13)),
              child: Icon(e['icon'] as IconData, color: clr, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: clr.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(e['cat'] as String,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: clr))),
              const SizedBox(height: 4),
              Text(e['action'] as String,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
            ])),
          ]),
          const SizedBox(height: 20),
          Divider(color: border, height: 1),
          const SizedBox(height: 16),

          // Details rows
          _DetailRow(Icons.access_time_rounded,   'Timestamp',   e['time'] as String,             clr, textPri, textSec),
          const SizedBox(height: 12),
          _DetailRow(Icons.person_outline,        'Performed by', widget.staffName,               clr, textPri, textSec),
          const SizedBox(height: 12),
          _DetailRow(Icons.badge_outlined,        'Role',         widget.staffRole,               clr, textPri, textSec),
          const SizedBox(height: 12),
          _DetailRow(Icons.category_outlined,     'Category',     e['cat'] as String,             clr, textPri, textSec),
          const SizedBox(height: 12),
          _DetailRow(Icons.lock_outline_rounded,  'Record type',  'Permanent — cannot be deleted',clr, textPri, textSec),
          const SizedBox(height: 24),

          // Close
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: border),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('Close', style: TextStyle(color: textPri, fontWeight: FontWeight.w600)))),
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon; final String label, value; final Color clr, textPri, textSec;
  const _DetailRow(this.icon, this.label, this.value, this.clr, this.textPri, this.textSec);
  @override Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 30, height: 30,
      decoration: BoxDecoration(color: clr.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: clr, size: 15)),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10, color: textSec, fontWeight: FontWeight.w500)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontSize: 13, color: textPri, fontWeight: FontWeight.w600)),
    ])),
  ]);
}

class _SHistStat extends StatelessWidget {
  final String v, l; final Color c; final bool active; final VoidCallback onTap;
  const _SHistStat(this.v, this.l, this.c, {required this.active, required this.onTap});
  @override Widget build(BuildContext ctx) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: active ? c.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active ? c.withOpacity(0.4) : Colors.transparent, width: 1)),
      child: Column(children: [
        Text(v, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c)),
        const SizedBox(height: 2),
        Text(l, style: TextStyle(fontSize: 9, color: active ? c.withOpacity(0.8) : const Color(0xFF8B91A8),
          fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
        if (active) ...[
          const SizedBox(height: 4),
          Container(width: 16, height: 2, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(1))),
        ],
      ]),
    ),
  ));
}
