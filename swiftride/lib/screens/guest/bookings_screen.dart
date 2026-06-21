import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/screens/guest/shared_drawer.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});
  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_BookingItem> _active = [
    _BookingItem(car: 'Toyota RAV4', company: 'DriveKigali', from: 'May 24', to: 'May 27', price: '\$135', status: 'Active', statusColor: Color(0xFF1D9E75)),
    _BookingItem(car: 'BMW 5 Series', company: 'SafariWheels', from: 'Jun 1', to: 'Jun 3', price: '\$180', status: 'Upcoming', statusColor: Color(0xFF3B5FD4)),
  ];

  final List<_BookingItem> _past = [
    _BookingItem(car: 'Toyota Camry', company: 'DriveKigali', from: 'Apr 10', to: 'Apr 12', price: '\$90', status: 'Completed', statusColor: Color(0xFF888780)),
    _BookingItem(car: 'Honda CR-V', company: 'RwandaRide', from: 'Mar 5', to: 'Mar 7', price: '\$76', status: 'Completed', statusColor: Color(0xFF888780)),
    _BookingItem(car: 'Mercedes C', company: 'LuxDrive', from: 'Feb 14', to: 'Feb 15', price: '\$95', status: 'Cancelled', statusColor: Color(0xFFD85A30)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.darkBg    : AppColors.lightBg;
    final card   = isDark ? AppColors.darkCard  : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder: const Color(0xFFDDE1EE);
    final textPri= isDark ? Colors.white        : const Color(0xFF0A0E1A);
    final textSec= isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      drawer: const AppDrawer(activeTab: 1),
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu, size: 22), onPressed: () => Scaffold.of(ctx).openDrawer())),
        title: Text('My Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: textSec,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [Tab(text: 'Active'), Tab(text: 'Past')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BookingList(items: _active, isDark: isDark, card: card, border: border, textPri: textPri, textSec: textSec),
          _BookingList(items: _past,   isDark: isDark, card: card, border: border, textPri: textPri, textSec: textSec),
        ],
      ),
    );
  }
}

class _BookingItem {
  final String car, company, from, to, price, status;
  final Color statusColor;
  const _BookingItem({required this.car, required this.company, required this.from, required this.to, required this.price, required this.status, required this.statusColor});
}

class _BookingList extends StatelessWidget {
  final List<_BookingItem> items;
  final bool isDark;
  final Color card, border, textPri, textSec;
  const _BookingList({required this.items, required this.isDark, required this.card, required this.border, required this.textPri, required this.textSec});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('No bookings yet', style: TextStyle(color: textSec)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final b = items[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 0.5),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car, color: AppColors.gold, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.car, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
                Text(b.company, style: TextStyle(fontSize: 12, color: textSec)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: b.statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(b.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: b.statusColor)),
              ),
            ]),
            const SizedBox(height: 14),
            Divider(color: border, height: 1),
            const SizedBox(height: 14),
            Row(children: [
              _InfoCol(label: 'Pick-up', value: b.from, textPri: textPri, textSec: textSec),
              Container(width: 1, height: 32, color: border, margin: const EdgeInsets.symmetric(horizontal: 16)),
              _InfoCol(label: 'Drop-off', value: b.to, textPri: textPri, textSec: textSec),
              Container(width: 1, height: 32, color: border, margin: const EdgeInsets.symmetric(horizontal: 16)),
              _InfoCol(label: 'Total', value: b.price, textPri: AppColors.gold, textSec: textSec),
            ]),
          ]),
        );
      },
    );
  }
}

class _InfoCol extends StatelessWidget {
  final String label, value;
  final Color textPri, textSec;
  const _InfoCol({required this.label, required this.value, required this.textPri, required this.textSec});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 10, color: textSec)),
    const SizedBox(height: 2),
    Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
  ]);
}
