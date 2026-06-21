// lib/screens/user/booking_flow_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/utils/constants.dart' show kNavy, kNavy2, kGold, kGoldL, kSurf, kSurf2, kText, kTextS, kError, kSuccess, kWarn, AppColors, kAllCars, kCategories, kPickupLocations;
import 'package:swiftride/services/app_data_store.dart';
import 'package:swiftride/services/auth_service.dart';
import 'package:swiftride/services/wallet_service.dart';

class BookingFlowScreen extends StatefulWidget {
  final Map<String, dynamic> car;
  const BookingFlowScreen({super.key, required this.car});
  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _step = 0; // 0=dates+location, 1=payment, 2=confirmed
  DateTime? _start, _end;
  String _location = 'Kigali City Centre';
  String _payMethod = 'card';
  String _cardNumber = '', _cardName = '', _cardExpiry = '', _cardCVV = '';
  bool _loading = false;
  int _months = 6; // for Monthly/Long-Term modes

  // ── Rental model from company ─────────────────────────────────
  String get _rentalModel {
    final companyName = (widget.car['company'] as String?) ?? '';
    final company = AppDataStore.instance.companyByName(companyName);
    return company?.rentalModel ?? 'Daily';
  }
  bool get _isMonthlyMode =>
      _rentalModel == 'Monthly' || _rentalModel == 'Long-Term';
  int get _minMonths => _rentalModel == 'Long-Term' ? 6 : 1;

  // ── Computed ─────────────────────────────────────────────────
  int get _days => (_start != null && _end != null)
      ? _end!.difference(_start!).inDays.abs().clamp(1, 365)
      : 1;
  double get _pricePerDay   => _carPrice(widget.car).toDouble();
  double get _pricePerMonth => _pricePerDay * 28 * 0.85; // 15% monthly discount
  double get _subtotal   => _isMonthlyMode ? _pricePerMonth * _months : _pricePerDay * _days;
  double get _serviceFee => _subtotal * 0.10;
  double get _insurance  => _isMonthlyMode ? 50.0 * _months : 15.0 * _days;
  double get _total      => _subtotal + _serviceFee + _insurance;

  // ── Helpers ───────────────────────────────────────────────────
  String _fmt(DateTime d) =>
      '${d.day} ${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.month-1]} ${d.year}';

  String get _bookingRef =>
      'SR${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

