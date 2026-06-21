// lib/screens/user/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/screens/guest/app_shell.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final String carName, company, price, category, fuel, transmission;
  final int seats;
  final String rentalModel;     // 'Daily' | 'Monthly' | 'Long-Term' | 'Hybrid'
  final double monthlyPrice;
  final double longTermPrice;
  const BookingScreen({
    super.key,
    required this.carName, required this.company, required this.price,
    required this.category, required this.seats, required this.fuel,
    required this.transmission,
    this.rentalModel = 'Daily',
    this.monthlyPrice = 0,
    this.longTermPrice = 0,
  });
  @override State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _pickupDate;
  DateTime? _returnDate;
  String _pickupLocation  = 'Kigali City Centre, KG 7 Ave';
  String _dropoffLocation = 'Kigali City Centre, KG 7 Ave';
  bool   _sameDropoff     = true;
  bool   _agreedToTerms   = false;
  int    _months          = 1;   // for Monthly / Long-Term / Hybrid-monthly
  String _hybridMode      = 'daily'; // 'daily' or 'monthly' — for Hybrid only

  // Effective rental model considering hybrid selection
  String get _effectiveModel {
    if (widget.rentalModel == 'Hybrid') return _hybridMode;
    if (widget.rentalModel == 'Long-Term') return 'monthly'; // months-based
    if (widget.rentalModel == 'Monthly') return 'monthly';
    return 'daily';
  }

  bool get _isMonthlyMode => _effectiveModel == 'monthly';

  static const List<String> _locations = [
    'Kigali City Centre, KG 7 Ave',
    'Kigali International Airport',
    'Nyamirambo, KN 3 Rd',
    'Kimironko Market',
    'Gisozi, KG 9 Ave',
  ];

  int    get _days     => (_pickupDate == null || _returnDate == null) ? 1 : _returnDate!.difference(_pickupDate!).inDays.clamp(1, 365);
  double get _perDay   => double.tryParse(widget.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;

  // Price per month — use longTermPrice if 6+ months, else monthlyPrice, else derive from daily
  double get _perMonth {
    if (widget.rentalModel == 'Long-Term' && widget.longTermPrice > 0) return widget.longTermPrice;
    if (widget.monthlyPrice > 0) return widget.monthlyPrice;
    return _perDay * 28 * 0.85; // 15% discount for monthly if not set
  }

  double get _subtotal => _isMonthlyMode ? _perMonth * _months : _perDay * _days;
  double get _service  => _subtotal * 0.08;
  double get _insure   => _isMonthlyMode ? 50.0 * _months : 5.0 * _days;
  double get _total    => _subtotal + _service + _insure;

  // For display
  String get _durationLabel => _isMonthlyMode
      ? '$_months month${_months > 1 ? 's' : ''}'
      : '$_days day${_days > 1 ? 's' : ''}';

  Future<void> _pickDate(bool pickup) async {
    final now   = DateTime.now();
    final first = pickup ? now : (_pickupDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: first, firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(
          primary: AppColors.gold, surface: AppColors.darkCard, onSurface: Colors.white)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => pickup ? _pickupDate = picked : _returnDate = picked);
  }

  String _fmt(DateTime d) {
    const w = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${w[d.weekday-1]}, ${m[d.month-1]} ${d.day}';
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
    final canGo = _isMonthlyMode
        ? (_pickupDate != null && _agreedToTerms && (_months >= (widget.rentalModel == 'Long-Term' ? 6 : 1)))
        : (_pickupDate != null && _returnDate != null && _agreedToTerms);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: surface, shape: BoxShape.circle),
            child: Icon(Icons.arrow_back, color: textPri, size: 20)),
        ),
        title: Text('Book Car', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Car summary ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
            child: Row(children: [
              Container(width: 60, height: 60,
                decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.directions_car, color: AppColors.gold, size: 32)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.carName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPri)),
                const SizedBox(height: 2),
                Text(widget.company, style: TextStyle(fontSize: 12, color: textSec)),
                const SizedBox(height: 5),
                Row(children: [
                  _Chip(icon: Icons.people_outline,             label: '${widget.seats}', textSec: textSec),
                  const SizedBox(width: 8),
                  _Chip(icon: Icons.settings_outlined,          label: widget.transmission, textSec: textSec),
                  const SizedBox(width: 8),
                  _Chip(icon: Icons.local_gas_station_outlined, label: widget.fuel, textSec: textSec),
                ]),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(widget.price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gold)),
                Text('/day', style: TextStyle(fontSize: 10, color: textSec)),
              ]),
            ]),
          ),

          const SizedBox(height: 14),

          // ── Rental model info banner ─────────────────────────
          _BookingModelBanner(
            rentalModel: widget.rentalModel,
            card: card, border: border, textPri: textPri, textSec: textSec,
          ),

          // ── Hybrid toggle ────────────────────────────────────
          if (widget.rentalModel == 'Hybrid') ...[
            const SizedBox(height: 20),
            _Label('Choose Rental Type', textPri),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
              child: Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => setState(() => _hybridMode = 'daily'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _hybridMode == 'daily' ? AppColors.gold.withOpacity(0.12) : Colors.transparent,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                      border: Border.all(color: _hybridMode == 'daily' ? AppColors.gold : Colors.transparent, width: 1.5),
                    ),
                    child: Column(children: [
                      Icon(Icons.today_rounded, color: _hybridMode == 'daily' ? AppColors.gold : textSec, size: 20),
                      const SizedBox(height: 4),
                      Text('Daily', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _hybridMode == 'daily' ? AppColors.gold : textPri)),
                      Text(widget.price, style: TextStyle(fontSize: 11, color: textSec)),
                    ]),
                  ),
                )),
                Container(width: 1, height: 70, color: border),
                Expanded(child: GestureDetector(
                  onTap: () => setState(() => _hybridMode = 'monthly'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _hybridMode == 'monthly' ? AppColors.gold.withOpacity(0.12) : Colors.transparent,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                      border: Border.all(color: _hybridMode == 'monthly' ? AppColors.gold : Colors.transparent, width: 1.5),
                    ),
                    child: Column(children: [
                      Icon(Icons.calendar_month_rounded, color: _hybridMode == 'monthly' ? AppColors.gold : textSec, size: 20),
                      const SizedBox(height: 4),
                      Text('Monthly', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _hybridMode == 'monthly' ? AppColors.gold : textPri)),
                      Text('\${_perMonth.toInt()}/mo', style: TextStyle(fontSize: 11, color: textSec)),
                    ]),
                  ),
                )),
              ]),
            ),
          ],

          const SizedBox(height: 20),

          // ── Duration — adapts per rental model ───────────────
          if (_isMonthlyMode) ...[
            _Label(widget.rentalModel == 'Long-Term' ? 'Duration (min. 6 months)' : 'Number of Months', textPri),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('How many months?', style: TextStyle(fontSize: 13, color: textSec)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      final min = widget.rentalModel == 'Long-Term' ? 6 : 1;
                      if (_months > min) setState(() => _months--);
                    },
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.remove, color: textPri, size: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('\$_months', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPri)),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _months++),
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.add, color: AppColors.gold, size: 18),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  for (final m in (widget.rentalModel == 'Long-Term' ? [6, 9, 12, 18, 24] : [1, 2, 3, 6, 12]))
                    GestureDetector(
                      onTap: () => setState(() => _months = m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _months == m ? AppColors.gold.withOpacity(0.15) : surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _months == m ? AppColors.gold : border, width: _months == m ? 1.5 : 0.5),
                        ),
                        child: Text('\$m mo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _months == m ? AppColors.gold : textSec)),
                      ),
                    ),
                ]),
                if (widget.rentalModel == 'Long-Term' && _months < 6) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFFD85A30)),
                    const SizedBox(width: 5),
                    const Text('Minimum 6 months required', style: TextStyle(fontSize: 11, color: Color(0xFFD85A30))),
                  ]),
                ],
              ]),
            ),
            const SizedBox(height: 16),
            _Label('Start Date', textPri),
            const SizedBox(height: 10),
            _DateTile(label: 'Start Date', date: _pickupDate,
              card: card, border: border, textPri: textPri, textSec: textSec,
              onTap: () => _pickDate(true)),
          ] else ...[
            _Label('Rental Dates', textPri),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _DateTile(label: 'Pick-up', date: _pickupDate,
                card: card, border: border, textPri: textPri, textSec: textSec,
                onTap: () => _pickDate(true))),
              const SizedBox(width: 12),
              Expanded(child: _DateTile(label: 'Return', date: _returnDate,
                card: card, border: border, textPri: textPri, textSec: textSec,
                onTap: () { if (_pickupDate != null) _pickDate(false); })),
            ]),
          ],

          // ── Duration summary ──────────────────────────────────
          if (_pickupDate != null && (_isMonthlyMode || _returnDate != null)) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5)),
              child: Row(children: [
                const Icon(Icons.timelapse_rounded, color: AppColors.gold, size: 16),
                const SizedBox(width: 8),
                Text(_durationLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
                const Spacer(),
                Text('\${_total.toStringAsFixed(0)} est. total', style: TextStyle(fontSize: 12, color: textSec)),
              ]),
            ),
          ],

          _Label('Pickup Location', textPri),
          const SizedBox(height: 12),
          _LocDrop(value: _pickupLocation, options: _locations,
            isDark: isDark, card: card, border: border, textPri: textPri, textSec: textSec,
            onChanged: (v) => setState(() => _pickupLocation = v)),

          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => setState(() => _sameDropoff = !_sameDropoff),
            child: Row(children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: _sameDropoff ? AppColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _sameDropoff ? AppColors.gold : border, width: 1.5)),
                child: _sameDropoff ? const Icon(Icons.check, color: Colors.black, size: 13) : null,
              ),
              const SizedBox(width: 10),
              Text('Drop-off at same location', style: TextStyle(fontSize: 13, color: textPri)),
            ]),
          ),

          if (!_sameDropoff) ...[
            const SizedBox(height: 14),
            _Label('Drop-off Location', textPri),
            const SizedBox(height: 12),
            _LocDrop(value: _dropoffLocation, options: _locations,
              isDark: isDark, card: card, border: border, textPri: textPri, textSec: textSec,
              onChanged: (v) => setState(() => _dropoffLocation = v)),
          ],

          const SizedBox(height: 24),
          _Label('Price Breakdown', textPri),
          const SizedBox(height: 12),

          // ── Price breakdown ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
            child: Column(children: [
              _PRow(
                _isMonthlyMode
                  ? '\${_perMonth.toInt()}/mo × $_months month${_months > 1 ? "s" : ""}'
                  : '${widget.price} × $_days day${_days > 1 ? "s" : ""}',
                '\${_subtotal.toStringAsFixed(0)}', textPri, textSec),
              const SizedBox(height: 10),
              _PRow('Service fee (8%)', '\${_service.toStringAsFixed(0)}', textPri, textSec),
              const SizedBox(height: 10),
              _PRow(_isMonthlyMode ? 'Insurance (\$50/mo)' : 'Insurance (\$5/day)', '\${_insure.toStringAsFixed(0)}', textPri, textSec),
              const SizedBox(height: 12),
              Divider(color: border, height: 1),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPri)),
                Text('\$${_total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.gold)),
              ]),
            ]),
          ),

          const SizedBox(height: 20),

          // ── Terms & Policy agreement ──────────────────────────
          GestureDetector(
            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _agreedToTerms
                    ? AppColors.gold.withOpacity(0.07)
                    : card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _agreedToTerms
                      ? AppColors.gold.withOpacity(0.5)
                      : border,
                  width: _agreedToTerms ? 1.2 : 0.8,
                ),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: _agreedToTerms ? AppColors.gold : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _agreedToTerms ? AppColors.gold : textSec,
                      width: 1.5,
                    ),
                  ),
                  child: _agreedToTerms
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.black)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'I agree to ${widget.company}\'s terms & conditions',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: _agreedToTerms ? AppColors.gold : textPri,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By proceeding you confirm that you have read and agree to the rental policy, cancellation terms, damage liability, and privacy policy of ${widget.company}.',
                    style: TextStyle(fontSize: 11, color: textSec, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    _PolicyLink(label: 'Rental Policy',    textSec: textSec),
                    const SizedBox(width: 12),
                    _PolicyLink(label: 'Cancellation',     textSec: textSec),
                    const SizedBox(width: 12),
                    _PolicyLink(label: 'Privacy Policy',   textSec: textSec),
                  ]),
                ])),
              ]),
            ),
          ),

          // ── Warning if dates set but terms not agreed ─────────
          if (_pickupDate != null && _returnDate != null && !_agreedToTerms) ...[
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.info_outline_rounded, size: 13, color: AppColors.gold.withOpacity(0.7)),
              const SizedBox(width: 6),
              Text(
                'Please agree to the terms above to continue.',
                style: TextStyle(fontSize: 11, color: AppColors.gold.withOpacity(0.8)),
              ),
            ]),
          ],

          const SizedBox(height: 20),

          // ── Continue button ──────────────────────────────────
          GestureDetector(
            onTap: canGo ? () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => PaymentScreen(
                carName: widget.carName, company: widget.company,
                pickupDate: _fmt(_pickupDate!), returnDate: _fmt(_returnDate!),
                pickupLocation: _pickupLocation,
                dropoffLocation: _sameDropoff ? _pickupLocation : _dropoffLocation,
                days: _days, total: _total,
              ))) : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: canGo ? AppColors.gold : AppColors.gold.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Continue to Payment', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16, color: Colors.black),
              ]),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text; final Color color;
  const _Label(this.text, this.color);
  @override Widget build(BuildContext context) =>
    Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color));
}

