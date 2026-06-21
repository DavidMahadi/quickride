// lib/screens/user/user_car_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/utils/constants.dart' show kNavy, kNavy2, kGold, kGoldL, kSurf, kSurf2, kText, kTextS, kError, kSuccess, kWarn, AppColors, kAllCars, kCategories, kPickupLocations;
import 'package:swiftride/screens/guest/messages_screen.dart' show MessagesScreen;
import 'package:swiftride/services/app_data_store.dart';
import 'package:swiftride/services/auth_service.dart';

class UserCarDetailScreen extends StatefulWidget {
  final Map<String, dynamic> car;
  const UserCarDetailScreen({super.key, required this.car});
  @override
  State<UserCarDetailScreen> createState() => _UserCarDetailScreenState();
}

class _UserCarDetailScreenState extends State<UserCarDetailScreen> {
  bool _isFav = false;

  void _openCompanyChat(BuildContext context, Map<String, dynamic> car) {
    final companyName = (car['company'] as String?) ?? 'DriveKigali';
    final initials = companyName.split(' ').map((e) => e.isEmpty ? '' : e[0]).take(2).join();
    final colors = [
      const Color(0xFF1D9E75), const Color(0xFF3B5FD4),
      const Color(0xFF7F77DD), const Color(0xFFD85A30), const Color(0xFFD4A017),
    ];
    final avatarColor = colors[companyName.length % colors.length];

    // Log activity
    AppDataStore.instance.addUserActivity(UserActivity(
      id: 'UA${DateTime.now().millisecondsSinceEpoch}',
      userId: AuthService.currentUserId,
      title: 'Messaged $companyName',
      subtitle: 'About ${(car['name'] as String?) ?? 'a car'}',
      icon: '💬',
      category: 'Message',
    ));

    Navigator.push(context, MaterialPageRoute(
      builder: (_) => CompanyChatScreen(
        companyName: companyName,
        initials: initials,
        avatarColor: avatarColor,
        carName: (car['name'] as String?) ?? '',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;
    return Scaffold(
      backgroundColor: kNavy,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: kNavy,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: kText, size: 16),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                child: Icon(_isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _isFav ? kError : kText, size: 18),
              ),
              onPressed: () => setState(() => _isFav = !_isFav),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                child: const Icon(Icons.share_rounded, color: kText, size: 18),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share link copied to clipboard'), backgroundColor: Color(0xFF1D9E75)));
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: Color(car['color'] as int),
              child: Center(child: Icon(Icons.directions_car_rounded,
                  size: 120, color: Colors.white.withOpacity(0.2))),
            ),
          ),
        ),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(car['name'] as String,
                    style: const TextStyle(color: kText, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text('${car['brand']} · ${car['year']}',
                    style: const TextStyle(color: kTextS, fontSize: 13)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                RichText(text: TextSpan(children: [
                  TextSpan(text: '\$${car['price']}',
                      style: const TextStyle(color: kGold, fontWeight: FontWeight.w800, fontSize: 24)),
                  const TextSpan(text: '/day', style: TextStyle(color: kTextS, fontSize: 13)),
                ])),
                Row(children: [
                  const Icon(Icons.star_rounded, color: kGold, size: 14),
                  const SizedBox(width: 3),
                  Text('${car['rating']}', style: const TextStyle(color: kTextS, fontSize: 13)),
                ]),
              ]),
            ]),

            const SizedBox(height: 18),

            // Spec chips
            Row(children: [
              _Chip(icon: Icons.event_seat_rounded,        value: '${car['seats']} seats'),
              const SizedBox(width: 8),
              _Chip(icon: Icons.settings_rounded,          value: car['transmission'] as String),
              const SizedBox(width: 8),
              _Chip(icon: Icons.local_gas_station_rounded, value: car['fuel'] as String),
              const SizedBox(width: 8),
              _Chip(icon: Icons.speed_rounded,             value: car['range'] as String),
            ]),

            const SizedBox(height: 22),
            const Text('About this car',
                style: TextStyle(color: kText, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(car['desc'] as String,
                style: const TextStyle(color: kTextS, fontSize: 13, height: 1.6)),

            const SizedBox(height: 22),
            const Text('Features',
                style: TextStyle(color: kText, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 4,
              children: const [
                _Feature(icon: Icons.ac_unit_rounded,        label: 'Air Conditioning'),
                _Feature(icon: Icons.wifi_rounded,           label: 'Wi-Fi Hotspot'),
                _Feature(icon: Icons.bluetooth_rounded,      label: 'Bluetooth Audio'),
                _Feature(icon: Icons.gps_fixed_rounded,      label: 'GPS Navigation'),
                _Feature(icon: Icons.camera_alt_rounded,     label: 'Backup Camera'),
                _Feature(icon: Icons.usb_rounded,            label: 'USB Charging'),
              ],
            ),

            const SizedBox(height: 22),
            const Text('Car Host',
                style: TextStyle(color: kText, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kSurf, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                CircleAvatar(radius: 24, backgroundColor: kGold,
                    child: Text(
                      ((car['company'] as String?) ?? 'DK')
                          .split(' ').map((e) => e.isEmpty ? '' : e[0]).take(2).join(),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text((car['company'] as String?) ?? 'DriveKigali',
                      style: const TextStyle(color: kText, fontWeight: FontWeight.w700)),
                  const Text('Verified company · SwiftRide Partner',
                      style: TextStyle(color: kTextS, fontSize: 12)),
                ])),
                OutlinedButton(
                  onPressed: () => _openCompanyChat(context, car),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kGold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Chat', style: TextStyle(color: kGold, fontSize: 13)),
                ),
              ]),
            ),
            const SizedBox(height: 100),
          ]),
        )),
      ]),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: kNavy2,
          border: Border(top: BorderSide(color: kSurf2)),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Starting from', style: TextStyle(color: kTextS, fontSize: 11)),
            RichText(text: TextSpan(children: [
              TextSpan(text: '\$${car['price']}',
                  style: const TextStyle(color: kGold, fontWeight: FontWeight.w800, fontSize: 20)),
              const TextSpan(text: '/day', style: TextStyle(color: kTextS, fontSize: 12)),
            ])),
          ])),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/user/booking-flow', arguments: car),
            child: const Text('Book Now'),
          )),
        ]),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon; final String value;
  const _Chip({required this.icon, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: kSurf, borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Icon(icon, color: kGold, size: 16),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: kTextS, fontSize: 9),
          textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
    ]),
  ));
}

