// lib/screens/admin/wallet_tab.dart
// ─────────────────────────────────────────────────────────────
//  WalletTab  —  reusable wallet UI used by both
//                SuperAdminScreen and CompanyAdminScreen.
//
//  SuperAdmin mode : ownerKey = kPlatformKey
//                   shows platform wallet + all company sub-wallets
//  Company mode    : ownerKey = companyName
//                   shows only that company's wallet
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:swiftride/services/wallet_service.dart';

class WalletTab extends StatefulWidget {
  final String ownerKey;       // kPlatformKey or company name
  final bool isSuperAdmin;
  final Color card, border, textPri, textSec, bg;

  const WalletTab({
    super.key,
    required this.ownerKey,
    required this.isSuperAdmin,
    required this.card,
    required this.border,
    required this.textPri,
    required this.textSec,
    required this.bg,
  });

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  static const _gold  = Color(0xFFD4A017);
  static const _green = Color(0xFF1D9E75);
  static const _red   = Color(0xFFD85A30);
  static const _blue  = Color(0xFF3B5FD4);

  WalletService get _ws => WalletService.instance;

  WalletAccount get _myWallet => widget.isSuperAdmin
      ? _ws.platformWallet
      : _ws.walletFor(widget.ownerKey);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Pending requests banner (company admin only) ─────────
        if (!widget.isSuperAdmin) ...[
          Builder(builder: (ctx) {
            final pending = _ws.pendingForCompany(widget.ownerKey);
            if (pending.isEmpty) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => _showPendingRequests(ctx),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _gold.withOpacity(0.4), width: 1),
                ),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                        color: _gold.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_active_rounded,
                        color: _gold, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${pending.length} pending request${pending.length > 1 ? 's' : ''}',
                        style: const TextStyle(color: _gold, fontSize: 13, fontWeight: FontWeight.w700)),
                    Text('Super Admin has requested wallet actions requiring your approval',
                        style: TextStyle(color: widget.textSec, fontSize: 11, height: 1.3)),
                  ])),
                  Icon(Icons.chevron_right_rounded, color: widget.textSec, size: 18),
                ]),
              ),
            );
          }),
        ],

        // ── My Wallet card ──────────────────────────────────────
        _WalletCard(
          wallet: _myWallet,
          isSuperAdmin: widget.isSuperAdmin,
          card: widget.card,
          border: widget.border,
          textPri: widget.textPri,
          textSec: widget.textSec,
          onSend:     () => _showSend(context),
          onWithdraw: () => _showWithdraw(context),
        ),

        // ── Super admin: total across all wallets ───────────────
        if (widget.isSuperAdmin) ...[
          const SizedBox(height: 16),
          _TotalCard(ws: _ws, card: widget.card, border: widget.border,
              textPri: widget.textPri, textSec: widget.textSec),
          const SizedBox(height: 20),
          Text('Company Wallets',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.textPri)),
          const SizedBox(height: 10),
          ..._ws.allCompanyWallets.map((w) => _CompanyWalletCard(
            wallet: w,
            commission: _ws.commissionFor(w.ownerKey),
            card: widget.card,
            border: widget.border,
            textPri: widget.textPri,
            textSec: widget.textSec,
            onTap: () => _showCompanyWalletDetail(context, w),
          )),
        ],

        // ── Transaction history ─────────────────────────────────
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Transaction History',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.textPri)),
          Text('${_myWallet.transactions.length} total',
              style: TextStyle(fontSize: 11, color: widget.textSec)),
        ]),
        const SizedBox(height: 10),
        if (_myWallet.transactions.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text('No transactions yet', style: TextStyle(color: widget.textSec)),
          ))
        else
          ..._myWallet.transactions.map((tx) => _TxRow(
            tx: tx,
            card: widget.card,
            border: widget.border,
            textPri: widget.textPri,
            textSec: widget.textSec,
            onTap: () => _showTxDetail(context, tx),
          )),
        const SizedBox(height: 24),
      ]),
    );
  }

  // ── Action sheets ─────────────────────────────────────────────

  void _showSend(BuildContext ctx) {
    final amtC      = TextEditingController();
    final noteC     = TextEditingController();
    final bankNameC = TextEditingController();
    final accountC  = TextEditingController();
    final phoneC    = TextEditingController();
    String? toKey;
    String? err;
    int methodIdx = 0; // 0=MTN, 1=Airtel, 2=Bank

    final allWallets = widget.isSuperAdmin
        ? _ws.allCompanyWallets.map((w) => (w.ownerKey, w.displayName)).toList()
        : [
            (kPlatformKey, 'SwiftRide Platform'),
            ..._ws.allCompanyWallets
                .where((w) => w.ownerKey != widget.ownerKey)
                .map((w) => (w.ownerKey, w.displayName)),
          ];

    _sheet(ctx, 'Send Money', [
      StatefulBuilder(builder: (c, ss) {
        final methods = [
          (Icons.phone_android_rounded, 'MTN Mobile Money', const Color(0xFFFFCC00)),
          (Icons.phone_android_rounded, 'Airtel Money',     const Color(0xFFD85A30)),
          (Icons.account_balance_rounded, 'Bank Transfer',  const Color(0xFF3B5FD4)),
        ];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        _Label('Payment Method', widget.textSec),
        Row(children: List.generate(3, (i) {
          final sel = methodIdx == i;
          final m = methods[i];
          return Expanded(child: GestureDetector(
            onTap: () => ss(() { methodIdx = i; phoneC.clear(); bankNameC.clear(); accountC.clear(); }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? m.$3.withOpacity(0.12) : widget.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? m.$3 : widget.border, width: sel ? 1.5 : 0.8),
              ),
              child: Column(children: [
                Icon(m.$1, color: sel ? m.$3 : widget.textSec, size: 18),
                const SizedBox(height: 4),
                Text(m.$2, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        color: sel ? m.$3 : widget.textSec)),
              ]),
            ),
          ));
        })),
        const SizedBox(height: 14),
        // Dynamic fields by method
        if (methodIdx == 2) ...[
          _Label('Bank Name', widget.textSec),
          _Field(ctrl: bankNameC, hint: 'e.g. Equity Bank, BPR, Bank of Kigali',
              textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),
          const SizedBox(height: 10),
          _Label('Account Number', widget.textSec),
          _Field(ctrl: accountC, hint: 'e.g. RW-EQ-001-4521',
              textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),
        ] else ...[
          _Label(methodIdx == 0 ? 'MTN Phone Number' : 'Airtel Phone Number', widget.textSec),
          _Field(ctrl: phoneC, hint: '+250 78X XXX XXX',
              keyboardType: TextInputType.phone,
              textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),
        ],
        const SizedBox(height: 10),
        _Label('Amount (USD)', widget.textSec),
        _Field(ctrl: amtC, hint: '0.00', keyboardType: TextInputType.number,
            textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),
        const SizedBox(height: 10),
        _Label('Note (optional)', widget.textSec),
        _Field(ctrl: noteC, hint: 'Payment note', textPri: widget.textPri,
            textSec: widget.textSec, card: widget.card, border: widget.border),
        if (err != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.error_outline_rounded, color: _red, size: 13),
            const SizedBox(width: 4),
            Expanded(child: Text(err!, style: const TextStyle(color: _red, fontSize: 12))),
          ]),
        ],
        const SizedBox(height: 20),
        _ActionBtn('Send Money', _gold, () {
          final amt = double.tryParse(amtC.text) ?? 0;
          if (amt <= 0)      { ss(() => err = 'Enter a valid amount'); return; }
          if (methodIdx == 2 && (bankNameC.text.isEmpty || accountC.text.isEmpty)) {
            ss(() => err = 'Enter bank name and account number'); return;
          }
          if (methodIdx != 2 && phoneC.text.isEmpty) {
            ss(() => err = 'Enter your phone number'); return;
          }
          Navigator.pop(ctx);
          _confirmPassword(ctx, action: 'Send Money', onConfirmed: () {
            final error = _ws.send(
              fromKey: widget.isSuperAdmin ? kPlatformKey : widget.ownerKey,
              toKey: toKey!,
              amount: amt,
              note: noteC.text,
            );
            if (error != null) { _toast(ctx, error); return; }
            setState(() {});
            _toast(ctx, 'Sent \$${amt.toStringAsFixed(0)} successfully');
          });
        }),
      ]);
      }),
    ]);
  }

  void _showWithdraw(BuildContext ctx) {
    _showWithdrawSheet(
      ctx,
      title: 'Withdraw Money',
      ownerKey: widget.isSuperAdmin ? kPlatformKey : widget.ownerKey,
      onSuccess: () => _toast(ctx, 'Withdrawal recorded'),
    );
  }

  // ── Shared withdraw sheet (used by own-wallet and company-wallet) ─
  void _showWithdrawSheet(BuildContext ctx, {
    required String title,
    required String ownerKey,
    required VoidCallback onSuccess,
  }) {
    final amtC    = TextEditingController();
    final noteC   = TextEditingController();
    final bankNameC = TextEditingController();
    final accountC  = TextEditingController();
    final phoneC    = TextEditingController();
    // 0 = MTN, 1 = Airtel, 2 = Bank
    int methodIdx = 0;
    String? err;

    _sheet(ctx, title, [
      StatefulBuilder(builder: (c, ss) {
        // Payment type selector
        final methods = [
          (Icons.phone_android_rounded, 'MTN Mobile Money', const Color(0xFFFFCC00)),
          (Icons.phone_android_rounded, 'Airtel Money',     const Color(0xFFD85A30)),
          (Icons.account_balance_rounded, 'Bank Transfer',  const Color(0xFF3B5FD4)),
        ];

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Label('Payment Method', widget.textSec),
          Row(children: List.generate(3, (i) {
            final sel = methodIdx == i;
            final m = methods[i];
            return Expanded(child: GestureDetector(
              onTap: () => ss(() => methodIdx = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? m.$3.withOpacity(0.12) : widget.bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? m.$3 : widget.border, width: sel ? 1.5 : 0.8),
                ),
                child: Column(children: [
                  Icon(m.$1, color: sel ? m.$3 : widget.textSec, size: 18),
                  const SizedBox(height: 4),
                  Text(m.$2, textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 9, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                          color: sel ? m.$3 : widget.textSec)),
                ]),
              ),
            ));
          })),

          const SizedBox(height: 14),

          // Dynamic fields based on method
          if (methodIdx == 2) ...[
            _Label('Bank Name', widget.textSec),
            _Field(ctrl: bankNameC, hint: 'e.g. Equity Bank, BPR, Bank of Kigali',
                textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),
            const SizedBox(height: 10),
            _Label('Account Number', widget.textSec),
            _Field(ctrl: accountC, hint: 'e.g. RW-EQ-001-4521',
                textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),
          ] else ...[
            _Label(methodIdx == 0 ? 'MTN Phone Number' : 'Airtel Phone Number', widget.textSec),
            _Field(ctrl: phoneC, hint: '+250 78X XXX XXX',
                keyboardType: TextInputType.phone,
                textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),
          ],

          const SizedBox(height: 10),
          _Label('Amount (USD)', widget.textSec),
          _Field(ctrl: amtC, hint: '0.00', keyboardType: TextInputType.number,
              textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),
          const SizedBox(height: 10),
          _Label('Note (optional)', widget.textSec),
          _Field(ctrl: noteC, hint: 'Withdrawal reason',
              textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),

          if (err != null) ...[
            const SizedBox(height: 8),
            Text(err!, style: const TextStyle(color: _red, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          _ActionBtn('Withdraw', _red, () {
            final amt  = double.tryParse(amtC.text) ?? 0;
            final ref  = methodIdx == 2 ? accountC.text : phoneC.text;
            final name = methodIdx == 2 ? bankNameC.text
                : methodIdx == 0 ? 'MTN Mobile Money' : 'Airtel Money';
            if (amt <= 0) { ss(() => err = 'Enter a valid amount'); return; }
            if (methodIdx == 2 && (bankNameC.text.isEmpty || accountC.text.isEmpty)) {
              ss(() => err = 'Enter bank name and account number'); return;
            }
            if (methodIdx != 2 && phoneC.text.isEmpty) {
              ss(() => err = 'Enter your phone number'); return;
            }
            // Close sheet, then confirm password, then execute
            Navigator.pop(ctx);
            _confirmPassword(ctx, action: 'Withdrawal', onConfirmed: () {
              final pm = methodIdx == 0 ? PaymentMethodType.mobileMTN
                  : methodIdx == 1 ? PaymentMethodType.mobileAirtel
                  : PaymentMethodType.bank;
              final error = _ws.withdraw(
                ownerKey: ownerKey, amount: amt,
                destination: name, note: noteC.text,
                paymentMethod: pm, paymentMethodName: name, paymentAccountRef: ref,
              );
              if (error != null) { _toast(ctx, error); return; }
              setState(() {});
              onSuccess();
            });
          }),
        ]);
      }),
    ]);
  }

  void _showCompanyWalletDetail(BuildContext ctx, WalletAccount w) {
    final commission = _ws.commissionFor(w.ownerKey);
    final initials = w.ownerKey.length >= 2
        ? w.ownerKey.substring(0, 2).toUpperCase()
        : w.ownerKey.toUpperCase();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: widget.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx2, ss) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.92,
          minChildSize: 0.5,
          builder: (_, ctrl) => Column(children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: widget.border, borderRadius: BorderRadius.circular(2)))),
            ),
            Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(20, 0, 20, 32), children: [

              // Header
              Row(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: _blue.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(initials,
                      style: const TextStyle(color: _blue, fontSize: 18, fontWeight: FontWeight.w800))),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(w.ownerKey, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: widget.textPri)),
                  Text('Company Wallet', style: TextStyle(fontSize: 12, color: widget.textSec)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _green.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Active', style: TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ]),

              const SizedBox(height: 20),

              // Balance card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF141828), Color(0xFF1C2236)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _gold.withOpacity(0.2), width: 0.8),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Current Balance', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 6),
                  Text('\$${w.balance.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  Row(children: [
                    _InfoPill(label: 'Total In',  value: '\$${w.totalReceived.toStringAsFixed(0)}', color: _green),
                    const SizedBox(width: 10),
                    _InfoPill(label: 'Total Out', value: '\$${w.totalSent.toStringAsFixed(0)}',     color: _red),
                    const SizedBox(width: 10),
                    _InfoPill(label: 'Txns',      value: '${w.transactions.length}',               color: _gold),
                  ]),
                ]),
              ),

              const SizedBox(height: 16),

              // Info grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: widget.card, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: widget.border, width: 0.5)),
                child: Column(children: [
                  _DetailRow(Icons.percent_rounded,                'Commission Rate',    '${commission.toStringAsFixed(0)}% per booking', widget.textPri, widget.textSec),
                  Divider(color: widget.border, height: 20),
                  _DetailRow(Icons.account_balance_wallet_rounded, 'Net Per Booking',   '${(100 - commission).toStringAsFixed(0)}% goes to this wallet', widget.textPri, widget.textSec),
                  Divider(color: widget.border, height: 20),
                  _DetailRow(Icons.receipt_long_rounded,           'Transactions',      '${w.transactions.length} recorded', widget.textPri, widget.textSec),
                  Divider(color: widget.border, height: 20),
                  _DetailRow(Icons.trending_up_rounded,            'Avg Tx Size',
                      w.transactions.isEmpty ? 'N/A'
                          : '\$${(w.transactions.fold(0.0, (s, t) => s + t.amount) / w.transactions.length).toStringAsFixed(0)}',
                      widget.textPri, widget.textSec),
                ]),
              ),

              const SizedBox(height: 20),

              // Actions
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: () { Navigator.pop(ctx); _showRequestSendToCompany(ctx, w.ownerKey); },
                  icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                  label: const Text('Send to Wallet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold, foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0, textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                )),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () { Navigator.pop(ctx); _showRequestWithdrawFor(ctx, w.ownerKey); },
                  icon: const Icon(Icons.account_balance_rounded, size: 16),
                  label: const Text('Withdraw'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _red),
                    foregroundColor: _red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                )),
              ]),
              const SizedBox(height: 8),
              Center(child: Text(
                'Actions require Company Admin approval',
                style: TextStyle(fontSize: 10, color: widget.textSec),
              )),

              const SizedBox(height: 24),

              // Recent transactions
              Text('Recent Transactions',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.textPri)),
              const SizedBox(height: 10),
              if (w.transactions.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text('No transactions yet', style: TextStyle(color: widget.textSec, fontSize: 13)),
                ))
              else
                ...w.transactions.take(5).map((tx) => _TxRow(
                  tx: tx, card: widget.bg,
                  border: widget.border,
                  textPri: widget.textPri, textSec: widget.textSec,
                  onTap: () => _showTxDetail(ctx, tx),
                )),
            ])),
          ]),
        );
      }),
    );
  }

  void _showWithdrawFor(BuildContext ctx, String ownerKey) {
    _showWithdrawSheet(
      ctx,
      title: 'Withdraw from ${_ws.walletFor(ownerKey).ownerKey}',
      ownerKey: ownerKey,
      onSuccess: () => _toast(ctx, 'Withdrawal recorded'),
    );
  }

  // ── Transaction detail sheet ──────────────────────────────────
  void _showTxDetail(BuildContext ctx, WalletTx tx) {
    final color   = tx.typeColor(ctx);
    final sign    = tx.isCredit ? '+' : '-';
    final dateStr = '${tx.at.day}/${tx.at.month}/${tx.at.year}';
    final timeStr = '${tx.at.hour.toString().padLeft(2,'0')}:${tx.at.minute.toString().padLeft(2,'0')}';
    final hasPayMethod = tx.paymentMethod != PaymentMethodType.none;

    showModalBottomSheet(
      context: ctx,
      backgroundColor: widget.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            // Handle
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: widget.border,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),

            // ── SUMMARY ──────────────────────────────────────────
            Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(tx.typeIcon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tx.typeLabel,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                        color: widget.textPri)),
                const SizedBox(height: 2),
                Text(tx.description,
                    style: TextStyle(fontSize: 12, color: widget.textSec), maxLines: 2),
                const SizedBox(height: 4),
                // Payment method badge
                if (hasPayMethod)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tx.paymentMethodIcon == Icons.account_balance_rounded
                          ? const Color(0xFF3B5FD4).withOpacity(0.12)
                          : const Color(0xFF1D9E75).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(tx.paymentMethodIcon,
                          size: 11,
                          color: tx.paymentMethodIcon == Icons.account_balance_rounded
                              ? const Color(0xFF3B5FD4)
                              : const Color(0xFF1D9E75)),
                      const SizedBox(width: 4),
                      Text(tx.paymentMethodName.isEmpty ? 'Payment' : tx.paymentMethodName,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                              color: tx.paymentMethodIcon == Icons.account_balance_rounded
                                  ? const Color(0xFF3B5FD4)
                                  : const Color(0xFF1D9E75))),
                    ]),
                  ),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('$sign\$${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
                Text(dateStr, style: TextStyle(fontSize: 11, color: widget.textSec)),
                Text(timeStr, style: TextStyle(fontSize: 11, color: widget.textSec)),
              ]),
            ]),

            const SizedBox(height: 20),
            Divider(color: widget.border, height: 1),
            const SizedBox(height: 16),

            // ── FULL DETAILS ─────────────────────────────────────
            Text('Transaction Details',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: widget.textPri)),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.border, width: 0.5),
              ),
              child: Column(children: [
                _TxDetailRow('Transaction ID', tx.id,
                    widget.textPri, widget.textSec, widget.border),
                _TxDetailRow('Type', tx.typeLabel,
                    widget.textPri, widget.textSec, widget.border),
                _TxDetailRow('Description', tx.description,
                    widget.textPri, widget.textSec, widget.border),
                _TxDetailRow('Counterpart',
                    tx.counterpart.isEmpty ? '—' : tx.counterpart,
                    widget.textPri, widget.textSec, widget.border),
                _TxDetailRow('Date & Time', '$dateStr at $timeStr',
                    widget.textPri, widget.textSec, widget.border),
                _TxDetailRow('Amount', '$sign\$${tx.amount.toStringAsFixed(2)}',
                    widget.textPri, widget.textSec, widget.border,
                    valueColor: color),

                // Payment method section
                if (hasPayMethod) ...[
                  Divider(color: widget.border.withOpacity(0.5), height: 20),
                  Align(alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text('Payment Method',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                              color: widget.textSec, letterSpacing: 0.3)),
                    )),
                  _TxDetailRow('Method',
                      tx.paymentMethod == PaymentMethodType.bank ? 'Bank Transfer'
                      : tx.paymentMethod == PaymentMethodType.mobileMTN ? 'MTN Mobile Money'
                      : tx.paymentMethod == PaymentMethodType.mobileAirtel ? 'Airtel Money'
                      : tx.paymentMethod == PaymentMethodType.internal ? 'Internal Transfer'
                      : '—',
                      widget.textPri, widget.textSec, widget.border),
                  if (tx.paymentMethodName.isNotEmpty)
                    _TxDetailRow(
                      tx.paymentMethod == PaymentMethodType.bank ? 'Bank Name' : 'Provider',
                      tx.paymentMethodName,
                      widget.textPri, widget.textSec, widget.border),
                  if (tx.paymentAccountRef.isNotEmpty)
                    _TxDetailRow(
                      tx.paymentMethod == PaymentMethodType.bank ? 'Account No.' : 'Phone No.',
                      tx.paymentAccountRef,
                      widget.textPri, widget.textSec, widget.border,
                      isLast: true),
                  if (tx.paymentAccountRef.isEmpty)
                    _TxDetailRow('Reference', '—',
                        widget.textPri, widget.textSec, widget.border, isLast: true),
                ] else
                  const SizedBox.shrink(),
              ]),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: widget.border),
                  foregroundColor: widget.textPri,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pending requests list (company admin) ─────────────────────
  void _showPendingRequests(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: widget.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx2, ss) {
        final pending = _ws.pendingForCompany(widget.ownerKey);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          builder: (_, ctrl) => Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: widget.border,
                      borderRadius: BorderRadius.circular(2)))),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(children: [
                Container(width: 32, height: 32,
                  decoration: BoxDecoration(color: _gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.pending_actions_rounded, color: _gold, size: 16)),
                const SizedBox(width: 10),
                Text('Pending Approvals',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                        color: widget.textPri)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('${pending.length}',
                      style: const TextStyle(color: _gold, fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
            Divider(color: widget.border, height: 1),
            Expanded(
              child: pending.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_circle_rounded, color: _green, size: 48),
                      const SizedBox(height: 12),
                      Text('All caught up!',
                          style: TextStyle(color: widget.textPri, fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('No pending requests',
                          style: TextStyle(color: widget.textSec, fontSize: 12)),
                    ]))
                  : ListView.separated(
                      controller: ctrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: pending.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final req = pending[i];
                        final isSend = req.type == PendingRequestType.send;
                        final color = isSend ? _gold : _red;
                        final icon  = isSend ? Icons.arrow_upward_rounded
                                              : Icons.account_balance_rounded;
                        final dateStr = '${req.createdAt.day}/${req.createdAt.month}/${req.createdAt.year}';

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: widget.bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: color.withOpacity(0.3), width: 0.8),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Container(width: 36, height: 36,
                                decoration: BoxDecoration(color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(9)),
                                child: Icon(icon, color: color, size: 17)),
                              const SizedBox(width: 10),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(req.typeLabel,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                        color: widget.textPri)),
                                Text('Requested by Super Admin · $dateStr',
                                    style: TextStyle(fontSize: 10, color: widget.textSec)),
                              ])),
                              Text('\$${req.amount.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                                      color: color)),
                            ]),
                            if (req.destination.isNotEmpty || req.note.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              if (req.destination.isNotEmpty)
                                _ReqInfoRow(Icons.location_on_outlined,
                                    isSend ? 'To' : 'Destination',
                                    req.destination, widget.textSec),
                              if (req.note.isNotEmpty)
                                _ReqInfoRow(Icons.notes_rounded, 'Note',
                                    req.note, widget.textSec),
                            ],
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(child: OutlinedButton(
                                onPressed: () {
                                  _ws.rejectRequest(req.id);
                                  ss(() {});
                                  setState(() {});
                                  _toast(ctx2, 'Request rejected');
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: _red),
                                  foregroundColor: _red,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  textStyle: const TextStyle(fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                                child: const Text('Reject'),
                              )),
                              const SizedBox(width: 10),
                              Expanded(child: ElevatedButton(
                                onPressed: () {
                                  final err = _ws.approveRequest(req.id);
                                  ss(() {});
                                  setState(() {});
                                  Navigator.pop(ctx2);
                                  if (err != null) {
                                    _toast(ctx, 'Error: $err');
                                  } else {
                                    _toast(ctx, '✓ Request approved & executed');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                  textStyle: const TextStyle(fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                                child: const Text('Approve'),
                              )),
                            ]),
                          ]),
                        );
                      },
                    ),
            ),
          ]),
        );
      }),
    );
  }

  // ── Super Admin: create request (send) for company wallet ─────
  void _showRequestSendToCompany(BuildContext ctx, String toKey) {
    final amtC  = TextEditingController();
    final noteC = TextEditingController();
    String? err;

    _sheet(ctx, 'Request Send to ${_ws.walletFor(toKey).ownerKey}', [
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _gold.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _gold.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, color: _gold, size: 15),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'This will send a request to the Company Admin for approval before the transfer is made.',
            style: TextStyle(fontSize: 11, color: widget.textSec, height: 1.3),
          )),
        ]),
      ),
      StatefulBuilder(builder: (c, ss) => Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Label('Amount (USD)', widget.textSec),
        _Field(ctrl: amtC, hint: '0.00', keyboardType: TextInputType.number,
            textPri: widget.textPri, textSec: widget.textSec,
            card: widget.card, border: widget.border),
        const SizedBox(height: 12),
        _Label('Note', widget.textSec),
        _Field(ctrl: noteC, hint: 'Reason for transfer',
            textPri: widget.textPri, textSec: widget.textSec,
            card: widget.card, border: widget.border),
        if (err != null) ...[
          const SizedBox(height: 8),
          Text(err!, style: const TextStyle(color: _red, fontSize: 12)),
        ],
        const SizedBox(height: 20),
        _ActionBtn('Submit Request', _gold, () {
          final amt = double.tryParse(amtC.text) ?? 0;
          if (amt <= 0) { ss(() => err = 'Enter a valid amount'); return; }
          _ws.createRequest(
            type: PendingRequestType.send,
            companyKey: toKey,
            amount: amt,
            destination: toKey,
            note: noteC.text,
          );
          Navigator.pop(ctx);
          setState(() {});
          _toast(ctx, 'Request sent to ${_ws.walletFor(toKey).ownerKey} Admin for approval');
        }),
      ])),
    ]);
  }

  // ── Super Admin: create request (withdraw) for company wallet ─
  void _showRequestWithdrawFor(BuildContext ctx, String ownerKey) {
    final amtC      = TextEditingController();
    final noteC     = TextEditingController();
    final bankNameC = TextEditingController();
    final accountC  = TextEditingController();
    final phoneC    = TextEditingController();
    int methodIdx = 0;
    String? err;

    final methods = [
      (Icons.phone_android_rounded, 'MTN Mobile Money', const Color(0xFFFFCC00)),
      (Icons.phone_android_rounded, 'Airtel Money',     const Color(0xFFD85A30)),
      (Icons.account_balance_rounded, 'Bank Transfer',  const Color(0xFF3B5FD4)),
    ];

    _sheet(ctx, 'Request Withdrawal from ${_ws.walletFor(ownerKey).ownerKey}', [
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _red.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _red.withOpacity(0.25)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, color: _red, size: 15),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'The Company Admin must approve this withdrawal before funds are moved.',
            style: TextStyle(fontSize: 11, color: widget.textSec, height: 1.3),
          )),
        ]),
      ),
      StatefulBuilder(builder: (c, ss) => Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Label('Payment Method', widget.textSec),
        Row(children: List.generate(3, (i) {
          final sel = methodIdx == i;
          final m = methods[i];
          return Expanded(child: GestureDetector(
            onTap: () => ss(() => methodIdx = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? m.$3.withOpacity(0.12) : widget.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? m.$3 : widget.border, width: sel ? 1.5 : 0.8),
              ),
              child: Column(children: [
                Icon(m.$1, color: sel ? m.$3 : widget.textSec, size: 18),
                const SizedBox(height: 4),
                Text(m.$2, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        color: sel ? m.$3 : widget.textSec)),
              ]),
            ),
          ));
        })),
        const SizedBox(height: 12),
        if (methodIdx == 2) ...[
          _Label('Bank Name', widget.textSec),
          _Field(ctrl: bankNameC, hint: 'e.g. Equity Bank, BPR, Bank of Kigali',
              textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),
          const SizedBox(height: 10),
          _Label('Account Number', widget.textSec),
          _Field(ctrl: accountC, hint: 'e.g. RW-EQ-001-4521',
              textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),
        ] else ...[
          _Label(methodIdx == 0 ? 'MTN Phone Number' : 'Airtel Phone Number', widget.textSec),
          _Field(ctrl: phoneC, hint: '+250 78X XXX XXX', keyboardType: TextInputType.phone,
              textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),
        ],
        const SizedBox(height: 10),
        _Label('Amount (USD)', widget.textSec),
        _Field(ctrl: amtC, hint: '0.00', keyboardType: TextInputType.number,
            textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),
        const SizedBox(height: 10),
        _Label('Note (optional)', widget.textSec),
        _Field(ctrl: noteC, hint: 'Withdrawal reason',
            textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),
        if (err != null) ...[
          const SizedBox(height: 8),
          Text(err!, style: const TextStyle(color: _red, fontSize: 12)),
        ],
        const SizedBox(height: 20),
        _ActionBtn('Submit Request', _red, () {
          final amt  = double.tryParse(amtC.text) ?? 0;
          final ref  = methodIdx == 2 ? accountC.text : phoneC.text;
          final name = methodIdx == 2 ? bankNameC.text
              : methodIdx == 0 ? 'MTN Mobile Money' : 'Airtel Money';
          if (amt <= 0 || ref.isEmpty || (methodIdx == 2 && bankNameC.text.isEmpty)) {
            ss(() => err = 'Fill in all payment details'); return;
          }
          final pm = methodIdx == 0 ? PaymentMethodType.mobileMTN
              : methodIdx == 1 ? PaymentMethodType.mobileAirtel
              : PaymentMethodType.bank;
          _ws.createRequest(
            type: PendingRequestType.withdraw,
            companyKey: ownerKey, amount: amt,
            destination: name, note: noteC.text,
            paymentMethod: pm, paymentMethodName: name, paymentAccountRef: ref,
          );
          Navigator.pop(ctx);
          setState(() {});
          _toast(ctx, 'Withdrawal request sent to ${_ws.walletFor(ownerKey).ownerKey} Admin');
        }),
      ])),
    ]);
  }

  void _showSendToCompany(BuildContext ctx, String toKey) {
    // Super admin sending directly to a company wallet
    final amtC  = TextEditingController();
    final noteC = TextEditingController();
    String? err;

    _sheet(ctx, 'Send to ${_ws.walletFor(toKey).displayName}', [
      StatefulBuilder(builder: (c, ss) => Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Label('Amount (USD)', widget.textSec),
        _Field(ctrl: amtC, hint: '0.00', keyboardType: TextInputType.number,
            textPri: widget.textPri, textSec: widget.textSec, card: widget.card, border: widget.border),
        const SizedBox(height: 12),
        _Label('Note', widget.textSec),
        _Field(ctrl: noteC, hint: 'Reason for transfer', textPri: widget.textPri,
            textSec: widget.textSec, card: widget.card, border: widget.border),
        if (err != null) ...[
          const SizedBox(height: 8),
          Text(err!, style: const TextStyle(color: _red, fontSize: 12)),
        ],
        const SizedBox(height: 20),
        _ActionBtn('Send', _gold, () {
          final amt = double.tryParse(amtC.text) ?? 0;
          if (amt <= 0) { ss(() => err = 'Enter a valid amount'); return; }
          final error = _ws.send(
            fromKey: kPlatformKey,
            toKey: toKey,
            amount: amt,
            note: noteC.text,
          );
          if (error != null) { ss(() => err = error); return; }
          Navigator.pop(ctx);
          setState(() {});
          _toast(ctx, 'Sent \$${amt.toStringAsFixed(0)} to ${_ws.walletFor(toKey).displayName}');
        }),
      ])),
    ]);
  }

  // ── Helpers ───────────────────────────────────────────────────

  // ── Password confirmation dialog ─────────────────────────────
  // The demo password for super admin is '123', for company admin is '121212'.
  // In production replace with an API auth call.
  void _confirmPassword(BuildContext ctx, {
    required String action,
    required VoidCallback onConfirmed,
  }) {
    final passC = TextEditingController();
    String? err;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(builder: (dctx, ss) => AlertDialog(
        backgroundColor: widget.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_rounded, color: _gold, size: 26),
          ),
          const SizedBox(height: 12),
          Text('Confirm $action',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: widget.textPri),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('Enter your password to proceed',
              style: TextStyle(fontSize: 12, color: widget.textSec, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: passC,
            obscureText: true,
            autofocus: true,
            style: TextStyle(color: widget.textPri, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(color: widget.textSec),
              prefixIcon: Icon(Icons.lock_outline_rounded, color: widget.textSec, size: 18),
              filled: true,
              fillColor: widget.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: widget.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: widget.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _gold, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          if (err != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.error_outline_rounded, color: _red, size: 13),
              const SizedBox(width: 4),
              Text(err!, style: const TextStyle(color: _red, fontSize: 12)),
            ]),
          ],
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: Text('Cancel', style: TextStyle(color: widget.textSec, fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              // Demo passwords: super admin = '123', company admin = '121212'
              final correctPass = widget.isSuperAdmin ? '123' : '121212';
              if (passC.text != correctPass) {
                ss(() => err = 'Incorrect password');
                return;
              }
              Navigator.pop(dctx);
              onConfirmed();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold, foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      )),
    );
  }

  void _sheet(BuildContext ctx, String title, List<Widget> children) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: widget.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20, right: 20, top: 16),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: widget.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),
          Center(child: Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: widget.textPri))),
          const SizedBox(height: 20),
          ...children,
        ]),
      ),
    );
  }

  void _toast(BuildContext ctx, String msg) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1D9E75),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
}

