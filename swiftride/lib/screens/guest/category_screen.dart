import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/screens/guest/car_detail_screen.dart';
import 'package:swiftride/screens/guest/app_shell.dart';
import 'package:swiftride/screens/guest/shared_drawer.dart';

// ── All cars data (shared source of truth) ────────────────────────────────────
final List<_CatCar> allCategoryCars = [
  _CatCar(name: 'Volkswagen Golf',   company: 'DriveKigali',  price: 38,  seats: 5,  fuel: 'Petrol', trans: 'Manual', rating: 4.4, category: 'Economy', reviews: 20),
  _CatCar(name: 'Toyota Corolla',    company: 'RwandaRide',   price: 32,  seats: 5,  fuel: 'Petrol', trans: 'Auto',   rating: 4.5, category: 'Economy', reviews: 17),
  _CatCar(name: 'Hyundai i10',       company: 'DriveKigali',  price: 30,  seats: 5,  fuel: 'Petrol', trans: 'Manual', rating: 4.3, category: 'Economy', reviews: 11),
  _CatCar(name: 'Toyota RAV4',       company: 'DriveKigali',  price: 60,  seats: 5,  fuel: 'Petrol', trans: 'Auto',   rating: 4.9, category: 'SUV',     reviews: 38),
  _CatCar(name: 'Honda CR-V',        company: 'RwandaRide',   price: 55,  seats: 5,  fuel: 'Petrol', trans: 'Auto',   rating: 4.6, category: 'SUV',     reviews: 16),
  _CatCar(name: 'Hyundai Tucson',    company: 'SafariWheels', price: 58,  seats: 5,  fuel: 'Petrol', trans: 'Auto',   rating: 4.6, category: 'SUV',     reviews: 14),
  _CatCar(name: 'Mitsubishi Pajero', company: 'SafariWheels', price: 65,  seats: 7,  fuel: 'Diesel', trans: 'Auto',   rating: 4.7, category: 'SUV',     reviews: 22),
  _CatCar(name: 'BMW 5 Series',      company: 'SafariWheels', price: 90,  seats: 5,  fuel: 'Petrol', trans: 'Auto',   rating: 4.8, category: 'Luxury',  reviews: 19),
  _CatCar(name: 'Mercedes C-Class',  company: 'LuxDrive',     price: 95,  seats: 5,  fuel: 'Diesel', trans: 'Auto',   rating: 4.9, category: 'Luxury',  reviews: 31),
  _CatCar(name: 'Audi A6',           company: 'LuxDrive',     price: 100, seats: 5,  fuel: 'Petrol', trans: 'Auto',   rating: 4.8, category: 'Luxury',  reviews: 15),
  _CatCar(name: 'Lexus RX',          company: 'LuxDrive',     price: 110, seats: 5,  fuel: 'Hybrid', trans: 'Auto',   rating: 5.0, category: 'Luxury',  reviews: 9),
  _CatCar(name: 'Toyota Hiace',      company: 'VanGo',        price: 70,  seats: 12, fuel: 'Diesel', trans: 'Manual', rating: 4.5, category: 'Van',     reviews: 12),
  _CatCar(name: 'Mercedes Sprinter', company: 'VanGo',        price: 85,  seats: 15, fuel: 'Diesel', trans: 'Manual', rating: 4.6, category: 'Van',     reviews: 8),
  _CatCar(name: 'Ford Transit',      company: 'RwandaRide',   price: 75,  seats: 12, fuel: 'Diesel', trans: 'Manual', rating: 4.4, category: 'Van',     reviews: 10),
];

class _CatCar {
  final String name, company, fuel, trans, category;
  final double price, rating;
  final int seats, reviews;
  bool isFav;
  _CatCar({required this.name, required this.company, required this.price,
    required this.seats, required this.fuel, required this.trans,
    required this.rating, required this.category, required this.reviews,
    this.isFav = false});
}

// ── Deal definitions ──────────────────────────────────────────────────────────
class DealInfo {
  final String label;      // short badge text, e.g. "20% OFF"
  final String headline;   // e.g. "20% off this weekend"
  final String subtitle;   // e.g. "Discount applied at checkout"
  final Color color;
  final IconData icon;
  final String? discountText; // shown on each card, e.g. "Save 20%"
  const DealInfo({
    required this.label, required this.headline, required this.subtitle,
    required this.color, required this.icon, this.discountText,
  });
}

