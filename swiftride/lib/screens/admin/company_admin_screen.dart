// lib/screens/admin/company_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart' show AppColors, themeNotifier;
import 'package:swiftride/screens/guest/companies_screen.dart'
    show RentalCompany, CompanyCar, allCompanies;
import 'package:swiftride/services/auth_service.dart';
import 'package:swiftride/services/app_data_store.dart';
import 'package:swiftride/services/wallet_service.dart';
import 'package:swiftride/screens/admin/wallet_tab.dart';

// ─────────────────────────────────────────────
//  SEED DATA
// ─────────────────────────────────────────────
final _kInitialBookings = [
  _Booking('SW240001','Cameron One',   'Toyota RAV4',      'May 24','May 27',3,135.0,'Active'),
  _Booking('SW240002','Diana Uwase',   'BMW 5 Series',     'Jun 1', 'Jun 3', 2,180.0,'Upcoming'),
  _Booking('SW240003','Alice Mugisha', 'Hyundai Tucson',   'Apr 10','Apr 12',2,116.0,'Completed'),
  _Booking('SW240004','Bob Nkusi',     'Mitsubishi Pajero','Mar 5', 'Mar 7', 2,130.0,'Cancelled'),
  _Booking('SW240005','Fiona Ingabire','Mitsubishi Pajero','Jun 8', 'Jun 10',2,130.0,'Active'),
  _Booking('SW240006','Eric Habimana', 'Hyundai Tucson',   'May 1', 'May 3', 2,116.0,'Completed'),
];
final _kInitialReviews = [
  _Review('Cameron One',   5,'Excellent service! Car was spotless and pickup was smooth.','May 28'),
  _Review('Alice Mugisha', 4,'Great experience overall. Highly recommend.',               'Apr 14'),
  _Review('Fiona Ingabire',5,'Perfect for our safari trip. The Pajero handled everything.','Jun 12'),
];

// ─────────────────────────────────────────────
class CompanyAdminScreen extends StatefulWidget {
  final RentalCompany company;
  const CompanyAdminScreen({super.key, required this.company});
  @override State<CompanyAdminScreen> createState() => _CAState();
}

