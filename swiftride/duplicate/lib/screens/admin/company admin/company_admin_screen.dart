// lib/screens/admin/company_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart' show AppColors;
import 'package:swiftride/screens/guest/companies_screen.dart'
    show RentalCompany, CompanyCar, allCompanies;
import 'package:swiftride/services/auth_service.dart';

// ─────────────────────────────────────────────
//  MUTABLE DATA (state-managed in screen)
// ─────────────────────────────────────────────
final _kInitialBookings = [
  _Booking('SW240001','Cameron One',   'Toyota RAV4',      'May 24','May 27',3, 135.0,'Active'),
  _Booking('SW240002','Diana Uwase',   'BMW 5 Series',     'Jun 1', 'Jun 3', 2, 180.0,'Upcoming'),
  _Booking('SW240003','Alice Mugisha', 'Hyundai Tucson',   'Apr 10','Apr 12',2, 116.0,'Completed'),
  _Booking('SW240004','Bob Nkusi',     'Mitsubishi Pajero','Mar 5', 'Mar 7', 2, 130.0,'Cancelled'),
  _Booking('SW240005','Fiona Ingabire','Mitsubishi Pajero','Jun 8', 'Jun 10',2, 130.0,'Active'),
  _Booking('SW240006','Eric Habimana', 'Hyundai Tucson',   'May 1', 'May 3', 2, 116.0,'Completed'),
];

final _kInitialReviews = [
  _Review('Cameron One',   5, 'Excellent service! Car was spotless and pickup was smooth.', 'May 28'),
  _Review('Alice Mugisha', 4, 'Great experience overall. Highly recommend.',                'Apr 14'),
  _Review('Fiona Ingabire',5, 'Perfect for our safari trip. The Pajero handled everything.','Jun 12'),
];

// ─────────────────────────────────────────────
class CompanyAdminScreen extends StatefulWidget {
  final RentalCompany company;
  const CompanyAdminScreen({super.key, required this.company});
  @override State<CompanyAdminScreen> createState() => _State();
}

