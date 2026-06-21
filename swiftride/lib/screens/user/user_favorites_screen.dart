// lib/screens/user/user_favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
class UserFavoritesScreen extends StatefulWidget {
  const UserFavoritesScreen({super.key});
  @override State<UserFavoritesScreen> createState() => _State();
}
class _State extends State<UserFavoritesScreen> {
  final List<_FC> _favs = [
    _FC(name: 'Toyota RAV4',  company: 'DriveKigali',  price: '\$60/day', seats: 5, fuel: 'Petrol', trans: 'Auto', rating: '4.9'),
    _FC(name: 'BMW 5 Series', company: 'SafariWheels', price: '\$90/day', seats: 5, fuel: 'Petrol', trans: 'Auto', rating: '4.8'),
    _FC(name: 'Toyota Camry', company: 'DriveKigali',  price: '\$45/day', seats: 5, fuel: 'Petrol', trans: 'Auto', rating: '4.7'),
  ];
  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.darkBg   : AppColors.lightBg;
    final card   = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri= isDark ? Colors.white : const Color(0xFF0A0E1A);
    final textSec= isDark ? const Color(0xFF8B91A8) : const Color(0xFF6B7280);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(backgroundColor: bg, elevation: 0, automaticallyImplyLeading: false,
        title: Text('Favorites', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
        actions: [Padding(padding: const EdgeInsets.only(right: 16),
          child: TextButton(onPressed: () => setState(() => _favs.clear()),
            child: const Text('Clear all', style: TextStyle(color: AppColors.gold, fontSize: 13))))]),
      body: _favs.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.favorite_outline, size: 56, color: textSec),
              const SizedBox(height: 12),
              Text('No favorites yet', style: TextStyle(color: textSec, fontSize: 15)),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.all(20), itemCount: _favs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final f = _favs[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
                  child: Row(children: [
                    Container(width: 70, height: 70,
                      decoration: BoxDecoration(color: isDark ? AppColors.darkSurface : AppColors.lightSurface, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.directions_car, color: AppColors.gold, size: 36)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(f.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
                      const SizedBox(height: 2),
                      Text(f.company, style: TextStyle(fontSize: 12, color: textSec)),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.star, color: AppColors.gold, size: 13),
                        const SizedBox(width: 3),
                        Text(f.rating, style: TextStyle(fontSize: 11, color: textSec)),
                        const SizedBox(width: 10),
                        Icon(Icons.people_outline, size: 12, color: textSec),
                        const SizedBox(width: 3),
                        Text('${f.seats}', style: TextStyle(fontSize: 11, color: textSec)),
                      ]),
                      const SizedBox(height: 6),
                      Text(f.price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gold)),
                    ])),
                    GestureDetector(
                      onTap: () => setState(() => _favs.removeAt(i)),
                      child: Container(width: 34, height: 34,
                        decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.favorite, color: Colors.redAccent, size: 17))),
                  ]),
                );
              }),
    );
  }
}
class _FC { final String name, company, price, fuel, trans, rating; final int seats;
  const _FC({required this.name, required this.company, required this.price, required this.fuel, required this.trans, required this.rating, required this.seats}); }