class _CAState extends State<CompanyAdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tc;
  late List<_Booking>   _bookings;
  late List<_Review>    _reviews;
  late List<_Agent>     _agents;
  late List<CompanyCar> _fleet;
  String _bookingFilter = 'All';
  String _notifMsg      = '';
  bool   _showNotif     = false;

  // Shared store
  AppDataStore get _store => AppDataStore.instance;
  String get _actor => '${widget.company.name} Admin';
  String get _actorRole => 'Company Admin';
  String get _company => widget.company.name;

  @override
  void initState() {
    super.initState();
    _tc       = TabController(length: 6, vsync: this);
    // Load from shared store if available, else use seed
    final storeBookings = _store.bookingsForCompany(widget.company.name);
    _bookings = storeBookings.isNotEmpty
      ? storeBookings.map((b) => _Booking(b.ref, b.customer, b.car, b.from, b.to, b.days, b.amount, b.status)).toList()
      : List.from(_kInitialBookings);
    _reviews  = List.from(_kInitialReviews);
    // Seed one car as rented so the rented section is always visible for demo
    final rawFleet = List<CompanyCar>.from(widget.company.fleet);
    _fleet = rawFleet.asMap().entries.map((e) {
      if (e.key == 1 && rawFleet.length > 1) {
        final c = e.value;
        return CompanyCar(name: c.name, category: c.category, price: c.price,
          seats: c.seats, transmission: c.transmission, fuel: c.fuel, available: false);
      }
      return e.value;
    }).toList();
    _agents   = [
      _Agent('James Doe',   'james@company.rw','+250 788 201 001','Senior Agent', true),
      _Agent('Mary Uwimana','mary@company.rw', '+250 788 201 002','Fleet Manager',true),
      _Agent('Paul Ndoli',  'paul@company.rw', '+250 788 201 003','Agent',        false),
    ];
  }

  @override void dispose() { _tc.dispose(); super.dispose(); }

  void _notify(String msg) {
    setState(() { _notifMsg = msg; _showNotif = true; });
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _showNotif = false); });
  }

  double get _revenue => _bookings.where((b) => b.status != 'Cancelled').fold(0.0, (s,b) => s+b.amount);
  int    get _active  => _bookings.where((b) => b.status == 'Active').length;
  int    get _avail   => _fleet.where((c) => c.available).length;
  List<_Booking> get _filteredBookings =>
    _bookingFilter == 'All' ? _bookings : _bookings.where((b) => b.status == _bookingFilter).toList();

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);
    final card    = isDark ? const Color(0xFF141828) : Colors.white;
    final border  = isDark ? const Color(0xFF252B3E) : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white             : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8)  : const Color(0xFF6B7280);
    final brand   = widget.company.brandColor;

    return Scaffold(
      backgroundColor: bg,
      drawer: _buildDrawer(isDark, card, border, textPri, textSec, brand),
      appBar: AppBar(
        backgroundColor: brand,
        elevation: 0,
        toolbarHeight: 56,
        leading: Builder(builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer())),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.company.name,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          const Text('Company Admin Panel',
            style: TextStyle(color: Colors.white70, fontSize: 11)),
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showProfile(context, card, border, textPri, textSec, brand),
              child: CircleAvatar(radius: 15, backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(widget.company.initials,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))))),
        ],
        bottom: TabBar(
          controller: _tc,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined, size: 18),    text: 'Overview'),
            Tab(icon: Icon(Icons.directions_car_outlined, size: 18),text: 'Fleet'),
            Tab(icon: Icon(Icons.receipt_long_outlined, size: 18),  text: 'Bookings'),
            Tab(icon: Icon(Icons.star_outline_rounded, size: 18),   text: 'Reviews'),
            Tab(icon: Icon(Icons.people_outline, size: 18),         text: 'Team'),
            Tab(icon: Icon(Icons.account_balance_wallet_rounded, size: 18), text: 'Wallet'),
          ],
        ),
      ),
      body: Stack(children: [
        TabBarView(controller: _tc, children: [
          _overviewTab(isDark, bg, card, border, textPri, textSec, brand),
          _fleetTab(isDark, bg, card, border, textPri, textSec, brand),
          _bookingsTab(isDark, bg, card, border, textPri, textSec, brand),
          _reviewsTab(isDark, bg, card, border, textPri, textSec),
          _teamTab(isDark, bg, card, border, textPri, textSec, brand),
          WalletTab(
            ownerKey: widget.company.name,
            isSuperAdmin: false,
            card: card, border: border,
            textPri: textPri, textSec: textSec, bg: bg,
          ),
        ]),
        if (_showNotif)
          Positioned(bottom: 20, left: 16, right: 16,
            child: Material(color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFF1D9E75), borderRadius: BorderRadius.circular(12)),
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
  //  OVERVIEW TAB
  // ══════════════════════════════════════════
  Widget _overviewTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec, Color brand) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Company card
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
              Text(widget.company.name,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              Text(widget.company.tagline,
                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                const Icon(Icons.star, color: Colors.white, size: 13),
                const SizedBox(width: 4),
                Text('${widget.company.rating}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ])),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.7), size: 13),
            const SizedBox(width: 5),
            Text(widget.company.location,
              style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
            const SizedBox(width: 14),
            Icon(Icons.phone_outlined, color: Colors.white.withOpacity(0.7), size: 13),
            const SizedBox(width: 5),
            Text(widget.company.phone,
              style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
          ]),
        ])),
      const SizedBox(height: 16),
      // KPIs
      Row(children: [
        _KPICard('\$${_revenue.toInt()}', 'Revenue', Icons.attach_money_rounded, const Color(0xFFD4A017), card, border, textPri, textSec,
          onTap: () => _showAnalytics(context, card, border, textPri, textSec, brand)),
        const SizedBox(width: 10),
        _KPICard('${_bookings.length}', 'Total Bookings', Icons.receipt_long_rounded, const Color(0xFF1D9E75), card, border, textPri, textSec,
          onTap: () => _tc.animateTo(2)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _KPICard('$_active active', 'In Progress', Icons.directions_car_rounded, const Color(0xFF3B5FD4), card, border, textPri, textSec,
          onTap: () { _tc.animateTo(2); WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() => _bookingFilter = 'Active'); }); }),
        const SizedBox(width: 10),
        _KPICard('$_avail / ${_fleet.length}', 'Available Cars', Icons.garage_rounded, const Color(0xFF7F77DD), card, border, textPri, textSec,
          onTap: () => _tc.animateTo(1)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _KPICard('\$${WalletService.instance.walletFor(widget.company.name).balance.toStringAsFixed(0)}',
          'Wallet Balance', Icons.account_balance_wallet_rounded, const Color(0xFF1D9E75), card, border, textPri, textSec,
          onTap: () => _tc.animateTo(5)),
        const SizedBox(width: 10),
        _KPICard('${WalletService.instance.commissionFor(widget.company.name).toInt()}%',
          'Commission Rate', Icons.percent_rounded, const Color(0xFFD85A30), card, border, textPri, textSec),
      ]),
      const SizedBox(height: 16),
      // ── Rental model banner ──────────────────────────────
      _RentalModelBanner(rentalModel: widget.company.rentalModel, brand: brand, textSec: textSec),
      const SizedBox(height: 20),
      // Quick actions
      Text('Quick Actions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 10),
      GridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.1,
        children: [
          _QAction(icon: Icons.add_circle_outline,    label: 'Add Car',  color: brand,                   card: card, border: border, textPri: textPri, onTap: () { _tc.animateTo(1); Future.delayed(const Duration(milliseconds: 300), () => _showAddCar(context, card, border, textPri, textSec, brand)); }),
          _QAction(icon: Icons.receipt_long_outlined, label: 'Bookings', color: const Color(0xFF1D9E75), card: card, border: border, textPri: textPri, onTap: () => _tc.animateTo(2)),
          _QAction(icon: Icons.star_outline_rounded,  label: 'Reviews',  color: const Color(0xFFD4A017),          card: card, border: border, textPri: textPri, onTap: () => _tc.animateTo(3)),
          _QAction(icon: Icons.people_outline,        label: 'Team',     color: const Color(0xFF7F77DD), card: card, border: border, textPri: textPri, onTap: () => _tc.animateTo(4)),
          _QAction(icon: Icons.bar_chart_rounded,     label: 'Analytics',color: const Color(0xFF3B5FD4), card: card, border: border, textPri: textPri, onTap: () => _showAnalytics(context, card, border, textPri, textSec, brand)),
          _QAction(icon: Icons.settings_outlined,     label: 'Settings', color: const Color(0xFF8B91A8), card: card, border: border, textPri: textPri, onTap: () => _showCompanySettings(context, card, border, textPri, textSec, brand)),
        ]),
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
              Text('\$${car.price.toInt()}/day', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFD4A017))),
              const SizedBox(height: 3),
              GestureDetector(
                onTap: () {
                  final idx = _fleet.indexOf(car);
                  setState(() => _fleet[idx] = CompanyCar(
                    name: car.name, category: car.category, price: car.price,
                    seats: car.seats, transmission: car.transmission, fuel: car.fuel,
                    available: !car.available));
                  _notify(car.available ? '${car.name} marked as Rented' : '${car.name} marked as Available');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: car.available ? const Color(0xFF1D9E75).withOpacity(0.1) : const Color(0xFFD85A30).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                  child: Text(car.available ? '● Available' : '✗ Rented',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                      color: car.available ? const Color(0xFF1D9E75) : const Color(0xFFD85A30))))),
            ]),
          ]));
      }),
      const SizedBox(height: 16),
    ]));
  }

  // ══════════════════════════════════════════
  //  FLEET TAB
  // ══════════════════════════════════════════
  Widget _fleetTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec, Color brand) {
    final rented    = _fleet.where((c) => !c.available).toList();
    final available = _fleet.where((c) => c.available).toList();

    return Column(children: [
      // ── Top bar ──────────────────────────────────
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Row(children: [
        Expanded(child: Text('${_fleet.length} vehicles total',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSec))),
        ElevatedButton.icon(
          onPressed: () => _showAddCar(context, card, border, textPri, textSec, brand),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Car'),
          style: ElevatedButton.styleFrom(
            backgroundColor: brand, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
      ])),

      // ── Summary cards ─────────────────────────────
      Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Row(children: [
        // Currently Rented card
        Expanded(child: GestureDetector(
          onTap: () => _showRentedList(context, rented, isDark, card, border, textPri, textSec, brand),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFD85A30).withOpacity(0.15), const Color(0xFFD85A30).withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD85A30).withOpacity(0.35), width: 1)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 32, height: 32,
                  decoration: BoxDecoration(color: const Color(0xFFD85A30).withOpacity(0.15), borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.car_rental_rounded, color: Color(0xFFD85A30), size: 16)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFFD85A30).withOpacity(0.6), size: 11),
              ]),
              const SizedBox(height: 10),
              Text('${rented.length}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFFD85A30))),
              const SizedBox(height: 2),
              const Text('Currently Rented Out', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFD85A30))),
            ]),
          ))),
        const SizedBox(width: 12),
        // Available for booking card
        Expanded(child: GestureDetector(
          onTap: () => _showAvailableList(context, available, isDark, card, border, textPri, textSec, brand),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1D9E75).withOpacity(0.15), const Color(0xFF1D9E75).withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1D9E75).withOpacity(0.35), width: 1)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 32, height: 32,
                  decoration: BoxDecoration(color: const Color(0xFF1D9E75).withOpacity(0.15), borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF1D9E75), size: 16)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFF1D9E75).withOpacity(0.6), size: 11),
              ]),
              const SizedBox(height: 10),
              Text('${available.length}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1D9E75))),
              const SizedBox(height: 2),
              const Text('Available for Booking', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1D9E75))),
            ]),
          ))),
      ])),

      // ── Available cars list ───────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(children: [
          Container(width: 3, height: 14,
            decoration: BoxDecoration(color: const Color(0xFF1D9E75), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text('Available Cars', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFF1D9E75).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('${available.length}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1D9E75)))),
        ])),

      Expanded(child: available.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.directions_car_outlined, size: 48, color: textSec),
            const SizedBox(height: 10),
            Text('All cars are currently rented', style: TextStyle(color: textSec, fontSize: 14)),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: available.length,
            itemBuilder: (_, i) {
              final car = available[i];
              final idx = _fleet.indexOf(car);
              return _FleetCard(
                car: car,
                catColor: _catColor(car.category),
                isDark: isDark,
                card: card, border: border, textPri: textPri, textSec: textSec, brand: brand,
                onTap:    () => _showCarDetail(context, car, idx, _catColor(car.category), isDark, card, border, textPri, textSec, brand),
                onToggle: () {
                  setState(() => _fleet[idx] = CompanyCar(name: car.name, category: car.category,
                    price: car.price, seats: car.seats, transmission: car.transmission,
                    fuel: car.fuel, available: false));
                  _notify('${car.name} marked as Rented');
                },
                onEdit:   () => _showEditCar(context, car, idx, card, border, textPri, textSec, brand),
                onDelete: () => _confirmDeleteCar(context, car, idx, card, border, textPri, textSec),
              );
            })),
    ]);
  }

  void _showRentedList(BuildContext ctx, List<CompanyCar> rented, bool isDark,
      Color card, Color border, Color textPri, Color textSec, Color brand) {
    showModalBottomSheet(
      context: ctx, backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.9, expand: false,
        builder: (_, ctrl) => Column(children: [
          Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
            decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 10), child: Row(children: [
            Container(width: 32, height: 32,
              decoration: BoxDecoration(color: const Color(0xFFD85A30).withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.car_rental_rounded, color: Color(0xFFD85A30), size: 16)),
            const SizedBox(width: 10),
            Text('Currently Rented Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFD85A30).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Text('${rented.length}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFD85A30)))),
          ])),
          Expanded(child: rented.isEmpty
            ? Center(child: Text('No cars currently rented', style: TextStyle(color: textSec)))
            : ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: rented.length,
                itemBuilder: (_, i) {
                  final car = rented[i];
                  final cc  = _catColor(car.category);
                  // Find matching booking
                  final booking = _bookings.where((b) => b.car == car.name && b.status == 'Active').toList();
                  final b = booking.isNotEmpty ? booking.first : null;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD85A30).withOpacity(0.25), width: 1)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Car header
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD85A30).withOpacity(0.05),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(13))),
                        child: Row(children: [
                          Container(width: 40, height: 40,
                            decoration: BoxDecoration(color: cc.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.directions_car_rounded, color: cc, size: 20)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(car.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPri)),
                            Text('${car.category} · ${car.fuel} · ${car.seats} seats',
                              style: TextStyle(fontSize: 11, color: textSec)),
                          ])),
                          Text('\$${car.price.toInt()}/day',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFD4A017))),
                        ])),
                      // Booking info
                      Padding(padding: const EdgeInsets.all(12), child: b != null
                        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1C2236) : const Color(0xFFF2F4F8),
                                borderRadius: BorderRadius.circular(10)),
                              child: Row(children: [
                                CircleAvatar(radius: 16, backgroundColor: brand.withOpacity(0.15),
                                  child: Text(b.user[0], style: TextStyle(color: brand, fontSize: 13, fontWeight: FontWeight.w700))),
                                const SizedBox(width: 10),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Rented by', style: TextStyle(fontSize: 10, color: textSec)),
                                  Text(b.user, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
                                ])),
                                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  Text('Ref: ${b.ref}', style: TextStyle(fontSize: 10, color: textSec)),
                                  Container(margin: const EdgeInsets.only(top: 3),
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFF1D9E75).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                    child: const Text('Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1D9E75)))),
                                ]),
                              ])),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1C2236) : const Color(0xFFF2F4F8),
                                  borderRadius: BorderRadius.circular(9)),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Pick-up', style: TextStyle(fontSize: 9, color: textSec)),
                                  const SizedBox(height: 2),
                                  Text(b.from, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri)),
                                ]))),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF8B91A8))),
                              Expanded(child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1C2236) : const Color(0xFFF2F4F8),
                                  borderRadius: BorderRadius.circular(9)),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Return', style: TextStyle(fontSize: 9, color: textSec)),
                                  const SizedBox(height: 2),
                                  Text(b.to, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri)),
                                ]))),
                            ]),
                          ])
                        : Text('No active booking found', style: TextStyle(fontSize: 12, color: textSec))),
                    ]));
                })),
        ])));
  }

  void _showAvailableList(BuildContext ctx, List<CompanyCar> available, bool isDark,
      Color card, Color border, Color textPri, Color textSec, Color brand) {
    showModalBottomSheet(
      context: ctx, backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.9, expand: false,
        builder: (_, ctrl) => Column(children: [
          Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
            decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 10), child: Row(children: [
            Container(width: 32, height: 32,
              decoration: BoxDecoration(color: const Color(0xFF1D9E75).withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF1D9E75), size: 16)),
            const SizedBox(width: 10),
            Text('Available for Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF1D9E75).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Text('${available.length}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1D9E75)))),
          ])),
          Expanded(child: available.isEmpty
            ? Center(child: Text('No cars available right now', style: TextStyle(color: textSec)))
            : ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: available.length,
                itemBuilder: (_, i) {
                  final car = available[i];
                  final cc  = _catColor(car.category);
                  final fleetIdx = _fleet.indexWhere((c) => c.name == car.name);
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _showCarDetail(context, car, fleetIdx >= 0 ? fleetIdx : i, cc, isDark, card, border, textPri, textSec, brand);
                    },
                    child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1D9E75).withOpacity(0.25), width: 1)),
                    child: Row(children: [
                      Container(width: 44, height: 44,
                        decoration: BoxDecoration(color: cc.withOpacity(0.1), borderRadius: BorderRadius.circular(11)),
                        child: Icon(Icons.directions_car_rounded, color: cc, size: 22)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(car.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
                        Text('${car.category} · ${car.fuel} · ${car.seats} seats',
                          style: TextStyle(fontSize: 11, color: textSec)),
                        const SizedBox(height: 4),
                        Text('\$${car.price.toInt()}/day',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFD4A017))),
                      ])),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D9E75).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                          child: const Text('● Ready',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1D9E75)))),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: textSec, size: 16),
                      ]),
                    ])));
                })),
        ])));
  }

  // ══════════════════════════════════════════
  //  BOOKINGS TAB
  // ══════════════════════════════════════════
  Widget _bookingsTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec, Color brand) {
    final filters = ['All','Active','Upcoming','Completed','Cancelled'];
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
          Text('Revenue: \$${_filteredBookings.where((b) => b.status != "Cancelled").fold(0.0, (s,b)=>s+b.amount).toInt()}',
            style: const TextStyle(fontSize: 12, color: const Color(0xFFD4A017), fontWeight: FontWeight.w600)),
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

  // ══════════════════════════════════════════
  //  REVIEWS TAB
  // ══════════════════════════════════════════
  Widget _reviewsTab(bool isDark, Color bg, Color card, Color border, Color textPri, Color textSec) {
    final avg = _reviews.isEmpty ? 0.0 : _reviews.fold(0.0, (s,r) => s+r.stars) / _reviews.length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
        child: Row(children: [
          Column(children: [
            Text(avg.toStringAsFixed(1), style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: const Color(0xFFD4A017))),
            Row(children: List.generate(5, (i) => Icon(Icons.star_rounded,
              color: i < avg.round() ? const Color(0xFFD4A017) : border, size: 16))),
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
              const Icon(Icons.star, color: const Color(0xFFD4A017), size: 12),
              const SizedBox(width: 8),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: pct, backgroundColor: border,
                  valueColor: const AlwaysStoppedAnimation(const Color(0xFFD4A017)), minHeight: 6))),
              const SizedBox(width: 8),
              Text('$count', style: TextStyle(fontSize: 11, color: textSec)),
            ]));
          }).toList())),
        ])),
      const SizedBox(height: 16),
      ..._reviews.map((r) => _ReviewCard(r: r, card: card, border: border, textPri: textPri, textSec: textSec,
        onReply: (reply) => _notify('Reply sent to ${r.name}'))),
    ]);
  }

  // ══════════════════════════════════════════
  //  TEAM TAB
  // ══════════════════════════════════════════
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
                  onTap: () { setState(() => _agents[i] = _Agent(a.name, a.email, a.phone, a.role, !a.active)); _notify('${a.name} ${!a.active ? "activated" : "deactivated"}'); },
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
            ]));
        })),
    ]);
  }

  // ══════════════════════════════════════════
  //  DRAWER
  // ══════════════════════════════════════════
  Widget _buildDrawer(bool isDark, Color card, Color border, Color textPri, Color textSec, Color brand) {
    final navItems = <Map<String, dynamic>>[
      {'icon': Icons.dashboard_outlined,     'label': 'Overview',  'tab': 0},
      {'icon': Icons.directions_car_outlined,'label': 'Fleet',     'tab': 1},
      {'icon': Icons.receipt_long_outlined,  'label': 'Bookings',  'tab': 2},
      {'icon': Icons.star_outline_rounded,   'label': 'Reviews',   'tab': 3},
      {'icon': Icons.people_outline,         'label': 'Team',      'tab': 4},
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'Wallet', 'tab': 5},
    ];
    final currentTab = _tc.index;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
      child: SafeArea(child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [brand, brand.withOpacity(0.65)]),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.15), width: 0.5))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 52, height: 52,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5)),
                child: Center(child: Text(widget.company.initials,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.company.name,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: const Text('Company Admin',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))),
              ])),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              _DrawerStat(label: 'Cars',     value: '${_fleet.length}'),
              _DrawerStat(label: 'Bookings', value: '${_bookings.length}'),
              _DrawerStat(label: 'Revenue',  value: '\$${_revenue.toInt()}'),
              _DrawerStat(label: 'Wallet',   value: '\$${WalletService.instance.walletFor(widget.company.name).balance.toStringAsFixed(0)}'),
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
                child: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  color: const Color(0xFFD4A017), size: 15)),
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
          ...navItems.map((item) {
            final active = currentTab == item['tab'] as int;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: active ? brand.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(item['icon'] as IconData, color: active ? brand : textSec, size: 20),
                title: Text(item['label'] as String, style: TextStyle(
                  fontSize: 14, color: active ? brand : textPri,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
                trailing: active
                  ? Container(width: 4, height: 20,
                      decoration: BoxDecoration(color: brand, borderRadius: BorderRadius.circular(2)))
                  : null,
                onTap: () { Navigator.pop(context); _tc.animateTo(item['tab'] as int); },
                dense: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
          }),
          const SizedBox(height: 4),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: ListTile(
              leading: Icon(Icons.settings_outlined, color: textSec, size: 20),
              title: Text('Company Settings', style: TextStyle(fontSize: 14, color: textPri)),
              onTap: () { Navigator.pop(context); _showCompanySettings(context, card, border, textPri, textSec, brand); },
              dense: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
        ])),

        Divider(color: border, height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            leading: Container(width: 34, height: 34,
              decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.history_rounded, color: const Color(0xFFD4A017), size: 17)),
            title: const Text('Account History', style: TextStyle(fontSize: 14, color: const Color(0xFFD4A017), fontWeight: FontWeight.w600)),
            subtitle: Text('All actions on this account', style: TextStyle(fontSize: 10, color: const Color(0xFF8B91A8))),
            onTap: () { Navigator.pop(context); _showAccountHistory(context); },
            dense: true)),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
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
  //  SHEETS & NAVIGATION
  // ══════════════════════════════════════════
  void _showAddCar(BuildContext ctx, Color card, Color border, Color textPri, Color textSec, Color brand) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => _AddEditCarScreen(
      brand: brand, card: card, border: border, textPri: textPri, textSec: textSec,
      companyName: widget.company.name,
      onSave: (car) { setState(() => _fleet.add(car)); _notify('${car.name} added to fleet'); })));
  }

  void _showEditCar(BuildContext ctx, CompanyCar car, int idx, Color card, Color border, Color textPri, Color textSec, Color brand) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => _AddEditCarScreen(
      brand: brand, card: card, border: border, textPri: textPri, textSec: textSec,
      companyName: widget.company.name, existing: car,
      onSave: (updated) { setState(() => _fleet[idx] = updated); _notify('${updated.name} updated'); })));
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
      ]));
  }

  void _showCarDetail(BuildContext ctx, CompanyCar car, int idx, Color cc, bool isDark, Color card, Color border, Color textPri, Color textSec, Color brand) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => _CarDetailScreen(
      car: car, catColor: cc, brand: brand, card: card, border: border,
      textPri: textPri, textSec: textSec, isDark: isDark,
      companyName: widget.company.name,
      onEdit:   () => _showEditCar(ctx, car, idx, card, border, textPri, textSec, brand),
      onToggle: () {
        setState(() => _fleet[idx] = CompanyCar(name: car.name, category: car.category, price: car.price,
          seats: car.seats, transmission: car.transmission, fuel: car.fuel, available: !car.available));
        _notify(car.available ? '${car.name} marked as Rented' : '${car.name} marked as Available');
      },
      onDelete: () { setState(() => _fleet.removeAt(idx)); _notify('${car.name} removed'); })));
  }

  void _showBookingDetail(BuildContext ctx, _Booking b, bool isDark, Color card, Color border, Color textPri, Color textSec) {
    final sc = _statusColor(b.status);
    showModalBottomSheet(context: ctx,
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
      isScrollControlled: true,
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
        _DRow(Icons.person_outline,         'Customer', b.user,              textPri, textSec),
        _DRow(Icons.directions_car_outlined,'Vehicle',  b.car,               textPri, textSec),
        _DRow(Icons.calendar_today_outlined,'Pick-up',  b.from,              textPri, textSec),
        _DRow(Icons.event_outlined,         'Drop-off', b.to,                textPri, textSec),
        _DRow(Icons.access_time_outlined,   'Duration', '${b.days} days',   textPri, textSec),
        const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
          Text('\$${b.amount.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFFD4A017))),
        ]),
        const SizedBox(height: 16),
        if (b.status == 'Upcoming') Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () {
              final idx = _bookings.indexOf(b);
              if (idx >= 0) setState(() => _bookings[idx] = _Booking(b.ref,b.user,b.car,b.from,b.to,b.days,b.amount,'Cancelled'));
              Navigator.pop(ctx); _notify('Booking ${b.ref} cancelled');
            },
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD85A30)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Cancel Booking', style: TextStyle(color: Color(0xFFD85A30))))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () {
              final idx = _bookings.indexOf(b);
              if (idx >= 0) setState(() => _bookings[idx] = _Booking(b.ref,b.user,b.car,b.from,b.to,b.days,b.amount,'Active'));
              Navigator.pop(ctx); _notify('Booking ${b.ref} confirmed');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D9E75), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Confirm'))),
        ]),
        if (b.status == 'Active') SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () {
            final idx = _bookings.indexOf(b);
            if (idx >= 0) setState(() => _bookings[idx] = _Booking(b.ref,b.user,b.car,b.from,b.to,b.days,b.amount,'Completed'));
            Navigator.pop(ctx); _notify('Booking ${b.ref} marked as Completed');
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B5FD4), foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
          child: const Text('Mark as Completed'))),
      ])));
  }

  void _showAddAgent(BuildContext ctx, Color card, Color border, Color textPri, Color textSec, Color brand) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => _AddMemberScreen(
      brand: brand, card: card, border: border, textPri: textPri, textSec: textSec,
      companyName: widget.company.name,
      onSave: (agent) { setState(() => _agents.add(agent)); _notify('${agent.name} added to team'); })));
  }

  void _showEditAgent(BuildContext ctx, _Agent a, int idx, Color card, Color border, Color textPri, Color textSec, Color brand) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => _EditAgentScreen(
      agent: a, brand: brand, card: card, border: border, textPri: textPri, textSec: textSec,
      companyName: widget.company.name,
      onSave: (updated) {
        setState(() => _agents[idx] = updated);
        _notify('${updated.name} updated');
      })));
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
      ]));
  }

  void _showNotifSheet(BuildContext ctx, Color card, Color border, Color textPri, Color textSec) {
    final notifs = <Map<String, dynamic>>[
      {'msg': 'New booking: Cameron One – RAV4', 'time': '2 min ago', 'color': const Color(0xFF1D9E75)},
      {'msg': 'Review received: 5 stars',        'time': '1 hr ago',  'color': const Color(0xFFD4A017)},
      {'msg': 'Booking SW240002 confirmed',       'time': '3 hr ago',  'color': const Color(0xFF3B5FD4)},
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

  void _showAnalytics(BuildContext ctx, Color card, Color border, Color textPri, Color textSec, Color brand) {
    final completed = _bookings.where((b) => b.status == 'Completed').fold(0.0, (s,b) => s+b.amount);
    final active    = _bookings.where((b) => b.status == 'Active').fold(0.0, (s,b) => s+b.amount);
    final upcoming  = _bookings.where((b) => b.status == 'Upcoming').fold(0.0, (s,b) => s+b.amount);
    final cancelled = _bookings.where((b) => b.status == 'Cancelled').fold(0.0, (s,b) => s+b.amount);
    final utilPct   = _fleet.isEmpty ? 0.0 : (_fleet.length - _avail) / _fleet.length;
    final rows = <Map<String, dynamic>>[
      {'label': 'Total Revenue',     'value': '\$${_revenue.toInt()}',  'color': const Color(0xFFD4A017)},
      {'label': 'Completed Revenue', 'value': '\$${completed.toInt()}', 'color': const Color(0xFF1D9E75)},
      {'label': 'Active Revenue',    'value': '\$${active.toInt()}',    'color': const Color(0xFF3B5FD4)},
      {'label': 'Fleet Utilisation', 'value': '${(utilPct*100).toInt()}%', 'color': brand},
      {'label': 'Avg Rating',        'value': '${widget.company.rating}\u2605','color': const Color(0xFFD4A017)},
    ];

    // Bar chart data
    final barData = [
      _BarData('Active',    active,    const Color(0xFF3B5FD4)),
      _BarData('Completed', completed, const Color(0xFF1D9E75)),
      _BarData('Upcoming',  upcoming,  const Color(0xFFD4A017)),
      _BarData('Cancelled', cancelled, const Color(0xFFD85A30)),
    ];
    final maxVal = barData.map((b) => b.value).fold(0.0, (a, b) => a > b ? a : b);

    showModalBottomSheet(
      context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.82, minChildSize: 0.4, maxChildSize: 0.95,
        builder: (_, sc) => Container(
          decoration: BoxDecoration(color: card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(controller: sc, padding: const EdgeInsets.all(20), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Handle
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Center(child: Text('Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri))),
            const SizedBox(height: 20),

            // ── Revenue Bar Chart ──────────────────────────
            Text('Revenue by Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              decoration: BoxDecoration(
                color: brand.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: 0.5)),
              child: Column(children: [
                SizedBox(
                  height: 140,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: barData.map((b) {
                    final ratio = maxVal <= 0 ? 0.0 : b.value / maxVal;
                    return Expanded(child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text('\$${b.value.toInt()}',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: b.color)),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          height: ratio > 0 ? (100 * ratio).clamp(4.0, 100.0) : 4,
                          decoration: BoxDecoration(
                            color: b.color,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [b.color, b.color.withOpacity(0.5)])),
                        ),
                      ]),
                    ));
                  }).toList()),
                ),
                const SizedBox(height: 8),
                Row(children: barData.map((b) => Expanded(child: Center(
                  child: Text(b.label, style: TextStyle(fontSize: 9, color: textSec, fontWeight: FontWeight.w600)),
                ))).toList()),
              ]),
            ),

            const SizedBox(height: 20),

            // ── Fleet Utilisation Ring ─────────────────────
            Text('Fleet Utilisation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: brand.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: 0.5)),
              child: Row(children: [
                SizedBox(
                  width: 90, height: 90,
                  child: CustomPaint(
                    painter: _RingPainter(utilPct, brand, border),
                    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('${(utilPct * 100).toInt()}%',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: brand)),
                      Text('Used', style: TextStyle(fontSize: 9, color: textSec)),
                    ])),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _RingLegend('Rented Out', '${_fleet.length - _avail}', brand, textSec),
                  const SizedBox(height: 8),
                  _RingLegend('Available',  '$_avail',                   const Color(0xFF1D9E75), textSec),
                  const SizedBox(height: 8),
                  _RingLegend('Total Fleet','${_fleet.length}',          textSec, textSec),
                ])),
              ]),
            ),

            const SizedBox(height: 20),

            // ── Stats rows ─────────────────────────────────
            Text('Summary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
            const SizedBox(height: 10),
            ...rows.map((r) {
              final clr = r['color'] as Color;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: clr.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: clr.withOpacity(0.15), width: 0.8)),
                child: Row(children: [
                  Container(width: 32, height: 32,
                    decoration: BoxDecoration(color: clr.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.bar_chart_rounded, color: clr, size: 16)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(r['label'] as String,
                    style: TextStyle(fontSize: 13, color: textSec))),
                  Text(r['value'] as String,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: clr)),
                ]));
            }),
            const SizedBox(height: 8),
          ])))));
  }

  void _showProfile(BuildContext ctx, Color card, Color border, Color textPri, Color textSec, Color brand) {
    showModalBottomSheet(context: ctx, backgroundColor: card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        CircleAvatar(radius: 32, backgroundColor: brand.withOpacity(0.15),
          child: Text(widget.company.initials, style: TextStyle(color: brand, fontSize: 22, fontWeight: FontWeight.w800))),
        const SizedBox(height: 10),
        Text(widget.company.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPri)),
        Text('Company Administrator', style: TextStyle(fontSize: 13, color: textSec)),
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
          const Icon(Icons.phone_outlined, color: Color(0xFF8B91A8), size: 16), const SizedBox(width: 10),
          Text(widget.company.phone, style: TextStyle(color: textSec, fontSize: 13)),
        ])),
        Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
          const Icon(Icons.location_on_outlined, color: Color(0xFF8B91A8), size: 16), const SizedBox(width: 10),
          Text(widget.company.location, style: TextStyle(color: textSec, fontSize: 13)),
        ])),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () { Navigator.pop(ctx); AuthService.logout(); Navigator.pushNamedAndRemoveUntil(ctx, '/home', (_) => false); },
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD85A30)),
            padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Sign Out', style: TextStyle(color: Color(0xFFD85A30), fontWeight: FontWeight.w700)))),
      ])));
  }

  void _showCompanySettings(BuildContext ctx, Color card, Color border, Color textPri, Color textSec, Color brand) {
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => _CompanySettingsScreen(
        brand: brand, card: card, border: border, textPri: textPri, textSec: textSec,
        companyName: widget.company.name, companyLocation: widget.company.location,
        companyPhone: widget.company.phone, companyEmail: widget.company.email)));
  }

  // ── Helpers ─────────────────────────────────
  Color _catColor(String cat) {
    const m = {'Economy':Color(0xFF1D9E75),'SUV':Color(0xFF3B5FD4),'Luxury':Color(0xFF7F77DD),
      '4x4':Color(0xFFD85A30),'Van':Color(0xFF0D7EA8),'Sedan':Color(0xFF1D9E75),'Premium':Color(0xFF7F77DD)};
    return m[cat] ?? const Color(0xFFD4A017);
  }
  void _showAccountHistory(BuildContext ctx) {
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => _AccountHistoryScreen(
        companyName: widget.company.name,
        brand: widget.company.brandColor)));
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
  final double amount; final int days;
  const _Booking(this.ref, this.user, this.car, this.from, this.to, this.days, this.amount, this.status);
}
class _Review {
  final String name, text, date; final int stars;
  const _Review(this.name, this.stars, this.text, this.date);
}
class _Agent {
  final String name, email, phone, role; final bool active;
  const _Agent(this.name, this.email, this.phone, this.role, this.active);
}

