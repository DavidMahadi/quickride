// lib/screens/user/user_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/screens/guest/bookings_screen.dart';

export 'package:swiftride/screens/guest/bookings_screen.dart' show BookingsScreen;

// ── Data model ────────────────────────────────────────────────
class _BookingItem {
  final String car, company, from, to, price, status, ref,
               pickupLocation, dropoffLocation, paymentMethod, days;
  final Color statusColor, carColor;
  final String seats, fuel, transmission, year;
  const _BookingItem({
    required this.car, required this.company,
    required this.from, required this.to, required this.price,
    required this.status, required this.statusColor,
    required this.ref, required this.pickupLocation,
    required this.dropoffLocation, required this.paymentMethod,
    required this.days, required this.carColor,
    required this.seats, required this.fuel,
    required this.transmission, required this.year,
  });
}

// ── Screen ────────────────────────────────────────────────────
class UserBookingsScreen extends StatefulWidget {
  const UserBookingsScreen({super.key});
  @override State<UserBookingsScreen> createState() => _State();
}

class _State extends State<UserBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tc;

  final List<_BookingItem> _active = [
    _BookingItem(
      car: 'Toyota RAV4', company: 'DriveKigali',
      from: 'May 24', to: 'May 27', price: '\$135', days: '3 days',
      status: 'Active', statusColor: Color(0xFF1D9E75),
      ref: 'SW240524001', pickupLocation: 'Kigali City Centre',
      dropoffLocation: 'Kigali City Centre', paymentMethod: 'Credit Card',
      carColor: Color(0xFF1B5E20), seats: '5', fuel: 'Petrol', transmission: 'Automatic', year: '2022',
    ),
    _BookingItem(
      car: 'BMW 5 Series', company: 'SafariWheels',
      from: 'Jun 1', to: 'Jun 3', price: '\$180', days: '2 days',
      status: 'Upcoming', statusColor: Color(0xFF3B5FD4),
      ref: 'SW240601002', pickupLocation: 'Kigali International Airport',
      dropoffLocation: 'Nyamirambo', paymentMethod: 'Mobile Money',
      carColor: Color(0xFF880E4F), seats: '5', fuel: 'Petrol', transmission: 'Automatic', year: '2023',
    ),
  ];

  final List<_BookingItem> _past = [
    _BookingItem(
      car: 'Toyota Camry', company: 'DriveKigali',
      from: 'Apr 10', to: 'Apr 12', price: '\$90', days: '2 days',
      status: 'Completed', statusColor: Color(0xFF888780),
      ref: 'SW240410003', pickupLocation: 'Kigali City Centre',
      dropoffLocation: 'Kimironko Market', paymentMethod: 'Credit Card',
      carColor: Color(0xFF1A237E), seats: '5', fuel: 'Petrol', transmission: 'Automatic', year: '2021',
    ),
    _BookingItem(
      car: 'Honda CR-V', company: 'RwandaRide',
      from: 'Mar 5', to: 'Mar 7', price: '\$76', days: '2 days',
      status: 'Completed', statusColor: Color(0xFF888780),
      ref: 'SW240305004', pickupLocation: 'Kigali International Airport',
      dropoffLocation: 'Kigali City Centre', paymentMethod: 'Cash on Pickup',
      carColor: Color(0xFF4E342E), seats: '5', fuel: 'Petrol', transmission: 'Automatic', year: '2020',
    ),
    _BookingItem(
      car: 'Mercedes C', company: 'LuxDrive',
      from: 'Feb 14', to: 'Feb 15', price: '\$95', days: '1 day',
      status: 'Cancelled', statusColor: Color(0xFFD85A30),
      ref: 'SW240214005', pickupLocation: 'Gisozi',
      dropoffLocation: 'Gisozi', paymentMethod: 'Mobile Money',
      carColor: Color(0xFF37474F), seats: '5', fuel: 'Diesel', transmission: 'Automatic', year: '2022',
    ),
  ];

  @override void initState() { super.initState(); _tc = TabController(length: 2, vsync: this); }
  @override void dispose()   { _tc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg   : AppColors.lightBg;
    final card    = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: textPri, size: 22),
              onPressed: () => Navigator.pop(context))
          : Builder(builder: (ctx) => IconButton(
              icon: Icon(Icons.menu, color: textPri, size: 22),
              onPressed: () => Scaffold.of(ctx).openDrawer())),
        title: Text('My Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
        bottom: TabBar(
          controller: _tc,
          indicatorColor: AppColors.gold, labelColor: AppColors.gold,
          unselectedLabelColor: textSec,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [Tab(text: 'Active'), Tab(text: 'Past')],
        ),
      ),
      body: TabBarView(controller: _tc, children: [
        _BookingList(items: _active, isDark: isDark, card: card, border: border, textPri: textPri, textSec: textSec),
        _BookingList(items: _past,   isDark: isDark, card: card, border: border, textPri: textPri, textSec: textSec),
      ]),
    );
  }
}

