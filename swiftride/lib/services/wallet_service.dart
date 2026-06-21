// lib/services/wallet_service.dart
// ─────────────────────────────────────────────────────────────
//  WalletService  —  singleton in-memory wallet store
//
//  Every company has its own WalletAccount keyed by company name.
//  Super Admin has a platform wallet keyed by kPlatformKey.
//  Commission % is stored per company and set during registration.
//  Whenever a booking payment is recorded, the platform wallet
//  automatically receives commissionPct % of the amount.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const String kPlatformKey = '__platform__';

enum TxType { receive, send, withdraw, commission }

enum PaymentMethodType { bank, mobileMTN, mobileAirtel, internal, none }

class WalletTx {
  final String id;
  final TxType type;
  final double amount;
  final String description;
  final String counterpart; // company name, user name, bank ref, etc.
  final DateTime at;

  // Payment method details (for withdrawals and sends)
  final PaymentMethodType paymentMethod;
  final String paymentMethodName;  // bank name OR 'MTN Mobile Money' / 'Airtel Money'
  final String paymentAccountRef;  // account number or phone number

  WalletTx({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.counterpart,
    DateTime? at,
    this.paymentMethod = PaymentMethodType.none,
    this.paymentMethodName = '',
    this.paymentAccountRef = '',
  }) : at = at ?? DateTime.now();

  String get typeLabel {
    switch (type) {
      case TxType.receive:    return 'Received';
      case TxType.send:       return 'Sent';
      case TxType.withdraw:   return 'Withdrawn';
      case TxType.commission: return 'Commission';
    }
  }

  Color typeColor(BuildContext context) {
    switch (type) {
      case TxType.receive:
      case TxType.commission: return const Color(0xFF1D9E75);
      case TxType.send:
      case TxType.withdraw:   return const Color(0xFFD85A30);
    }
  }

  IconData get typeIcon {
    switch (type) {
      case TxType.receive:    return Icons.arrow_downward_rounded;
      case TxType.send:       return Icons.arrow_upward_rounded;
      case TxType.withdraw:   return Icons.account_balance_rounded;
      case TxType.commission: return Icons.percent_rounded;
    }
  }

  bool get isCredit => type == TxType.receive || type == TxType.commission;

  /// Human-readable payment method summary for display
  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case PaymentMethodType.bank:
        return '${paymentMethodName.isEmpty ? 'Bank' : paymentMethodName}'
            '${paymentAccountRef.isEmpty ? '' : ' · Acc: $paymentAccountRef'}';
      case PaymentMethodType.mobileMTN:
        return 'MTN Mobile Money${paymentAccountRef.isEmpty ? '' : ' · $paymentAccountRef'}';
      case PaymentMethodType.mobileAirtel:
        return 'Airtel Money${paymentAccountRef.isEmpty ? '' : ' · $paymentAccountRef'}';
      case PaymentMethodType.internal:
        return paymentMethodName.isEmpty ? 'Internal Transfer' : paymentMethodName;
      case PaymentMethodType.none:
        return counterpart.isEmpty ? '—' : counterpart;
    }
  }

  IconData get paymentMethodIcon {
    switch (paymentMethod) {
      case PaymentMethodType.bank:        return Icons.account_balance_rounded;
      case PaymentMethodType.mobileMTN:   return Icons.phone_android_rounded;
      case PaymentMethodType.mobileAirtel:return Icons.phone_android_rounded;
      case PaymentMethodType.internal:    return Icons.swap_horiz_rounded;
      case PaymentMethodType.none:        return Icons.payment_rounded;
    }
  }
}

class WalletAccount {
  final String ownerKey;   // company name or kPlatformKey
  final String displayName;
  double _balance;
  final List<WalletTx> _txs;

  WalletAccount({
    required this.ownerKey,
    required this.displayName,
    double initialBalance = 0,
    List<WalletTx>? txs,
  })  : _balance = initialBalance,
        _txs = txs ?? [];

  double get balance => _balance;
  List<WalletTx> get transactions => List.unmodifiable(_txs);

  double get totalReceived =>
      _txs.where((t) => t.isCredit).fold(0, (s, t) => s + t.amount);
  double get totalSent =>
      _txs.where((t) => !t.isCredit).fold(0, (s, t) => s + t.amount);

  void _credit(double amt, TxType type, String desc, String counterpart, {
    PaymentMethodType pm = PaymentMethodType.none,
    String pmName = '', String pmRef = '',
  }) {
    _balance += amt;
    _txs.insert(0, WalletTx(
      id: 'TX${DateTime.now().millisecondsSinceEpoch}',
      type: type, amount: amt, description: desc, counterpart: counterpart,
      paymentMethod: pm, paymentMethodName: pmName, paymentAccountRef: pmRef,
    ));
  }

  void _debit(double amt, TxType type, String desc, String counterpart, {
    PaymentMethodType pm = PaymentMethodType.none,
    String pmName = '', String pmRef = '',
  }) {
    _balance -= amt;
    _txs.insert(0, WalletTx(
      id: 'TX${DateTime.now().millisecondsSinceEpoch}',
      type: type, amount: amt, description: desc, counterpart: counterpart,
      paymentMethod: pm, paymentMethodName: pmName, paymentAccountRef: pmRef,
    ));
  }
}