// ─────────────────────────────────────────────
//  SHARED REUSABLE WIDGETS (inside file)
// ─────────────────────────────────────────────
class _KPICard extends StatelessWidget {
  final String value, label; final IconData icon;
  final Color color, card, border, textPri, textSec;
  final VoidCallback? onTap;
  const _KPICard(this.value, this.label, this.icon, this.color, this.card, this.border, this.textPri, this.textSec, {this.onTap});
  @override Widget build(BuildContext c) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: Container(
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
    ]))));
}

class _QAction extends StatelessWidget {
  final IconData icon; final String label; final Color color, card, border, textPri;
  final VoidCallback onTap;
  const _QAction({required this.icon, required this.label, required this.color, required this.card, required this.border, required this.textPri, required this.onTap});
  @override Widget build(BuildContext c) => GestureDetector(onTap: onTap, child: Container(
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
  @override Widget build(BuildContext c) => Container(
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
  final void Function(String) onReply;
  const _ReviewCard({required this.r, required this.card, required this.border, required this.textPri, required this.textSec, required this.onReply});
  @override State<_ReviewCard> createState() => _ReviewCardState();
}
class _ReviewCardState extends State<_ReviewCard> {
  bool _showReply = false; String? _reply;
  final _ctrl = TextEditingController();
  @override Widget build(BuildContext c) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: widget.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: widget.border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(radius: 18, backgroundColor: const Color(0xFFD4A017).withOpacity(0.15),
          child: Text(widget.r.name[0], style: const TextStyle(color: const Color(0xFFD4A017), fontWeight: FontWeight.w700))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.r.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.textPri)),
          Text(widget.r.date, style: TextStyle(fontSize: 11, color: widget.textSec)),
        ])),
        Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, color: i < widget.r.stars ? const Color(0xFFD4A017) : widget.border, size: 14))),
      ]),
      const SizedBox(height: 10),
      Text(widget.r.text, style: TextStyle(fontSize: 13, color: widget.textPri, height: 1.5)),
      const SizedBox(height: 10),
      if (_reply != null)
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.06), borderRadius: BorderRadius.circular(9)),
          child: Row(children: [
            const Icon(Icons.reply_rounded, color: const Color(0xFFD4A017), size: 15), const SizedBox(width: 8),
            Expanded(child: Text(_reply!, style: TextStyle(fontSize: 12, color: widget.textSec))),
          ]))
      else if (_showReply)
        Row(children: [
          Expanded(child: TextField(
            controller: _ctrl,
            style: TextStyle(fontSize: 12, color: widget.textPri),
            decoration: InputDecoration(hintText: 'Write a reply…', hintStyle: TextStyle(color: widget.textSec, fontSize: 12),
              filled: true, fillColor: widget.border.withOpacity(0.15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)))),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () { setState(() { _reply = _ctrl.text; _showReply = false; }); widget.onReply(_ctrl.text); },
            child: Container(width: 36, height: 36,
              decoration: const BoxDecoration(color: const Color(0xFFD4A017), shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 16))),
        ])
      else
        GestureDetector(
          onTap: () => setState(() => _showReply = true),
          child: Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.06), borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.15), width: 0.8)),
            child: Row(children: [
              const Icon(Icons.reply_rounded, color: const Color(0xFFD4A017), size: 15), const SizedBox(width: 8),
              Text('Reply to this review', style: TextStyle(fontSize: 12, color: widget.textSec)),
            ]))),
    ]));
}