// ── List ──────────────────────────────────────────────────────
class _BookingList extends StatelessWidget {
  final List<_BookingItem> items;
  final bool isDark;
  final Color card, border, textPri, textSec;
  const _BookingList({required this.items, required this.isDark, required this.card, required this.border, required this.textPri, required this.textSec});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.receipt_long_outlined, size: 56, color: textSec),
        const SizedBox(height: 14),
        Text('No bookings yet', style: TextStyle(color: textSec, fontSize: 15)),
      ]));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _BookingCard(
        b: items[i], isDark: isDark, card: card,
        border: border, textPri: textPri, textSec: textSec,
      ),
    );
  }
}

// ── List card ─────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final _BookingItem b;
  final bool isDark;
  final Color card, border, textPri, textSec;
  const _BookingCard({required this.b, required this.isDark, required this.card, required this.border, required this.textPri, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _BookingDetailSheet(b: b, isDark: isDark, card: card, border: border, textPri: textPri, textSec: textSec),
      ),
      child: Container(
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
              decoration: BoxDecoration(color: b.carColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.directions_car, color: b.carColor, size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.car, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
              Text(b.company, style: TextStyle(fontSize: 12, color: textSec)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: b.statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(b.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: b.statusColor))),
          ]),
          const SizedBox(height: 14),
          Divider(color: border, height: 1),
          const SizedBox(height: 14),
          Row(children: [
            _IC(label: 'Pick-up',  value: b.from,  textPri: textPri, textSec: textSec),
            Container(width: 1, height: 32, color: border, margin: const EdgeInsets.symmetric(horizontal: 16)),
            _IC(label: 'Drop-off', value: b.to,    textPri: textPri, textSec: textSec),
            Container(width: 1, height: 32, color: border, margin: const EdgeInsets.symmetric(horizontal: 16)),
            _IC(label: 'Total',    value: b.price, textPri: AppColors.gold, textSec: textSec),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: textSec, size: 18),
          ]),
        ]),
      ),
    );
  }
}

// ── Detail bottom sheet ───────────────────────────────────────
class _BookingDetailSheet extends StatelessWidget {
  final _BookingItem b;
  final bool isDark;
  final Color card, border, textPri, textSec;
  const _BookingDetailSheet({required this.b, required this.isDark, required this.card, required this.border, required this.textPri, required this.textSec});

  Color get _surface => isDark ? AppColors.darkSurface : AppColors.lightSurface;