class _Feature extends StatelessWidget {
  final IconData icon; final String label;
  const _Feature({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: kGold, size: 15),
    const SizedBox(width: 6),
    Expanded(child: Text(label, style: const TextStyle(color: kTextS, fontSize: 12), overflow: TextOverflow.ellipsis)),
  ]);
}

// ── Company-specific chat screen ───────────────────────────────
class CompanyChatScreen extends StatefulWidget {
  final String companyName, initials;
  final Color avatarColor;
  final String carName;
  const CompanyChatScreen({
    required this.companyName, required this.initials,
    required this.avatarColor, this.carName = ''});
  @override State<CompanyChatScreen> createState() => CompanyChatScreenState();
}
class CompanyChatScreenState extends State<CompanyChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<ChatMessage> get _messages =>
      AppDataStore.instance.chatWith(widget.companyName);

  @override
  void initState() {
    super.initState();
    // Seed initial greeting if no history
    if (_messages.isEmpty) {
      final greeting = widget.carName.isNotEmpty
          ? 'Hello! Thanks for your interest in the ${widget.carName}. How can we help you today?'
          : 'Hello! How can we help you today?';
      AppDataStore.instance.addChatMessage(widget.companyName, ChatMessage(
        id: 'cm0', text: greeting,
        senderId: widget.companyName, senderName: widget.companyName,
        isFromUser: false,
      ));
    }
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    AppDataStore.instance.addChatMessage(widget.companyName, ChatMessage(
      id: 'cm${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      senderId: AuthService.currentUserId,
      senderName: AuthService.userName,
      isFromUser: true,
    ));
    setState(() {});
    _scrollToBottom();

    // Auto-reply after 800ms
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final replies = [
        'Thanks for reaching out! Our team will get back to you shortly.',
        'Great question! Let me check that for you.',
        'We\'d be happy to help. Please give us a moment.',
        'Noted! A team member will follow up with you soon.',
      ];
      final reply = replies[DateTime.now().millisecond % replies.length];
      AppDataStore.instance.addChatMessage(widget.companyName, ChatMessage(
        id: 'cm${DateTime.now().millisecondsSinceEpoch}',
        text: reply,
        senderId: widget.companyName, senderName: widget.companyName,
        isFromUser: false,
      ));
      if (mounted) setState(() {});
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final msgs = _messages;
    return Scaffold(
      backgroundColor: kNavy,
      appBar: AppBar(
        backgroundColor: kNavy2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          CircleAvatar(radius: 16, backgroundColor: widget.avatarColor.withOpacity(0.2),
            child: Text(widget.initials, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: widget.avatarColor))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.companyName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
            const Text('Online', style: TextStyle(fontSize: 11, color: kSuccess)),
          ])),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined, color: kTextS), onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Calling company... (demo)'), backgroundColor: Color(0xFF1D9E75)));
        }),
        ],
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: kSuccess.withOpacity(0.08),
          child: Row(children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: kSuccess, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text('${widget.companyName} typically replies within minutes',
                style: const TextStyle(color: kSuccess, fontSize: 11))),
          ]),
        ),
        Expanded(child: ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(16),
          itemCount: msgs.length,
          itemBuilder: (_, i) {
            final m = msgs[i];
            return Align(
              alignment: m.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!m.isFromUser) ...[
                    CircleAvatar(radius: 14, backgroundColor: widget.avatarColor.withOpacity(0.2),
                      child: Text(widget.initials, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: widget.avatarColor))),
                    const SizedBox(width: 6),
                  ],
                  Flexible(child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: m.isFromUser ? kGold : kSurf,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft: Radius.circular(m.isFromUser ? 14 : 4),
                        bottomRight: Radius.circular(m.isFromUser ? 4 : 14),
                      ),
                    ),
                    child: Text(m.text,
                        style: TextStyle(fontSize: 13, color: m.isFromUser ? Colors.black : kText)),
                  )),
                ],
              ),
            );
          },
        )),
        SizedBox(height: 44, child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          children: [
            if (widget.carName.isNotEmpty) 'Is the ${widget.carName} available?',
            "What\'s the daily rate?",
            'Do you offer airport pickup?',
            'Can I see the car first?',
          ].map((q) => GestureDetector(
            onTap: () => _send(q),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: kSurf, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kGold.withOpacity(0.3), width: 0.8)),
              child: Center(child: Text(q, style: const TextStyle(color: kGold, fontSize: 11))),
            ),
          )).toList(),
        )),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          color: kNavy2,
          child: Row(children: [
            Expanded(child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: kText, fontSize: 13),
              onSubmitted: _send,
              decoration: InputDecoration(
                hintText: 'Type a message…',
                hintStyle: const TextStyle(color: kTextS, fontSize: 13),
                filled: true, fillColor: kSurf,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            )),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _send(_ctrl.text),
              child: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}