// Drawer stat helper
class _DrawerStat extends StatelessWidget {
  final String label, value;
  const _DrawerStat({required this.label, required this.value});
  @override Widget build(BuildContext c) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
    Text(label,  style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 9)),
  ]));
}

// Detail row helper
Widget _DRow(IconData icon, String label, String value, Color textPri, Color textSec) =>
  Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 15, color: textSec), const SizedBox(width: 10),
    Text('$label: ', style: TextStyle(fontSize: 12, color: textSec)),
    Expanded(child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri), overflow: TextOverflow.ellipsis)),
  ]));

// Simple text field for sheets
Widget _CAField(String label, String hint, TextEditingController ctrl, Color textPri, Color textSec, {bool numeric = false}) =>
  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 11, color: textSec, fontWeight: FontWeight.w500)),
    const SizedBox(height: 4),
    TextField(controller: ctrl,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      style: TextStyle(fontSize: 13, color: textPri),
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: textSec, fontSize: 13),
        filled: true, fillColor: const Color(0xFF1C2236),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
  ]);

// ─────────────────────────────────────────────
//  ADD / EDIT CAR FULL SCREEN
// ─────────────────────────────────────────────
class _AddEditCarScreen extends StatefulWidget {
  final Color brand, card, border, textPri, textSec;
  final String companyName;
  final CompanyCar? existing;
  final void Function(CompanyCar) onSave;
  const _AddEditCarScreen({required this.brand, required this.card, required this.border,
    required this.textPri, required this.textSec, required this.companyName,
    required this.onSave, this.existing});
  @override State<_AddEditCarScreen> createState() => _AddEditCarState();
}
class _AddEditCarState extends State<_AddEditCarScreen> {
  late TextEditingController _nameC, _plateC, _priceC, _yearC, _mileageC;
  static const _categories    = ['Economy','SUV','Luxury','Sports','4x4','Van','Electric','Sedan'];
  static const _fuels         = ['Petrol','Diesel','Electric','Hybrid','LPG'];
  static const _transmissions = ['Automatic','Manual','Semi-Auto','CVT'];
  static const _seatOpts      = ['2','4','5','6','7','8','9'];
  static const _colors        = ['Black','White','Silver','Red','Blue','Grey','Green','Orange'];
  String _selCat='SUV', _selFuel='Petrol', _selTrans='Automatic', _selSeats='5', _selColor='Black';
  bool _available = true;
  bool get isEdit => widget.existing != null;
  @override void initState() {
    super.initState();
    final e = widget.existing;
    _nameC    = TextEditingController(text: e?.name ?? '');
    _plateC   = TextEditingController();
    _priceC   = TextEditingController(text: e != null ? e.price.toInt().toString() : '');
    _yearC    = TextEditingController();
    _mileageC = TextEditingController();
    if (e != null) {
      _selCat   = _categories.contains(e.category)   ? e.category    : 'SUV';
      _selFuel  = _fuels.contains(e.fuel)             ? e.fuel        : 'Petrol';
      _selTrans = _transmissions.firstWhere((t) => e.transmission.contains(t.split(' ')[0]),
                  orElse: () => 'Automatic');
      _selSeats = _seatOpts.contains(e.seats.toString()) ? e.seats.toString() : '5';
      _available = e.available;
    }
  }
  @override void dispose() {
    for (final c in [_nameC,_plateC,_priceC,_yearC,_mileageC]) c.dispose();
    super.dispose();
  }
  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg  = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);
    final c   = isDark ? const Color(0xFF141828) : Colors.white;
    final brd = isDark ? const Color(0xFF252B3E) : const Color(0xFFDDE1EE);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: widget.brand, foregroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(isEdit ? 'Edit Vehicle' : 'Add New Vehicle',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _FSection('Vehicle Identity', const Color(0xFFD4A017)),
        _FCard(c, brd, [
          _FField('Vehicle Name', 'e.g. Toyota RAV4 2022', _nameC, widget.textPri, widget.textSec),
          _FDivider(brd),
          _FField('Number Plate', 'e.g. RAD 123 B', _plateC, widget.textPri, widget.textSec, caps: true),
          _FDivider(brd),
          Row(children: [
            Expanded(child: _FField('Year', 'e.g. 2022', _yearC, widget.textPri, widget.textSec, numeric: true)),
            Container(width: 1, height: 52, color: brd),
            Expanded(child: _FField('Mileage (km)', 'e.g. 25000', _mileageC, widget.textPri, widget.textSec, numeric: true)),
          ]),
        ]),
        const SizedBox(height: 16),
        _FSection('Company', const Color(0xFFD4A017)),
        _FCard(c, brd, [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
            Icon(Icons.business_outlined, color: widget.textSec, size: 18), const SizedBox(width: 12),
            Text('Assigned to:', style: TextStyle(fontSize: 12, color: widget.textSec)),
            const SizedBox(width: 8),
            Text(widget.companyName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.textPri)),
          ])),
        ]),
        const SizedBox(height: 16),
        _FSection('Category', const Color(0xFFD4A017)),
        Wrap(spacing: 8, runSpacing: 8, children: _categories.map((cat) {
          final sel = _selCat == cat;
          return GestureDetector(
            onTap: () => setState(() => _selCat = cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? widget.brand.withOpacity(0.15) : c,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? widget.brand : brd, width: sel ? 1.5 : 0.8)),
              child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: sel ? widget.brand : widget.textSec))));
        }).toList()),
        const SizedBox(height: 16),
        _FSection('Specifications', const Color(0xFFD4A017)),
        _FCard(c, brd, [
          _FChipRow('Fuel Type',     _fuels,         _selFuel,  widget.brand, brd, widget.textSec, (v) => setState(() => _selFuel = v)),
          _FDivider(brd),
          _FChipRow('Transmission',  _transmissions, _selTrans, widget.brand, brd, widget.textSec, (v) => setState(() => _selTrans = v)),
          _FDivider(brd),
          _FChipRow('Seats',         _seatOpts,      _selSeats, widget.brand, brd, widget.textSec, (v) => setState(() => _selSeats = v)),
          _FDivider(brd),
          _FChipRow('Color',         _colors,        _selColor, widget.brand, brd, widget.textSec, (v) => setState(() => _selColor = v)),
        ]),
        const SizedBox(height: 16),
        _FSection('Pricing', const Color(0xFFD4A017)),
        _FCard(c, brd, [_FField('Price per Day (\$)', 'e.g. 60', _priceC, widget.textPri, widget.textSec, numeric: true)]),
        const SizedBox(height: 16),
        _FSection('Availability', const Color(0xFFD4A017)),
        _FCard(c, brd, [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Row(children: [
            Icon(_available ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: _available ? const Color(0xFF1D9E75) : const Color(0xFFD85A30), size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(_available ? 'Available for booking' : 'Currently rented',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: widget.textPri))),
            Switch(value: _available, onChanged: (v) => setState(() => _available = v),
              activeColor: const Color(0xFF1D9E75), activeTrackColor: const Color(0xFF1D9E75).withOpacity(0.3)),
          ])),
        ]),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (_nameC.text.isEmpty || _priceC.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Color(0xFFD85A30),
                content: Text('Vehicle name and price are required'))); return;
            }
            widget.onSave(CompanyCar(name: _nameC.text, category: _selCat,
              price: double.tryParse(_priceC.text) ?? 60, seats: int.tryParse(_selSeats) ?? 5,
              transmission: _selTrans, fuel: _selFuel, available: _available));
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: widget.brand, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
          child: Text(isEdit ? 'Save Changes' : 'Add Vehicle',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
        const SizedBox(height: 32),
      ]));
  }
}