// ── Sub-widgets ───────────────────────────────────────────────

class _WalletCard extends StatelessWidget {
  final WalletAccount wallet;
  final bool isSuperAdmin;
  final Color card, border, textPri, textSec;
  final VoidCallback onSend, onWithdraw;

  const _WalletCard({
    required this.wallet,
    required this.isSuperAdmin,
    required this.card,
    required this.border,
    required this.textPri,
    required this.textSec,
    required this.onSend,
    required this.onWithdraw,
  });

  static const _gold  = Color(0xFFD4A017);
  static const _green = Color(0xFF1D9E75);
  static const _red   = Color(0xFFD85A30);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSuperAdmin
              ? [const Color(0xFF1A1F3C), const Color(0xFF252B4E)]
              : [const Color(0xFF141828), const Color(0xFF1C2236)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.25), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: _gold.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.account_balance_wallet_rounded, color: _gold, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(wallet.displayName,
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
            Text(isSuperAdmin ? 'Platform Wallet' : 'Company Wallet',
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: _green.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: const Text('Active', style: TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ]),

        const SizedBox(height: 20),
        const Text('Total Balance', style: TextStyle(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 4),
        Text('\$${wallet.balance.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),

        const SizedBox(height: 16),
        Row(children: [
          _BalStat(label: 'Total In',  value: '\$${wallet.totalReceived.toStringAsFixed(0)}', color: _green),
          Container(width: 1, height: 28, color: Colors.white12, margin: const EdgeInsets.symmetric(horizontal: 16)),
          _BalStat(label: 'Total Out', value: '\$${wallet.totalSent.toStringAsFixed(0)}',     color: _red),
          Container(width: 1, height: 28, color: Colors.white12, margin: const EdgeInsets.symmetric(horizontal: 16)),
          _BalStat(label: 'Txns',      value: '${wallet.transactions.length}',                color: _gold),
        ]),

        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _QuickBtn(icon: Icons.arrow_upward_rounded,   label: 'Send',     color: _gold,  onTap: onSend)),
          const SizedBox(width: 8),
          Expanded(child: _QuickBtn(icon: Icons.account_balance_rounded, label: 'Withdraw', color: _red,   onTap: onWithdraw)),
        ]),
      ]),
    );
  }
}

