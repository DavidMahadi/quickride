// lib/screens/user/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/services/app_data_store.dart';
import 'package:swiftride/services/auth_service.dart';
import 'package:swiftride/services/wallet_service.dart';
import 'booking_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String carName, company, pickupDate, returnDate, pickupLocation, dropoffLocation;
  final int days;
  final double total;
  const PaymentScreen({
    super.key,
    required this.carName, required this.company,
    required this.pickupDate, required this.returnDate,
    required this.pickupLocation, required this.dropoffLocation,
    required this.days, required this.total,
  });
  @override State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _method = 0; // 0=card 1=mobile 2=cash
  bool _processing = false;

  // Card fields
  final _cardNum  = TextEditingController();
  final _cardName = TextEditingController();
  final _expiry   = TextEditingController();
  final _cvv      = TextEditingController();

  // Mobile money
  final _phone    = TextEditingController();
  int _mobileNet  = 0; // 0=MTN 1=Airtel

  @override void dispose() {
    _cardNum.dispose(); _cardName.dispose();
    _expiry.dispose();  _cvv.dispose(); _phone.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _processing = false);

    final payLabel = _method == 0 ? 'Credit Card'
        : _method == 1 ? 'Mobile Money' : 'Cash on Pickup';

    // ── Record booking to AppDataStore ────────────────────────
    final ref = 'SW${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final company = AppDataStore.instance.companyByName(widget.company);
    final booking = SharedBooking(
      id:              'B${DateTime.now().millisecondsSinceEpoch}',
      ref:             ref,
      customerId:      AuthService.currentUserId.isEmpty ? 'U001' : AuthService.currentUserId,
      customerName:    AuthService.userName,
      customerPhone:   AuthService.userPhone,
      carId:           '',
      carName:         widget.carName,
      carBrand:        '',
      carCategory:     '',
      carColor:        0xFF37474F,
      carSeats:        5,
      carFuel:         '',
      carTransmission: '',
      carYear:         '',
      companyId:       company?.id ?? '',
      companyName:     widget.company,
      pickupDate:      widget.pickupDate,
      returnDate:      widget.returnDate,
      pickupLocation:  widget.pickupLocation,
      dropoffLocation: widget.dropoffLocation,
      days:            widget.days,
      pricePerDay:     widget.days > 0 ? widget.total / widget.days : widget.total,
      subtotal:        widget.total * 0.88,
      serviceFee:      widget.total * 0.08,
      insurance:       widget.total * 0.04,
      total:           widget.total,
      paymentMethod:   payLabel,
      status:          'Upcoming',
      termsAgreed:     true,
    );
    AppDataStore.instance.addBooking(booking, AuthService.userName, 'Client');

    // ── Record payment to company wallet ───────────────────────
    WalletService.instance.recordBookingPayment(
      companyName:  widget.company,
      amount:       widget.total,
      bookingRef:   ref,
      customerName: AuthService.userName,
    );

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => BookingConfirmationScreen(
        carName: widget.carName, company: widget.company,
        pickupDate: widget.pickupDate, returnDate: widget.returnDate,
        pickupLocation: widget.pickupLocation,
        dropoffLocation: widget.dropoffLocation,
        days: widget.days, total: widget.total,
        paymentMethod: payLabel,
      ),
    ));
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
        title: Text('Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Order summary ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
            child: Column(children: [
              Row(children: [
                Container(width: 48, height: 48,
                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.directions_car, color: AppColors.gold, size: 26)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.carName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
                  Text(widget.company, style: TextStyle(fontSize: 12, color: textSec)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('\$${widget.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gold)),
                  Text('${widget.days} day${widget.days > 1 ? "s" : ""}', style: TextStyle(fontSize: 11, color: textSec)),
                ]),
              ]),
              const SizedBox(height: 12),
              Divider(color: border, height: 1),
              const SizedBox(height: 12),
              _SRow(Icons.calendar_today_outlined, '${widget.pickupDate} → ${widget.returnDate}', textSec),
              const SizedBox(height: 6),
              _SRow(Icons.location_on_outlined, widget.pickupLocation, textSec),
            ]),
          ),

          const SizedBox(height: 24),
          Text('Payment Method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPri)),
          const SizedBox(height: 12),

          // ── Payment method selector ──────────────────────────
          Row(children: [
            _MethodTab(label: 'Card',   icon: Icons.credit_card, selected: _method == 0, onTap: () => setState(() => _method = 0), border: border, textPri: textPri, textSec: textSec, card: card),
            const SizedBox(width: 10),
            _MethodTab(label: 'Mobile', icon: Icons.phone_android, selected: _method == 1, onTap: () => setState(() => _method = 1), border: border, textPri: textPri, textSec: textSec, card: card),
            const SizedBox(width: 10),
            _MethodTab(label: 'Cash',   icon: Icons.money, selected: _method == 2, onTap: () => setState(() => _method = 2), border: border, textPri: textPri, textSec: textSec, card: card),
          ]),

          const SizedBox(height: 20),

          // ── Payment form ─────────────────────────────────────
          if (_method == 0) _CardForm(
            cardNum: _cardNum, cardName: _cardName, expiry: _expiry, cvv: _cvv,
            isDark: isDark, card: card, border: border, textPri: textPri, textSec: textSec,
          ),

          if (_method == 1) _MobileForm(
            phone: _phone, network: _mobileNet,
            isDark: isDark, card: card, border: border, textPri: textPri, textSec: textSec,
            onNetworkChanged: (i) => setState(() => _mobileNet = i),
          ),

          if (_method == 2) _CashInfo(card: card, border: border, textPri: textPri, textSec: textSec),

          const SizedBox(height: 30),

          // ── Pay button ───────────────────────────────────────
          GestureDetector(
            onTap: _processing ? null : _pay,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(14)),
              child: _processing
                  ? const Center(child: SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5)))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        _method == 2
                          ? 'Confirm Booking'
                          : 'Pay \$${widget.total.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),
                      const SizedBox(width: 8),
                      const Icon(Icons.lock_outline, size: 16, color: Colors.black),
                    ]),
            ),
          ),

          const SizedBox(height: 14),
          Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.shield_outlined, size: 14, color: textSec),
            const SizedBox(width: 5),
            Text('256-bit encrypted & secure payment', style: TextStyle(fontSize: 11, color: textSec)),
          ])),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