// ─────────────────────────────────────────────
//  CAR DETAIL FULL SCREEN
// ─────────────────────────────────────────────
class _CarDetailScreen extends StatelessWidget {
  final CompanyCar car;
  final Color catColor, brand, card, border, textPri, textSec;
  final bool isDark;
  final String companyName;
  final VoidCallback onEdit, onToggle, onDelete;
  const _CarDetailScreen({required this.car, required this.catColor, required this.brand,
    required this.card, required this.border, required this.textPri, required this.textSec,
    required this.isDark, required this.companyName,
    required this.onEdit, required this.onToggle, required this.onDelete});
  @override Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);
    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(slivers: [
        SliverAppBar(expandedHeight: 220, pinned: true, backgroundColor: brand,
          leading: IconButton(
            icon: Container(padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16)),
            onPressed: () => Navigator.pop(context)),
          actions: [
            IconButton(icon: Container(padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16)),
              onPressed: () { Navigator.pop(context); onEdit(); }),
            Padding(padding: const EdgeInsets.only(right: 10), child: IconButton(
              icon: Container(padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16)),
              onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
                backgroundColor: card,
                title: Text('Remove Vehicle?', style: TextStyle(color: textPri, fontWeight: FontWeight.w700)),
                content: Text('Remove "${car.name}" from fleet?', style: TextStyle(color: textSec)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: textSec))),
                  TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); onDelete(); },
                    child: const Text('Remove', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700))),
                ])))),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [brand, brand.withOpacity(0.6)])),
              child: Stack(children: [
                Center(child: Icon(Icons.directions_car_rounded, size: 130, color: Colors.white.withOpacity(0.15))),
                Positioned(bottom: 16, left: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text(car.category, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 4),
                  Text(car.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                ])),
                Positioned(bottom: 16, right: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('\$${car.price.toInt()}', style: const TextStyle(color: const Color(0xFFD4A017), fontSize: 28, fontWeight: FontWeight.w800)),
                  const Text('/day', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
              ]))),
        ),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: car.available ? const Color(0xFF1D9E75).withOpacity(0.1) : const Color(0xFFD85A30).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: car.available ? const Color(0xFF1D9E75) : const Color(0xFFD85A30), width: 0.8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(car.available ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: car.available ? const Color(0xFF1D9E75) : const Color(0xFFD85A30), size: 14),
                const SizedBox(width: 6),
                Text(car.available ? 'Available' : 'Currently Rented',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: car.available ? const Color(0xFF1D9E75) : const Color(0xFFD85A30))),
              ])),
            const SizedBox(width: 10),
            Icon(Icons.business_outlined, size: 13, color: textSec), const SizedBox(width: 4),
            Text(companyName, style: TextStyle(fontSize: 12, color: textSec, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),
          Text('Specifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textSec)),
          const SizedBox(height: 8),
          GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 3.5,
            children: [
              _SpecTile(Icons.event_seat_outlined,        'Seats',        '${car.seats}',   card, border, textPri, textSec),
              _SpecTile(Icons.settings_rounded,           'Transmission', car.transmission, card, border, textPri, textSec),
              _SpecTile(Icons.local_gas_station_outlined, 'Fuel',         car.fuel,         card, border, textPri, textSec),
              _SpecTile(Icons.category_outlined,          'Category',     car.category,     card, border, textPri, textSec),
            ]),
          const SizedBox(height: 16),
          Text('Standard Features', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textSec)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            'Air Conditioning','Bluetooth Audio','GPS Navigation','USB Charging','Backup Camera','Power Windows',
          ].map((f) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(8), border: Border.all(color: border, width: 0.5)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF1D9E75), size: 12),
              const SizedBox(width: 5),
              Text(f, style: TextStyle(fontSize: 11, color: textPri)),
            ]))).toList()),
          const SizedBox(height: 16),
          Text('Documents & Insurance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textSec)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
            child: Column(children: [
              _DocRow(Icons.shield_outlined,        'Insurance',      'Valid – Dec 2025',  const Color(0xFF1D9E75), textPri, textSec),
              _DocRow(Icons.description_outlined,   'Registration',   'RWF 2024 – valid',  const Color(0xFF1D9E75), textPri, textSec),
              _DocRow(Icons.build_outlined,         'Last Service',   '2,000 km ago',      const Color(0xFFD4A017),         textPri, textSec),
              _DocRow(Icons.directions_car_outlined,'Next Service',   'Due at 3,000 km',   const Color(0xFFD4A017),         textPri, textSec),
            ])),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: () { Navigator.pop(context); onEdit(); },
              icon: const Icon(Icons.edit_rounded, size: 16), label: const Text('Edit Details'),
              style: ElevatedButton.styleFrom(backgroundColor: brand, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(
              onPressed: () { Navigator.pop(context); onToggle(); },
              icon: Icon(car.available ? Icons.block_rounded : Icons.check_circle_outline, size: 16),
              label: Text(car.available ? 'Mark Rented' : 'Mark Available'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: car.available ? const Color(0xFFD85A30) : const Color(0xFF1D9E75)),
                foregroundColor: car.available ? const Color(0xFFD85A30) : const Color(0xFF1D9E75),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          ]),
          const SizedBox(height: 32),
        ]))),
      ]));
  }
}

// ─────────────────────────────────────────────
//  ADD TEAM MEMBER FULL SCREEN
// ─────────────────────────────────────────────
class _AddMemberScreen extends StatefulWidget {
  final Color brand, card, border, textPri, textSec;
  final String companyName;
  final void Function(_Agent) onSave;
  const _AddMemberScreen({required this.brand, required this.card, required this.border,
    required this.textPri, required this.textSec, required this.companyName, required this.onSave});
  @override State<_AddMemberScreen> createState() => _AddMemberState();
}
class _AddMemberState extends State<_AddMemberScreen> {
  final _nameC=TextEditingController(), _emailC=TextEditingController(),
        _phoneC=TextEditingController(), _passC=TextEditingController(),
        _nationalC=TextEditingController(), _addressC=TextEditingController();
  String _selRole='Agent', _selGender='Male';
  bool _obscure = true;
  static const _roles   = ['Agent','Fleet Manager','Senior Agent','Accountant','Supervisor'];
  static const _genders = ['Male','Female','Other'];
  @override void dispose() {
    for (final c in [_nameC,_emailC,_phoneC,_passC,_nationalC,_addressC]) c.dispose();
    super.dispose();
  }
  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg  = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);
    final c   = isDark ? const Color(0xFF141828) : Colors.white;
    final brd = isDark ? const Color(0xFF252B3E) : const Color(0xFFDDE1EE);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: widget.brand, foregroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Add Team Member', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Center(child: Stack(children: [
          Container(width: 80, height: 80,
            decoration: BoxDecoration(color: widget.brand.withOpacity(0.15), shape: BoxShape.circle,
              border: Border.all(color: widget.brand.withOpacity(0.3), width: 2)),
            child: Icon(Icons.person_rounded, color: widget.brand, size: 44)),
          Positioned(bottom: 0, right: 0, child: Container(width: 26, height: 26,
            decoration: BoxDecoration(color: widget.brand, shape: BoxShape.circle, border: Border.all(color: bg, width: 2)),
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 13))),
        ])),
        const SizedBox(height: 20),
        _FSection('Personal Information', const Color(0xFFD4A017)),
        _FCard(c, brd, [
          _FField('Full Name',          'e.g. Jean Claude Nkusi', _nameC,     widget.textPri, widget.textSec),
          _FDivider(brd),
          _FField('Email Address',      'email@company.rw',       _emailC,    widget.textPri, widget.textSec, keyboard: TextInputType.emailAddress),
          _FDivider(brd),
          _FField('Phone Number',       '+250 7XX XXX XXX',       _phoneC,    widget.textPri, widget.textSec, keyboard: TextInputType.phone),
          _FDivider(brd),
          _FField('National ID',        'ID / Passport number',   _nationalC, widget.textPri, widget.textSec),
          _FDivider(brd),
          _FField('Address',            'KG 7 Ave, Kigali',       _addressC,  widget.textPri, widget.textSec),
        ]),
        const SizedBox(height: 16),
        _FSection('Gender', const Color(0xFFD4A017)),
        Row(children: _genders.map((g) {
          final sel = _selGender == g;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _selGender = g),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? widget.brand.withOpacity(0.12) : c,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? widget.brand : brd, width: sel ? 1.5 : 0.8)),
              child: Center(child: Text(g, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: sel ? widget.brand : widget.textSec))))));
        }).toList()),
        const SizedBox(height: 16),
        _FSection('Company & Role', const Color(0xFFD4A017)),
        _FCard(c, brd, [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
            Icon(Icons.business_outlined, color: widget.textSec, size: 18), const SizedBox(width: 12),
            Text('Company: ', style: TextStyle(fontSize: 12, color: widget.textSec)),
            Text(widget.companyName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.textPri)),
          ])),
          _FDivider(brd),
          Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.textSec)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _roles.map((r) {
              final sel = _selRole == r;
              return GestureDetector(
                onTap: () => setState(() => _selRole = r),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? widget.brand.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? widget.brand : brd, width: sel ? 1.5 : 0.8)),
                  child: Text(r, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: sel ? widget.brand : widget.textSec))));
            }).toList()),
          ])),
        ]),
        const SizedBox(height: 16),
        _FSection('Account Credentials', const Color(0xFFD4A017)),
        _FCard(c, brd, [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Temporary Password', style: TextStyle(fontSize: 12, color: widget.textSec)),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: TextField(controller: _passC, obscureText: _obscure,
                style: TextStyle(fontSize: 14, color: widget.textPri),
                decoration: InputDecoration(
                  hintText: 'Set temporary password', hintStyle: TextStyle(color: widget.textSec, fontSize: 13),
                  filled: true, fillColor: isDark ? const Color(0xFF1C2236) : const Color(0xFFF2F4F8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)))),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: widget.brand.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: widget.brand, size: 18))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.info_outline_rounded, size: 13, color: const Color(0xFFD4A017)), const SizedBox(width: 6),
              const Expanded(child: Text('Member will be prompted to change password on first login.',
                style: TextStyle(fontSize: 10, color: const Color(0xFFD4A017)))),
            ]),
          ])),
        ]),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (_nameC.text.isEmpty || _emailC.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Color(0xFFD85A30),
                content: Text('Name and email are required'))); return;
            }
            widget.onSave(_Agent(_nameC.text, _emailC.text, _phoneC.text, _selRole, true));
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: widget.brand, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
          child: const Text('Add Team Member', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
        const SizedBox(height: 32),
      ]));
  }
}

// ─────────────────────────────────────────────
//  FORM HELPER WIDGETS (prefixed with _F to avoid conflicts)
// ─────────────────────────────────────────────
Widget _FSection(String label, Color color) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Row(children: [
    Container(width: 3, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.3)),
  ]));

Widget _FCard(Color card, Color border, List<Widget> children) => Container(
  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));

Widget _FDivider(Color border) => Divider(color: border, height: 1);

Widget _FField(String label, String hint, TextEditingController ctrl, Color textPri, Color textSec,
    {bool numeric = false, bool caps = false, TextInputType? keyboard}) {
  final isDark = textPri == Colors.white;
  final fillColor = isDark ? const Color(0xFF1C2236) : const Color(0xFFF0F2F8);
  return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 11, color: textSec, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
    const SizedBox(height: 6),
    Container(
      decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(10)),
      child: TextField(controller: ctrl,
        textCapitalization: caps ? TextCapitalization.characters : TextCapitalization.none,
        keyboardType: keyboard ?? (numeric ? TextInputType.number : TextInputType.text),
        style: TextStyle(fontSize: 14, color: textPri, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textSec.withOpacity(0.6), fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: const Color(0xFFD4A017), width: 1.5)),
          filled: true, fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true)),
    ),
  ]));
}

