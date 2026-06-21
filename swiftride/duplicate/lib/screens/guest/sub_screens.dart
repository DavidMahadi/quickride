import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/screens/guest/app_shell.dart';
import 'package:swiftride/screens/guest/shared_drawer.dart';

// ═══════════════════════════════════════════════════════════════
//  SHARED SCAFFOLD HELPER
// ═══════════════════════════════════════════════════════════════
class _SubScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  const _SubScaffold({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg   : AppColors.lightBg;
    final textPri = isDark ? Colors.white        : const Color(0xFF0A0E1A);
    return Scaffold(
      backgroundColor: bg,
      drawer: const AppDrawer(activeTab: 0),
      bottomNavigationBar: AppBottomNav(activeIndex: 0),
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPri, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
      ),
      body: body,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  PERSONAL INFO
// ═══════════════════════════════════════════════════════════════
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});
  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameCtrl  = TextEditingController(text: 'Alex Johnson');
  final _emailCtrl = TextEditingController(text: 'alex@email.com');
  final _phoneCtrl = TextEditingController(text: '+250 788 000 000');
  final _dobCtrl   = TextEditingController(text: '01 Jan 1990');

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg      : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border  = isDark ? AppColors.darkBorder  : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white           : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return _SubScaffold(
      title: 'Personal Info',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Avatar
          Center(child: Stack(children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.gold.withOpacity(0.15),
              child: const Text('A',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.gold)),
            ),
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  color: AppColors.gold, shape: BoxShape.circle,
                  border: Border.all(color: bg, width: 2),
                ),
                child: const Icon(Icons.camera_alt, size: 13, color: Colors.black),
              ),
            ),
          ])),
          const SizedBox(height: 28),
          _field('Full Name',    _nameCtrl,  Icons.person_outline,    surface, border, textPri, textSec),
          const SizedBox(height: 14),
          _field('Email',        _emailCtrl, Icons.email_outlined,    surface, border, textPri, textSec,
              type: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _field('Phone Number', _phoneCtrl, Icons.phone_outlined,    surface, border, textPri, textSec,
              type: TextInputType.phone),
          const SizedBox(height: 14),
          _field('Date of Birth',_dobCtrl,   Icons.cake_outlined,     surface, border, textPri, textSec,
              readOnly: true),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold, foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Save Changes',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      Color surface, Color border, Color textPri, Color textSec,
      {TextInputType? type, bool readOnly = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSec)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        keyboardType: type,
        readOnly: readOnly,
        style: TextStyle(color: textPri, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: textSec, size: 18),
          filled: true, fillColor: surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border, width: 0.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold, width: 1)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        ),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════
//  PAYMENT METHODS
// ═══════════════════════════════════════════════════════════════
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});
  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _selected = 0;
  final _cards = [
    {'label': 'Visa', 'last4': '4242', 'expiry': '12/26', 'icon': Icons.credit_card},
    {'label': 'MasterCard', 'last4': '1234', 'expiry': '09/25', 'icon': Icons.credit_card},
    {'label': 'MTN Mobile Money', 'last4': '0780', 'expiry': '',   'icon': Icons.phone_android},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final card    = isDark ? AppColors.darkCard   : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white          : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return _SubScaffold(
      title: 'Payment Methods',
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ..._cards.asMap().entries.map((e) {
            final i = e.key; final m = e.value;
            final active = _selected == i;
            return GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active ? AppColors.gold : border,
                    width: active ? 1.5 : 0.5,
                  ),
                ),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(m['icon'] as IconData, color: AppColors.gold, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${m['label']} ••••${m['last4']}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPri)),
                    if ((m['expiry'] as String).isNotEmpty)
                      Text('Expires ${m['expiry']}',
                          style: TextStyle(fontSize: 12, color: textSec)),
                  ])),
                  if (active)
                    Container(
                      width: 22, height: 22,
                      decoration: const BoxDecoration(
                          color: AppColors.gold, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.black, size: 14),
                    ),
                ]),
              ),
            );
          }),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment method saved (demo)'), backgroundColor: Color(0xFF1D9E75))),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5),
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add, color: AppColors.gold, size: 18),
                SizedBox(width: 8),
                Text('Add Payment Method',
                    style: TextStyle(fontSize: 14, color: AppColors.gold, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  MY DOCUMENTS
// ═══════════════════════════════════════════════════════════════
class MyDocumentsScreen extends StatelessWidget {
  const MyDocumentsScreen({super.key});

  static const _docs = [
    {'title': "Driver's License", 'status': 'Verified',   'color': 0xFF1D9E75, 'icon': Icons.badge_outlined},
    {'title': 'National ID',      'status': 'Verified',   'color': 0xFF1D9E75, 'icon': Icons.credit_card_outlined},
    {'title': 'Passport',         'status': 'Not uploaded','color': 0xFF8B91A8, 'icon': Icons.book_outlined},
    {'title': 'Insurance Card',   'status': 'Expired',    'color': 0xFFD85A30, 'icon': Icons.health_and_safety_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final card    = isDark ? AppColors.darkCard   : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white          : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return _SubScaffold(
      title: 'My Documents',
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _docs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final d = _docs[i];
          final statusColor = Color(d['color'] as int);
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 0.5),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(d['icon'] as IconData, color: AppColors.gold, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d['title'] as String,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPri)),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(d['status'] as String,
                      style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                ),
              ])),
              Icon(Icons.chevron_right, color: textSec, size: 18),
            ]),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SAVED ADDRESSES
