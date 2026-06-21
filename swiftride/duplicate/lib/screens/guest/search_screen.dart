import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/screens/guest/car_detail_screen.dart';
import 'package:swiftride/screens/guest/app_shell.dart';
import 'package:swiftride/screens/guest/shared_drawer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(20, 200);
  String _selectedSort = 'Popular';

  final List<String> _categories = ['All', 'Economy', 'SUV', 'Luxury', 'Van', 'Sedan'];
  final List<String> _sortOptions = ['Popular', 'Price: Low', 'Price: High', 'Rating'];

  final List<_SearchCar> _allCars = [
    _SearchCar(name: 'Toyota RAV4',    company: 'DriveKigali',  price: 60,  seats: 5, fuel: 'Petrol', trans: 'Auto',   rating: 4.9, category: 'SUV',     reviews: 38),
    _SearchCar(name: 'Toyota Camry',   company: 'DriveKigali',  price: 45,  seats: 5, fuel: 'Petrol', trans: 'Auto',   rating: 4.7, category: 'Sedan',   reviews: 24),
    _SearchCar(name: 'BMW 5 Series',   company: 'SafariWheels', price: 90,  seats: 5, fuel: 'Petrol', trans: 'Auto',   rating: 4.8, category: 'Luxury',  reviews: 19),
    _SearchCar(name: 'Mercedes C',     company: 'LuxDrive',     price: 95,  seats: 5, fuel: 'Diesel', trans: 'Auto',   rating: 4.9, category: 'Luxury',  reviews: 31),
    _SearchCar(name: 'Honda CR-V',     company: 'RwandaRide',   price: 55,  seats: 5, fuel: 'Petrol', trans: 'Auto',   rating: 4.6, category: 'SUV',     reviews: 16),
    _SearchCar(name: 'Toyota Hiace',   company: 'VanGo',        price: 70,  seats: 12,fuel: 'Diesel', trans: 'Manual', rating: 4.5, category: 'Van',     reviews: 12),
    _SearchCar(name: 'Volkswagen Golf',company: 'DriveKigali',  price: 38,  seats: 5, fuel: 'Petrol', trans: 'Manual', rating: 4.4, category: 'Economy', reviews: 20),
    _SearchCar(name: 'Hyundai Tucson', company: 'SafariWheels', price: 58,  seats: 5, fuel: 'Petrol', trans: 'Auto',   rating: 4.6, category: 'SUV',     reviews: 14),
  ];

  List<_SearchCar> get _filtered {
    var list = _allCars.where((c) {
      final matchCat = _selectedCategory == 'All' || c.category == _selectedCategory;
      final matchPrice = c.price >= _priceRange.start && c.price <= _priceRange.end;
      final matchQuery = _searchCtrl.text.isEmpty ||
          c.name.toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
          c.company.toLowerCase().contains(_searchCtrl.text.toLowerCase());
      return matchCat && matchPrice && matchQuery;
    }).toList();

    switch (_selectedSort) {
      case 'Price: Low':  list.sort((a, b) => a.price.compareTo(b.price)); break;
      case 'Price: High': list.sort((a, b) => b.price.compareTo(a.price)); break;
      case 'Rating':      list.sort((a, b) => b.rating.compareTo(a.rating)); break;
      default:            list.sort((a, b) => b.reviews.compareTo(a.reviews));
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg      : AppColors.lightBg;
    final card    = isDark ? AppColors.darkCard    : AppColors.lightCard;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border  = isDark ? AppColors.darkBorder  : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white          : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    final results = _filtered;

    return Scaffold(
      backgroundColor: bg,
      drawer: const AppDrawer(activeTab: 0),
      bottomNavigationBar: AppBottomNav(activeIndex: 0),
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textPri, size: 20), onPressed: () => Navigator.of(context).maybePop()),
        titleSpacing: 20,
        title: Text('Search Cars', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _SortButton(
              selected: _selectedSort,
              options: _sortOptions,
              textPri: textPri,
              textSec: textSec,
              card: card,
              border: border,
              onChanged: (v) => setState(() => _selectedSort = v),
            ),
          ),
        ],
      ),
      body: Column(children: [

        // ── Search bar ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: textPri, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by car or company…',
              hintStyle: TextStyle(color: textSec, fontSize: 13),
              prefixIcon: Icon(Icons.search, color: textSec, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(icon: Icon(Icons.close, color: textSec, size: 18), onPressed: () => setState(() => _searchCtrl.clear()))
                  : null,
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border, width: 0.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: const Color(0xFFD4A017), width: 1)),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        // ── Category chips ──
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final selected = _categories[i] == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = _categories[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFD4A017) : surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? const Color(0xFFD4A017) : border, width: 0.5),
                  ),
                  child: Text(_categories[i],
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: selected ? Colors.black : textSec,
                      )),
                ),
              );
            },
          ),
        ),

        // ── Price range ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(children: [
            Text('Price: ', style: TextStyle(fontSize: 12, color: textSec)),
            Text('\$${_priceRange.start.round()} – \$${_priceRange.end.round()}/day',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFD4A017))),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: const Color(0xFFD4A017),
                  inactiveTrackColor: border,
                  thumbColor: const Color(0xFFD4A017),
                  overlayColor: const Color(0xFFD4A017).withOpacity(0.1),
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                ),
                child: RangeSlider(
                  values: _priceRange,
                  min: 20, max: 200,
                  onChanged: (v) => setState(() => _priceRange = v),
                ),
              ),
            ),
          ]),
        ),

        // ── Results count ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Row(children: [
            Text('${results.length} cars found', style: TextStyle(fontSize: 12, color: textSec)),
          ]),
        ),

        // ── Results list ──
        Expanded(
          child: results.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.search_off, size: 48, color: textSec),
                  const SizedBox(height: 12),
                  Text('No cars found', style: TextStyle(color: textSec, fontSize: 15)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _SearchCarCard(
                    car: results[i], isDark: isDark,
                    card: card, border: border, textPri: textPri, textSec: textSec,
                  ),
                ),
        ),
      ]),
    );
  }
}