Widget _FChipRow(String label, List<String> opts, String sel, Color brand, Color border,
    Color textSec, ValueChanged<String> onTap) =>
  Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 10), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 11, color: textSec, fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    Wrap(spacing: 6, runSpacing: 6, children: opts.map((o) {
      final s = sel == o;
      return GestureDetector(onTap: () => onTap(o), child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: s ? brand.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: s ? brand : border, width: s ? 1.5 : 0.8)),
        child: Text(o, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: s ? brand : textSec))));
    }).toList()),
  ]));

class _SpecTile extends StatelessWidget {
  final IconData icon; final String label, value;
  final Color card, border, textPri, textSec;
  const _SpecTile(this.icon, this.label, this.value, this.card, this.border, this.textPri, this.textSec);
  @override Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(10), border: Border.all(color: border, width: 0.5)),
    child: Row(children: [
      Icon(icon, color: const Color(0xFFD4A017), size: 16), const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label, style: TextStyle(fontSize: 9, color: textSec)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri), overflow: TextOverflow.ellipsis),
      ]),
    ]));
}

class _DocRow extends StatelessWidget {
  final IconData icon; final String label, value; final Color color, textPri, textSec;
  const _DocRow(this.icon, this.label, this.value, this.color, this.textPri, this.textSec);
  @override Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 15)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: textSec)),
        Text(value,  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri)),
      ])),
      Icon(Icons.check_circle_rounded, color: color, size: 14),
    ]));
}

// ─────────────────────────────────────────────
//  FLEET CARD WIDGET (extracted to avoid deep nesting)
// ─────────────────────────────────────────────
class _FleetCard extends StatelessWidget {
  final CompanyCar car;
  final Color catColor, card, border, textPri, textSec, brand;
  final bool isDark;
  final VoidCallback onTap, onToggle, onEdit, onDelete;
  const _FleetCard({
    required this.car, required this.catColor, required this.isDark,
    required this.card, required this.border, required this.textPri,
    required this.textSec, required this.brand,
    required this.onTap, required this.onToggle,
    required this.onEdit, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cc = catColor;
    final availColor = car.available ? const Color(0xFF1D9E75) : const Color(0xFFD85A30);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Column(children: [
          // ── Hero image area ──────────────────────────
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: cc.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(children: [
              Center(child: Icon(Icons.directions_car_rounded, size: 64, color: cc.withOpacity(0.22))),

              // Category badge
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cc.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(car.category,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cc)),
                ),
              ),

              // Availability toggle
              Positioned(
                top: 10, right: 10,
                child: GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: availColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      car.available ? '● Available' : '✗ Rented',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: availColor),
                    ),
                  ),
                ),
              ),

              // Price badge
              Positioned(
                bottom: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141828) : Colors.white,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    '\$${car.price.toInt()}/day',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFFD4A017)),
                  ),
                ),
              ),
            ]),
          ),

          // ── Details row ──────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(car.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPri)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.event_seat_outlined, size: 12, color: textSec),
                  const SizedBox(width: 3),
                  Text('${car.seats}', style: TextStyle(fontSize: 11, color: textSec)),
                  const SizedBox(width: 8),
                  Icon(Icons.settings_outlined, size: 12, color: textSec),
                  const SizedBox(width: 3),
                  Text(car.transmission, style: TextStyle(fontSize: 11, color: textSec)),
                  const SizedBox(width: 8),
                  Icon(Icons.local_gas_station_outlined, size: 12, color: textSec),
                  const SizedBox(width: 3),
                  Text(car.fuel, style: TextStyle(fontSize: 11, color: textSec)),
                ]),
              ])),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: brand, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFD85A30), size: 20),
                onPressed: onDelete,
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FLEET SECTION HEADER
// ─────────────────────────────────────────────
class _FleetSectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color, textPri;
  const _FleetSectionHeader({
    required this.icon, required this.label,
    required this.count, required this.color, required this.textPri});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 28, height: 28,
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 14)),
    const SizedBox(width: 10),
    Expanded(child: Text(label,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri))),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color))),
  ]);
}

// ─────────────────────────────────────────────
//  RENTED CAR CARD
// ─────────────────────────────────────────────
class _RentedCard extends StatelessWidget {
  final CompanyCar car;
  final Color catColor, card, border, textPri, textSec, brand;
  final bool isDark;
  final String customer, fromDate, toDate, ref;
  final VoidCallback onToggle, onEdit;
  const _RentedCard({
    required this.car, required this.catColor, required this.isDark,
    required this.card, required this.border, required this.textPri,
    required this.textSec, required this.brand,
    required this.customer, required this.fromDate,
    required this.toDate, required this.ref,
    required this.onToggle, required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cc = catColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD85A30).withOpacity(0.3), width: 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header row ──────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFD85A30).withOpacity(0.06),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(13))),
          child: Row(children: [
            Container(width: 38, height: 38,
              decoration: BoxDecoration(color: cc.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.directions_car_rounded, color: cc, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(car.name,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPri)),
              Text('${car.category} · ${car.fuel} · ${car.transmission}',
                style: TextStyle(fontSize: 11, color: textSec)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD85A30).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.circle, color: Color(0xFFD85A30), size: 7),
                SizedBox(width: 5),
                Text('Rented Out',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFD85A30))),
              ])),
          ])),

        // ── Rented-to info ───────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Customer row
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2236) : const Color(0xFFF2F4F8),
                borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                CircleAvatar(radius: 16, backgroundColor: brand.withOpacity(0.15),
                  child: Text(customer.isNotEmpty ? customer[0] : '?',
                    style: TextStyle(color: brand, fontSize: 13, fontWeight: FontWeight.w700))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Rented by', style: TextStyle(fontSize: 10, color: textSec)),
                  Text(customer, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('Ref: $ref', style: TextStyle(fontSize: 10, color: textSec)),
                  Text('\$${car.price.toInt()}/day',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFD4A017))),
                ]),
              ])),
            const SizedBox(height: 8),
            // Dates row
            Row(children: [
              Expanded(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2236) : const Color(0xFFF2F4F8),
                  borderRadius: BorderRadius.circular(8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 11, color: Color(0xFF8B91A8)),
                    const SizedBox(width: 4),
                    Text('Pick-up', style: TextStyle(fontSize: 9, color: textSec)),
                  ]),
                  const SizedBox(height: 2),
                  Text(fromDate, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri)),
                ]))),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF8B91A8)),
              const SizedBox(width: 8),
              Expanded(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2236) : const Color(0xFFF2F4F8),
                  borderRadius: BorderRadius.circular(8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.event_outlined, size: 11, color: Color(0xFF8B91A8)),
                    const SizedBox(width: 4),
                    Text('Return', style: TextStyle(fontSize: 9, color: textSec)),
                  ]),
                  const SizedBox(height: 2),
                  Text(toDate, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri)),
                ]))),
            ]),
          ])),

        // ── Actions ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 14),
              label: const Text('Edit Car'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: brand),
                foregroundColor: brand,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(
              onPressed: onToggle,
              icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
              label: const Text('Mark Available'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D9E75), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                elevation: 0,
                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)))),
          ])),
      ]));
  }
}

// ─────────────────────────────────────────────
//  COMPANY SETTINGS FULL SCREEN
// ─────────────────────────────────────────────
class _CompanySettingsScreen extends StatefulWidget {
  final Color brand, card, border, textPri, textSec;
  final String companyName, companyLocation, companyPhone, companyEmail;
  const _CompanySettingsScreen({
    required this.brand, required this.card, required this.border,
    required this.textPri, required this.textSec,
    required this.companyName, required this.companyLocation,
    required this.companyPhone, required this.companyEmail,
  });
  @override State<_CompanySettingsScreen> createState() => _CompanySettingsState();
}

class _CompanySettingsState extends State<_CompanySettingsScreen> {
  // Profile controllers
  late TextEditingController _nameC, _locationC, _phoneC, _emailC, _websiteC, _descC;
  // Edit mode
  bool _isEditing = false;
  // Toggles
  bool _bookingNotifs  = true;
  bool _reviewNotifs   = true;
  bool _paymentNotifs  = false;
  bool _smsAlerts      = true;
  bool _instantBook    = false;
  bool _requireDeposit = true;
  bool _autoConfirm    = false;
  // Values
  String _currency     = 'USD';
  String _cancelPolicy = '48 hours';
  String _minAge       = '25';

  @override
  void initState() {
    super.initState();
    _nameC     = TextEditingController(text: widget.companyName);
    _locationC = TextEditingController(text: widget.companyLocation);
    _phoneC    = TextEditingController(text: widget.companyPhone);
    _emailC    = TextEditingController(text: widget.companyEmail);
    _websiteC  = TextEditingController();
    _descC     = TextEditingController(text: 'Premium car rental service in Kigali, Rwanda. We provide reliable, comfortable vehicles for business and leisure.');
  }