// ═══════════════════════════════════════════════════════════════
class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});
  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final _addrs = [
    {'label': 'Home',   'addr': 'KG 123 St, Kigali, Rwanda',  'icon': Icons.home_outlined},
    {'label': 'Office', 'addr': 'KN 5 Rd, Kigali City Tower', 'icon': Icons.business_outlined},
    {'label': 'Airport','addr': 'Kigali International Airport','icon': Icons.flight_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final card    = isDark ? AppColors.darkCard   : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white          : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return _SubScaffold(
      title: 'Saved Addresses',
      body: Column(children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _addrs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final a = _addrs[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: card, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: 0.5),
                ),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(a['icon'] as IconData, color: AppColors.gold, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(a['label'] as String,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPri)),
                    const SizedBox(height: 3),
                    Text(a['addr'] as String,
                        style: TextStyle(fontSize: 12, color: textSec)),
                  ])),
                  GestureDetector(
                    onTap: () => setState(() => _addrs.removeAt(i)),
                    child: Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  ),
                ]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Address saved (demo)'), backgroundColor: Color(0xFF1D9E75))),
              icon: const Icon(Icons.add, color: Colors.black, size: 18),
              label: const Text('Add New Address',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  NOTIFICATIONS SETTINGS
// ═══════════════════════════════════════════════════════════════
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _push    = true;
  bool _email   = false;
  bool _sms     = true;
  bool _promo   = false;
  bool _reminders = true;

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final card    = isDark ? AppColors.darkCard   : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white          : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    final items = [
      {'label': 'Push Notifications', 'sub': 'Booking updates & alerts',     'val': _push,     'set': (v) => setState(() => _push = v)},
      {'label': 'Email Notifications','sub': 'Receipts and summaries',        'val': _email,    'set': (v) => setState(() => _email = v)},
      {'label': 'SMS Notifications',  'sub': 'Booking confirmations',         'val': _sms,      'set': (v) => setState(() => _sms = v)},
      {'label': 'Promotions',         'sub': 'Deals and special offers',      'val': _promo,    'set': (v) => setState(() => _promo = v)},
      {'label': 'Reminders',          'sub': 'Pickup and drop-off reminders', 'val': _reminders,'set': (v) => setState(() => _reminders = v)},
    ];

    return _SubScaffold(
      title: 'Notifications',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: card, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 0.5),
            ),
            child: Column(
              children: items.asMap().entries.map((e) {
                final isLast = e.key == items.length - 1;
                final item = e.value;
                return Column(children: [
                  SwitchListTile(
                    value: item['val'] as bool,
                    onChanged: item['set'] as void Function(bool),
                    activeColor: AppColors.gold,
                    activeTrackColor: AppColors.gold.withOpacity(0.3),
                    title: Text(item['label'] as String,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPri)),
                    subtitle: Text(item['sub'] as String,
                        style: TextStyle(fontSize: 11, color: textSec)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  ),
                  if (!isLast) Divider(color: border, height: 1, indent: 16),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  LANGUAGE
// ═══════════════════════════════════════════════════════════════
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'English';
  final _langs = ['English', 'French', 'Kinyarwanda', 'Swahili', 'Arabic', 'Spanish'];

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final card    = isDark ? AppColors.darkCard   : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white          : const Color(0xFF0A0E1A);

    return _SubScaffold(
      title: 'Language',
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _langs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final lang = _langs[i];
          final active = _selected == lang;
          return GestureDetector(
            onTap: () => setState(() => _selected = lang),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? AppColors.gold : border,
                  width: active ? 1.5 : 0.5,
                ),
              ),
              child: Row(children: [
                Expanded(child: Text(lang,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? AppColors.gold : textPri))),
                if (active)
                  Container(
                    width: 22, height: 22,
                    decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.black, size: 14),
                  ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CURRENCY
// ═══════════════════════════════════════════════════════════════
class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});
  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String _selected = 'USD';
  final _currencies = [
    {'code': 'USD', 'name': 'US Dollar',        'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro',             'symbol': '€'},
    {'code': 'RWF', 'name': 'Rwandan Franc',    'symbol': 'Fr'},
    {'code': 'GBP', 'name': 'British Pound',    'symbol': '£'},
    {'code': 'KES', 'name': 'Kenyan Shilling',  'symbol': 'Ksh'},
    {'code': 'UGX', 'name': 'Ugandan Shilling', 'symbol': 'USh'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final card    = isDark ? AppColors.darkCard   : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white          : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return _SubScaffold(
      title: 'Currency',
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _currencies.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final c = _currencies[i];
          final active = _selected == c['code'];
          return GestureDetector(
            onTap: () => setState(() => _selected = c['code']!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? AppColors.gold : border,
                  width: active ? 1.5 : 0.5,
                ),
              ),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(c['symbol']!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gold))),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c['code']!,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPri)),
                  Text(c['name']!,
                      style: TextStyle(fontSize: 12, color: textSec)),
                ])),
                if (active)
                  Container(
                    width: 22, height: 22,
                    decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.black, size: 14),
                  ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  HELP CENTER