class _BalStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _BalStat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
    const SizedBox(height: 2),
    Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
  ]);
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickBtn({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3), width: 0.8)),
      child: Column(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

class _TotalCard extends StatelessWidget {
  final WalletService ws;
  final Color card, border, textPri, textSec;
  const _TotalCard({required this.ws, required this.card, required this.border,
      required this.textPri, required this.textSec});

  static const _gold = Color(0xFFD4A017);

  @override
  Widget build(BuildContext context) {
    final total = ws.totalPlatformBalance;
    final allWallets = ws.allCompanyWallets;
    final totalCompany = allWallets.fold(0.0, (s, w) => s + w.balance);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: card, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _gold.withOpacity(0.2), width: 0.8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.pie_chart_rounded, color: _gold, size: 16),
          const SizedBox(width: 8),
          Text('All Wallets Total', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _TotStat(label: 'Platform', value: '\$${ws.platformWallet.balance.toStringAsFixed(0)}',
              color: _gold, textSec: textSec),
          const SizedBox(width: 16),
          _TotStat(label: 'Companies', value: '\$${totalCompany.toStringAsFixed(0)}',
              color: const Color(0xFF3B5FD4), textSec: textSec),
          const SizedBox(width: 16),
          _TotStat(label: 'Grand Total', value: '\$${total.toStringAsFixed(0)}',
              color: const Color(0xFF1D9E75), textSec: textSec),
        ]),
      ]),
    );
  }
}