  late final String _confirmedRef = _bookingRef;

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? now : (_start?.add(const Duration(days: 1)) ?? now),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kGold, surface: kSurf, onSurface: kText,
          ),
          dialogBackgroundColor: kNavy2,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() {
      if (isStart) { _start = picked; _end = null; }
      else _end = picked;
    });
  }

  void _confirmAndPay() {
    final passC = TextEditingController();
    String? err;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(builder: (ctx, ss) => AlertDialog(
        backgroundColor: kSurf,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: kGold.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.lock_rounded, color: kGold, size: 26),
          ),
          const SizedBox(height: 12),
          const Text('Confirm Payment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('\$${_total.toStringAsFixed(0)} will be charged',
              style: const TextStyle(fontSize: 12, color: kTextS, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: passC,
            obscureText: true,
            autofocus: true,
            style: const TextStyle(color: kText, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter password',
              hintStyle: const TextStyle(color: kTextS),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: kTextS, size: 18),
              filled: true,
              fillColor: kNavy2,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kSurf2)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kSurf2)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kGold, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          if (err != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.error_outline_rounded, color: kError, size: 13),
              const SizedBox(width: 4),
              Text(err!, style: const TextStyle(color: kError, fontSize: 12)),
            ]),
          ],
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: kTextS, fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              if (passC.text != '123') {
                ss(() => err = 'Incorrect password');
                return;
              }
              Navigator.pop(ctx);
              _pay();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kGold, foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      )),
    );
  }

  Future<void> _pay() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    // ── Record booking to AppDataStore ────────────────────────
    final car = widget.car;
    final companyName = (car['company'] as String?) ?? 'DriveKigali';
    final company = AppDataStore.instance.companyByName(companyName);
    final payLabel = _payMethod == 'card'   ? 'Credit Card'
                   : _payMethod == 'mobile' ? 'MTN Mobile Money'
                   : 'SwiftRide Wallet';

    final booking = SharedBooking(
      id:              'B${DateTime.now().millisecondsSinceEpoch}',
      ref:             _confirmedRef,
      customerId:      AuthService.currentUserId.isEmpty ? 'U001' : AuthService.currentUserId,
      customerName:    AuthService.userName,
      customerPhone:   AuthService.userPhone,
      carId:           (car['id'] as String?) ?? '',
      carName:         (car['name'] as String?) ?? '',
      carBrand:        (car['brand'] as String?) ?? '',
      carCategory:     (car['category'] as String?) ?? '',
      carColor:        _carColor(car),
      carSeats:        _carSeats(car),
      carFuel:         (car['fuel'] as String?) ?? '',
      carTransmission: (car['transmission'] as String?) ?? '',
      carYear:         (car['year'] as String?) ?? '',
      companyId:       company?.id ?? '',
      companyName:     companyName,
      pickupDate:      _fmt(_start!),
      returnDate:      _isMonthlyMode
          ? _fmt(_start!.add(Duration(days: (_months * 30).round())))
          : _fmt(_end!),
      pickupLocation:  _location,
      dropoffLocation: _location,
      days:            _isMonthlyMode ? _months * 30 : _days,
      pricePerDay:     _isMonthlyMode ? _pricePerMonth : _pricePerDay,
      subtotal:        _subtotal,
      serviceFee:      _serviceFee,
      insurance:       _insurance,
      total:           _total,
      paymentMethod:   payLabel,
      paymentReference: _cardNumber.length >= 4 ? '**** ${_cardNumber.substring(_cardNumber.length - 4)}' : '',
      status:          'Upcoming',
      termsAgreed:     true,
    );

    AppDataStore.instance.addBooking(
      booking, AuthService.userName, 'Client');

    // ── Record payment to company wallet ───────────────────────
    WalletService.instance.recordBookingPayment(
      companyName:  companyName,
      amount:       _total,
      bookingRef:   _confirmedRef,
      customerName: AuthService.userName,
    );

    setState(() { _loading = false; _step = 2; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      appBar: _step < 2 ? AppBar(
        title: Text(['Select Dates', 'Payment'][_step]),
        leading: BackButton(onPressed: () {
          if (_step == 0) Navigator.pop(context);
          else setState(() => _step--);
        }),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / 2,
            backgroundColor: kSurf2,
            valueColor: const AlwaysStoppedAnimation<Color>(kGold),
          ),
        ),
      ) : null,
      body: [_datesStep, _paymentStep, _confirmedStep][_step](),
    );
  }

  // ════════════════════════════════════════════════════════════
  // STEP 0 — Dates & Location
  // ════════════════════════════════════════════════════════════
  Widget _datesStep() {
    final canContinue = _isMonthlyMode
        ? (_start != null && _months >= _minMonths)
        : (_start != null && _end != null);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _MiniCarCard(car: widget.car),
        const SizedBox(height: 16),

        // ── Rental model info banner ──────────────────────────
        _RentalModelBanner(rentalModel: _rentalModel),
        const SizedBox(height: 20),

        if (_isMonthlyMode) ...[
          // ── Monthly/Long-Term: months selector + start date ──
          _SectionLabel(_rentalModel == 'Long-Term'
              ? 'Duration (minimum 6 months)' : 'Number of Months'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kSurf, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              Row(children: [
                const Text('How many months?', style: TextStyle(color: kTextS, fontSize: 13)),
                const Spacer(),
                GestureDetector(
                  onTap: () { if (_months > _minMonths) setState(() => _months--); },
                  child: Container(width: 34, height: 34,
                    decoration: BoxDecoration(color: kNavy2, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.remove, color: kText, size: 18)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('${_months}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kText)),
                ),
                GestureDetector(
                  onTap: () => setState(() => _months++),
                  child: Container(width: 34, height: 34,
                    decoration: BoxDecoration(color: kGold.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.add, color: kGold, size: 18)),
                ),
              ]),
              const SizedBox(height: 14),
              // Quick chips
              Wrap(spacing: 8, runSpacing: 6, children: [
                for (final m in (_rentalModel == 'Long-Term'
                    ? [6, 9, 12, 18, 24] : [1, 2, 3, 6, 12]))
                  GestureDetector(
                    onTap: () => setState(() => _months = m),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _months == m ? kGold.withOpacity(0.15) : kNavy2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _months == m ? kGold : Colors.transparent,
                          width: _months == m ? 1.5 : 0.5)),
                      child: Text('${m} mo',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                              color: _months == m ? kGold : kTextS)),
                    ),
                  ),
              ]),
              if (_rentalModel == 'Long-Term' && _months < 6) ...[
                const SizedBox(height: 10),
                const Row(children: [
                  Icon(Icons.info_outline_rounded, size: 13, color: kError),
                  SizedBox(width: 5),
                  Text('Minimum 6 months required', style: TextStyle(fontSize: 11, color: kError)),
                ]),
              ],
            ]),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Start Date'),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _pickDate(true),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSurf, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _start != null ? kGold : Colors.transparent, width: 1.5)),
              child: Row(children: [
                Icon(Icons.calendar_today_rounded, color: _start != null ? kGold : kTextS, size: 18),
                const SizedBox(width: 10),
                Text(_start != null ? _fmt(_start!) : 'Select start date',
                    style: TextStyle(color: _start != null ? kText : kTextS, fontSize: 14)),
                const Spacer(),
                if (_start != null) const Icon(Icons.check_circle_rounded, color: kGold, size: 18),
              ]),
            ),
          ),
          // Duration summary
          if (_start != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kGold.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kGold.withOpacity(0.3))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Row(children: [
                  Icon(Icons.event_repeat_rounded, color: kGold, size: 15),
                  SizedBox(width: 6),
                  Text('Duration', style: TextStyle(color: kGold, fontSize: 13)),
                ]),
                Text('${_months} month${_months > 1 ? "s" : ""}',
                    style: const TextStyle(color: kGold, fontWeight: FontWeight.w700)),
              ]),
            ),
          ],
        ] else ...[
          // ── Daily: date pickers ───────────────────────────────
          const _SectionLabel('Pick-up & Return Dates'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _DateBox(label: 'Pick-up', date: _start, onTap: () => _pickDate(true))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.arrow_forward_rounded, color: kTextS)),
            Expanded(child: _DateBox(
              label: 'Return', date: _end,
              onTap: _start != null ? () => _pickDate(false) : null,
            )),
          ]),
          if (_start != null && _end != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kGold.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kGold.withOpacity(0.3))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Row(children: [
                  Icon(Icons.calendar_today_rounded, color: kGold, size: 15),
                  SizedBox(width: 6),
                  Text('Duration', style: TextStyle(color: kGold, fontSize: 13)),
                ]),
                Text('${_days} day${_days != 1 ? "s" : ""}',
                    style: const TextStyle(color: kGold, fontWeight: FontWeight.w700)),
              ]),
            ),
          ],
        ],

        const SizedBox(height: 24),
        const _SectionLabel('Pickup Location'),
        const SizedBox(height: 10),
        ...kPickupLocations.map((loc) => GestureDetector(
          onTap: () => setState(() => _location = loc),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _location == loc ? kGold.withOpacity(0.12) : kSurf,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _location == loc ? kGold : Colors.transparent, width: 1.5)),
            child: Row(children: [
              Icon(Icons.location_on_rounded,
                  color: _location == loc ? kGold : kTextS, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(loc,
                  style: TextStyle(color: _location == loc ? kGold : kText, fontSize: 13))),
              if (_location == loc)
                const Icon(Icons.check_circle_rounded, color: kGold, size: 18),
            ]),
          ),
        )),

        const SizedBox(height: 28),
        SizedBox(height: 52, child: ElevatedButton(
          onPressed: canContinue ? () => setState(() => _step = 1) : null,
          child: const Text('Continue to Payment'),
        )),
        const SizedBox(height: 16),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════
  // STEP 1 — Payment
  // ════════════════════════════════════════════════════════════
  Widget _paymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Order summary
        _MiniCarCard(car: widget.car, subtitle: _isMonthlyMode
            ? '${_fmt(_start!)} · $_months month${_months > 1 ? 's' : ''}'
            : '${_fmt(_start!)} → ${_fmt(_end!)}  · $_days days'),
        const SizedBox(height: 20),

        // Price breakdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kSurf, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            const _SectionLabel('Order Summary'),
            const SizedBox(height: 12),
            _PriceRow(
              _isMonthlyMode
                ? '\$${_pricePerMonth.toInt()}/mo × ${_months} months'
                : '\$${_carPrice(widget.car)}/day × ${_days} days',
              '\$${_subtotal.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            _PriceRow('Service fee (10%)', '\$${_serviceFee.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            _PriceRow('Insurance (\$15/day)', '\$${_insurance.toStringAsFixed(0)}'),
            const Divider(color: kSurf2, height: 20),
            _PriceRow('Total', '\$${_total.toStringAsFixed(0)}', bold: true, goldValue: true),
          ]),
        ),

        const SizedBox(height: 20),
        const _SectionLabel('Payment Method'),
        const SizedBox(height: 12),

        // Method selector
        Row(children: [
          _PayMethodBtn(icon: Icons.credit_card_rounded,           label: 'Card',   value: 'card',   selected: _payMethod, onTap: (v) => setState(() => _payMethod = v)),
          const SizedBox(width: 10),
          _PayMethodBtn(icon: Icons.phone_android_rounded,         label: 'Mobile', value: 'mobile', selected: _payMethod, onTap: (v) => setState(() => _payMethod = v)),
          const SizedBox(width: 10),
          _PayMethodBtn(icon: Icons.account_balance_wallet_rounded, label: 'Wallet', value: 'wallet', selected: _payMethod, onTap: (v) => setState(() => _payMethod = v)),
        ]),

        const SizedBox(height: 16),

        // Card form
        if (_payMethod == 'card') ...[
          _CardForm(
            onNumberChanged: (v) => _cardNumber = v,
            onNameChanged:   (v) => _cardName   = v,
            onExpiryChanged: (v) => _cardExpiry = v,
            onCVVChanged:    (v) => _cardCVV    = v,
          ),
        ],

        if (_payMethod == 'mobile') ...[
          _MobileMoneyForm(),
        ],

        if (_payMethod == 'wallet') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kSurf, borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Icon(Icons.account_balance_wallet_rounded, color: kGold, size: 32),
              SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('SwiftRide Wallet', style: TextStyle(color: kText, fontWeight: FontWeight.w700)),
                Text('Balance: \$240.00', style: TextStyle(color: kSuccess, fontSize: 13)),
              ]),
            ]),
          ),
        ],

        const SizedBox(height: 24),

        // Terms notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: kSurf2, borderRadius: BorderRadius.circular(10)),
          child: const Row(children: [
            Icon(Icons.shield_rounded, color: kSuccess, size: 16),
            SizedBox(width: 8),
            Expanded(child: Text(
              'Your payment is secured with 256-bit encryption. '
              'By proceeding you agree to our cancellation policy.',
              style: TextStyle(color: kTextS, fontSize: 11, height: 1.4),
            )),
          ]),
        ),
        const SizedBox(height: 20),

        SizedBox(height: 56, child: ElevatedButton(
          onPressed: _loading ? null : _confirmAndPay,
          style: ElevatedButton.styleFrom(
            backgroundColor: kSuccess,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          child: _loading
              ? const SizedBox(width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Text('Pay \$${_total.toStringAsFixed(0)}'),
        )),
        const SizedBox(height: 16),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════
  // STEP 2 — Confirmation
  // ════════════════════════════════════════════════════════════
  Widget _confirmedStep() {
    return SafeArea(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Spacer(),
        // Success animation placeholder
        Center(child: Container(
          width: 100, height: 100,
          decoration: const BoxDecoration(color: kSuccess, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 58),
        )),
        const SizedBox(height: 24),
        const Text('Booking Confirmed! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(color: kText, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Your ride is all set. Have a great trip!',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextS, fontSize: 14)),
        const SizedBox(height: 28),

        // Booking card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: kSurf, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kGold.withOpacity(0.2)),
          ),
          child: Column(children: [
            _ConfirmRow(label: 'Booking Ref', value: _confirmedRef, bold: true),
            const Divider(color: kSurf2, height: 20),
            _ConfirmRow(label: 'Car',         value: _carStr(widget.car, 'name')),
            const SizedBox(height: 8),
            _ConfirmRow(label: 'Pick-up',     value: _fmt(_start!)),
            const SizedBox(height: 8),
            _ConfirmRow(label: _isMonthlyMode ? 'Duration' : 'Return',
              value: _isMonthlyMode
                ? '${_months} month${_months > 1 ? "s" : ""}'
                : _fmt(_end!)),
            const SizedBox(height: 8),
            _ConfirmRow(label: 'Location',    value: _location),
            const SizedBox(height: 8),
            _ConfirmRow(label: 'Payment',     value: _payMethod.toUpperCase()),
            const Divider(color: kSurf2, height: 20),
            _ConfirmRow(label: 'Total Paid',  value: '\$${_total.toStringAsFixed(0)}',
                bold: true, goldValue: true),
          ]),
        ),

        const Spacer(),
        ElevatedButton(
          onPressed: () =>
              Navigator.pushNamedAndRemoveUntil(context, '/user/home', (_) => false),
          child: const Text('Back to Home'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () =>
              Navigator.pushNamed(context, '/user/my-bookings'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            side: const BorderSide(color: kGold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('View My Bookings', style: TextStyle(color: kGold)),
        ),
        const SizedBox(height: 16),
      ]),
    ));
  }
}

