// lib/screens/user/user_search_tab.dart
import 'package:flutter/material.dart';
import 'package:swiftride/utils/constants.dart' show kNavy, kNavy2, kGold, kGoldL, kSurf, kSurf2, kText, kTextS, kError, kSuccess, kWarn, AppColors, kAllCars, kCategories, kPickupLocations;

class UserSearchTab extends StatefulWidget {
  const UserSearchTab({super.key});
  @override
  State<UserSearchTab> createState() => _UserSearchTabState();
}

class _UserSearchTabState extends State<UserSearchTab> {
  final _ctrl = TextEditingController();
  String _selCat = 'All';
  RangeValues _price = const RangeValues(0, 250);
  List<Map<String, dynamic>> _results = kAllCars;

  void _filter() => setState(() {
    _results = kAllCars.where((c) {
      final q = _ctrl.text.toLowerCase();
      final matchQ = q.isEmpty ||
          (c['name'] as String).toLowerCase().contains(q) ||
          (c['brand'] as String).toLowerCase().contains(q);
      final matchCat = _selCat == 'All' || c['category'] == _selCat;
      final matchP   = (c['price'] as int) >= _price.start && (c['price'] as int) <= _price.end;
      return matchQ && matchCat && matchP;
    }).toList();
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 52),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: TextField(
          controller: _ctrl,
          onChanged: (_) => _filter(),
          style: const TextStyle(color: kText),
          decoration: InputDecoration(
            hintText: 'Search cars, brands…',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _ctrl.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear_rounded, color: kTextS),
                    onPressed: () { _ctrl.clear(); _filter(); })
                : null,
          ),
        ),
      ),
      SizedBox(height: 44, child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: kCategories.map((cat) {
          final sel = _selCat == cat;
          return GestureDetector(
            onTap: () { setState(() => _selCat = cat); _filter(); },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: sel ? kGold : kSurf2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(child: Text(cat,
                style: TextStyle(color: sel ? Colors.black : kTextS,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500, fontSize: 12))),
            ),
          );
        }).toList(),
      )),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Text('\$${_price.start.round()} – \$${_price.end.round()}/day',
            style: const TextStyle(color: kTextS, fontSize: 12)),
          Expanded(child: RangeSlider(
            values: _price, min: 0, max: 250,
            activeColor: kGold, inactiveColor: kSurf2,
            onChanged: (v) { setState(() => _price = v); _filter(); },
          )),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Align(alignment: Alignment.centerLeft,
          child: Text('${_results.length} car${_results.length != 1 ? 's' : ''} found',
            style: const TextStyle(color: kTextS, fontSize: 12))),
      ),
      Expanded(child: _results.isEmpty
          ? const Center(child: Text('No cars match your search', style: TextStyle(color: kTextS, fontSize: 15)))
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.68,
              ),
              itemCount: _results.length,
              itemBuilder: (_, i) {
                final car = _results[i];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/user/car-detail', arguments: car),
                  child: _Card(car: car),
                );
              },
            )),
    ]);
  }
}

class _Card extends StatelessWidget {
  final Map<String, dynamic> car;
  const _Card({required this.car});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: kSurf, borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(height: 96, width: double.infinity,
          color: Color(car['color'] as int),
          child: Icon(Icons.directions_car_rounded, size: 52, color: Colors.white.withOpacity(0.22))),
      ),
      Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(car['name'] as String,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 2),
        Row(children: [
          const Icon(Icons.star_rounded, color: kGold, size: 11),
          const SizedBox(width: 2),
          Text('${car['rating']}', style: const TextStyle(color: kTextS, fontSize: 10)),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          RichText(text: TextSpan(children: [
            TextSpan(text: '\$${car['price']}',
              style: const TextStyle(color: kGold, fontWeight: FontWeight.w800, fontSize: 13)),
            const TextSpan(text: '/day', style: TextStyle(color: kTextS, fontSize: 9)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(7)),
            child: const Text('Book', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w700)),
          ),
        ]),
      ])),
    ]),
  );
}
