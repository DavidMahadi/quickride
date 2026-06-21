// lib/screens/user/fleet_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart' show AppColors;
import 'package:swiftride/screens/guest/companies_screen.dart' show RentalCompany, CompanyCar;
import 'package:swiftride/screens/user/booking_screen.dart' show BookingScreen;
import 'package:swiftride/services/auth_service.dart';

const _kCatColors = {
  'Economy': Color(0xFF1D9E75), 'SUV': Color(0xFF3B5FD4),
  'Luxury': Color(0xFF7F77DD),  '4x4': Color(0xFFD85A30),
  'Van': Color(0xFF0D7EA8),     'Sedan': Color(0xFF1D9E75),
  'Premium': Color(0xFF7F77DD),
};
Color _cc(String cat) => _kCatColors[cat] ?? AppColors.gold;

class FleetScreen extends StatefulWidget {
  final RentalCompany company;
  const FleetScreen({super.key, required this.company});
  @override State<FleetScreen> createState() => _State();
}

class _State extends State<FleetScreen> {
  String _cat  = 'All';
  String _sort = 'price_asc';
  final Set<String> _selected = {}; // selected car names

  List<String> get _cats =>
      ['All', ...widget.company.fleet.map((c) => c.category).toSet()];

  List<CompanyCar> get _cars {
    var l = widget.company.fleet
        .where((c) => _cat == 'All' || c.category == _cat).toList();
    switch (_sort) {
      case 'price_asc':  l.sort((a, b) => a.price.compareTo(b.price)); break;
      case 'price_desc': l.sort((a, b) => b.price.compareTo(a.price)); break;
      case 'seats':      l.sort((a, b) => b.seats.compareTo(a.seats)); break;
    }
    return l;
  }

  int    get _avail    => widget.company.fleet.where((c) => c.available).length;
  double get _min      => widget.company.fleet.map((c) => c.price).reduce((a,b) => a<b?a:b);
  double get _selTotal => widget.company.fleet
      .where((c) => _selected.contains(c.name))
      .fold(0.0, (sum, c) => sum + c.price);
  bool get _selecting  => _selected.isNotEmpty;