enum PendingRequestType { send, withdraw }
enum PendingRequestStatus { pending, approved, rejected }

class PendingWalletRequest {
  final String id;
  final PendingRequestType type;
  final String companyKey;
  final double amount;
  final String destination;
  final String note;
  final DateTime createdAt;
  PendingRequestStatus status;
  // Payment method details
  final PaymentMethodType paymentMethod;
  final String paymentMethodName;
  final String paymentAccountRef;

  PendingWalletRequest({
    required this.id,
    required this.type,
    required this.companyKey,
    required this.amount,
    required this.destination,
    required this.note,
    required this.createdAt,
    this.status = PendingRequestStatus.pending,
    this.paymentMethod = PaymentMethodType.none,
    this.paymentMethodName = '',
    this.paymentAccountRef = '',
  });

  String get typeLabel => type == PendingRequestType.send ? 'Send to Wallet' : 'Withdrawal';
  bool get isPending => status == PendingRequestStatus.pending;
}

class WalletService {
  WalletService._();
  static final WalletService instance = WalletService._();

  // ── Pending requests (super-admin → company, awaiting company approval) ──
  final List<PendingWalletRequest> pendingRequests = [];

  /// Super Admin requests a send/withdraw on a company wallet.
  PendingWalletRequest createRequest({
    required PendingRequestType type,
    required String companyKey,
    required double amount,
    required String destination,
    required String note,
    PaymentMethodType paymentMethod = PaymentMethodType.none,
    String paymentMethodName = '',
    String paymentAccountRef = '',
  }) {
    final req = PendingWalletRequest(
      id: 'PR${DateTime.now().millisecondsSinceEpoch}',
      type: type, companyKey: companyKey, amount: amount,
      destination: destination, note: note, createdAt: DateTime.now(),
      paymentMethod: paymentMethod,
      paymentMethodName: paymentMethodName,
      paymentAccountRef: paymentAccountRef,
    );
    pendingRequests.insert(0, req);
    return req;
  }

  /// Company Admin approves — executes the transaction.
  String? approveRequest(String requestId) {
    final req = pendingRequests.firstWhere((r) => r.id == requestId,
        orElse: () => throw Exception('Not found'));
    if (!req.isPending) return 'Already processed';
    req.status = PendingRequestStatus.approved;
    if (req.type == PendingRequestType.withdraw) {
      return withdraw(
        ownerKey: req.companyKey, amount: req.amount,
        destination: req.destination,
        note: req.note.isEmpty ? 'Approved withdrawal' : req.note,
        paymentMethod: req.paymentMethod,
        paymentMethodName: req.paymentMethodName,
        paymentAccountRef: req.paymentAccountRef,
      );
    } else {
      return send(fromKey: kPlatformKey, toKey: req.companyKey,
          amount: req.amount,
          note: req.note.isEmpty ? 'Approved transfer' : req.note);
    }
  }

  /// Company Admin rejects.
  void rejectRequest(String requestId) {
    final req = pendingRequests.firstWhere((r) => r.id == requestId,
        orElse: () => throw Exception('Not found'));
    req.status = PendingRequestStatus.rejected;
  }

  List<PendingWalletRequest> pendingForCompany(String companyKey) =>
      pendingRequests.where((r) => r.companyKey == companyKey && r.isPending).toList();

  // company name → commission pct (0–100)
  final Map<String, double> _commissionPct = {
    'DriveKigali':  10,
    'SafariWheels': 12,
    'LuxDrive':     8,
    'RwandaRide':   15,
    'VanGo':        10,
  };

  // company name → WalletAccount
  final Map<String, WalletAccount> _wallets = {};

  // platform wallet
  late final WalletAccount _platform;

  bool _seeded = false;