class _PolicyLink extends StatelessWidget {
  final String label;
  final Color textSec;
  const _PolicyLink({required this.label, required this.textSec});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {}, // hook up to real policy screen if needed
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: const TextStyle(
          fontSize: 10, color: AppColors.gold,
          fontWeight: FontWeight.w600, decoration: TextDecoration.underline,
          decorationColor: AppColors.gold)),
    ]),
  );
}


class _Chip extends StatelessWidget {
  final IconData icon; final String label; final Color textSec;
  const _Chip({required this.icon, required this.label, required this.textSec});
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: textSec),
    const SizedBox(width: 3),
    Text(label, style: TextStyle(fontSize: 11, color: textSec)),
  ]);
}

class _DateTile extends StatelessWidget {
  final String label; final DateTime? date;
  final Color card, border, textPri, textSec; final VoidCallback onTap;
  const _DateTile({required this.label, this.date, required this.card, required this.border, required this.textPri, required this.textSec, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: date != null ? AppColors.gold : border, width: date != null ? 1.5 : 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: textSec)),
        const SizedBox(height: 6),
        Text(date != null ? '${date!.day}/${date!.month}/${date!.year}' : 'Select date',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: date != null ? textPri : textSec)),
        const SizedBox(height: 4),
        Icon(Icons.calendar_today_outlined, size: 13, color: date != null ? AppColors.gold : textSec),
      ]),
    ),
  );
}