  void _toggle(CompanyCar car) {
    if (!car.available) return;
    setState(() {
      if (_selected.contains(car.name)) {
        _selected.remove(car.name);
      } else {
        _selected.add(car.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg      : AppColors.lightBg;
    final card    = isDark ? AppColors.darkCard    : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder  : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white           : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);
    final brand   = widget.company.brandColor;
    final cars    = _cars;

    return WillPopScope(
      onWillPop: () async {
        if (_selecting) { setState(() => _selected.clear()); return false; }
        Navigator.pop(context); return false;
      },
      child: Material(
        color: bg,
        child: SafeArea(child: Column(children: [

          // ── TOP BAR ────────────────────────────────────────────
          Container(
            color: _selecting ? const Color(0xFF1D9E75) : brand,
            padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
            child: Row(children: [
              IconButton(
                icon: Icon(_selecting ? Icons.close : Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (_selecting) setState(() => _selected.clear());
                  else Navigator.pop(context);
                },
              ),
              Expanded(child: _selecting
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${_selected.length} car${_selected.length > 1 ? 's' : ''} selected',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('\$${_selTotal.toInt()} total/day',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                  ])
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.company.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('${widget.company.fleet.length} vehicles · tap to select multiple',
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
                  ]),
              ),
              if (_selecting)
                TextButton(
                  onPressed: () => setState(() => _selected.clear()),
                  child: const Text('Clear', style: TextStyle(color: Colors.white, fontSize: 13)),
                )
              else
                IconButton(
                  icon: const Icon(Icons.sort_rounded, color: Colors.white),
                  onPressed: () => _showSort(context, textPri, textSec, card, border),
                ),
            ]),
          ),

          // ── COMPANY STRIP ───────────────────────────────────────
          Container(
            color: (_selecting ? const Color(0xFF1D9E75) : brand).withOpacity(0.85),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.company.tagline,
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
              const SizedBox(height: 10),
              Row(children: [
                _SB(v: '$_avail',                        l: 'Available'),
                const SizedBox(width: 8),
                _SB(v: '${widget.company.fleet.length}', l: 'Total'),
                const SizedBox(width: 8),
                _SB(v: '\$${_min.toInt()}+',             l: 'From/day'),
                const SizedBox(width: 8),
                _SB(v: '${widget.company.rating}★',      l: 'Rating'),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.7), size: 13),
                const SizedBox(width: 5),
                Expanded(child: Text(widget.company.location,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                  overflow: TextOverflow.ellipsis)),
              ]),
            ]),
          ),

          // ── SELECTION HINT BANNER ───────────────────────────────
          if (!_selecting) Container(
            color: AppColors.gold.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              const Icon(Icons.touch_app_outlined, color: AppColors.gold, size: 15),
              const SizedBox(width: 8),
              Text('Long-press or tap ☐ to select multiple cars',
                style: TextStyle(fontSize: 11, color: AppColors.gold.withOpacity(0.9))),
            ]),
          ),

          // ── CATEGORY PILLS ──────────────────────────────────────
          Container(
            height: 48, color: bg,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: _cats.map((cat) {
                final sel   = _cat == cat;
                final count = cat == 'All'
                    ? widget.company.fleet.length
                    : widget.company.fleet.where((c) => c.category == cat).length;
                return GestureDetector(
                  onTap: () => setState(() => _cat = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: sel ? brand : card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? brand : border, width: 0.8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : textSec)),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: sel ? Colors.white.withOpacity(0.25) : border,
                          borderRadius: BorderRadius.circular(10)),
                        child: Text('$count', style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : textSec)),
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── COUNT + SORT ────────────────────────────────────────
          Container(
            color: bg,
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
            child: Row(children: [
              Text('${cars.length} vehicle${cars.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 12, color: textSec)),
              const Spacer(),
              if (!_selecting) GestureDetector(
                onTap: () => _showSort(context, textPri, textSec, card, border),
                child: Row(children: [
                  Icon(Icons.sort_rounded, size: 15, color: brand),
                  const SizedBox(width: 4),
                  Text(_sortLabel, style: TextStyle(fontSize: 12, color: brand, fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
          Divider(color: border, height: 1),

          // ── CAR LIST ────────────────────────────────────────────
          Expanded(child: cars.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.directions_car_outlined, size: 56, color: textSec),
                const SizedBox(height: 12),
                Text('No vehicles in this category', style: TextStyle(color: textSec)),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                itemCount: cars.length,
                itemBuilder: (_, i) => _Card(
                  car: cars[i],
                  company: widget.company,
                  isDark: isDark, card: card, border: border,
                  textPri: textPri, textSec: textSec,
                  isSelected: _selected.contains(cars[i].name),
                  isSelecting: _selecting,
                  onTap: () {
                    if (_selecting) {
                      _toggle(cars[i]);
                    } else {
                      _detail(context, cars[i], isDark, card, border, textPri, textSec);
                    }
                  },
                  onLongPress: () => _toggle(cars[i]),
                  onSelect: () => _toggle(cars[i]),
                  onBook: () => _bookSingle(context, cars[i]),
                  onDetail: () => _detail(context, cars[i], isDark, card, border, textPri, textSec),
                ),
              ),
          ),

          // ── BOTTOM CTA ──────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: card,
              border: Border(top: BorderSide(color: border, width: 0.5))),
            child: _selecting
              // Multi-select CTA
              ? Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${_selected.length} car${_selected.length > 1 ? 's' : ''} selected',
                      style: TextStyle(fontSize: 12, color: textSec)),
                    RichText(text: TextSpan(children: [
                      TextSpan(text: '\$${_selTotal.toInt()}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.gold)),
                      TextSpan(text: ' total/day', style: TextStyle(fontSize: 11, color: textSec)),
                    ])),
                  ])),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _bookMultiple(context),
                    icon: const Icon(Icons.calendar_today_outlined, size: 15),
                    label: Text('Book ${_selected.length} Car${_selected.length > 1 ? 's' : ''}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D9E75), foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ])
              // Default CTA
              : Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$_avail available', style: TextStyle(fontSize: 11, color: textSec)),
                    RichText(text: TextSpan(children: [
                      TextSpan(text: 'from \$${_min.toInt()}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gold)),
                      TextSpan(text: '/day', style: TextStyle(fontSize: 11, color: textSec)),
                    ])),
                  ]),
                  const SizedBox(width: 14),
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () {
                      final avail = widget.company.fleet.where((c) => c.available).toList();
                      if (avail.isEmpty) return;
                      _bookSingle(context, avail.first);
                    },
                    icon: const Icon(Icons.calendar_today_outlined, size: 15),
                    label: const Text('Book a Car'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brand, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  )),
                ]),
          ),
        ])),
      ),
    );
  }

  void _bookSingle(BuildContext context, CompanyCar car) {
    if (!AuthService.isLoggedIn) {
      AuthService.setPending('/user/booking', args: {
        'carName': car.name, 'company': widget.company.name,
        'price': '\$${car.price.toInt()}', 'category': car.category,
        'seats': car.seats, 'fuel': car.fuel, 'transmission': car.transmission,
      });
      Navigator.pushNamed(context, '/login'); return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(
      carName: car.name, company: widget.company.name,
      price: '\$${car.price.toInt()}', category: car.category,
      seats: car.seats, fuel: car.fuel, transmission: car.transmission,
    )));
  }

  void _bookMultiple(BuildContext context) {
    final selectedCars = widget.company.fleet
        .where((c) => _selected.contains(c.name)).toList();
    _showMultiBookSheet(context, selectedCars);
  }

  void _showMultiBookSheet(BuildContext context, List<CompanyCar> cars) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final card    = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8) : const Color(0xFF6B7280);
    final brand   = widget.company.brandColor;
    final total   = cars.fold(0.0, (s, c) => s + c.price);

    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.9,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg : AppColors.lightBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            Container(margin: const EdgeInsets.only(top: 12, bottom: 8), width: 40, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Fleet Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPri)),
                  Text('${cars.length} vehicles selected from ${widget.company.name}',
                    style: TextStyle(fontSize: 12, color: textSec)),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.8)),
                  child: Text('\$${total.toInt()}/day',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.gold)),
                ),
              ]),
            ),
            Divider(color: border, height: 1),
            Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: [
              // Selected cars list — each tappable
              ...cars.map((car) {
                final cc = _cc(car.category);
                return GestureDetector(
                  onTap: () => _showCarBrief(context, car, cc, isDark, card, border, textPri, textSec),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border, width: 0.5)),
                    child: Row(children: [
                      Container(width: 44, height: 44,
                        decoration: BoxDecoration(color: cc.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.directions_car_rounded, color: cc, size: 22)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(car.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
                        Text('${car.seats} seats · ${car.transmission} · ${car.fuel}',
                          style: TextStyle(fontSize: 11, color: textSec)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: cc.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                            child: Text(car.category, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: cc))),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: car.available ? const Color(0xFF1D9E75).withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6)),
                            child: Text(car.available ? '● Available' : '✗ Unavailable',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                                color: car.available ? const Color(0xFF1D9E75) : Colors.redAccent))),
                        ]),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('\$${car.price.toInt()}/day',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
                        const SizedBox(height: 4),
                        Icon(Icons.chevron_right_rounded, color: textSec, size: 16),
                      ]),
                    ]),
                  ),
                );
              }),

              const SizedBox(height: 8),

              // Summary
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gold.withOpacity(0.2), width: 0.8)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Vehicles', style: TextStyle(fontSize: 13, color: textSec)),
                    Text('${cars.length}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
                  ]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Total seats', style: TextStyle(fontSize: 13, color: textSec)),
                    Text('${cars.fold(0, (s, c) => s + c.seats)}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
                  ]),
                  Divider(color: AppColors.gold.withOpacity(0.2), height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Total per day', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
                    Text('\$${total.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gold)),
                  ]),
                ]),
              ),

              const SizedBox(height: 20),

              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Book the first car as primary (real app would handle multi-booking)
                  _bookSingle(context, cars.first);
                },
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text('Proceed to Book ${cars.length} Car${cars.length > 1 ? 's' : ''}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brand, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              )),
            ])),
          ]),
        ),
      ),
    );
  }

  void _showCarBrief(BuildContext context, CompanyCar car, Color cc,
      bool isDark, Color card, Color border, Color textPri, Color textSec) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),

          // Car hero mini
          Container(
            width: double.infinity, height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [cc.withOpacity(0.2), cc.withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(16)),
            child: Stack(children: [
              Center(child: Icon(Icons.directions_car_rounded, size: 70, color: cc.withOpacity(0.3))),
              Positioned(top: 10, left: 10, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: cc.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(car.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cc)))),
              Positioned(bottom: 10, right: 10, child: RichText(text: TextSpan(children: [
                TextSpan(text: '\$${car.price.toInt()}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.gold)),
                TextSpan(text: '/day', style: TextStyle(fontSize: 11, color: textSec)),
              ]))),
            ]),
          ),

          const SizedBox(height: 16),

          // Name + availability
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(car.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPri)),
              const SizedBox(height: 2),
              Text(widget.company.name, style: TextStyle(fontSize: 12, color: textSec)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: car.available ? const Color(0xFF1D9E75).withOpacity(0.12) : Colors.redAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    color: car.available ? const Color(0xFF1D9E75) : Colors.redAccent)),
                Text(car.available ? 'Available' : 'Unavailable',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: car.available ? const Color(0xFF1D9E75) : Colors.redAccent)),
              ]),
            ),
          ]),

          const SizedBox(height: 16),

          // Spec grid — 2 rows of 2
          Row(children: [
            _BriefSpec(icon: Icons.event_seat_outlined,        label: 'Seats',        value: '${car.seats}', cc: cc, textPri: textPri, textSec: textSec, isDark: isDark),
            const SizedBox(width: 10),
            _BriefSpec(icon: Icons.settings_outlined,          label: 'Transmission', value: car.transmission, cc: cc, textPri: textPri, textSec: textSec, isDark: isDark),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _BriefSpec(icon: Icons.local_gas_station_outlined, label: 'Fuel',         value: car.fuel,        cc: cc, textPri: textPri, textSec: textSec, isDark: isDark),
            const SizedBox(width: 10),
            _BriefSpec(icon: Icons.attach_money_rounded,       label: '3-day est.',   value: '\$${(car.price * 3).toInt()}', cc: cc, textPri: textPri, textSec: textSec, isDark: isDark),
          ]),

          const SizedBox(height: 16),

          // Key inclusions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _MiniInclusion(icon: Icons.health_and_safety_outlined, label: 'Insurance', cc: cc),
              _MiniInclusion(icon: Icons.map_outlined,               label: 'Mileage',   cc: cc),
              _MiniInclusion(icon: Icons.support_agent_outlined,     label: '24/7',      cc: cc),
              _MiniInclusion(icon: Icons.clean_hands_outlined,       label: 'Cleaned',   cc: cc),
            ]),
          ),

          const SizedBox(height: 16),

          // Close button
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: border),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('Close', style: TextStyle(color: textPri, fontSize: 14, fontWeight: FontWeight.w600)),
          )),
        ])),  // end SingleChildScrollView > Column
      ),
    );
  }

  void _detail(BuildContext context, CompanyCar car, bool isDark, Color card, Color border, Color textPri, Color textSec) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => _Detail(car: car, company: widget.company, isDark: isDark,
        card: card, border: border, textPri: textPri, textSec: textSec, cc: _cc(car.category)),
    );
  }

  String get _sortLabel {
    switch (_sort) {
      case 'price_asc':  return 'Price ↑';
      case 'price_desc': return 'Price ↓';
      case 'seats':      return 'Seats';
      default:           return 'Sort';
    }
  }

  void _showSort(BuildContext ctx, Color tp, Color ts, Color card, Color border) {
    showModalBottomSheet(
      context: ctx, backgroundColor: card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20,16,20,32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width:40,height:4,
            decoration:BoxDecoration(color:border,borderRadius:BorderRadius.circular(2)))),
          const SizedBox(height:14),
          Text('Sort By', style: TextStyle(fontSize:16, fontWeight:FontWeight.w700, color:tp)),
          const SizedBox(height:8),
          ...[
            ('price_asc',  Icons.arrow_upward_rounded,   'Price: Low to High'),
            ('price_desc', Icons.arrow_downward_rounded, 'Price: High to Low'),
            ('seats',      Icons.event_seat_outlined,    'Most Seats First'),
          ].map((s) => ListTile(
            leading: Icon(s.$2, color: _sort==s.$1 ? AppColors.gold : ts, size:20),
            title: Text(s.$3, style: TextStyle(fontSize:14, color:tp,
              fontWeight: _sort==s.$1 ? FontWeight.w700 : FontWeight.w400)),
            trailing: _sort==s.$1 ? const Icon(Icons.check_rounded, color:AppColors.gold, size:18) : null,
            onTap: () { setState(() => _sort=s.$1); Navigator.pop(ctx); },
            dense: true,
          )),
        ]),
      ),
    );
  }
}