// ── Summary row ─────────────────────────────────────────────────
class _SRow extends StatelessWidget {
  final IconData icon; final String text; final Color color;
  const _SRow(this.icon, this.text, this.color);
  @override Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14, color: color),
    const SizedBox(width: 8),
    Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: color), overflow: TextOverflow.ellipsis)),
  ]);
}

// ── Method tab ──────────────────────────────────────────────────
class _MethodTab extends StatelessWidget {
  final String label; final IconData icon; final bool selected;
  final VoidCallback onTap; final Color border, textPri, textSec, card;
  const _MethodTab({required this.label, required this.icon, required this.selected, required this.onTap, required this.border, required this.textPri, required this.textSec, required this.card});
  @override Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: selected ? AppColors.gold.withOpacity(0.1) : card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? AppColors.gold : border, width: selected ? 1.5 : 0.5)),
      child: Column(children: [
        Icon(icon, color: selected ? AppColors.gold : textSec, size: 22),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? AppColors.gold : textSec)),
      ]),
    ),
  ));
}

// ── Card form ───────────────────────────────────────────────────
class _CardForm extends StatelessWidget {
  final TextEditingController cardNum, cardName, expiry, cvv;
  final bool isDark; final Color card, border, textPri, textSec;
  const _CardForm({required this.cardNum, required this.cardName, required this.expiry, required this.cvv, required this.isDark, required this.card, required this.border, required this.textPri, required this.textSec});

  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
    child: Column(children: [
      // Card preview
      Container(
        width: double.infinity, height: 130,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1A2550), Color(0xFF0A0E21)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5)),
        child: Stack(children: [
          Positioned(top: 16, left: 16, child: const Text('SwiftRide', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w700))),
          Positioned(top: 16, right: 16, child: const Icon(Icons.credit_card, color: AppColors.gold, size: 28)),
          Positioned(bottom: 30, left: 16, child: Text(
            cardNum.text.isEmpty ? '•••• •••• •••• ••••' : cardNum.text,
            style: const TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 2, fontWeight: FontWeight.w600))),
          Positioned(bottom: 14, left: 16, child: Text(
            cardName.text.isEmpty ? 'CARDHOLDER NAME' : cardName.text.toUpperCase(),
            style: const TextStyle(color: Colors.white60, fontSize: 11))),
          Positioned(bottom: 14, right: 16, child: Text(
            expiry.text.isEmpty ? 'MM/YY' : expiry.text,
            style: const TextStyle(color: Colors.white60, fontSize: 11))),
        ]),
      ),
      _TF(ctrl: cardNum,  label: 'Card Number',    hint: '1234 5678 9012 3456', keyboard: TextInputType.number, isDark: isDark, border: border, textPri: textPri, textSec: textSec),
      const SizedBox(height: 12),
      _TF(ctrl: cardName, label: 'Cardholder Name',hint: AuthService.userName, isDark: isDark, border: border, textPri: textPri, textSec: textSec),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _TF(ctrl: expiry, label: 'Expiry', hint: 'MM/YY', keyboard: TextInputType.number, isDark: isDark, border: border, textPri: textPri, textSec: textSec)),
        const SizedBox(width: 12),
        Expanded(child: _TF(ctrl: cvv, label: 'CVV', hint: '•••', keyboard: TextInputType.number, isDark: isDark, border: border, textPri: textPri, textSec: textSec, obscure: true)),
      ]),
    ]),
  );
}