class _TotStat extends StatelessWidget {
  final String label, value;
  final Color color, textSec;
  const _TotStat({required this.label, required this.value, required this.color, required this.textSec});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(color: textSec, fontSize: 10)),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800)),
  ]));
}

class _CompanyWalletCard extends StatelessWidget {
  final WalletAccount wallet;
  final double commission;
  final Color card, border, textPri, textSec;
  final VoidCallback onTap;
  const _CompanyWalletCard({required this.wallet, required this.commission,
      required this.card, required this.border, required this.textPri,
      required this.textSec, required this.onTap});

  static const _gold  = Color(0xFFD4A017);
  static const _green = Color(0xFF1D9E75);
  static const _blue  = Color(0xFF3B5FD4);
  static const _red   = Color(0xFFD85A30);

  @override
  Widget build(BuildContext context) {
    final initials = wallet.ownerKey.length >= 2
        ? wallet.ownerKey.substring(0, 2).toUpperCase()
        : wallet.ownerKey.toUpperCase();
    final netPct = 100 - commission;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: card, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 0.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Top row: avatar + name + balance
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: _blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(initials,
                  style: const TextStyle(color: _blue, fontSize: 15, fontWeight: FontWeight.w800))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(wallet.ownerKey,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
              Text('${wallet.transactions.length} transactions',
                  style: TextStyle(fontSize: 11, color: textSec)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('\$${wallet.balance.toStringAsFixed(2)}',
                  style: const TextStyle(color: _green, fontSize: 16, fontWeight: FontWeight.w800)),
              const Text('balance', style: TextStyle(color: _green, fontSize: 10)),
            ]),
          ]),

          const SizedBox(height: 12),
          Divider(color: border, height: 1),
          const SizedBox(height: 12),

          // Stats row
          Row(children: [
            _MiniPill(label: 'Commission', value: '${commission.toInt()}%', color: _gold),
            const SizedBox(width: 8),
            _MiniPill(label: 'Net cut', value: '${netPct.toInt()}%', color: _blue),
            const SizedBox(width: 8),
            _MiniPill(label: 'In', value: '\$${wallet.totalReceived.toInt()}', color: _green),
            const SizedBox(width: 8),
            _MiniPill(label: 'Out', value: '\$${wallet.totalSent.toInt()}', color: _red),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: textSec, size: 18),
          ]),
        ]),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniPill({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w500)),
    Text(value,  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
  ]);
}