// ── Stat box ──────────────────────────────────────────────────
class _SB extends StatelessWidget {
  final String v, l;
  const _SB({required this.v, required this.l});
  @override Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
    child: Column(children: [
      Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
      Text(l, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 9)),
    ]),
  ));
}

// ── Car card ──────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final CompanyCar car;
  final RentalCompany company;
  final bool isDark, isSelected, isSelecting;
  final Color card, border, textPri, textSec;
  final VoidCallback onTap, onLongPress, onSelect, onBook, onDetail;

  const _Card({
    required this.car, required this.company,
    required this.isDark, required this.card, required this.border,
    required this.textPri, required this.textSec,
    required this.isSelected, required this.isSelecting,
    required this.onTap, required this.onLongPress,
    required this.onSelect, required this.onBook, required this.onDetail,
  });

  Color get _c => _cc(car.category);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isSelected ? _c.withOpacity(0.08) : card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? _c : border,
            width: isSelected ? 2 : 0.5)),
        child: Column(children: [

          // Image banner
          Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [_c.withOpacity(0.18), _c.withOpacity(0.05)]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17))),
            child: Stack(children: [
              Center(child: Icon(Icons.directions_car_rounded, size: 90, color: _c.withOpacity(0.25))),

              // Selection checkbox
              Positioned(top: 10, left: 10, child: GestureDetector(
                onTap: car.available ? onSelect : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: isSelected ? _c : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? _c : Colors.white.withOpacity(0.5),
                      width: 1.5)),
                  child: isSelected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : null,
                ),
              )),

              // Category tag
              if (!isSelecting) Positioned(top: 10, left: 10, child: Container(
                padding: const EdgeInsets.symmetric(horizontal:10, vertical:4),
                decoration: BoxDecoration(color:_c.withOpacity(0.15), borderRadius:BorderRadius.circular(8)),
                child: Text(car.category, style:TextStyle(fontSize:10, fontWeight:FontWeight.w700, color:_c)))),

              // Availability
              Positioned(top:10, right:10, child: Container(
                padding: const EdgeInsets.symmetric(horizontal:10, vertical:4),
                decoration: BoxDecoration(
                  color: car.available ? const Color(0xFF1D9E75).withOpacity(0.15) : Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: car.available ? const Color(0xFF1D9E75).withOpacity(0.4) : Colors.redAccent.withOpacity(0.4),
                    width:0.8)),
                child: Row(mainAxisSize:MainAxisSize.min, children: [
                  Container(width:6, height:6, margin: const EdgeInsets.only(right:5),
                    decoration: BoxDecoration(shape:BoxShape.circle,
                      color: car.available ? const Color(0xFF1D9E75) : Colors.redAccent)),
                  Text(car.available ? 'Available' : 'Unavailable',
                    style:TextStyle(fontSize:11, fontWeight:FontWeight.w600,
                      color: car.available ? const Color(0xFF1D9E75) : Colors.redAccent)),
                ]))),

              // Price
              Positioned(bottom:10, right:10, child: Container(
                padding: const EdgeInsets.symmetric(horizontal:10, vertical:4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color:Colors.black.withOpacity(0.1), blurRadius:6)]),
                child: RichText(text: TextSpan(children: [
                  TextSpan(text:'\$${car.price.toInt()}',
                    style: const TextStyle(fontSize:15, fontWeight:FontWeight.w800, color:AppColors.gold)),
                  TextSpan(text:'/day', style:TextStyle(fontSize:10, color:textSec)),
                ])))),
            ]),
          ),

          // Info
          Padding(padding: const EdgeInsets.all(14), child:
            Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
                Text(car.name, style:TextStyle(fontSize:16, fontWeight:FontWeight.w800, color:textPri)),
                Text(company.name, style:TextStyle(fontSize:12, color:textSec)),
              ])),
              if (!isSelecting) GestureDetector(
                onTap: onDetail,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal:10, vertical:5),
                  decoration: BoxDecoration(
                    color:_c.withOpacity(0.08), borderRadius:BorderRadius.circular(8),
                    border:Border.all(color:_c.withOpacity(0.2), width:0.8)),
                  child: Text('Details', style:TextStyle(fontSize:11, fontWeight:FontWeight.w600, color:_c)))),
              if (isSelecting && isSelected) Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _c.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Text('Selected ✓',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _c))),
            ]),
            const SizedBox(height:10),
            Wrap(spacing:8, runSpacing:6, children: [
              _Spec(icon:Icons.event_seat_outlined,        label:'${car.seats} seats', textSec:textSec, isDark:isDark),
              _Spec(icon:Icons.settings_outlined,          label:car.transmission,     textSec:textSec, isDark:isDark),
              _Spec(icon:Icons.local_gas_station_outlined, label:car.fuel,             textSec:textSec, isDark:isDark),
            ]),
            if (!isSelecting) ...[
              const SizedBox(height:10),
              SizedBox(width:double.infinity, child: ElevatedButton(
                onPressed: car.available ? onBook : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:company.brandColor, disabledBackgroundColor:border,
                  foregroundColor:Colors.white, disabledForegroundColor:textSec,
                  padding: const EdgeInsets.symmetric(vertical:11),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),
                  elevation:0, textStyle: const TextStyle(fontSize:13, fontWeight:FontWeight.w700)),
                child: Text(car.available ? 'Book Now — \$${car.price.toInt()}/day' : 'Unavailable'),
              )),
            ] else ...[
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: OutlinedButton(
                onPressed: car.available ? onSelect : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isSelected ? _c : border, width: isSelected ? 2 : 1),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(
                  isSelected ? 'Remove from selection' : (car.available ? 'Add to selection' : 'Unavailable'),
                  style: TextStyle(color: isSelected ? _c : (car.available ? textPri : textSec),
                    fontSize: 13, fontWeight: FontWeight.w600)),
              )),
            ],
          ])),
        ]),
      ),
    );
  }
}