// Map: category → DealInfo  (null = no active deal for that category)
const Map<String, DealInfo> categoryDeals = {
  'Economy': DealInfo(
    label: '20% OFF',
    headline: '20% off Economy cars this weekend',
    subtitle: 'Book any Economy car and save 20% — valid Fri–Sun only.',
    color: Color(0xFF1D9E75),
    icon: Icons.local_offer_outlined,
    discountText: 'Save 20%',
  ),
  'SUV': DealInfo(
    label: 'FREE GPS',
    headline: 'Free GPS on all SUV bookings today',
    subtitle: 'Every SUV booking today includes a complimentary GPS unit.',
    color: Color(0xFF3B5FD4),
    icon: Icons.gps_fixed,
    discountText: 'Free GPS',
  ),
  'Luxury': DealInfo(
    label: 'CHAUFFEUR',
    headline: 'Free chauffeur with Luxury rides',
    subtitle: 'Book any Luxury car and get a professional driver at no extra cost.',
    color: Color(0xFF7F77DD),
    icon: Icons.drive_eta_outlined,
    discountText: 'Free Driver',
  ),
  'Van': DealInfo(
    label: 'GROUP DEAL',
    headline: 'Special group deal for vans & minibuses',
    subtitle: 'Hire a van for 8+ passengers and get 15% off the total price.',
    color: Color(0xFFD85A30),
    icon: Icons.group_outlined,
    discountText: 'Save 15%',
  ),
};

// ═══════════════════════════════════════════════════════════════
//  CATEGORY SCREEN
// ═══════════════════════════════════════════════════════════════
class CategoryScreen extends StatefulWidget {
  final String? initialCategory;
  final bool fromDeal; // true when opened via a deal card

  const CategoryScreen({
    super.key,
    this.initialCategory,
    this.fromDeal = false,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late String _selected;
  final _cats = ['All', 'Economy', 'SUV', 'Luxury', 'Van'];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialCategory ?? 'All';
  }

  List<_CatCar> get _filtered => _selected == 'All'
      ? allCategoryCars
      : allCategoryCars.where((c) => c.category == _selected).toList();

  DealInfo? get _activeDeal =>
      widget.fromDeal ? categoryDeals[_selected] : null;

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'Economy': return Icons.directions_car;
      case 'SUV':     return Icons.airport_shuttle;
      case 'Luxury':  return Icons.star_outline;
      case 'Van':     return Icons.local_shipping_outlined;
      default:        return Icons.grid_view;
    }
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'Economy': return const Color(0xFF1D9E75);
      case 'SUV':     return const Color(0xFF3B5FD4);
      case 'Luxury':  return const Color(0xFF7F77DD);
      case 'Van':     return const Color(0xFFD85A30);
      default:        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg      : AppColors.lightBg;
    final card    = isDark ? AppColors.darkCard    : AppColors.lightCard;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border  = isDark ? AppColors.darkBorder  : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white           : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    final results = _filtered;
    final deal    = _activeDeal;

