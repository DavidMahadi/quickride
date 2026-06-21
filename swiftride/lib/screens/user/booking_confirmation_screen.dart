// lib/screens/user/booking_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String carName, company, pickupDate, returnDate,
               pickupLocation, dropoffLocation, paymentMethod;
  final int days; final double total;
  const BookingConfirmationScreen({
    super.key,
    required this.carName, required this.company,
    required this.pickupDate, required this.returnDate,
    required this.pickupLocation, required this.dropoffLocation,
    required this.days, required this.total, required this.paymentMethod,
  });
  @override State<BookingConfirmationScreen> createState() => _State();
}

class _State extends State<BookingConfirmationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  // Generate booking ref
  final String _ref = 'SW${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade  = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0)));
    _ctrl.forward();
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg      : AppColors.lightBg;
    final card    = isDark ? AppColors.darkCard    : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder  : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white           : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 20),

            // ── Success animation ──────────────────────────────
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Transform.scale(
                scale: _scale.value,
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D9E75).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1D9E75).withOpacity(0.4), width: 2)),
                  child: const Icon(Icons.check_rounded, color: Color(0xFF1D9E75), size: 48),
                ),
              ),
            ),
            const SizedBox(height: 20),

            AnimatedBuilder(
              animation: _fade,
              builder: (_, child) => Opacity(opacity: _fade.value, child: child),
              child: Column(children: [
                const Text('Booking Confirmed!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.gold)),
                const SizedBox(height: 8),
                Text('Your car has been reserved successfully.\nYou\'re all set to drive!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: textSec, height: 1.5)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5)),
                  child: Text('Booking Ref: $_ref',
                    style: const TextStyle(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),

            const SizedBox(height: 28),

            // ── Booking details card ───────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: border, width: 0.5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 48, height: 48,
                    decoration: BoxDecoration(color: isDark ? AppColors.darkSurface : AppColors.lightSurface, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.directions_car, color: AppColors.gold, size: 26)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.carName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPri)),
                    Text(widget.company, style: TextStyle(fontSize: 12, color: textSec)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF1D9E75).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Confirmed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1D9E75))),
                  ),
                ]),
                const SizedBox(height: 16),
                Divider(color: border, height: 1),
                const SizedBox(height: 16),
                _DRow(Icons.calendar_today_outlined, 'Pickup',    widget.pickupDate, textPri, textSec),
                const SizedBox(height: 10),
                _DRow(Icons.event_outlined,          'Return',    widget.returnDate, textPri, textSec),
                const SizedBox(height: 10),
                _DRow(Icons.location_on_outlined,    'Pickup at', widget.pickupLocation, textPri, textSec),
                const SizedBox(height: 10),
                _DRow(Icons.flag_outlined,           'Drop-off',  widget.dropoffLocation, textPri, textSec),
                const SizedBox(height: 10),
                _DRow(Icons.payment_outlined,        'Payment',   widget.paymentMethod, textPri, textSec),
                const SizedBox(height: 16),
                Divider(color: border, height: 1),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Total Paid', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPri)),
                  Text('\$${widget.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.gold)),
                ]),
              ]),
            ),

            const SizedBox(height: 24),

            // ── What's next ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("What's next?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
                const SizedBox(height: 12),
                ...[
                  [Icons.email_outlined,        'Confirmation sent to your email'],
                  [Icons.chat_bubble_outline,   'Company will contact you before pickup'],
                  [Icons.badge_outlined,        'Bring your driver\'s license & ID'],
                  [Icons.calendar_today_outlined,'Add to your calendar'],
                ].map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    Container(width: 32, height: 32,
                      decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(i[0] as IconData, color: AppColors.gold, size: 16)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(i[1] as String, style: TextStyle(fontSize: 13, color: textSec))),
                  ]),
                )),
              ]),
            ),

            const SizedBox(height: 30),

            // ── Actions ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/user/home', (_) => false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold, foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0),
                child: const Text('Back to Home', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/user/home', (_) => false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.gold),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('View My Bookings', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        )),
      ),
    );
  }
}

class _DRow extends StatelessWidget {
  final IconData icon; final String label, value; final Color textPri, textSec;
  const _DRow(this.icon, this.label, this.value, this.textPri, this.textSec);
  @override Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 15, color: textSec),
    const SizedBox(width: 10),
    Text('$label: ', style: TextStyle(fontSize: 12, color: textSec)),
    Expanded(child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri), overflow: TextOverflow.ellipsis)),
  ]);
}