// ── Spec badge ────────────────────────────────────────────────
class _Spec extends StatelessWidget {
  final IconData icon; final String label; final Color textSec; final bool isDark;
  const _Spec({required this.icon, required this.label, required this.textSec, required this.isDark});
  @override Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.symmetric(horizontal:10, vertical:5),
    decoration: BoxDecoration(color: isDark ? AppColors.darkSurface : AppColors.lightSurface, borderRadius:BorderRadius.circular(8)),
    child: Row(mainAxisSize:MainAxisSize.min, children: [
      Icon(icon, size:12, color:textSec), const SizedBox(width:5),
      Text(label, style:TextStyle(fontSize:11, color:textSec, fontWeight:FontWeight.w500)),
    ]));
}

// ── Detail sheet ──────────────────────────────────────────────
class _Detail extends StatelessWidget {
  final CompanyCar car; final RentalCompany company;
  final bool isDark; final Color card, border, textPri, textSec, cc;
  const _Detail({required this.car, required this.company, required this.isDark,
    required this.card, required this.border, required this.textPri, required this.textSec, required this.cc});

  @override Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize:0.9, minChildSize:0.5, maxChildSize:0.97,
      builder:(_,ctrl)=>Container(
        decoration:BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
          borderRadius: const BorderRadius.vertical(top:Radius.circular(26))),
        child:Column(children:[
          Container(margin: const EdgeInsets.only(top:12,bottom:4), width:40, height:4,
            decoration:BoxDecoration(color:border,borderRadius:BorderRadius.circular(2))),
          Expanded(child:ListView(controller:ctrl,children:[
            // Hero
            Container(height:200,
              decoration:BoxDecoration(gradient:LinearGradient(
                begin:Alignment.topLeft,end:Alignment.bottomRight,
                colors:[cc,cc.withOpacity(0.5)])),
              child:Stack(children:[
                Center(child:Icon(Icons.directions_car_rounded,size:150,color:Colors.white.withOpacity(0.07))),
                Padding(padding:const EdgeInsets.all(20),child:Column(
                  mainAxisAlignment:MainAxisAlignment.end,crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
                    decoration:BoxDecoration(color:Colors.white.withOpacity(0.18),borderRadius:BorderRadius.circular(8)),
                    child:Text(car.category,style:const TextStyle(color:Colors.white,fontSize:11,fontWeight:FontWeight.w700))),
                  const SizedBox(height:8),
                  Text(car.name,style:const TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.w800)),
                  Text(company.name,style:TextStyle(color:Colors.white.withOpacity(0.7),fontSize:13)),
                ])),
                Positioned(top:16,right:16,child:Container(
                  padding:const EdgeInsets.symmetric(horizontal:12,vertical:6),
                  decoration:BoxDecoration(color:Colors.white.withOpacity(0.18),borderRadius:BorderRadius.circular(20),
                    border:Border.all(color:Colors.white.withOpacity(0.3),width:0.8)),
                  child:Row(mainAxisSize:MainAxisSize.min,children:[
                    Container(width:7,height:7,margin:const EdgeInsets.only(right:6),
                      decoration:BoxDecoration(shape:BoxShape.circle,
                        color:car.available?const Color(0xFF1D9E75):Colors.redAccent)),
                    Text(car.available?'Available':'Unavailable',
                      style:const TextStyle(color:Colors.white,fontSize:12,fontWeight:FontWeight.w600)),
                  ]))),
              ])),
            Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Row(children:[
                Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Text('Daily rate',style:TextStyle(fontSize:11,color:textSec)),
                  RichText(text:TextSpan(children:[
                    TextSpan(text:'\$${car.price.toInt()}',style:const TextStyle(fontSize:32,fontWeight:FontWeight.w800,color:AppColors.gold)),
                    TextSpan(text:' /day',style:TextStyle(fontSize:13,color:textSec)),
                  ])),
                ]),
                const Spacer(),
                Container(padding:const EdgeInsets.all(12),
                  decoration:BoxDecoration(color:company.brandColor.withOpacity(0.1),borderRadius:BorderRadius.circular(14),
                    border:Border.all(color:company.brandColor.withOpacity(0.2),width:0.8)),
                  child:Column(children:[
                    Text(company.initials,style:TextStyle(fontSize:16,fontWeight:FontWeight.w800,color:company.brandColor)),
                    Row(children:[const Icon(Icons.star,color:AppColors.gold,size:11),const SizedBox(width:2),
                      Text('${company.rating}',style:TextStyle(fontSize:10,color:textSec))]),
                  ])),
              ]),
              const SizedBox(height:20),
              Text('Specifications',style:TextStyle(fontSize:15,fontWeight:FontWeight.w700,color:textPri)),
              const SizedBox(height:12),
              GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),
                crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:2.6,
                children:[
                  _ST2(icon:Icons.event_seat_outlined,        l:'Seats',        v:'${car.seats} seats',cc:cc,d:isDark,tp:textPri,ts:textSec),
                  _ST2(icon:Icons.settings_outlined,          l:'Transmission', v:car.transmission,    cc:cc,d:isDark,tp:textPri,ts:textSec),
                  _ST2(icon:Icons.local_gas_station_outlined, l:'Fuel',         v:car.fuel,            cc:cc,d:isDark,tp:textPri,ts:textSec),
                  _ST2(icon:Icons.category_outlined,          l:'Class',        v:car.category,        cc:cc,d:isDark,tp:textPri,ts:textSec),
                ]),
              const SizedBox(height:20),
              Text("What's Included",style:TextStyle(fontSize:15,fontWeight:FontWeight.w700,color:textPri)),
              const SizedBox(height:12),
              ...[
                (Icons.health_and_safety_outlined,'Basic Insurance','CDW included'),
                (Icons.clean_hands_outlined,'Pre-cleaned Vehicle','Sanitised before pickup'),
                (Icons.support_agent_outlined,'24/7 Support','Roadside assistance'),
                (Icons.local_gas_station_outlined,'Full-to-Full Fuel','Return same level'),
                (Icons.map_outlined,'Unlimited Mileage','Within Rwanda'),
              ].map((i)=>Container(
                margin:const EdgeInsets.only(bottom:10),
                padding:const EdgeInsets.all(12),
                decoration:BoxDecoration(color:card,borderRadius:BorderRadius.circular(12),
                  border:Border.all(color:border,width:0.5)),
                child:Row(children:[
                  Container(width:36,height:36,
                    decoration:BoxDecoration(color:cc.withOpacity(0.1),borderRadius:BorderRadius.circular(9)),
                    child:Icon(i.$1,color:cc,size:17)),
                  const SizedBox(width:12),
                  Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                    Text(i.$2,style:TextStyle(fontSize:13,fontWeight:FontWeight.w600,color:textPri)),
                    Text(i.$3,style:TextStyle(fontSize:11,color:textSec)),
                  ])),
                  const Icon(Icons.check_circle_rounded,color:Color(0xFF1D9E75),size:18),
                ])),
              ),
              const SizedBox(height:20),
              Text('Cost Estimator',style:TextStyle(fontSize:15,fontWeight:FontWeight.w700,color:textPri)),
              const SizedBox(height:12),
              Container(
                padding:const EdgeInsets.all(14),
                decoration:BoxDecoration(color:AppColors.gold.withOpacity(0.06),borderRadius:BorderRadius.circular(14),
                  border:Border.all(color:AppColors.gold.withOpacity(0.2),width:0.8)),
                child:Column(children:[
                  _CR(l:'1 day',a:car.price*1,tp:textPri,ts:textSec),
                  Divider(color:AppColors.gold.withOpacity(0.15),height:16),
                  _CR(l:'3 days',a:car.price*3,tp:textPri,ts:textSec),
                  Divider(color:AppColors.gold.withOpacity(0.15),height:16),
                  _CR(l:'7 days',a:car.price*7,tp:textPri,ts:textSec),
                  Divider(color:AppColors.gold.withOpacity(0.15),height:16),
                  _CR(l:'30 days',a:car.price*30,tp:textPri,ts:textSec,hi:true),
                ])),
              const SizedBox(height:24),
              SizedBox(width:double.infinity,child:ElevatedButton.icon(
                onPressed:car.available?(){
                  Navigator.pop(context);
                  if(!AuthService.isLoggedIn){
                    AuthService.setPending('/user/booking',args:{
                      'carName':car.name,'company':company.name,
                      'price':'\$${car.price.toInt()}','category':car.category,
                      'seats':car.seats,'fuel':car.fuel,'transmission':car.transmission,
                    });
                    Navigator.pushNamed(context,'/login');return;
                  }
                  Navigator.push(context,MaterialPageRoute(builder:(_)=>BookingScreen(
                    carName:car.name,company:company.name,price:'\$${car.price.toInt()}',
                    category:car.category,seats:car.seats,fuel:car.fuel,transmission:car.transmission)));
                }:null,
                icon:const Icon(Icons.calendar_today_outlined,size:18),
                label:Text(car.available?'Book — \$${car.price.toInt()}/day':'Unavailable'),
                style:ElevatedButton.styleFrom(
                  backgroundColor:company.brandColor,
                  disabledBackgroundColor:isDark?AppColors.darkSurface:AppColors.lightSurface,
                  disabledForegroundColor:textSec,foregroundColor:Colors.white,
                  padding:const EdgeInsets.symmetric(vertical:16),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),
                  elevation:0,textStyle:const TextStyle(fontSize:15,fontWeight:FontWeight.w700)),
              )),
              const SizedBox(height:8),
            ])),
          ])),
        ]),
      ),
    );
  }
}