class _InfoPill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _InfoPill({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 9)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)),
    ]),
  ));
}

Widget _DetailRow(IconData icon, String label, String value, Color textPri, Color textSec) =>
    Row(children: [
      Container(width: 34, height: 34,
        decoration: BoxDecoration(color: const Color(0xFFD4A017).withOpacity(0.08), borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, color: const Color(0xFFD4A017), size: 16)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: textSec)),
        Text(value,  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
      ])),
    ]);



class _TxRow extends StatelessWidget {
  final WalletTx tx;
  final Color card, border, textPri, textSec;
  final VoidCallback? onTap;
  const _TxRow({required this.tx, required this.card, required this.border,
      required this.textPri, required this.textSec, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = tx.typeColor(context);
    final sign  = tx.isCredit ? '+' : '-';
    final dateStr = '${tx.at.day}/${tx.at.month}/${tx.at.year}';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: card, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 0.5)),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
            child: Icon(tx.typeIcon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tx.typeLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri)),
            Text(tx.description, style: TextStyle(fontSize: 11, color: textSec), overflow: TextOverflow.ellipsis),
            if (tx.paymentMethod != PaymentMethodType.none && tx.paymentMethodName.isNotEmpty)
              Text(tx.paymentMethodName, style: TextStyle(fontSize: 10, color: textSec,
                  fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)
            else
              Text(tx.counterpart, style: TextStyle(fontSize: 10, color: textSec)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$sign\$${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
            Text(dateStr, style: TextStyle(fontSize: 10, color: textSec)),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: textSec, size: 14),
          ]),
        ]),
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────