// ─── Reusable sub-widgets ─────────────────────────────────────

// Safe car map accessors — DDC-safe, never throw on Web
int _carColor(Map<String, dynamic> car) {
  final v = car['color'];
  if (v == null) return 0xFF37474F;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    // Handle "0xFF37474F" hex string format
    final hex = v.startsWith('0x') ? v.substring(2) : v;
    return int.tryParse(hex, radix: 16) ?? 0xFF37474F;
  }
  return 0xFF37474F;
}
int _carPrice(Map<String, dynamic> car) {
  final v = car['price'];
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    // Handle "$45/day", "$45", "45"
    final digits = v.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(digits) ?? 0;
  }
  return 0;
}
int _carSeats(Map<String, dynamic> car) {
  final v = car['seats'];
  if (v == null) return 5;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return 5;
}
double _carRating(Map<String, dynamic> car) {
  final v = car['rating'];
  if (v == null) return 0;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return 0;
}
String _carStr(Map<String, dynamic> car, String key, [String fallback = '']) {
  final v = car[key];
  if (v == null) return fallback;
  if (v is String) return v.isEmpty ? fallback : v;
  return v.toString();
}

class _MiniCarCard extends StatelessWidget {
  final Map<String, dynamic> car;
  final String? subtitle;
  const _MiniCarCard({required this.car, this.subtitle});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: kSurf, borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      ClipRRect(borderRadius: BorderRadius.circular(10), child: Container(
        width: 64, height: 64, color: Color(_carColor(car)),
        child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 32),
      )),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_carStr(car, 'name'),
            style: const TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 2),
        Text(subtitle ?? '${_carStr(car, "category")} · ${_carStr(car, "transmission")}',
            style: const TextStyle(color: kTextS, fontSize: 12)),
      ])),
      RichText(text: TextSpan(children: [
        TextSpan(text: '\$${_carPrice(car)}',
            style: const TextStyle(color: kGold, fontWeight: FontWeight.w800, fontSize: 16)),
        const TextSpan(text: '/day', style: TextStyle(color: kTextS, fontSize: 11)),
      ])),
    ]),
  );
}