class _State extends State<CompanyAdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tc;
  late List<_Booking>     _bookings;
  late List<_Review>      _reviews;
  late List<_Agent>       _agents;
  late List<CompanyCar>   _fleet;
  String _bookingFilter   = 'All';
  String _notifMessage    = '';
  bool   _showNotif       = false;

  @override
  void initState() {
    super.initState();
    _tc       = TabController(length: 5, vsync: this);
    _bookings = List.from(_kInitialBookings);
    _reviews  = List.from(_kInitialReviews);
    _fleet    = List.from(widget.company.fleet);
    _agents   = [
      _Agent('James Doe',    'james@safariwheels.rw','+250 788 201 001','Senior Agent',   true),
      _Agent('Mary Uwimana', 'mary@safariwheels.rw', '+250 788 201 002','Fleet Manager',  true),
      _Agent('Paul Ndoli',   'paul@safariwheels.rw', '+250 788 201 003','Agent',          false),
    ];
  }

  @override void dispose() { _tc.dispose(); super.dispose(); }

  void _notify(String msg) {
    setState(() { _notifMessage = msg; _showNotif = true; });
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _showNotif = false); });
  }

  double get _revenue  => _bookings.where((b) => b.status != 'Cancelled').fold(0.0, (s,b)=>s+b.amount);
  int    get _active   => _bookings.where((b) => b.status == 'Active').length;
  int    get _avail    => _fleet.where((c) => c.available).length;

  List<_Booking> get _filteredBookings => _bookingFilter == 'All'
      ? _bookings
      : _bookings.where((b) => b.status == _bookingFilter).toList();

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);
    final card    = isDark ? const Color(0xFF141828) : Colors.white;
    final border  = isDark ? const Color(0xFF252B3E) : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8) : const Color(0xFF6B7280);
    final brand   = widget.company.brandColor;

    return Scaffold(
      backgroundColor: bg,
      drawer: _drawer(isDark, card, border, textPri, textSec, brand),
      appBar: AppBar(
        backgroundColor: brand,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Builder(builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        )),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.company.name,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          Text('Company Admin Panel',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
        ]),
        actions: [
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () => _showNotifSheet(context, card, border, textPri, textSec)),
            Positioned(right: 8, top: 8,
              child: Container(width: 8, height: 8,
                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle))),
          ]),
          Padding(padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showProfile(context, card, border, textPri, textSec, brand),
              child: CircleAvatar(radius: 15, backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(widget.company.initials,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))))),
        ],
        bottom: TabBar(
          controller: _tc,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.55),
          isScrollable: true,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined, size: 16), text: 'Overview'),
            Tab(icon: Icon(Icons.directions_car_outlined, size: 16), text: 'Fleet'),
            Tab(icon: Icon(Icons.receipt_long_outlined, size: 16), text: 'Bookings'),
            Tab(icon: Icon(Icons.star_outline_rounded, size: 16), text: 'Reviews'),
            Tab(icon: Icon(Icons.people_outline, size: 16), text: 'Team'),
          ],
        ),
      ),
      body: Stack(children: [
        TabBarView(controller: _tc, children: [
          _overview(isDark, bg, card, border, textPri, textSec, brand),
          _fleetTab(isDark, bg, card, border, textPri, textSec, brand),
          _bookingsTab(isDark, bg, card, border, textPri, textSec, brand),
          _reviewsTab(isDark, bg, card, border, textPri, textSec),
          _teamTab(isDark, bg, card, border, textPri, textSec, brand),
        ]),
        // Toast notification
        if (_showNotif)
          Positioned(bottom: 20, left: 16, right: 16,
            child: Material(color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D9E75),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_notifMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
                ]),
              ))),
      ]),
    );
  }

  // ══ OVERVIEW ══════════════════════════════════
  Widget _overview(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec, Color brand) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Company profile card
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [brand, brand.withOpacity(0.6)]),
          borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 52, height: 52,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(widget.company.initials,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.company.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              Text(widget.company.tagline, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                const Icon(Icons.star, color: Colors.white, size: 13),
                const SizedBox(width: 4),
                Text('${widget.company.rating}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ])),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.7), size: 13),
            const SizedBox(width: 5),
            Text(widget.company.location, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
            const SizedBox(width: 14),
            Icon(Icons.phone_outlined, color: Colors.white.withOpacity(0.7), size: 13),
            const SizedBox(width: 5),
            Text(widget.company.phone, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
          ]),
        ]),
      ),

      const SizedBox(height: 16),

      // KPIs
      Row(children: [
        _KPICard('\$${_revenue.toInt()}', 'Revenue',       Icons.attach_money_rounded, const Color(0xFFD4A017), card, border, textPri, textSec),
        const SizedBox(width: 10),
        _KPICard('${_bookings.length}',  'Total Bookings', Icons.receipt_long_rounded, const Color(0xFF1D9E75), card, border, textPri, textSec),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _KPICard('$_active active', 'In Progress',  Icons.directions_car_rounded, const Color(0xFF3B5FD4), card, border, textPri, textSec),
        const SizedBox(width: 10),
        _KPICard('$_avail / ${_fleet.length}', 'Available Cars', Icons.garage_rounded, const Color(0xFF7F77DD), card, border, textPri, textSec),
      ]),

      const SizedBox(height: 20),

      // Quick Actions
      Text('Quick Actions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),
      GridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.1,
        children: [
          _QAction(icon: Icons.add_circle_outline,    label: 'Add Car',      color: brand,                   card: card, border: border, textPri: textPri, onTap: () { _tc.animateTo(1); Future.delayed(const Duration(milliseconds: 300), () => _showAddCar(context, card, border, textPri, textSec, brand)); }),
          _QAction(icon: Icons.receipt_long_outlined, label: 'Bookings',     color: const Color(0xFF1D9E75), card: card, border: border, textPri: textPri, onTap: () => _tc.animateTo(2)),
          _QAction(icon: Icons.star_outline_rounded,  label: 'Reviews',      color: AppColors.gold,          card: card, border: border, textPri: textPri, onTap: () => _tc.animateTo(3)),
          _QAction(icon: Icons.people_outline,        label: 'Team',         color: const Color(0xFF7F77DD), card: card, border: border, textPri: textPri, onTap: () => _tc.animateTo(4)),
          _QAction(icon: Icons.bar_chart_rounded,     label: 'Analytics',    color: const Color(0xFF3B5FD4), card: card, border: border, textPri: textPri, onTap: () => _showAnalytics(context, card, border, textPri, textSec, brand)),
          _QAction(icon: Icons.settings_outlined,     label: 'Settings',     color: const Color(0xFF8B91A8), card: card, border: border, textPri: textPri, onTap: () => _showCompanySettings(context, card, border, textPri, textSec, brand)),
        ],
      ),

      const SizedBox(height: 20),
      Text('Recent Bookings', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),
      ..._bookings.take(3).map((b) => GestureDetector(
        onTap: () => _showBookingDetail(context, b, isDark, card, border, textPri, textSec),
        child: _BookingTile(b: b, card: card, border: border, textPri: textPri, textSec: textSec, showChevron: true))),

      const SizedBox(height: 20),
      Text('Fleet Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),
      ..._fleet.map((car) {
        final cc = _catColor(car.category);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
          child: Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: cc.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
              child: Icon(Icons.directions_car_rounded, color: cc, size: 17)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(car.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
              Text('${car.category} · ${car.fuel} · ${car.seats} seats', style: TextStyle(fontSize: 11, color: textSec)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('\$${car.price.toInt()}/day', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold)),
              const SizedBox(height: 3),
              GestureDetector(
                onTap: () => setState(() {
                  final idx = _fleet.indexOf(car);
                  _fleet[idx] = CompanyCar(name: car.name, category: car.category, price: car.price,
                    seats: car.seats, transmission: car.transmission, fuel: car.fuel, available: !car.available);
                  _notify(car.available ? '${car.name} marked as Rented' : '${car.name} marked as Available');
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: car.available ? const Color(0xFF1D9E75).withOpacity(0.1) : const Color(0xFFD85A30).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                  child: Text(car.available ? '● Available' : '✗ Rented',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                      color: car.available ? const Color(0xFF1D9E75) : const Color(0xFFD85A30))))),
            ]),
          ]),
        );
      }),
      const SizedBox(height: 16),
    ]));
  }

  // ══ FLEET TAB ═════════════════════════════════
  Widget _fleetTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec, Color brand) {
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${_fleet.length} vehicles', style: TextStyle(fontSize: 13, color: textSec)),
          Text('$_avail available · ${_fleet.length - _avail} rented', style: TextStyle(fontSize: 11, color: textSec)),
        ])),
        ElevatedButton.icon(
          onPressed: () => _showAddCar(context, card, border, textPri, textSec, brand),
          icon: const Icon(Icons.add, size: 16), label: const Text('Add Car'),
          style: ElevatedButton.styleFrom(
            backgroundColor: brand, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0, textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ])),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _fleet.length,
        itemBuilder: (_, i) {
          final car = _fleet[i];
          final cc  = _catColor(car.category);
          return GestureDetector(
            onTap: () => _showCarDetail(context, car, i, cc, isDark, card, border, textPri, textSec, brand),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
              child: Column(children: [
                Container(height: 100, decoration: BoxDecoration(
                  color: cc.withOpacity(0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                  child: Stack(children: [
                    Center(child: Icon(Icons.directions_car_rounded, size: 64, color: cc.withOpacity(0.22))),
                    Positioned(top: 10, left: 10, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: cc.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text(car.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cc)))),
                    Positioned(top: 10, right: 10, child: GestureDetector(
                      onTap: () => setState(() {
                        _fleet[i] = CompanyCar(name: car.name, category: car.category, price: car.price,
                          seats: car.seats, transmission: car.transmission, fuel: car.fuel, available: !car.available);
                        _notify(car.available ? '${car.name} marked as Rented' : '${car.name} marked as Available');
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: car.available ? const Color(0xFF1D9E75).withOpacity(0.12) : const Color(0xFFD85A30).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20)),
                        child: Text(car.available ? '● Available' : '✗ Rented',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                            color: car.available ? const Color(0xFF1D9E75) : const Color(0xFFD85A30)))))),
                    Positioned(bottom: 10, right: 10, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF141828) : Colors.white, borderRadius: BorderRadius.circular(9),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)]),
                      child: Text('\$${car.price.toInt()}/day',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.gold)))),
                  ])),
                Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(car.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPri)),
                    const SizedBox(height: 4),
                    Wrap(spacing: 8, children: [
                      _SpecChip(icon: Icons.event_seat_outlined, label: '${car.seats}', textSec: textSec, isDark: isDark),
                      _SpecChip(icon: Icons.settings_outlined,   label: car.transmission, textSec: textSec, isDark: isDark),
                      _SpecChip(icon: Icons.local_gas_station_outlined, label: car.fuel, textSec: textSec, isDark: isDark),
                    ]),
                  ])),
                  Row(children: [
                    IconButton(icon: Icon(Icons.edit_outlined, color: brand, size: 20),
                      onPressed: () => _showEditCar(context, car, i, card, border, textPri, textSec, brand)),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFD85A30), size: 20),
                      onPressed: () => _confirmDeleteCar(context, car, i, card, border, textPri, textSec)),
                  ]),
                ])),
              ]),
            ),
          );
        },
      )),
    ]);
  }

  // ══ BOOKINGS TAB ══════════════════════════════
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
          Text('${_filteredBookings.length} bookings', style: TextStyle(fontSize: 12, color: textSec)),
          Text('Revenue: \$${_filteredBookings.where((b)=>b.status!='Cancelled').fold(0.0,(s,b)=>s+b.amount).toInt()}',
            style: const TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600)),
        ])),
      Expanded(child: _filteredBookings.isEmpty
        ? Center(child: Text('No $_bookingFilter bookings', style: TextStyle(color: textSec)))
        : ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: _filteredBookings.length,
          itemBuilder: (_, i) {
            final b = _filteredBookings[i];
            return GestureDetector(
              onTap: () => _showBookingDetail(context, b, isDark, card, border, textPri, textSec),
              child: _BookingTile(b: b, card: card, border: border, textPri: textPri, textSec: textSec, showChevron: true));
          })),
    ]);
  }

  // ══ REVIEWS TAB ═══════════════════════════════
  Widget _reviewsTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec) {
    final avg = _reviews.isEmpty ? 0.0 : _reviews.fold(0.0, (s, r) => s + r.stars) / _reviews.length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
        child: Row(children: [
          Column(children: [
            Text(avg.toStringAsFixed(1), style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: AppColors.gold)),
            Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, color: i < avg.round() ? AppColors.gold : border, size: 16))),
            const SizedBox(height: 4),
            Text('${_reviews.length} reviews', style: TextStyle(fontSize: 11, color: textSec)),
          ]),
          const SizedBox(width: 20),
          Expanded(child: Column(children: [5,4,3,2,1].map((stars) {
            final count = _reviews.where((r) => r.stars == stars).length;
            final pct   = _reviews.isEmpty ? 0.0 : count / _reviews.length;
            return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
              Text('$stars', style: TextStyle(fontSize: 11, color: textSec, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: AppColors.gold, size: 12),
              const SizedBox(width: 8),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: pct, backgroundColor: border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.gold), minHeight: 6))),
              const SizedBox(width: 8),
              Text('$count', style: TextStyle(fontSize: 11, color: textSec)),
            ]));
          }).toList())),
        ]),
      ),
      const SizedBox(height: 16),
      ..._reviews.map((r) => _ReviewCard(r: r, card: card, border: border, textPri: textPri, textSec: textSec,
        onReply: (reply) { _notify('Reply sent to ${r.name}'); })),
    ]);
  }

  // ══ TEAM TAB ══════════════════════════════════
  Widget _teamTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec, Color brand) {
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${_agents.length} team members', style: TextStyle(fontSize: 13, color: textSec)),
          Text('${_agents.where((a) => a.active).length} active', style: TextStyle(fontSize: 11, color: textSec)),
        ])),
        ElevatedButton.icon(
          onPressed: () => _showAddAgent(context, card, border, textPri, textSec, brand),
          icon: const Icon(Icons.person_add_outlined, size: 16), label: const Text('Add Member'),
          style: ElevatedButton.styleFrom(
            backgroundColor: brand, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0, textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
      ])),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _agents.length,
        itemBuilder: (_, i) {
          final a = _agents[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
            child: Row(children: [
              CircleAvatar(radius: 22, backgroundColor: brand.withOpacity(0.15),
                child: Text(a.name.split(' ').map((e) => e[0]).take(2).join(),
                  style: TextStyle(color: brand, fontSize: 13, fontWeight: FontWeight.w700))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
                Text(a.role, style: TextStyle(fontSize: 12, color: textSec)),
                Text(a.email, style: TextStyle(fontSize: 11, color: textSec)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                GestureDetector(
                  onTap: () => setState(() { _agents[i] = _Agent(a.name, a.email, a.phone, a.role, !a.active); _notify('${a.name} ${!a.active ? "activated" : "deactivated"}'); }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: a.active ? const Color(0xFF1D9E75).withOpacity(0.1) : const Color(0xFFD85A30).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                    child: Text(a.active ? 'Active' : 'Inactive',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: a.active ? const Color(0xFF1D9E75) : const Color(0xFFD85A30))))),
                const SizedBox(height: 6),
                Row(children: [
                  IconButton(icon: Icon(Icons.edit_outlined, color: brand, size: 16), padding: EdgeInsets.zero,
                    onPressed: () => _showEditAgent(context, a, i, card, border, textPri, textSec, brand)),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFD85A30), size: 16), padding: EdgeInsets.zero,
                    onPressed: () => _confirmDeleteAgent(context, a, i, card, border, textPri, textSec)),
                ]),
              ]),
            ]),
          );
        },
      )),
    ]);
  }

  // ── Drawer ────────────────────────────────────
  Widget _drawer(bool isDark, Color card, Color border, Color textPri, Color textSec, Color brand) {
    return Drawer(backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
      child: SafeArea(child: Column(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [brand, brand.withOpacity(0.7)])),
          child: Row(children: [
            Container(width: 46, height: 46,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(widget.company.initials,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.company.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              Text('Company Admin', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
            ])),
          ]),
        ),
        const SizedBox(height: 8),
        ...[ (Icons.dashboard_outlined,'Overview',0),(Icons.directions_car_outlined,'Fleet',1),
             (Icons.receipt_long_outlined,'Bookings',2),(Icons.star_outline_rounded,'Reviews',3),
             (Icons.people_outline,'Team',4) ].map((i) => ListTile(
          leading: Icon(i.$1 as IconData, color: textSec, size: 20),
          title: Text(i.$2 as String, style: TextStyle(fontSize: 14, color: textPri)),
          onTap: () { Navigator.pop(context); _tc.animateTo(i.$3 as int); }, dense: true)),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings_outlined, color: Color(0xFF8B91A8), size: 20),
          title: Text('Company Settings', style: TextStyle(fontSize: 14, color: textPri)),
          onTap: () { Navigator.pop(context); _showCompanySettings(context, card, border, textPri, textSec, brand); }, dense: true),
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: Color(0xFFD85A30), size: 20),
          title: const Text('Sign Out', style: TextStyle(fontSize: 14, color: Color(0xFFD85A30))),
          onTap: () { AuthService.logout(); Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false); }, dense: true),
      ])));
  }

  // ── Sheets ────────────────────────────────────
  void _showAddCar(BuildContext ctx, Color card, Color border, Color textPri, Color textSec, Color brand) {
    final nameC = TextEditingController(); final catC = TextEditingController();
    final priceC = TextEditingController(); final fuelC = TextEditingController();
    final seatsC = TextEditingController(); final transC = TextEditingController();
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Text('Add New Vehicle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
          const SizedBox(height: 16),
          _TField('Vehicle Name', 'e.g. Toyota RAV4', nameC, textPri, textSec),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _TField('Category', 'SUV', catC, textPri, textSec)),
            const SizedBox(width: 10),
            Expanded(child: _TField('Price/day \$', '60', priceC, textPri, textSec, numeric: true)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _TField('Fuel', 'Petrol', fuelC, textPri, textSec)),
            const SizedBox(width: 10),
            Expanded(child: _TField('Seats', '5', seatsC, textPri, textSec, numeric: true)),
          ]),
          const SizedBox(height: 10),
          _TField('Transmission', 'Auto / Manual', transC, textPri, textSec),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (nameC.text.isEmpty) return;
              setState(() {
                _fleet.add(CompanyCar(
                  name: nameC.text,
                  category: catC.text.isEmpty ? 'SUV' : catC.text,
                  price: double.tryParse(priceC.text) ?? 60,
                  seats: int.tryParse(seatsC.text) ?? 5,
                  transmission: transC.text.isEmpty ? 'Auto' : transC.text,
                  fuel: fuelC.text.isEmpty ? 'Petrol' : fuelC.text,
                  available: true,
                ));
              });
              Navigator.pop(ctx);
              _notify('${nameC.text} added to fleet');
            },
            style: ElevatedButton.styleFrom(backgroundColor: brand, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Add Vehicle', style: TextStyle(fontWeight: FontWeight.w700)))),
        ]))));
  }

  void _showEditCar(BuildContext ctx, CompanyCar car, int idx, Color card, Color border, Color textPri, Color textSec, Color brand) {
    final nameC  = TextEditingController(text: car.name);
    final priceC = TextEditingController(text: car.price.toInt().toString());
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Text('Edit Vehicle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
          const SizedBox(height: 16),
          _TField('Vehicle Name', car.name, nameC, textPri, textSec),
          const SizedBox(height: 10),
          _TField('Price/day \$', car.price.toInt().toString(), priceC, textPri, textSec, numeric: true),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(side: BorderSide(color: border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14)),
              child: Text('Cancel', style: TextStyle(color: textSec)))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _fleet[idx] = CompanyCar(
                    name: nameC.text, category: car.category,
                    price: double.tryParse(priceC.text) ?? car.price,
                    seats: car.seats, transmission: car.transmission,
                    fuel: car.fuel, available: car.available);
                });
                Navigator.pop(ctx);
                _notify('${nameC.text} updated');
              },
              style: ElevatedButton.styleFrom(backgroundColor: brand, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)))),
          ]),
        ]))));
  }

  void _confirmDeleteCar(BuildContext ctx, CompanyCar car, int idx, Color card, Color border, Color textPri, Color textSec) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: card,
      title: Text('Remove Vehicle?', style: TextStyle(color: textPri, fontWeight: FontWeight.w700)),
      content: Text('Remove "${car.name}" from the fleet?', style: TextStyle(color: textSec)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: textSec))),
        TextButton(onPressed: () { setState(() => _fleet.removeAt(idx)); Navigator.pop(ctx); _notify('${car.name} removed'); },
          child: const Text('Remove', style: TextStyle(color: Color(0xFFD85A30), fontWeight: FontWeight.w700))),
      ],
    ));
  }

  void _showCarDetail(BuildContext ctx, CompanyCar car, int idx, Color cc, bool isDark, Color card, Color border, Color textPri, Color textSec, Color brand) {
    showModalBottomSheet(context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(initialChildSize: 0.65, minChildSize: 0.4, maxChildSize: 0.9,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Container(height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [cc.withOpacity(0.18), cc.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(14)),
              child: Stack(children: [
                Center(child: Icon(Icons.directions_car_rounded, size: 70, color: cc.withOpacity(0.25))),
                Positioned(top: 10, right: 10, child: Text('\$${car.price.toInt()}/day',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gold))),
              ])),
            const SizedBox(height: 14),
            Text(car.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPri)),
            const SizedBox(height: 4),
            Text('${car.category} · ${car.fuel} · ${car.transmission} · ${car.seats} seats', style: TextStyle(fontSize: 13, color: textSec)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: ElevatedButton.icon(
                onPressed: () { Navigator.pop(ctx); _showEditCar(ctx, car, idx, card, border, textPri, textSec, brand); },
                icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Edit'),
                style: ElevatedButton.styleFrom(backgroundColor: brand, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _fleet[idx] = CompanyCar(name: car.name, category: car.category, price: car.price,
                      seats: car.seats, transmission: car.transmission, fuel: car.fuel, available: !car.available);
                  });
                  Navigator.pop(ctx);
                  _notify(car.available ? '${car.name} marked as Rented' : '${car.name} marked as Available');
                },
                icon: const Icon(Icons.toggle_on_outlined, size: 16),
                label: Text(car.available ? 'Mark Rented' : 'Mark Available'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: car.available ? const Color(0xFF1D9E75) : AppColors.gold),
                  foregroundColor: car.available ? const Color(0xFF1D9E75) : AppColors.gold,
                  padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
            ]),
          ]))));
  }

  void _showBookingDetail(BuildContext ctx, _Booking b, bool isDark, Color card, Color border, Color textPri, Color textSec) {
    final sc = _statusColor(b.status);
    showModalBottomSheet(context: ctx, backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.receipt_long_rounded, color: sc, size: 22)),
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
        ...[(Icons.person_outline,'Customer',b.user),(Icons.directions_car_outlined,'Vehicle',b.car),
            (Icons.calendar_today_outlined,'Pick-up',b.from),(Icons.event_outlined,'Drop-off',b.to),
            (Icons.access_time_outlined,'Duration','${b.days} days')].map((r) =>
          Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
            Icon(r.$1 as IconData, size: 15, color: textSec),
            const SizedBox(width: 10),
            Text('${r.$2}: ', style: TextStyle(fontSize: 12, color: textSec)),
            Expanded(child: Text(r.$3 as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri))),
          ]))),
        const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
          Text('\$${b.amount.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gold)),
        ]),
        const SizedBox(height: 16),
        if (b.status == 'Upcoming') Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () {
              final idx = _bookings.indexOf(b);
              if (idx >= 0) setState(() => _bookings[idx] = _Booking(b.ref,b.user,b.car,b.from,b.to,b.days,b.amount,'Cancelled'));
              Navigator.pop(ctx);
              _notify('Booking ${b.ref} cancelled');
            },
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD85A30)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Cancel Booking', style: TextStyle(color: Color(0xFFD85A30))))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () {
              final idx = _bookings.indexOf(b);
              if (idx >= 0) setState(() => _bookings[idx] = _Booking(b.ref,b.user,b.car,b.from,b.to,b.days,b.amount,'Active'));
              Navigator.pop(ctx);
              _notify('Booking ${b.ref} confirmed');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D9E75), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Confirm'))),
        ]),
        if (b.status == 'Active') SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () {
            final idx = _bookings.indexOf(b);
            if (idx >= 0) setState(() => _bookings[idx] = _Booking(b.ref,b.user,b.car,b.from,b.to,b.days,b.amount,'Completed'));
            Navigator.pop(ctx);
            _notify('Booking ${b.ref} marked as Completed');
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B5FD4), foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
          child: const Text('Mark as Completed'))),
      ])));
  }

  void _showAddAgent(BuildContext ctx, Color card, Color border, Color textPri, Color textSec, Color brand) {
    final nameC  = TextEditingController();
    final emailC = TextEditingController();
    final phoneC = TextEditingController();
    final roleC  = TextEditingController();
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Text('Add Team Member', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
          const SizedBox(height: 16),
          _TField('Full Name', 'e.g. Jean Claude', nameC, textPri, textSec),
          const SizedBox(height: 10),
          _TField('Email', 'email@company.rw', emailC, textPri, textSec),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _TField('Phone', '+250...', phoneC, textPri, textSec)),
            const SizedBox(width: 10),
            Expanded(child: _TField('Role', 'Agent', roleC, textPri, textSec)),
          ]),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (nameC.text.isEmpty) return;
              setState(() => _agents.add(_Agent(nameC.text, emailC.text, phoneC.text, roleC.text.isEmpty ? 'Agent' : roleC.text, true)));
              Navigator.pop(ctx);
              _notify('${nameC.text} added to team');
            },
            style: ElevatedButton.styleFrom(backgroundColor: brand, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Add Member', style: TextStyle(fontWeight: FontWeight.w700)))),
        ]))));
  }

  void _showEditAgent(BuildContext ctx, _Agent a, int idx, Color card, Color border, Color textPri, Color textSec, Color brand) {
    final roleC = TextEditingController(text: a.role);
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Text('Edit ${a.name}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
          const SizedBox(height: 16),
          _TField('Role', a.role, roleC, textPri, textSec),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              setState(() => _agents[idx] = _Agent(a.name, a.email, a.phone, roleC.text, a.active));
              Navigator.pop(ctx);
              _notify('${a.name} role updated');
            },
            style: ElevatedButton.styleFrom(backgroundColor: brand, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)))),
        ]))));
  }

  void _confirmDeleteAgent(BuildContext ctx, _Agent a, int idx, Color card, Color border, Color textPri, Color textSec) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: card,
      title: Text('Remove Member?', style: TextStyle(color: textPri, fontWeight: FontWeight.w700)),
      content: Text('Remove ${a.name} from the team?', style: TextStyle(color: textSec)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: textSec))),
        TextButton(onPressed: () { setState(() => _agents.removeAt(idx)); Navigator.pop(ctx); _notify('${a.name} removed'); },
          child: const Text('Remove', style: TextStyle(color: Color(0xFFD85A30), fontWeight: FontWeight.w700))),
      ],
    ));
  }

  void _showNotifSheet(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 14),
        Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
        const SizedBox(height: 16),
        ...[('New booking: Cameron One – RAV4','2 min ago',const Color(0xFF1D9E75)),
            ('Review received: 5 stars','1 hr ago',AppColors.gold),
            ('Booking SW240002 confirmed','3 hr ago',const Color(0xFF3B5FD4))].map((n) =>
          Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: n.$3.withOpacity(0.07), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: n.$3.withOpacity(0.2), width: 0.5)),
            child: Row(children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: n.$3.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(Icons.notifications_outlined, color: n.$3, size: 16)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(n.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri)),
                Text(n.$2, style: TextStyle(fontSize: 10, color: textSec)),
              ])),
            ]))),
      ])));
  }

  void _showAnalytics(BuildContext ctx, Color card, Color border, Color textPri, Color textSec, Color brand) {
    final completed = _bookings.where((b) => b.status == 'Completed').fold(0.0, (s,b)=>s+b.amount);
    final active    = _bookings.where((b) => b.status == 'Active').fold(0.0, (s,b)=>s+b.amount);
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 14),
        Text('Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
        const SizedBox(height: 16),
        ...[ ('Total Revenue',    '\$${_revenue.toInt()}',    AppColors.gold),
             ('Completed Revenue','\$${completed.toInt()}',   const Color(0xFF1D9E75)),
             ('Active Revenue',   '\$${active.toInt()}',      const Color(0xFF3B5FD4)),
             ('Fleet Utilisation','${((_fleet.length-_avail)/_fleet.length*100).toInt()}%', brand),
             ('Avg Rating',       '${widget.company.rating}★',AppColors.gold),
        ].map((r) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: r.$3.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
            child: Center(child: Icon(Icons.bar_chart_rounded, color: r.$3, size: 18))),
          const SizedBox(width: 12),
          Expanded(child: Text(r.$1, style: TextStyle(fontSize: 13, color: textSec))),
          Text(r.$2, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: r.$3)),
        ]))),
      ])));
  }

  void _showProfile(BuildContext ctx, Color card, Color border, Color textPri, Color textSec, Color brand) {
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        CircleAvatar(radius: 32, backgroundColor: brand.withOpacity(0.15),
          child: Text(widget.company.initials, style: TextStyle(color: brand, fontSize: 22, fontWeight: FontWeight.w800))),
        const SizedBox(height: 10),
        Text(widget.company.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPri)),
        Text('Company Administrator', style: TextStyle(fontSize: 13, color: textSec)),
        const SizedBox(height: 16),
        ...[(Icons.email_outlined, widget.company.phone),
            (Icons.location_on_outlined, widget.company.location)].map((r) =>
          Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
            Icon(r.$1, color: textSec, size: 16), const SizedBox(width: 10),
            Text(r.$2, style: TextStyle(color: textSec, fontSize: 13)),
          ]))),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () { Navigator.pop(ctx); AuthService.logout(); Navigator.pushNamedAndRemoveUntil(ctx, '/home', (_) => false); },
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD85A30)),
            padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Sign Out', style: TextStyle(color: Color(0xFFD85A30), fontWeight: FontWeight.w700)))),
      ])));
  }

  void _showCompanySettings(BuildContext ctx, Color card, Color border, Color textPri, Color textSec, Color brand) {
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 14),
        Text('Company Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
        const SizedBox(height: 16),
        ...[('Edit Company Profile', Icons.business_outlined),
            ('Manage Availability Hours', Icons.schedule_outlined),
            ('Payment Settings', Icons.payment_outlined),
            ('Notification Preferences', Icons.notifications_outlined)].map((i) =>
          ListTile(
            leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: brand.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
              child: Icon(i.$2, color: brand, size: 18)),
            title: Text(i.$1, style: TextStyle(fontSize: 13, color: textPri)),
            trailing: Icon(Icons.chevron_right_rounded, color: textSec, size: 18),
            onTap: () { Navigator.pop(ctx); _notify('${i.$1} — coming soon'); },
            dense: true)),
        const SizedBox(height: 8),
      ])));
  }

  // ── Helpers ───────────────────────────────────
  Color _catColor(String cat) {
    const m = {'Economy':Color(0xFF1D9E75),'SUV':Color(0xFF3B5FD4),'Luxury':Color(0xFF7F77DD),
      '4x4':Color(0xFFD85A30),'Van':Color(0xFF0D7EA8),'Sedan':Color(0xFF1D9E75),'Premium':Color(0xFF7F77DD)};
    return m[cat] ?? AppColors.gold;
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
//  DATA MODELS
// ─────────────────────────────────────────────
class _Booking {
  final String ref, user, car, from, to, status;
  final double amount;
  final int    days;
  const _Booking(this.ref, this.user, this.car, this.from, this.to, this.days, this.amount, this.status);
}

class _Review {
  final String name, text, date;
  final int    stars;
  const _Review(this.name, this.stars, this.text, this.date);
}

class _Agent {
  final String name, email, phone, role;
  final bool   active;
  const _Agent(this.name, this.email, this.phone, this.role, this.active);
}

// ─────────────────────────────────────────────
//  REUSABLE WIDGETS
// ─────────────────────────────────────────────
class _KPICard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color, card, border, textPri, textSec;
  const _KPICard(this.value, this.label, this.icon, this.color, this.card, this.border, this.textPri, this.textSec);
  @override
  Widget build(BuildContext c) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
    child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri), overflow: TextOverflow.ellipsis),
        Text(label,  style: TextStyle(fontSize: 10, color: textSec)),
      ])),
    ])));
}