  @override
  void dispose() {
    for (final c in [_nameC, _locationC, _phoneC, _emailC, _websiteC, _descC]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: widget.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
        title: const Text('Company Settings',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() => _isEditing = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: Color(0xFF1D9E75),
                  content: Text('Changes saved', style: TextStyle(color: Colors.white)),
                  duration: Duration(seconds: 2)));
              },
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)))
          else
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.edit_outlined, color: Colors.white, size: 15),
                const SizedBox(width: 5),
                const Text('Edit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              ])),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // ── Company profile header ────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [widget.brand, widget.brand.withOpacity(0.6)]),
            borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5)),
              child: Center(child: Text(
                widget.companyName.substring(0, 2).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.companyName,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(widget.companyLocation,
                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: const Text('Company Admin',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))),
            ])),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo upload coming soon'), backgroundColor: Color(0xFF1D9E75))),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18))),
          ])),

        const SizedBox(height: 20),

        // ── Company Information ───────────────────────
        _CSettSection('Company Information', Icons.business_outlined, widget.textSec),
        _CSettCard(widget.card, widget.border, [
          _CSettField('Company Name',  _nameC,     widget.textPri, widget.textSec, isDark, readOnly: !_isEditing),
          _CSettField('Location',      _locationC, widget.textPri, widget.textSec, isDark,
            icon: Icons.location_on_outlined, readOnly: !_isEditing),
          _CSettField('Phone Number',  _phoneC,    widget.textPri, widget.textSec, isDark,
            icon: Icons.phone_outlined, keyboard: TextInputType.phone, readOnly: !_isEditing),
          _CSettField('Email Address', _emailC,    widget.textPri, widget.textSec, isDark,
            icon: Icons.email_outlined, keyboard: TextInputType.emailAddress, readOnly: !_isEditing),
          _CSettField('Website',       _websiteC,  widget.textPri, widget.textSec, isDark,
            icon: Icons.language_outlined, hint: 'www.yourcompany.rw', readOnly: !_isEditing),
          _CSettDivider(widget.border),
          // Description
          Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Description', style: TextStyle(fontSize: 11, color: widget.textSec, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: _isEditing
                    ? (isDark ? const Color(0xFF1C2236) : const Color(0xFFF0F2F8))
                    : (isDark ? const Color(0xFF141828) : const Color(0xFFEAECF4)),
                borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: _descC,
                maxLines: 3,
                readOnly: !_isEditing,
                style: TextStyle(fontSize: 13,
                  color: _isEditing ? widget.textPri : widget.textPri.withOpacity(0.55)),
                decoration: InputDecoration(
                  hintText: 'Tell customers about your company...',
                  hintStyle: TextStyle(color: widget.textSec, fontSize: 12),
                  filled: true, fillColor: Colors.transparent,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  focusedBorder: _isEditing
                      ? OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: widget.brand, width: 1.5))
                      : OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12)))),
          ])),
        ]),

        const SizedBox(height: 20),

        // ── Availability & Booking ────────────────────
        _CSettSection('Availability & Booking', Icons.calendar_today_outlined, widget.textSec),
        _CSettCard(widget.card, widget.border, [
          _CSettToggle('Instant Booking', 'Skip confirmation, book immediately',
            Icons.flash_on_outlined, _instantBook, widget.brand, widget.textPri, widget.textSec,
            (v) => setState(() => _instantBook = v)),
          _CSettDivider(widget.border),
          _CSettToggle('Auto-Confirm Requests', 'Automatically confirm new bookings',
            Icons.check_circle_outline, _autoConfirm, widget.brand, widget.textPri, widget.textSec,
            (v) => setState(() => _autoConfirm = v)),
          _CSettDivider(widget.border),
          _CSettToggle('Require Security Deposit', 'Ask for deposit before confirming',
            Icons.shield_outlined, _requireDeposit, widget.brand, widget.textPri, widget.textSec,
            (v) => setState(() => _requireDeposit = v)),
          _CSettDivider(widget.border),
          // Min driver age
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: widget.brand.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
              child: Icon(Icons.person_outline, color: widget.brand, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Minimum Driver Age', style: TextStyle(fontSize: 13, color: widget.textPri)),
              Text('Minimum age to rent a vehicle', style: TextStyle(fontSize: 11, color: widget.textSec)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              width: 60,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2236) : const Color(0xFFF0F2F8),
                borderRadius: BorderRadius.circular(8)),
              child: TextField(
                controller: TextEditingController(text: _minAge),
                onChanged: (v) => _minAge = v,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.textPri),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8)))),
          ])),
          _CSettDivider(widget.border),
          // Cancellation policy
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: widget.brand.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
              child: Icon(Icons.cancel_outlined, color: widget.brand, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Cancellation Policy', style: TextStyle(fontSize: 13, color: widget.textPri)),
              Text('Free cancellation window', style: TextStyle(fontSize: 11, color: widget.textSec)),
            ])),
            DropdownButton<String>(
              value: _cancelPolicy,
              dropdownColor: widget.card,
              underline: const SizedBox(),
              style: TextStyle(fontSize: 12, color: widget.textPri, fontWeight: FontWeight.w600),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: widget.textSec, size: 18),
              items: ['24 hours', '48 hours', '72 hours', 'No refund'].map((v) =>
                DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => _cancelPolicy = v!)),
          ])),
        ]),

        const SizedBox(height: 20),

        // ── Payment ───────────────────────────────────
        _CSettSection('Payment', Icons.payment_outlined, widget.textSec),
        _CSettCard(widget.card, widget.border, [
          // Currency
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.attach_money_rounded, color: const Color(0xFFD4A017), size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Display Currency', style: TextStyle(fontSize: 13, color: widget.textPri)),
              Text('Currency shown to customers', style: TextStyle(fontSize: 11, color: widget.textSec)),
            ])),
            DropdownButton<String>(
              value: _currency,
              dropdownColor: widget.card,
              underline: const SizedBox(),
              style: TextStyle(fontSize: 12, color: widget.textPri, fontWeight: FontWeight.w600),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: widget.textSec, size: 18),
              items: ['USD', 'EUR', 'RWF', 'GBP'].map((v) =>
                DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => _currency = v!)),
          ])),
          _CSettDivider(widget.border),
          _CSettNav('Payout Account',    'Set up your bank account',          Icons.account_balance_outlined, widget.brand, widget.textPri, widget.textSec),
          _CSettDivider(widget.border),
          _CSettNav('Tax Configuration', 'VAT and applicable taxes',          Icons.receipt_outlined,         widget.brand, widget.textPri, widget.textSec),
          _CSettDivider(widget.border),
          _CSettNav('Pricing Rules',     'Set discounts and seasonal pricing', Icons.local_offer_outlined,     widget.brand, widget.textPri, widget.textSec),
        ]),

        const SizedBox(height: 20),

        // ── Notifications ─────────────────────────────
        _CSettSection('Notifications', Icons.notifications_outlined, widget.textSec),
        _CSettCard(widget.card, widget.border, [
          _CSettToggle('New Booking Alerts',  'Get notified on new reservations',
            Icons.calendar_today_outlined, _bookingNotifs, widget.brand, widget.textPri, widget.textSec,
            (v) => setState(() => _bookingNotifs = v)),
          _CSettDivider(widget.border),
          _CSettToggle('Review Alerts',       'Get notified on new customer reviews',
            Icons.star_outline_rounded,    _reviewNotifs,  widget.brand, widget.textPri, widget.textSec,
            (v) => setState(() => _reviewNotifs = v)),
          _CSettDivider(widget.border),
          _CSettToggle('Payment Alerts',      'Get notified on payment events',
            Icons.payment_outlined,        _paymentNotifs, widget.brand, widget.textPri, widget.textSec,
            (v) => setState(() => _paymentNotifs = v)),
          _CSettDivider(widget.border),
          _CSettToggle('SMS Alerts',          'Receive text messages for urgent events',
            Icons.sms_outlined,            _smsAlerts,     widget.brand, widget.textPri, widget.textSec,
            (v) => setState(() => _smsAlerts = v)),
        ]),

        const SizedBox(height: 20),

        // ── Support & Legal ───────────────────────────
        _CSettSection('Support & Legal', Icons.info_outline, widget.textSec),
        _CSettCard(widget.card, widget.border, [
          _CSettNav('Terms & Conditions',  'Your rental terms for customers', Icons.description_outlined,  widget.brand, widget.textPri, widget.textSec),
          _CSettDivider(widget.border),
          _CSettNav('Insurance Policy',    'Upload insurance documents',      Icons.shield_outlined,        widget.brand, widget.textPri, widget.textSec),
          _CSettDivider(widget.border),
          _CSettNav('Support Contact',     'Set support email and phone',     Icons.support_agent_outlined, widget.brand, widget.textPri, widget.textSec),
          _CSettDivider(widget.border),
          _CSettNav('App Version',         'SwiftRide Admin v1.0.0',          Icons.info_outline,           widget.brand, widget.textPri, widget.textSec, trailing: 'v1.0.0'),
        ]),

        const SizedBox(height: 24),

        // ── Save button ───────────────────────────────
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: const Color(0xFF1D9E75),
              content: const Text('Settings saved successfully', style: TextStyle(color: Colors.white)),
              duration: const Duration(seconds: 2)));
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.brand, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0),
          child: const Text('Save Settings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),

        const SizedBox(height: 32),
      ]),
    );
  }
}

// ── Settings screen helper widgets ─────────────────────────
Widget _CSettSection(String label, IconData icon, Color textSec) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Row(children: [
    Icon(icon, size: 14, color: const Color(0xFFD4A017)),
    const SizedBox(width: 7),
    Text(label.toUpperCase(),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
        color: const Color(0xFFD4A017), letterSpacing: 0.8)),
  ]));

Widget _CSettCard(Color card, Color border, List<Widget> children) => Container(
  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16),
    border: Border.all(color: border, width: 0.5)),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));

Widget _CSettDivider(Color border) => Divider(color: border, height: 1, indent: 64);

Widget _CSettField(String label, TextEditingController ctrl, Color textPri, Color textSec, bool isDark,
    {IconData? icon, TextInputType? keyboard, String? hint, bool readOnly = false}) {
  final fillColor = readOnly
      ? (isDark ? const Color(0xFF141828) : const Color(0xFFEAECF4))
      : (isDark ? const Color(0xFF1C2236) : const Color(0xFFF0F2F8));
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: readOnly ? textSec.withOpacity(0.4) : textSec.withOpacity(0.7)),
          const SizedBox(width: 5),
        ],
        Text(label, style: TextStyle(
          fontSize: 11,
          color: readOnly ? textSec.withOpacity(0.5) : textSec,
          fontWeight: FontWeight.w600, letterSpacing: 0.2)),
      ]),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(10),
          border: readOnly ? Border.all(color: Colors.transparent) : null,
        ),
        child: TextField(
          controller: ctrl,
          keyboardType: keyboard,
          readOnly: readOnly,
          style: TextStyle(
            fontSize: 14,
            color: readOnly ? textPri.withOpacity(0.55) : textPri,
            fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: TextStyle(color: textSec.withOpacity(0.35), fontSize: 13),
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
            focusedBorder: readOnly
                ? OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: const Color(0xFFD4A017), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            isDense: true)),
      ),
      const SizedBox(height: 8),
    ]));
}

Widget _CSettToggle(String label, String subtitle, IconData icon, bool value,
    Color brand, Color textPri, Color textSec, ValueChanged<bool> onChanged) =>
  ListTile(
    leading: Container(width: 36, height: 36,
      decoration: BoxDecoration(color: brand.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, color: brand, size: 18)),
    title: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPri)),
    subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: textSec)),
    trailing: Switch(value: value, onChanged: onChanged,
      activeColor: brand, activeTrackColor: brand.withOpacity(0.3),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
    dense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2));

Widget _CSettNav(String label, String subtitle, IconData icon,
    Color brand, Color textPri, Color textSec, {String? trailing}) =>
  ListTile(
    onTap: () {},
    leading: Container(width: 36, height: 36,
      decoration: BoxDecoration(color: brand.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, color: brand, size: 18)),
    title: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPri)),
    subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: textSec)),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      if (trailing != null) Text(trailing, style: TextStyle(fontSize: 12, color: textSec)),
      const SizedBox(width: 4),
      Icon(Icons.chevron_right_rounded, color: textSec, size: 18),
    ]),
    dense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2));

// ─────────────────────────────────────────────
//  ACCOUNT HISTORY FULL SCREEN
//  Shows every event on this company account
//  from creation to now, pulled from AppDataStore
// ─────────────────────────────────────────────
class _AccountHistoryScreen extends StatefulWidget {
  final String companyName;
  final Color brand;
  const _AccountHistoryScreen({required this.companyName, required this.brand});
  @override State<_AccountHistoryScreen> createState() => _AccountHistoryState();
}

class _AccountHistoryState extends State<_AccountHistoryScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);
    final card    = isDark ? const Color(0xFF141828) : Colors.white;
    final border  = isDark ? const Color(0xFF252B3E) : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white             : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8)  : const Color(0xFF6B7280);

    final store   = AppDataStore.instance;
    final allLogs = store.auditLog.where((e) =>
        e.company == widget.companyName || e.company.isEmpty && e.actor.contains(widget.companyName)).toList();
    final cats    = ['All', 'Booking', 'Fleet', 'Team', 'Settings'];
    final entries = _filter == 'All' ? allLogs : allLogs.where((e) => e.category == _filter).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: widget.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Account History', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          Text(widget.companyName, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
        ]),
      ),
      body: Column(children: [
        // Stats strip
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [widget.brand.withOpacity(0.15), widget.brand.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.brand.withOpacity(0.2), width: 0.8)),
          child: Row(children: [
            _HistStat('${allLogs.length}', 'Total Events',  const Color(0xFFD4A017)),
            _HistStat('${allLogs.where((e)=>e.category=="Booking").length}',  'Bookings', const Color(0xFF1D9E75)),
            _HistStat('${allLogs.where((e)=>e.category=="Fleet").length}',    'Fleet',    const Color(0xFF3B5FD4)),
            _HistStat('${allLogs.where((e)=>e.category=="Team").length}',     'Team',     const Color(0xFF7F77DD)),
          ])),
        // Category filter chips
        SizedBox(height: 42, child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: cats.map((cat) {
            final sel = _filter == cat;
            final clr = _histCatColor(cat);
            return GestureDetector(
              onTap: () => setState(() => _filter = cat),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: sel ? clr : card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? clr : border, width: 0.8)),
                child: Center(child: Text(cat,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : textSec)))));
          }).toList())),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${entries.length} event${entries.length != 1 ? "s" : ""}',
              style: TextStyle(fontSize: 12, color: textSec)),
            Row(children: [
              const Icon(Icons.lock_outline, size: 12, color: const Color(0xFFD4A017)),
              const SizedBox(width: 4),
              const Text('Permanent record', style: TextStyle(fontSize: 11, color: const Color(0xFFD4A017), fontWeight: FontWeight.w600)),
            ]),
          ])),
        Expanded(child: entries.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.history_rounded, size: 52, color: textSec),
              const SizedBox(height: 12),
              Text('No events recorded yet', style: TextStyle(color: textSec, fontSize: 15)),
              const SizedBox(height: 6),
              Text('Events appear here as actions are taken', style: TextStyle(color: textSec, fontSize: 12)),
            ]))
          : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final e   = entries[i];
              final clr = _histCatColor(e.category);
              return GestureDetector(
                onTap: () => _showHistoryDetail(context, e, isDark, card, border, textPri, textSec, widget.brand),
                child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border, width: 0.5)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 34, height: 34,
                    decoration: BoxDecoration(color: clr.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                    child: Icon(_histCatIcon(e.category), color: clr, size: 16)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.action, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${e.actor} · ${e.actorRole}',
                      style: TextStyle(fontSize: 10, color: textSec),
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                    const SizedBox(height: 2),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: clr.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(e.category, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: clr))),
                      const SizedBox(width: 6),
                      Expanded(child: Text(e.timestamp,
                        style: TextStyle(fontSize: 9, color: textSec), overflow: TextOverflow.ellipsis)),
                    ]),
                  ])),
                ])));
            })),
      ]),
    );
  }

  void _showHistoryDetail(BuildContext ctx, AuditEntry e, bool isDark,
      Color card, Color border, Color textPri, Color textSec, Color brand) {
    final clr = _histCatColor(e.category);
    showModalBottomSheet(
      context: ctx,
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
            decoration: BoxDecoration(color: clr.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(_histCatIcon(e.category), color: clr, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.id, style: TextStyle(fontSize: 12, color: textSec, fontWeight: FontWeight.w600)),
            Text(e.timestamp, style: TextStyle(fontSize: 11, color: textSec)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: clr.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(e.category, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: clr))),
        ]),
        const SizedBox(height: 16),

        // Action description
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: clr.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: clr.withOpacity(0.2), width: 0.5)),
          child: Text(e.action,
            style: TextStyle(fontSize: 14, color: textPri, fontWeight: FontWeight.w500, height: 1.5))),
        const SizedBox(height: 16),

        // Meta rows
        _HistDetailRow(Icons.person_outline,       'Performed by', e.actor,     textPri, textSec),
        _HistDetailRow(Icons.shield_outlined,      'Role',         e.actorRole, textPri, textSec),
        if (e.company.isNotEmpty)
          _HistDetailRow(Icons.business_outlined,  'Company',      e.company,   textPri, textSec),
        _HistDetailRow(Icons.access_time_outlined, 'Timestamp',    e.timestamp, textPri, textSec),
        _HistDetailRow(Icons.tag_rounded,          'Entry ID',     e.id,        textPri, textSec),
        const SizedBox(height: 16),

        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style: ElevatedButton.styleFrom(
            backgroundColor: brand, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
          child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)))),
      ])));
  }

    Color _histCatColor(String cat) {
    switch (cat) {
      case 'Booking':  return const Color(0xFF1D9E75);
      case 'Fleet':    return const Color(0xFF3B5FD4);
      case 'Team':     return const Color(0xFF7F77DD);
      case 'Settings': return const Color(0xFF8B91A8);
      default:         return const Color(0xFFD4A017);
    }
  }

  IconData _histCatIcon(String cat) {
    switch (cat) {
      case 'Booking':  return Icons.receipt_long_rounded;
      case 'Fleet':    return Icons.directions_car_rounded;
      case 'Team':     return Icons.people_rounded;
      case 'Settings': return Icons.settings_rounded;
      default:         return Icons.history_rounded;
    }
  }
}