class _DateBox extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback? onTap;
  const _DateBox({required this.label, this.date, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurf,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: date != null ? kGold : kSurf2, width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: kTextS, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          date == null ? 'Select date' : '${date!.day}/${date!.month}/${date!.year}',
          style: TextStyle(
            color: date == null ? kTextS : kText,
            fontWeight: FontWeight.w700, fontSize: 14,
          ),
        ),
      ]),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 15));
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool bold, goldValue;
  const _PriceRow(this.label, this.value, {this.bold = false, this.goldValue = false});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Flexible(child: Text(label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: kTextS, fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.normal))),
      const SizedBox(width: 12),
      Text(value, style: TextStyle(
        color: goldValue ? kGold : kText,
        fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
      )),
    ],
  );
}

class _PayMethodBtn extends StatelessWidget {
  final IconData icon; final String label, value, selected;
  final ValueChanged<String> onTap;
  const _PayMethodBtn({required this.icon, required this.label, required this.value,
      required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final sel = selected == value;
    return Expanded(child: GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: sel ? kGold.withOpacity(0.15) : kSurf,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? kGold : Colors.transparent, width: 1.5),
        ),
        child: Column(children: [
          Icon(icon, color: sel ? kGold : kTextS, size: 20),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: sel ? kGold : kTextS, fontSize: 11)),
        ]),
      ),
    ));
  }
}