// ── Sort button ───────────────────────────────────────────────────────────────
class _SortButton extends StatelessWidget {
  final String selected;
  final List<String> options;
  final Color textPri, textSec, card, border;
  final ValueChanged<String> onChanged;
  const _SortButton({required this.selected, required this.options, required this.textPri, required this.textSec, required this.card, required this.border, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: card,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (_) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Sort by', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 12),
              ...options.map((o) => ListTile(
                title: Text(o, style: TextStyle(fontSize: 14, color: textPri)),
                trailing: o == selected ? const Icon(Icons.check, color: const Color(0xFFD4A017), size: 18) : null,
                onTap: () => Navigator.pop(context, o),
                dense: true,
              )),
            ]),
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFD4A017).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.3), width: 0.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.sort, color: const Color(0xFFD4A017), size: 16),
          const SizedBox(width: 5),
          Text(selected, style: const TextStyle(fontSize: 12, color: const Color(0xFFD4A017), fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ── Search result car card ────────────────────────────────────────────────────
class _SearchCarCard extends StatefulWidget {
  final _SearchCar car;
  final bool isDark;
  final Color card, border, textPri, textSec;
  const _SearchCarCard({required this.car, required this.isDark, required this.card, required this.border, required this.textPri, required this.textSec});
  @override
  State<_SearchCarCard> createState() => _SearchCarCardState();
}

class _SearchCarCardState extends State<_SearchCarCard> {
  bool _fav = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.car;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => CarDetailScreen(
          carName: c.name, company: c.company,
          price: '\$${c.price.round()}', category: c.category,
          rating: c.rating, reviews: c.reviews,
          seats: c.seats, fuel: c.fuel, transmission: c.trans,
        ),
      )),
      child: Container(
      decoration: BoxDecoration(
        color: widget.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.border, width: 0.5),
      ),
      child: Row(children: [
        // Car image area
        Container(
          width: 110, height: 100,
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
          ),
          child: Stack(children: [
            Center(child: Icon(Icons.directions_car, size: 56, color: widget.isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.05))),
            Positioned(top: 8, left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(c.category, style: const TextStyle(fontSize: 9, color: const Color(0xFFD4A017), fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
        // Details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(c.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.textPri), overflow: TextOverflow.ellipsis)),
                GestureDetector(
                  onTap: () => setState(() => _fav = !_fav),
                  child: Icon(_fav ? Icons.favorite : Icons.favorite_outline,
                      color: _fav ? Colors.redAccent : widget.textSec, size: 18),
                ),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.business_outlined, size: 11, color: widget.textSec),
                const SizedBox(width: 3),
                Text(c.company, style: TextStyle(fontSize: 11, color: widget.textSec)),
                const SizedBox(width: 8),
                Icon(Icons.star, size: 11, color: const Color(0xFFD4A017)),
                const SizedBox(width: 2),
                Text(c.rating.toStringAsFixed(1), style: TextStyle(fontSize: 11, color: widget.textSec)),
                Text(' (${c.reviews})', style: TextStyle(fontSize: 10, color: widget.textSec)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _Spec(icon: Icons.people_outline,          label: '${c.seats}', textSec: widget.textSec),
                const SizedBox(width: 10),
                _Spec(icon: Icons.settings_outlined,       label: c.trans,      textSec: widget.textSec),
                const SizedBox(width: 10),
                _Spec(icon: Icons.local_gas_station_outlined, label: c.fuel,   textSec: widget.textSec),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                RichText(text: TextSpan(children: [
                  TextSpan(text: '\$${c.price}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFFD4A017))),
                  TextSpan(text: '/day', style: TextStyle(fontSize: 11, color: widget.textSec)),
                ])),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CarDetailScreen(
                      carName: c.name, company: c.company,
                      price: '\$${c.price.round()}', category: c.category,
                      rating: c.rating, reviews: c.reviews,
                      seats: c.seats, fuel: c.fuel, transmission: c.trans,
                    ),
                  )),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFD4A017), borderRadius: BorderRadius.circular(8)),
                    child: const Text('Book', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ]),
    ));
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color textSec;
  const _Spec({required this.icon, required this.label, required this.textSec});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: textSec),
    const SizedBox(width: 3),
    Text(label, style: TextStyle(fontSize: 11, color: textSec)),
  ]);
}

class _SearchCar {
  final String name, company, fuel, trans, category;
  final double price, rating;
  final int seats, reviews;
  const _SearchCar({required this.name, required this.company, required this.price, required this.seats, required this.fuel, required this.trans, required this.rating, required this.category, required this.reviews});
}