    return Scaffold(
      backgroundColor: bg,
      drawer: const AppDrawer(activeTab: 0),
      bottomNavigationBar: AppBottomNav(activeIndex: 0),
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPri, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selected == 'All' ? 'All Cars' : '$_selected Cars',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.tune, color: textPri, size: 20),
          ),
        ],
      ),
      body: Column(children: [

        // ── Deal banner (only when opened from a deal card) ──────
        if (deal != null)
          _DealBanner(deal: deal),

        // ── Category chip bar ────────────────────────────────────
        SizedBox(
          height: 50,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            scrollDirection: Axis.horizontal,
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat    = _cats[i];
              final active = _selected == cat;
              final color  = _catColor(cat);
              return GestureDetector(
                onTap: () => setState(() => _selected = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? color : surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? color : border, width: active ? 1.5 : 0.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_catIcon(cat), size: 14,
                        color: active ? Colors.white : textSec),
                    const SizedBox(width: 5),
                    Text(cat, style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: active ? Colors.white : textSec,
                    )),
                  ]),
                ),
              );
            },
          ),
        ),

        // ── Result count ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
          child: Row(children: [
            Text('${results.length} cars available',
                style: TextStyle(fontSize: 12, color: textSec)),
            if (deal != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: deal.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(deal.icon, size: 10, color: deal.color),
                  const SizedBox(width: 4),
                  Text(deal.label,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                          color: deal.color)),
                ]),
              ),
            ],
          ]),
        ),

        // ── Car list ─────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final c         = results[i];
              final cardDeal  = widget.fromDeal ? categoryDeals[c.category] : null;
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CarDetailScreen(
                    carName:      c.name,
                    company:      c.company,
                    price:        '\$${c.price.round()}',
                    category:     c.category,
                    rating:       c.rating,
                    reviews:      c.reviews,
                    seats:        c.seats,
                    fuel:         c.fuel,
                    transmission: c.trans,
                  ),
                )),
                child: Container(
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: cardDeal != null
                          ? cardDeal.color.withOpacity(0.4)
                          : border,
                      width: cardDeal != null ? 1.2 : 0.5,
                    ),
                  ),
                  child: Row(children: [

                    // ── Left image area ──
                    Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(
                        color: _catColor(c.category).withOpacity(0.08),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                        ),
                      ),
                      child: Stack(children: [
                        Center(child: Icon(
                          _catIcon(c.category), size: 52,
                          color: _catColor(c.category).withOpacity(0.25),
                        )),

                        // Category chip
                        Positioned(top: 8, left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _catColor(c.category).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(c.category,
                                style: TextStyle(fontSize: 9,
                                    color: _catColor(c.category),
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),

                        // Deal badge on image (bottom-left)
                        if (cardDeal != null)
                          Positioned(bottom: 8, left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: cardDeal.color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(cardDeal.icon, size: 9, color: Colors.white),
                                const SizedBox(width: 3),
                                Text(cardDeal.discountText ?? cardDeal.label,
                                    style: const TextStyle(
                                        fontSize: 8, fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                              ]),
                            ),
                          ),
                      ]),
                    ),

                    // ── Right details ──
                    Expanded(child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Row(children: [
                          Expanded(child: Text(c.name,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                                  color: textPri),
                              overflow: TextOverflow.ellipsis)),
                          GestureDetector(
                            onTap: () => setState(() => c.isFav = !c.isFav),
                            child: Icon(
                              c.isFav ? Icons.favorite : Icons.favorite_outline,
                              color: c.isFav ? Colors.redAccent : textSec, size: 18,
                            ),
                          ),
                        ]),

                        const SizedBox(height: 2),
                        Row(children: [
                          Icon(Icons.business_outlined, size: 11, color: textSec),
                          const SizedBox(width: 3),
                          Text(c.company, style: TextStyle(fontSize: 11, color: textSec)),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, size: 11, color: AppColors.gold),
                          const SizedBox(width: 2),
                          Text(c.rating.toStringAsFixed(1),
                              style: TextStyle(fontSize: 11, color: textSec)),
                          Text(' (${c.reviews})',
                              style: TextStyle(fontSize: 10, color: textSec)),
                        ]),

                        const SizedBox(height: 8),
                        Row(children: [
                          _Chip(icon: Icons.people_outline,
                              label: '${c.seats}', textSec: textSec),
                          const SizedBox(width: 8),
                          _Chip(icon: Icons.settings_outlined,
                              label: c.trans, textSec: textSec),
                          const SizedBox(width: 8),
                          _Chip(icon: Icons.local_gas_station_outlined,
                              label: c.fuel, textSec: textSec),
                        ]),

                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          // Price with strikethrough if there's a discount
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            if (cardDeal != null && c.category == 'Economy')
                              Text(
                                '\$${c.price.round()}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSec,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            RichText(text: TextSpan(children: [
                              TextSpan(
                                text: cardDeal != null && c.category == 'Economy'
                                    ? '\$${(c.price * 0.8).round()}'
                                    : '\$${c.price.round()}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700,
                                    color: AppColors.gold)),
                              TextSpan(text: '/day',
                                  style: TextStyle(fontSize: 11, color: textSec)),
                            ])),
                          ]),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: cardDeal != null
                                  ? cardDeal.color
                                  : AppColors.gold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Book',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        ]),
                      ]),
                    )),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ── Deal banner widget ────────────────────────────────────────────────────────
class _DealBanner extends StatelessWidget {
  final DealInfo deal;
  const _DealBanner({required this.deal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: deal.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: deal.color.withOpacity(0.35), width: 1),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: deal.color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(deal.icon, color: deal.color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: deal.color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(deal.label,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(deal.headline,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: deal.color),
                overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 4),
          Text(deal.subtitle,
              style: TextStyle(
                  fontSize: 11,
                  color: deal.color.withOpacity(0.8),
                  height: 1.4)),
        ])),
      ]),
    );
  }
}

// ── Chip ──────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final IconData icon; final String label; final Color textSec;
  const _Chip({required this.icon, required this.label, required this.textSec});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: textSec),
    const SizedBox(width: 3),
    Text(label, style: TextStyle(fontSize: 11, color: textSec)),
  ]);
}