class _QAction extends StatelessWidget {
  final IconData icon; final String label; final Color color, card, border, textPri;
  final VoidCallback onTap;
  const _QAction({required this.icon, required this.label, required this.color, required this.card, required this.border, required this.textPri, required this.onTap});
  @override
  Widget build(BuildContext c) => GestureDetector(onTap: onTap, child: Container(
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 19)),
      const SizedBox(height: 8),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textPri), textAlign: TextAlign.center),
    ])));
}

class _BookingTile extends StatelessWidget {
  final _Booking b; final Color card, border, textPri, textSec; final bool showChevron;
  const _BookingTile({required this.b, required this.card, required this.border, required this.textPri, required this.textSec, this.showChevron = false});
  Color get _sc { switch(b.status){case'Active':return const Color(0xFF1D9E75);case'Upcoming':return const Color(0xFF3B5FD4);case'Cancelled':return const Color(0xFFD85A30);default:return const Color(0xFF8B91A8);} }
  @override
  Widget build(BuildContext c) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
    child: Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: _sc.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
        child: Icon(Icons.directions_car_rounded, color: _sc, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${b.car} · ${b.user}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
        Text('${b.from} → ${b.to} · \$${b.amount.toInt()}', style: TextStyle(fontSize: 11, color: textSec)),
      ])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: _sc.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Text(b.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _sc))),
      if (showChevron) ...[const SizedBox(width: 6), Icon(Icons.chevron_right_rounded, color: textSec, size: 16)],
    ]));
}