class _HistStat extends StatelessWidget {
  final String value, label; final Color color;
  const _HistStat(this.value, this.label, this.color);
  @override Widget build(BuildContext c) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
    Text(label,  style: const TextStyle(fontSize: 9, color: Color(0xFF8B91A8))),
  ]));
}

Widget _HistDetailRow(IconData icon, String label, String value, Color textPri, Color textSec) =>
  Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
    Icon(icon, size: 16, color: textSec),
    const SizedBox(width: 10),
    Text('$label: ', style: TextStyle(fontSize: 12, color: textSec)),
    Expanded(child: Text(value,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri),
      overflow: TextOverflow.ellipsis)),
  ]));

// ─────────────────────────────────────────────
//  FULL EDIT AGENT SCREEN  (item 6 — team edit)
// ─────────────────────────────────────────────
class _EditAgentScreen extends StatefulWidget {
  final _Agent agent;
  final Color brand, card, border, textPri, textSec;
  final String companyName;
  final void Function(_Agent) onSave;
  const _EditAgentScreen({
    required this.agent, required this.brand, required this.card,
    required this.border, required this.textPri, required this.textSec,
    required this.companyName, required this.onSave});
  @override State<_EditAgentScreen> createState() => _EditAgentState();
}
class _EditAgentState extends State<_EditAgentScreen> {
  late TextEditingController _nameC, _emailC, _phoneC, _nationalC, _addressC, _emergencyC;
  String _selRole = 'Agent';
  bool   _active  = true;
  static const _roles = ['Agent','Fleet Manager','Senior Agent','Accountant','Supervisor','Team Lead'];

  @override
  void initState() {
    super.initState();
    final a = widget.agent;
    _nameC      = TextEditingController(text: a.name);
    _emailC     = TextEditingController(text: a.email);
    _phoneC     = TextEditingController(text: a.phone);
    _nationalC  = TextEditingController();
    _addressC   = TextEditingController();
    _emergencyC = TextEditingController();
    _selRole    = _roles.contains(a.role) ? a.role : 'Agent';
    _active     = a.active;
  }
  @override void dispose() {
    for (final c in [_nameC,_emailC,_phoneC,_nationalC,_addressC,_emergencyC]) c.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F2F8);
    final c      = isDark ? const Color(0xFF141828) : Colors.white;
    final brd    = isDark ? const Color(0xFF252B3E) : const Color(0xFFDDE1EE);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: widget.brand, foregroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('Edit ${widget.agent.name.split(' ').first}',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [TextButton(
          onPressed: () {
            if (_nameC.text.isEmpty || _emailC.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                backgroundColor: Color(0xFFD85A30), content: Text('Name and email required'))); return;
            }
            widget.onSave(_Agent(_nameC.text, _emailC.text, _phoneC.text, _selRole, _active));
            Navigator.pop(context);
          },
          child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)))],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Avatar
        Center(child: Stack(children: [
          CircleAvatar(radius: 40, backgroundColor: widget.brand.withOpacity(0.15),
            child: Text(widget.agent.name.split(' ').map((e) => e[0]).take(2).join(),
              style: TextStyle(color: widget.brand, fontSize: 24, fontWeight: FontWeight.w800))),
          Positioned(bottom: 0, right: 0, child: Container(width: 28, height: 28,
            decoration: BoxDecoration(color: widget.brand, shape: BoxShape.circle, border: Border.all(color: bg, width: 2)),
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14))),
        ])),
        const SizedBox(height: 20),

        // Status toggle
        Container(padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(14), border: Border.all(color: brd, width: 0.5)),
          child: Row(children: [
            Icon(_active ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: _active ? const Color(0xFF1D9E75) : const Color(0xFFD85A30), size: 22),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_active ? 'Account Active' : 'Account Inactive',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: _active ? const Color(0xFF1D9E75) : const Color(0xFFD85A30))),
              Text('Tap to ${_active ? "deactivate" : "activate"} this account',
                style: TextStyle(fontSize: 11, color: widget.textSec)),
            ])),
            Switch(value: _active, onChanged: (v) => setState(() => _active = v),
              activeColor: const Color(0xFF1D9E75), activeTrackColor: const Color(0xFF1D9E75).withOpacity(0.3)),
          ])),

        // Personal info
        _EASection('Personal Information', widget.textSec),
        _EAField('Full Name',         _nameC,      widget.textPri, widget.textSec),
        _EAField('Email Address',     _emailC,     widget.textPri, widget.textSec, kb: TextInputType.emailAddress),
        _EAField('Phone Number',      _phoneC,     widget.textPri, widget.textSec, kb: TextInputType.phone),
        _EAField('National ID',       _nationalC,  widget.textPri, widget.textSec),
        _EAField('Address',           _addressC,   widget.textPri, widget.textSec),
        _EAField('Emergency Contact', _emergencyC, widget.textPri, widget.textSec, kb: TextInputType.phone),
        const SizedBox(height: 16),

        // Company & role
        _EASection('Company & Role', widget.textSec),
        _EACard(c, brd, [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
            Icon(Icons.business_outlined, color: widget.textSec, size: 18),
            const SizedBox(width: 12),
            Text('Company: ', style: TextStyle(fontSize: 12, color: widget.textSec)),
            Text(widget.companyName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.textPri)),
          ])),
          _EADiv(brd),
          Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.textSec)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _roles.map((r) {
              final sel = _selRole == r;
              return GestureDetector(
                onTap: () => setState(() => _selRole = r),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? widget.brand.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? widget.brand : brd, width: sel ? 1.5 : 0.8)),
                  child: Text(r, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: sel ? widget.brand : widget.textSec))));
            }).toList()),
          ])),
        ]),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: () {
            widget.onSave(_Agent(_nameC.text, _emailC.text, _phoneC.text, _selRole, _active));
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: widget.brand, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
          child: const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
        const SizedBox(height: 32),
      ]));
  }
}

// Edit agent helper widgets
Widget _EASection(String label, Color textSec) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Row(children: [
    Container(width: 3, height: 14, decoration: BoxDecoration(color: const Color(0xFFD4A017), borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFD4A017))),
  ]));

Widget _EACard(Color card, Color border, List<Widget> children) => Container(
  margin: const EdgeInsets.only(bottom: 0),
  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
  child: Column(children: children));

Widget _EADiv(Color border) => Divider(color: border, height: 1);

Widget _EAField(String label, TextEditingController ctrl, Color textPri, Color textSec, {TextInputType? kb}) {
  final isDark = textPri == Colors.white;
  final fillColor = isDark ? const Color(0xFF1C2236) : const Color(0xFFF0F2F8);
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 11, color: textSec, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: ctrl,
          keyboardType: kb,
          style: TextStyle(fontSize: 14, color: textPri, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: textSec.withOpacity(0.45), fontSize: 13),
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            isDense: true)),
      ),
      const SizedBox(height: 4),
    ]));
}

// ── Rental model banner for company admin overview ─────────────
class _RentalModelBanner extends StatelessWidget {
  final String rentalModel;
  final Color brand, textSec;
  const _RentalModelBanner({required this.rentalModel, required this.brand, required this.textSec});

  IconData get _icon {
    switch (rentalModel) {
      case 'Monthly':   return Icons.calendar_month_rounded;
      case 'Long-Term': return Icons.event_repeat_rounded;
      case 'Hybrid':    return Icons.swap_horiz_rounded;
      default:          return Icons.today_rounded;
    }
  }

  String get _desc {
    switch (rentalModel) {
      case 'Monthly':   return 'Your company operates on a monthly billing model. Customers choose number of months when booking.';
      case 'Long-Term': return 'Your company offers long-term rentals (6+ months minimum). Best for corporate & expat clients.';
      case 'Hybrid':    return 'Your company offers both daily and monthly rates. Customers choose at booking.';
      default:          return 'Your company operates on a daily rate model. Customers pick start and end dates.';
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: brand.withOpacity(0.07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: brand.withOpacity(0.25), width: 1),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: brand.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(_icon, color: brand, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Rental Model', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: brand)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: brand.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(rentalModel.isEmpty ? 'Daily' : rentalModel,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: brand)),
          ),
        ]),
        const SizedBox(height: 4),
        Text(_desc, style: TextStyle(fontSize: 11, color: textSec, height: 1.4)),
      ])),
    ]),
  );
}

// ── Analytics chart helpers ──────────────────────────────────────────────────

class _BarData {
  final String label; final double value; final Color color;
  const _BarData(this.label, this.value, this.color);
}

class _RingPainter extends CustomPainter {
  final double ratio; final Color fill, track;
  const _RingPainter(this.ratio, this.fill, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r  = (size.width / 2) - 8;
    final sw = 10.0;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Track
    canvas.drawArc(rect, -1.5708, 6.2832, false,
      Paint()..color = track..strokeWidth = sw..style = PaintingStyle.stroke
             ..strokeCap = StrokeCap.round);

    // Fill
    if (ratio > 0) {
      canvas.drawArc(rect, -1.5708, 6.2832 * ratio.clamp(0.0, 1.0), false,
        Paint()..color = fill..strokeWidth = sw..style = PaintingStyle.stroke
               ..strokeCap = StrokeCap.round);
    }
  }

  @override bool shouldRepaint(_RingPainter o) => o.ratio != ratio;
}

class _RingLegend extends StatelessWidget {
  final String label, value; final Color color, textSec;
  const _RingLegend(this.label, this.value, this.color, this.textSec);
  @override Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 8),
    Expanded(child: Text(label, style: TextStyle(fontSize: 11, color: textSec))),
    Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
  ]);
}