  // ── Init ─────────────────────────────────────────────────────
  void seed() {
    if (_seeded) return;
    _seeded = true;

    _platform = WalletAccount(
      ownerKey: kPlatformKey,
      displayName: 'SwiftRide Platform',
      initialBalance: 4320.0,
      txs: [
        WalletTx(id:'TX001', type: TxType.commission, amount: 135*0.10, description:'Commission from booking SW240001', counterpart:'DriveKigali', paymentMethod: PaymentMethodType.internal, paymentMethodName: 'Platform Commission', at: DateTime.now().subtract(const Duration(days:1))),
        WalletTx(id:'TX002', type: TxType.commission, amount: 180*0.12, description:'Commission from booking SW240002', counterpart:'SafariWheels', paymentMethod: PaymentMethodType.internal, paymentMethodName: 'Platform Commission', at: DateTime.now().subtract(const Duration(hours:18))),
        WalletTx(id:'TX003', type: TxType.commission, amount: 220*0.08, description:'Commission from booking SW240003', counterpart:'LuxDrive', paymentMethod: PaymentMethodType.internal, paymentMethodName: 'Platform Commission', at: DateTime.now().subtract(const Duration(hours:10))),
        WalletTx(id:'TX004', type: TxType.withdraw,   amount: 1000,     description:'Withdrawal to platform bank account', counterpart:'Equity Bank Rwanda', paymentMethod: PaymentMethodType.bank, paymentMethodName: 'Equity Bank Rwanda', paymentAccountRef: 'RW-BNK-001-4521', at: DateTime.now().subtract(const Duration(hours:5))),
      ],
    );

    final seedData = [
      ('DriveKigali',  2800.0),
      ('SafariWheels', 1640.0),
      ('LuxDrive',     3200.0),
      ('RwandaRide',    480.0),
      ('VanGo',         220.0),
    ];
    for (final s in seedData) {
      _wallets[s.$1] = WalletAccount(
        ownerKey: s.$1,
        displayName: '${s.$1} Wallet',
        initialBalance: s.$2,
        txs: [
          WalletTx(id:'TX${s.$1}001', type:TxType.receive,  amount: s.$2 * 0.6,  description:'Booking payments received',  counterpart:'Clients',       paymentMethod: PaymentMethodType.internal, paymentMethodName: 'SwiftRide Platform', at: DateTime.now().subtract(const Duration(days:2))),
          WalletTx(id:'TX${s.$1}002', type:TxType.withdraw, amount: s.$2 * 0.15, description:'Weekly withdrawal',           counterpart:'Equity Bank RW', paymentMethod: PaymentMethodType.bank, paymentMethodName: 'Equity Bank Rwanda', paymentAccountRef: 'RW-EQ-${s.$1.hashCode.abs() % 9000 + 1000}', at: DateTime.now().subtract(const Duration(days:1))),
          WalletTx(id:'TX${s.$1}003', type:TxType.receive,  amount: s.$2 * 0.55, description:'Booking payment received',   counterpart:'Cameron One',    paymentMethod: PaymentMethodType.internal, paymentMethodName: 'SwiftRide Platform', at: DateTime.now().subtract(const Duration(hours:6))),
        ],
      );
    }
  }

  // ── Accessors ─────────────────────────────────────────────────
  WalletAccount get platformWallet {
    seed();
    return _platform;
  }

  WalletAccount walletFor(String companyName) {
    seed();
    return _wallets.putIfAbsent(companyName, () => WalletAccount(
      ownerKey: companyName,
      displayName: '$companyName Wallet',
    ));
  }

  List<WalletAccount> get allCompanyWallets {
    seed();
    return _wallets.values.toList();
  }

  double commissionFor(String companyName) =>
      _commissionPct[companyName] ?? 10.0;

  void setCommission(String companyName, double pct) =>
      _commissionPct[companyName] = pct;

  double get totalPlatformBalance {
    seed();
    return _platform.balance + _wallets.values.fold(0.0, (s, w) => s + w.balance);
  }

  // ── Operations ────────────────────────────────────────────────

  /// Call when a booking payment is made. Credits company wallet (net) and
  /// platform wallet (commission).
  String recordBookingPayment({
    required String companyName,
    required double amount,
    required String bookingRef,
    required String customerName,
  }) {
    seed();
    final pct = commissionFor(companyName);
    final commission = amount * pct / 100;
    final net = amount - commission;

    final wallet = walletFor(companyName);
    wallet._credit(net, TxType.receive,
        'Payment for booking $bookingRef', customerName);
    _platform._credit(commission, TxType.commission,
        'Commission ($pct%) from booking $bookingRef', companyName);
    return 'Payment recorded · \$${net.toStringAsFixed(0)} to $companyName · \$${commission.toStringAsFixed(0)} commission';
  }

  /// Send money between company wallets or from company to platform.
  String? send({
    required String fromKey,
    required String toKey,
    required double amount,
    required String note,
  }) {
    seed();
    final from = fromKey == kPlatformKey ? _platform : walletFor(fromKey);
    final to   = toKey   == kPlatformKey ? _platform : walletFor(toKey);
    if (from.balance < amount) return 'Insufficient balance';
    from._debit(amount, TxType.send, note.isEmpty ? 'Transfer' : note, to.displayName,
        pm: PaymentMethodType.internal, pmName: to.displayName);
    to._credit(amount, TxType.receive, note.isEmpty ? 'Transfer received' : note, from.displayName,
        pm: PaymentMethodType.internal, pmName: from.displayName);
    return null;
  }

  /// Withdraw from a wallet to external bank/mobile money.
  String? withdraw({
    required String ownerKey,
    required double amount,
    required String destination,
    required String note,
    PaymentMethodType paymentMethod = PaymentMethodType.bank,
    String paymentMethodName = '',
    String paymentAccountRef = '',
  }) {
    seed();
    final wallet = ownerKey == kPlatformKey ? _platform : walletFor(ownerKey);
    if (wallet.balance < amount) return 'Insufficient balance';
    wallet._debit(amount, TxType.withdraw,
        note.isEmpty ? 'Withdrawal to $destination' : note, destination,
        pm: paymentMethod, pmName: paymentMethodName, pmRef: paymentAccountRef);
    return null;
  }

}