class _LocDrop extends StatelessWidget {
  final String value; final List<String> options;
  final bool isDark; final Color card, border, textPri, textSec;
  final ValueChanged<String> onChanged;
  const _LocDrop({required this.value, required this.options, required this.isDark, required this.card, required this.border, required this.textPri, required this.textSec, required this.onChanged});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
    child: DropdownButton<String>(
      value: value, isExpanded: true, underline: const SizedBox(),
      dropdownColor: isDark ? AppColors.darkCard : Colors.white,
      icon: Icon(Icons.keyboard_arrow_down, color: textSec),
      style: TextStyle(fontSize: 13, color: textPri, fontFamily: 'Inter'),
      items: options.map((o) => DropdownMenuItem(value: o, child: Row(children: [
        const Icon(Icons.location_on_outlined, size: 15, color: AppColors.gold),
        const SizedBox(width: 8),
        Expanded(child: Text(o, overflow: TextOverflow.ellipsis)),
      ]))).toList(),
      onChanged: (v) => onChanged(v!),
    ),
  );
}

class _PRow extends StatelessWidget {
  final String label, value; final Color textPri, textSec;
  const _PRow(this.label, this.value, this.textPri, this.textSec);
  @override Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: TextStyle(fontSize: 13, color: textSec)),
    Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
  ]);
}