class _ST2 extends StatelessWidget {
  final IconData icon;final String l,v;final Color cc,tp,ts;final bool d;
  const _ST2({required this.icon,required this.l,required this.v,required this.cc,required this.d,required this.tp,required this.ts});
  @override Widget build(BuildContext c)=>Container(
    padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),
    decoration:BoxDecoration(color:d?AppColors.darkCard:AppColors.lightCard,borderRadius:BorderRadius.circular(12),
      border:Border.all(color:d?AppColors.darkBorder:const Color(0xFFDDE1EE),width:0.5)),
    child:Row(children:[Icon(icon,color:cc,size:16),const SizedBox(width:8),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[
        Text(l,style:TextStyle(fontSize:9,color:ts)),
        Text(v,style:TextStyle(fontSize:12,fontWeight:FontWeight.w700,color:tp),overflow:TextOverflow.ellipsis),
      ])),
    ]));
}

class _CR extends StatelessWidget {
  final String l;final double a;final Color tp,ts;final bool hi;
  const _CR({required this.l,required this.a,required this.tp,required this.ts,this.hi=false});
  @override Widget build(BuildContext c)=>Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
    Text(l,style:TextStyle(fontSize:13,color:hi?AppColors.gold:ts,fontWeight:hi?FontWeight.w700:FontWeight.w400)),
    Text('\$${a.toInt()}',style:TextStyle(fontSize:14,fontWeight:FontWeight.w700,color:hi?AppColors.gold:tp)),
  ]);
}

// ── Brief spec tile ───────────────────────────────────────────
class _BriefSpec extends StatelessWidget {
  final IconData icon; final String label, value;
  final Color cc, textPri, textSec; final bool isDark;
  const _BriefSpec({required this.icon, required this.label, required this.value,
    required this.cc, required this.textPri, required this.textSec, required this.isDark});
  @override Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(icon, color: cc, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 9, color: textSec)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri),
          overflow: TextOverflow.ellipsis),
      ])),
    ]),
  ));
}

// ── Mini inclusion icon ───────────────────────────────────────
class _MiniInclusion extends StatelessWidget {
  final IconData icon; final String label; final Color cc;
  const _MiniInclusion({required this.icon, required this.label, required this.cc});
  @override Widget build(BuildContext context) => Column(children: [
    Container(width: 34, height: 34,
      decoration: BoxDecoration(color: cc.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, color: cc, size: 16)),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(fontSize: 9, color: AppColors.gold, fontWeight: FontWeight.w600)),
  ]);
}