class _CardForm extends StatelessWidget {
  final ValueChanged<String> onNumberChanged, onNameChanged, onExpiryChanged, onCVVChanged;
  const _CardForm({required this.onNumberChanged, required this.onNameChanged,
      required this.onExpiryChanged, required this.onCVVChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kSurf, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        // Card preview
        Container(
          height: 100, width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A3050), Color(0xFF0D1F3C)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGold.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Icon(Icons.credit_card_rounded, color: kGold, size: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: kGold.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: const Text('VISA', style: TextStyle(color: kGoldL, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
            ]),
            const Text('•••• •••• •••• ••••',
                style: TextStyle(color: kTextS, fontSize: 13, letterSpacing: 2)),
          ]),
        ),
        _FormField(label: 'Card Number', hint: '1234 5678 9012 3456',
            icon: Icons.credit_card_rounded, keyboardType: TextInputType.number, onChanged: onNumberChanged),
        const SizedBox(height: 10),
        _FormField(label: 'Cardholder Name', hint: 'JOHN DOE',
            icon: Icons.person_outline_rounded, onChanged: onNameChanged),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _FormField(label: 'Expiry', hint: 'MM/YY',
              icon: Icons.date_range_rounded, onChanged: onExpiryChanged)),
          const SizedBox(width: 10),
          Expanded(child: _FormField(label: 'CVV', hint: '•••',
              icon: Icons.lock_outline_rounded, keyboardType: TextInputType.number, onChanged: onCVVChanged)),
        ]),
      ]),
    );
  }
}