class _BookingModelBanner extends StatelessWidget {
  final String rentalModel;
  final Color card, border, textPri, textSec;
  const _BookingModelBanner({
    required this.rentalModel, required this.card,
    required this.border, required this.textPri, required this.textSec,
  });

  static const _gold = AppColors.gold;

  IconData get _icon {
    switch (rentalModel) {
      case 'Monthly':   return Icons.calendar_month_rounded;
      case 'Long-Term': return Icons.event_repeat_rounded;
      case 'Hybrid':    return Icons.swap_horiz_rounded;
      default:          return Icons.today_rounded;
    }
  }

  String get _label {
    switch (rentalModel) {
      case 'Monthly':   return 'This company rents by the month';
      case 'Long-Term': return 'Long-term rental · 6 months minimum';
      case 'Hybrid':    return 'Choose daily or monthly below';
      default:          return 'Daily rental — pick your dates';
    }
  }

  Color get _color {
    switch (rentalModel) {
      case 'Monthly':   return const Color(0xFF1D9E75);
      case 'Long-Term': return const Color(0xFF7F77DD);
      case 'Hybrid':    return _gold;
      default:          return const Color(0xFF3B5FD4);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: _color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _color.withOpacity(0.3), width: 0.8),
    ),
    child: Row(children: [
      Icon(_icon, color: _color, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(_label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _color))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
            color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
        child: Text(rentalModel,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _color)),
      ),
    ]),
  );
}