// ═══════════════════════════════════════════════════════════════
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});
  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _faqs = [
    {'q': 'How do I book a car?',
     'a': 'Tap "Search Cars", choose your dates and location, pick a car, then tap "Book Now". You\'ll need to be signed in to complete a booking.'},
    {'q': 'Can I cancel a booking?',
     'a': 'Yes. Go to My Bookings, select the active booking, and tap "Cancel". Cancellations made 24+ hours before pickup are fully refunded.'},
    {'q': 'What documents do I need?',
     'a': 'A valid driver\'s license and a national ID or passport are required. Upload them in Profile → My Documents before pickup.'},
    {'q': 'How does payment work?',
     'a': 'We accept Visa, MasterCard, and MTN Mobile Money. You\'re charged at the time of booking confirmation.'},
    {'q': 'What if the car breaks down?',
     'a': 'Call the rental company directly via the Messages tab. All listed companies provide 24/7 roadside assistance.'},
  ];

  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final card    = isDark ? AppColors.darkCard   : AppColors.lightCard;
    final surface = isDark ? AppColors.darkSurface: AppColors.lightSurface;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white          : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return _SubScaffold(
      title: 'Help Center',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Contact banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5),
            ),
            child: Row(children: [
              const Icon(Icons.headset_mic_outlined, color: AppColors.gold, size: 28),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('24/7 Support', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
                Text('Chat with us anytime', style: TextStyle(fontSize: 12, color: textSec)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.gold, borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Chat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black)),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Text('Frequently Asked Questions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPri)),
          const SizedBox(height: 12),
          ..._faqs.asMap().entries.map((e) {
            final i = e.key; final faq = e.value;
            final open = _expanded.contains(i);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: card, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: open ? AppColors.gold : border, width: open ? 1 : 0.5),
              ),
              child: Column(children: [
                ListTile(
                  title: Text(faq['q']!,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
                  trailing: Icon(open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.gold, size: 20),
                  onTap: () => setState(() => open ? _expanded.remove(i) : _expanded.add(i)),
                  dense: true,
                ),
                if (open)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(faq['a']!,
                        style: TextStyle(fontSize: 13, color: textSec, height: 1.5)),
                  ),
              ]),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  PRIVACY POLICY
// ═══════════════════════════════════════════════════════════════
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = [
    {'title': '1. Data We Collect',
     'body': 'We collect personal information you provide during registration (name, email, phone), location data when the app is in use, device identifiers, and usage analytics to improve the service.'},
    {'title': '2. How We Use Your Data',
     'body': 'Your data is used to process bookings, communicate rental updates, improve app performance, and (with your consent) send promotional offers.'},
    {'title': '3. Data Sharing',
     'body': 'We share necessary booking information with the rental company you choose. We do not sell your personal data to third parties.'},
    {'title': '4. Data Security',
     'body': 'All data is encrypted in transit using TLS 1.2+. Passwords are hashed and never stored in plain text. We conduct regular security audits.'},
    {'title': '5. Your Rights',
     'body': 'You may request access, correction, or deletion of your personal data at any time by contacting support@swiftride.rw.'},
    {'title': '6. Cookies',
     'body': 'We use essential cookies for authentication and analytics cookies (opt-out available in Settings) to understand usage patterns.'},
    {'title': '7. Changes to This Policy',
     'body': 'We will notify you via email and in-app notification at least 14 days before any material changes to this policy take effect.'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final card    = isDark ? AppColors.darkCard   : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white          : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return _SubScaffold(
      title: 'Privacy Policy',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.25), width: 0.5),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, color: AppColors.gold, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text('Last updated: 1 June 2026',
                  style: TextStyle(fontSize: 12, color: textSec))),
            ]),
          ),
          const SizedBox(height: 16),
          ..._sections.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 0.5),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s['title']!,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 8),
              Text(s['body']!,
                  style: TextStyle(fontSize: 13, color: textSec, height: 1.5)),
            ]),
          )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ABOUT