// ── Mobile money form ───────────────────────────────────────────
class _MobileForm extends StatelessWidget {
  final TextEditingController phone; final int network;
  final bool isDark; final Color card, border, textPri, textSec;
  final ValueChanged<int> onNetworkChanged;
  const _MobileForm({required this.phone, required this.network, required this.isDark, required this.card, required this.border, required this.textPri, required this.textSec, required this.onNetworkChanged});

  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Select Network', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
      const SizedBox(height: 12),
      Row(children: [
        _NetBtn(label: 'MTN Money', color: const Color(0xFFFFCC00), selected: network == 0, onTap: () => onNetworkChanged(0), border: border, card: card),
        const SizedBox(width: 10),
        _NetBtn(label: 'Airtel Money', color: const Color(0xFFE30613), selected: network == 1, onTap: () => onNetworkChanged(1), border: border, card: card),
      ]),
      const SizedBox(height: 16),
      _TF(ctrl: phone, label: 'Phone Number', hint: '+250 7XX XXX XXX', keyboard: TextInputType.phone, isDark: isDark, border: border, textPri: textPri, textSec: textSec),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5)),
        child: Row(children: [
          const Icon(Icons.info_outline, color: AppColors.gold, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text('You will receive a USSD prompt to confirm payment.', style: TextStyle(fontSize: 12, color: textSec))),
        ]),
      ),
    ]),
  );
}

class _NetBtn extends StatelessWidget {
  final String label; final Color color; final bool selected;
  final VoidCallback onTap; final Color border, card;
  const _NetBtn({required this.label, required this.color, required this.selected, required this.onTap, required this.border, required this.card});
  @override Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.12) : card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selected ? color : border, width: selected ? 1.5 : 0.5)),
      child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w400, color: selected ? color : border))),
    ),
  ));
}

// ── Cash info ───────────────────────────────────────────────────
class _CashInfo extends StatelessWidget {
  final Color card, border, textPri, textSec;
  const _CashInfo({required this.card, required this.border, required this.textPri, required this.textSec});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 0.5)),
    child: Column(children: [
      Container(width: 60, height: 60,
        decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), shape: BoxShape.circle),
        child: const Icon(Icons.money, color: AppColors.gold, size: 30)),
      const SizedBox(height: 12),
      Text('Pay at Pickup', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPri)),
      const SizedBox(height: 8),
      Text('Pay in cash when you collect the car.\nExact amount required.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: textSec, height: 1.5)),
      const SizedBox(height: 16),
      ...[
        'Booking confirmed instantly',
        'Pay in RWF or USD at pickup',
        'Receipt provided at pickup',
      ].map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF1D9E75), size: 16),
          const SizedBox(width: 8),
          Text(s, style: TextStyle(fontSize: 13, color: textPri)),
        ]),
      )),
    ]),
  );
}

// ── Text field ──────────────────────────────────────────────────
class _TF extends StatelessWidget {
  final TextEditingController ctrl; final String label, hint;
  final TextInputType keyboard; final bool isDark, obscure;
  final Color border, textPri, textSec;
  const _TF({required this.ctrl, required this.label, required this.hint, this.keyboard = TextInputType.text, required this.isDark, required this.border, required this.textPri, required this.textSec, this.obscure = false});
  @override Widget build(BuildContext context) => TextField(
    controller: ctrl, keyboardType: keyboard, obscureText: obscure,
    style: TextStyle(color: textPri, fontSize: 14),
    decoration: InputDecoration(
      labelText: label, hintText: hint,
      labelStyle: TextStyle(color: textSec, fontSize: 12),
      hintStyle: TextStyle(color: textSec.withOpacity(0.5), fontSize: 13),
      filled: true,
      fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}