class _MobileMoneyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kSurf, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Mobile Money Provider', style: TextStyle(color: kTextS, fontSize: 12)),
        const SizedBox(height: 10),
        Row(children: [
          _MomoBtn(label: 'MTN MoMo', color: const Color(0xFFFFCC00)),
          const SizedBox(width: 10),
          _MomoBtn(label: 'Airtel Money', color: const Color(0xFFE60026)),
        ]),
        const SizedBox(height: 14),
        _FormField(label: 'Phone Number', hint: '+250 7XX XXX XXX',
            icon: Icons.phone_rounded, keyboardType: TextInputType.phone, onChanged: (_) {}),
      ]),
    );
  }
}

class _MomoBtn extends StatelessWidget {
  final String label; final Color color;
  const _MomoBtn({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(label, textAlign: TextAlign.center,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
  ));
}

class _FormField extends StatelessWidget {
  final String label, hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;
  const _FormField({required this.label, required this.hint, required this.icon,
      this.keyboardType, required this.onChanged});
  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    keyboardType: keyboardType,
    style: const TextStyle(color: kText),
    decoration: InputDecoration(
      labelText: label, hintText: hint, prefixIcon: Icon(icon),
    ),
  );
}

class _ConfirmRow extends StatelessWidget {
  final String label, value; final bool bold, goldValue;
  const _ConfirmRow({required this.label, required this.value, this.bold = false, this.goldValue = false});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(color: kTextS, fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
      Flexible(child: Text(value,
        textAlign: TextAlign.right,
        style: TextStyle(color: goldValue ? kGold : kText, fontSize: 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600),
      )),
    ],
  );
}

// ── Rental model info banner ────────────────────────────────────
class _RentalModelBanner extends StatelessWidget {
  final String rentalModel;
  const _RentalModelBanner({required this.rentalModel});

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
      case 'Monthly':   return 'This company rents by the month. Choose how many months below.';
      case 'Long-Term': return 'Minimum 6 months required. Choose your duration and start date.';
      case 'Hybrid':    return 'Choose daily or monthly pricing below.';
      default:          return 'Pick your start and end dates below.';
    }
  }

  Color get _color {
    switch (rentalModel) {
      case 'Monthly':   return const Color(0xFF1D9E75);
      case 'Long-Term': return const Color(0xFF7F77DD);
      case 'Hybrid':    return kGold;
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
      Expanded(child: Text(_desc, style: TextStyle(fontSize: 12, color: _color, fontWeight: FontWeight.w500))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
        child: Text(rentalModel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _color)),
      ),
    ]),
  );
}