  @override
  Widget build(BuildContext context) {
    final isActive    = b.status == 'Active';
    final isUpcoming  = b.status == 'Upcoming';
    final isCompleted = b.status == 'Completed';
    final isCancelled = b.status == 'Cancelled';

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          // ── Handle ───────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40, height: 4,
            decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)),
          ),

          Expanded(child: ListView(controller: ctrl, children: [

            // ══════════════════════════════════════════════
            // CAR HERO BANNER
            // ══════════════════════════════════════════════
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [b.carColor, b.carColor.withOpacity(0.6)],
                ),
              ),
              child: Column(children: [
                // Big car icon
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 14),
                Text(b.car,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Text(b.company,
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7))),
                const SizedBox(height: 14),
                // Status pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.8),
                  ),
                  child: Text(b.status,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                const SizedBox(height: 16),
                // Car specs row
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _HeroSpec(icon: Icons.event_seat_outlined,        label: '${b.seats} seats'),
                  _HeroDivider(),
                  _HeroSpec(icon: Icons.local_gas_station_outlined, label: b.fuel),
                  _HeroDivider(),
                  _HeroSpec(icon: Icons.settings_outlined,          label: b.transmission),
                  _HeroDivider(),
                  _HeroSpec(icon: Icons.calendar_month_outlined,    label: b.year),
                ]),
              ]),
            ),

            // ══════════════════════════════════════════════
            // BODY CONTENT
            // ══════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

                // ── Ref chip ──────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withOpacity(0.25), width: 0.8),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.confirmation_number_outlined, color: AppColors.gold, size: 16),
                    const SizedBox(width: 8),
                    Text('Booking Ref: ', style: TextStyle(fontSize: 13, color: textSec)),
                    Text(b.ref, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.gold)),
                  ]),
                ),

                const SizedBox(height: 24),

                // ── Trip info grid (2 columns) ─────────────
                _SectionLabel(label: 'Trip Details', textPri: textPri),
                const SizedBox(height: 12),

                // Row 1: pick-up ↔ drop-off
                Row(children: [
                  Expanded(child: _InfoTile(
                    icon: Icons.flight_land_outlined,
                    label: 'Pick-up',
                    value: b.from,
                    color: const Color(0xFF1D9E75),
                    isDark: isDark, textPri: textPri, textSec: textSec,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _InfoTile(
                    icon: Icons.flight_takeoff_outlined,
                    label: 'Drop-off',
                    value: b.to,
                    color: const Color(0xFF3B5FD4),
                    isDark: isDark, textPri: textPri, textSec: textSec,
                  )),
                ]),
                const SizedBox(height: 10),

                // Row 2: duration ↔ payment
                Row(children: [
                  Expanded(child: _InfoTile(
                    icon: Icons.access_time_outlined,
                    label: 'Duration',
                    value: b.days,
                    color: const Color(0xFF7F77DD),
                    isDark: isDark, textPri: textPri, textSec: textSec,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _InfoTile(
                    icon: Icons.payment_outlined,
                    label: 'Payment',
                    value: b.paymentMethod,
                    color: const Color(0xFFD85A30),
                    isDark: isDark, textPri: textPri, textSec: textSec,
                  )),
                ]),
                const SizedBox(height: 10),

                // Row 3: pick-up location (full width)
                _LocationTile(
                  icon: Icons.location_on_outlined,
                  label: 'Pick-up location',
                  value: b.pickupLocation,
                  color: const Color(0xFF1D9E75),
                  isDark: isDark, textPri: textPri, textSec: textSec,
                ),
                const SizedBox(height: 10),

                // Row 4: drop-off location (full width)
                _LocationTile(
                  icon: Icons.flag_outlined,
                  label: 'Drop-off location',
                  value: b.dropoffLocation,
                  color: const Color(0xFF3B5FD4),
                  isDark: isDark, textPri: textPri, textSec: textSec,
                ),

                const SizedBox(height: 24),

                // ── Payment summary card ───────────────────
                _SectionLabel(label: 'Payment Summary', textPri: textPri),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 0.5),
                  ),
                  child: Column(children: [
                    _PayRow(label: 'Car rental', value: b.price, textPri: textPri, textSec: textSec, bold: false),
                    const SizedBox(height: 8),
                    _PayRow(label: 'Service fee', value: '~10%', textPri: textPri, textSec: textSec, bold: false),
                    const SizedBox(height: 8),
                    _PayRow(label: 'Insurance', value: 'Included', textPri: textPri, textSec: textSec, bold: false),
                    Divider(color: border, height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Total paid', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
                      Text(b.price, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.gold)),
                    ]),
                  ]),
                ),

                const SizedBox(height: 24),

                // ── Action buttons ─────────────────────────
                if (isActive) ...[
                  _ActionBtn(icon: Icons.qr_code_rounded,      label: 'Show QR Pass',      color: AppColors.gold, filled: true,  onTap: () => _showQR(context)),
                  const SizedBox(height: 10),
                  _ActionBtn(icon: Icons.chat_bubble_outline,  label: 'Message Company',   color: AppColors.gold, filled: false, onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/user/messages'); }),
                ],
                if (isUpcoming) ...[
                  _ActionBtn(icon: Icons.edit_calendar_outlined, label: 'Modify Booking',  color: AppColors.gold,            filled: true,  onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/user/booking-flow', arguments: {}); }),
                  const SizedBox(height: 10),
                  _ActionBtn(icon: Icons.cancel_outlined,        label: 'Cancel Booking',  color: const Color(0xFFD85A30),   filled: false, onTap: () => _confirmCancel(context)),
                ],
                if (isCompleted) ...[
                  _ActionBtn(icon: Icons.replay_rounded,         label: 'Rebook This Car', color: AppColors.gold,            filled: true,  onTap: () => Navigator.pop(context)),
                  const SizedBox(height: 10),
                  _ActionBtn(icon: Icons.star_outline_rounded,   label: 'Leave a Review',  color: AppColors.gold,            filled: false, onTap: () { Navigator.pop(context); _showReviewSheet(context); }),
                ],
                if (isCancelled)
                  _ActionBtn(icon: Icons.replay_rounded,         label: 'Book Again',      color: AppColors.gold,            filled: true,  onTap: () => Navigator.pop(context)),

                const SizedBox(height: 16),
              ]),
            ),
          ])),
        ]),
      ),
    );
  }

  void _showQR(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('QR Pass', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPri)),
        const SizedBox(height: 16),
        Container(
          width: 160, height: 160,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: const Center(child: Icon(Icons.qr_code_2_rounded, size: 130, color: Colors.black)),
        ),
        const SizedBox(height: 12),
        Text(b.ref, style: const TextStyle(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Show this at pickup', style: TextStyle(fontSize: 12, color: textSec)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: AppColors.gold)))],
    ),
  );

  void _confirmCancel(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Cancel Booking', style: TextStyle(color: textPri, fontWeight: FontWeight.w700)),
      content: Text('Are you sure? This action cannot be undone.', style: TextStyle(color: textSec, fontSize: 13, height: 1.5)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Keep it', style: TextStyle(color: textSec))),
        TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); },
          child: const Text('Cancel Booking', style: TextStyle(color: Color(0xFFD85A30), fontWeight: FontWeight.w700))),
      ],
    ),
  );
}