class _ReviewCard extends StatefulWidget {
  final _Review r; final Color card, border, textPri, textSec;
  final void Function(String reply) onReply;
  const _ReviewCard({required this.r, required this.card, required this.border, required this.textPri, required this.textSec, required this.onReply});
  @override State<_ReviewCard> createState() => _ReviewCardState();
}
class _ReviewCardState extends State<_ReviewCard> {
  bool _showReply = false;
  String? _reply;
  final _ctrl = TextEditingController();
  @override
  Widget build(BuildContext c) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: widget.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: widget.border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(radius: 18, backgroundColor: AppColors.gold.withOpacity(0.15),
          child: Text(widget.r.name[0], style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.r.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.textPri)),
          Text(widget.r.date, style: TextStyle(fontSize: 11, color: widget.textSec)),
        ])),
        Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, color: i < widget.r.stars ? AppColors.gold : widget.border, size: 14))),
      ]),
      const SizedBox(height: 10),
      Text(widget.r.text, style: TextStyle(fontSize: 13, color: widget.textPri, height: 1.5)),
      const SizedBox(height: 10),
      if (_reply != null)
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.06), borderRadius: BorderRadius.circular(9)),
          child: Row(children: [
            const Icon(Icons.reply_rounded, color: AppColors.gold, size: 15),
            const SizedBox(width: 8),
            Expanded(child: Text(_reply!, style: TextStyle(fontSize: 12, color: widget.textSec))),
          ]))
      else if (_showReply)
        Row(children: [
          Expanded(child: TextField(
            controller: _ctrl,
            style: TextStyle(fontSize: 12, color: widget.textPri),
            decoration: InputDecoration(
              hintText: 'Write a reply…',
              hintStyle: TextStyle(color: widget.textSec, fontSize: 12),
              filled: true, fillColor: widget.border.withOpacity(0.15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          )),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () { setState(() { _reply = _ctrl.text; _showReply = false; }); widget.onReply(_ctrl.text); },
            child: Container(width: 36, height: 36,
              decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 16))),
        ])
      else
        GestureDetector(
          onTap: () => setState(() => _showReply = true),
          child: Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.06), borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.gold.withOpacity(0.15), width: 0.8)),
            child: Row(children: [
              const Icon(Icons.reply_rounded, color: AppColors.gold, size: 15),
              const SizedBox(width: 8),
              Text('Reply to this review', style: TextStyle(fontSize: 12, color: widget.textSec)),
            ]))),
    ]));
}

class _SpecChip extends StatelessWidget {
  final IconData icon; final String label; final Color textSec; final bool isDark;
  const _SpecChip({required this.icon, required this.label, required this.textSec, required this.isDark});
  @override
  Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: isDark ? const Color(0xFF1C2236) : const Color(0xFFF2F4F8), borderRadius: BorderRadius.circular(7)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: textSec), const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, color: textSec))]));
}

Widget _TField(String label, String hint, TextEditingController ctrl, Color textPri, Color textSec, {bool numeric = false}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 11, color: textSec, fontWeight: FontWeight.w500)),
    const SizedBox(height: 4),
    TextField(
      controller: ctrl,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      style: TextStyle(fontSize: 13, color: textPri),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textSec, fontSize: 13),
        filled: true, fillColor: const Color(0xFF1C2236),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
  ]);
}