// ═══════════════════════════════════════════════════════════════
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final card    = isDark ? AppColors.darkCard   : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white          : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return _SubScaffold(
      title: 'About',
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Logo
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
            ),
            child: const Icon(Icons.directions_car, color: AppColors.gold, size: 40),
          ),
          const SizedBox(height: 16),
          Text('SwiftRide', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPri)),
          const SizedBox(height: 4),
          Text('v1.0.0', style: TextStyle(fontSize: 13, color: textSec)),
          const SizedBox(height: 6),
          Text('Drive Your Journey', style: TextStyle(fontSize: 13, color: AppColors.gold)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 0.5),
            ),
            child: Column(children: [
              _AboutRow(label: 'Version',   value: '1.0.0',                       textPri: textPri, textSec: textSec, border: border),
              _AboutRow(label: 'Build',     value: '2026.06.01',                  textPri: textPri, textSec: textSec, border: border),
              _AboutRow(label: 'Developer', value: 'SwiftRide Technologies Ltd',  textPri: textPri, textSec: textSec, border: border),
              _AboutRow(label: 'Website',   value: 'www.swiftride.rw',            textPri: textPri, textSec: textSec, border: border),
              _AboutRow(label: 'Contact',   value: 'support@swiftride.rw',        textPri: textPri, textSec: textSec, border: border, isLast: true),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label, value;
  final Color textPri, textSec, border;
  final bool isLast;
  const _AboutRow({required this.label, required this.value, required this.textPri, required this.textSec, required this.border, this.isLast = false});
  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: textSec))),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPri)),
      ]),
    ),
    if (!isLast) Divider(color: border, height: 1),
  ]);
}

// ═══════════════════════════════════════════════════════════════
//  CHANGE PASSWORD
// ═══════════════════════════════════════════════════════════════
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _curCtrl  = TextEditingController();
  final _newCtrl  = TextEditingController();
  final _confCtrl = TextEditingController();
  bool _obsCur = true, _obsNew = true, _obsConf = true;

  @override
  void dispose() { _curCtrl.dispose(); _newCtrl.dispose(); _confCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border  = isDark ? AppColors.darkBorder  : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white           : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return _SubScaffold(
      title: 'Change Password',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _passField('Current Password', _curCtrl, _obsCur, () => setState(() => _obsCur = !_obsCur), surface, border, textPri, textSec),
          const SizedBox(height: 14),
          _passField('New Password',     _newCtrl, _obsNew, () => setState(() => _obsNew = !_obsNew), surface, border, textPri, textSec),
          const SizedBox(height: 14),
          _passField('Confirm Password', _confCtrl, _obsConf, () => setState(() => _obsConf = !_obsConf), surface, border, textPri, textSec),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold, foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Update Password', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _passField(String label, TextEditingController ctrl, bool obs, VoidCallback toggle,
      Color surface, Color border, Color textPri, Color textSec) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSec)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl, obscureText: obs,
        style: TextStyle(color: textPri, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock_outline, color: textSec, size: 18),
          suffixIcon: IconButton(
            icon: Icon(obs ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: textSec, size: 18),
            onPressed: toggle,
          ),
          filled: true, fillColor: surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border, width: 0.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gold, width: 1)),
          contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        ),
      ),
    ]);
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg    : AppColors.lightBg;
    final card    = isDark ? AppColors.darkCard  : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder: const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white         : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8) : const Color(0xFF6B7280);
    const sections = [
      ('1. Acceptance of Terms', 'By using SwiftRide, you agree to these terms. If you do not agree, please do not use the app.'),
      ('2. Car Rental Agreement', 'All rentals are subject to availability. You must hold a valid driving license. Minimum age is 21.'),
      ('3. Payments', 'Payments are processed securely. Cancellations made 24h before pickup receive a full refund.'),
      ('4. Damage & Insurance', 'Basic CDW is included. You are liable for damages not covered by insurance.'),
      ('5. Privacy', 'Your data is handled per our Privacy Policy. We do not sell your data to third parties.'),
      ('6. Governing Law', 'These terms are governed by the laws of Rwanda. Disputes shall be resolved in Kigali courts.'),
    ];
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(backgroundColor: bg, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textPri), onPressed: () => Navigator.pop(context)),
        title: Text('Terms of Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPri))),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.08), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withOpacity(0.2))),
          child: Row(children: [
            const Icon(Icons.gavel_rounded, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('Last updated: June 2026', style: TextStyle(fontSize: 12, color: textSec))),
          ])),
        ...sections.map((s) => Container(margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.$1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
            const SizedBox(height: 6),
            Text(s.$2, style: TextStyle(fontSize: 12, color: textSec, height: 1.5)),
          ]))),
      ]),
    );
  }
}