// ── Hero spec chip ────────────────────────────────────────────
class _HeroSpec extends StatelessWidget {
  final IconData icon; final String label;
  const _HeroSpec({required this.icon, required this.label});
  @override Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: Colors.white.withOpacity(0.85), size: 16),
    const SizedBox(height: 4),
    Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w500)),
  ]);
}

class _HeroDivider extends StatelessWidget {
  @override Widget build(BuildContext context) => Container(
    width: 1, height: 28, color: Colors.white.withOpacity(0.2),
    margin: const EdgeInsets.symmetric(horizontal: 14),
  );
}

// ── Info tile (2-column grid) ─────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  final bool isDark; final Color textPri, textSec;
  const _InfoTile({required this.icon, required this.label, required this.value, required this.color, required this.isDark, required this.textPri, required this.textSec});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE), width: 0.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 16),
      ),
      const SizedBox(height: 10),
      Text(label, style: TextStyle(fontSize: 11, color: textSec)),
      const SizedBox(height: 3),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri), maxLines: 1, overflow: TextOverflow.ellipsis),
    ]),
  );
}

// ── Location tile (full width) ────────────────────────────────
class _LocationTile extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  final bool isDark; final Color textPri, textSec;
  const _LocationTile({required this.icon, required this.label, required this.value, required this.color, required this.isDark, required this.textPri, required this.textSec});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE), width: 0.5),
    ),
    child: Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: textSec)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
      ])),
    ]),
  );
}

// ── Section label ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label; final Color textPri;
  const _SectionLabel({required this.label, required this.textPri});
  @override Widget build(BuildContext context) => Text(label,
    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPri));
}

// ── Payment row ───────────────────────────────────────────────
class _PayRow extends StatelessWidget {
  final String label, value; final Color textPri, textSec; final bool bold;
  const _PayRow({required this.label, required this.value, required this.textPri, required this.textSec, required this.bold});
  @override Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: TextStyle(fontSize: 13, color: textSec)),
    Text(value, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: textPri)),
  ]);
}

// ── Action button ─────────────────────────────────────────────
void _showReviewSheet(BuildContext context) {
  int stars = 0;
  final ctrl = TextEditingController();
  final isDark  = Theme.of(context).brightness == Brightness.dark;
  final card    = isDark ? AppColors.darkCard    : AppColors.lightCard;
  final border  = isDark ? AppColors.darkBorder  : const Color(0xFFDDE1EE);
  final textPri = isDark ? Colors.white           : const Color(0xFF0A0E1A);
  final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);
  showModalBottomSheet(context: context, backgroundColor: card, isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => StatefulBuilder(builder: (ctx, ss) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text('Leave a Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPri)),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) =>
          GestureDetector(
            onTap: () => ss(() => stars = i + 1),
            child: Icon(i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
              color: AppColors.gold, size: 38)))),
        const SizedBox(height: 16),
        TextField(controller: ctrl, maxLines: 4,
          style: TextStyle(color: textPri, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Share your experience...',
            hintStyle: TextStyle(color: textSec),
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(14))),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: stars == 0 ? null : () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Thank you for your \$stars-star review!'),
                backgroundColor: const Color(0xFF1D9E75)));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold, foregroundColor: Colors.black,
            disabledBackgroundColor: AppColors.gold.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.w700)))),
      ]))))));
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  final bool filled; final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.filled, required this.onTap});
  @override Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: filled
      ? ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color, foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ))
      : OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18, color: color),
          label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          )),
  );
}

// ── Small inline cell ─────────────────────────────────────────
class _IC extends StatelessWidget {
  final String label, value; final Color textPri, textSec;
  const _IC({required this.label, required this.value, required this.textPri, required this.textSec});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 10, color: textSec)),
    const SizedBox(height: 2),
    Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
  ]);
}