Widget _TxDetailRow(String label, String value, Color textPri, Color textSec,
    Color border, {bool isLast = false, Color? valueColor}) =>
    Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Text(label, style: TextStyle(fontSize: 12, color: textSec)),
          const Spacer(),
          Flexible(child: Text(value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: valueColor ?? textPri))),
        ]),
      ),
      if (!isLast) Divider(color: border, height: 1),
    ]);

Widget _ReqInfoRow(IconData icon, String label, String value, Color textSec) =>
    Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(children: [
        Icon(icon, size: 12, color: textSec),
        const SizedBox(width: 6),
        Text('$label: ', style: TextStyle(fontSize: 10, color: textSec)),
        Expanded(child: Text(value,
            style: TextStyle(fontSize: 10, color: textSec, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis)),
      ]),
    );

Widget _Label(String text, Color color) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
      color: color, letterSpacing: 0.3)),
);

Widget _Field({
  required TextEditingController ctrl,
  required String hint,
  required Color textPri,
  required Color textSec,
  required Color card,
  required Color border,
  TextInputType keyboardType = TextInputType.text,
}) => TextField(
  controller: ctrl,
  keyboardType: keyboardType,
  style: TextStyle(color: textPri, fontSize: 13),
  decoration: InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: textSec, fontSize: 13),
    filled: true, fillColor: card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: border, width: 0.8)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: border, width: 0.8)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD4A017), width: 1.5)),
  ),
);

Widget _ActionBtn(String label, Color color, VoidCallback onTap) =>
    SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
