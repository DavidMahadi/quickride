import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/services/auth_service.dart';
import 'package:swiftride/screens/user/booking_screen.dart';
import 'package:swiftride/screens/guest/app_shell.dart';

class CarDetailScreen extends StatefulWidget {
  final String carName;
  final String company;
  final String price;
  final String category;
  final double rating;
  final int reviews;
  final int seats;
  final String fuel;
  final String transmission;

  const CarDetailScreen({
    super.key,
    required this.carName,
    required this.company,
    required this.price,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.seats,
    required this.fuel,
    required this.transmission,
  });

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  bool _isFavorite = false;
  int _selectedImageIndex = 0;

  // Parse "$120" or "120" → 120
  int _parsePriceInt(String price) {
    final cleaned = price.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  final List<_Review> _dummyReviews = [
    _Review(name: 'James K.', avatar: 'JK', rating: 5, comment: 'Excellent car, very clean and comfortable. Pickup was smooth.', date: 'May 2024'),
    _Review(name: 'Sarah M.', avatar: 'SM', rating: 5, comment: 'Great experience! The company was very professional.', date: 'Apr 2024'),
    _Review(name: 'David R.', avatar: 'DR', rating: 4, comment: 'Good car but drop-off took a bit longer than expected.', date: 'Mar 2024'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg     : AppColors.lightBg;
    final card    = isDark ? AppColors.darkCard   : AppColors.lightCard;
    final surface = isDark ? AppColors.darkSurface: AppColors.lightSurface;
    final border  = isDark ? AppColors.darkBorder : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white         : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: AppBottomNav(activeIndex: 0),
      body: Stack(children: [
        // ── Scrollable content ──
        CustomScrollView(slivers: [

          // ── App bar with car image ──
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: bg,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: textPri, size: 20),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => setState(() => _isFavorite = !_isFavorite),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_outline,
                    color: _isFavorite ? Colors.redAccent : textSec,
                    size: 20,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.share_outlined, color: textSec, size: 20),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: isDark ? AppColors.darkCard : const Color(0xFF1C2236),
                child: Stack(children: [
                  // Gold glow
                  Center(child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withOpacity(0.06),
                    ),
                  )),
                  // Car icon
                  Center(child: Icon(Icons.directions_car, size: 160,
                      color: Colors.white.withOpacity(0.07))),
                  // Category badge
                  Positioned(bottom: 16, left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5),
                      ),
                      child: Text(widget.category,
                          style: const TextStyle(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  // Image dots
                  Positioned(bottom: 16, right: 20,
                    child: Row(children: List.generate(3, (i) => Container(
                      width: i == _selectedImageIndex ? 16 : 6,
                      height: 6, margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: i == _selectedImageIndex ? AppColors.gold : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ))),
                  ),
                ]),
              ),
            ),
          ),

          // ── Body content ──
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Name + rating ──
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.carName,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPri)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.business_outlined, size: 13, color: textSec),
                    const SizedBox(width: 4),
                    Text(widget.company, style: TextStyle(fontSize: 13, color: textSec)),
                  ]),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  RichText(text: TextSpan(children: [
                    TextSpan(text: widget.price,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.gold)),
                    TextSpan(text: '/day', style: TextStyle(fontSize: 12, color: textSec)),
                  ])),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star, color: AppColors.gold, size: 14),
                    const SizedBox(width: 3),
                    Text(widget.rating.toStringAsFixed(1),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
                    Text(' (${widget.reviews} reviews)',
                        style: TextStyle(fontSize: 12, color: textSec)),
                  ]),
                ]),
              ]),

              const SizedBox(height: 20),

              // ── Specs grid ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: 0.5),
                ),
                child: Row(children: [
                  _SpecItem(icon: Icons.people_outline, label: 'Seats', value: '${widget.seats}', textPri: textPri, textSec: textSec),
                  _Divider(border: border),
                  _SpecItem(icon: Icons.settings_outlined, label: 'Trans.', value: widget.transmission, textPri: textPri, textSec: textSec),
                  _Divider(border: border),
                  _SpecItem(icon: Icons.local_gas_station_outlined, label: 'Fuel', value: widget.fuel, textPri: textPri, textSec: textSec),
                  _Divider(border: border),
                  _SpecItem(icon: Icons.ac_unit_outlined, label: 'A/C', value: 'Yes', textPri: textPri, textSec: textSec),
                ]),
              ),

              const SizedBox(height: 20),

              // ── Features ──
              Text('Features', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _FeatureBadge(label: 'GPS Navigation', surface: surface, border: border, textSec: textSec),
                _FeatureBadge(label: 'Bluetooth', surface: surface, border: border, textSec: textSec),
                _FeatureBadge(label: 'USB Charging', surface: surface, border: border, textSec: textSec),
                _FeatureBadge(label: 'Child Seat', surface: surface, border: border, textSec: textSec),
                _FeatureBadge(label: 'Backup Camera', surface: surface, border: border, textSec: textSec),
                _FeatureBadge(label: 'Sunroof', surface: surface, border: border, textSec: textSec),
              ]),

              const SizedBox(height: 20),

              // ── Company info ──
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: 0.5),
                ),
                child: Row(children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('DK',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gold))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.company,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.star, color: AppColors.gold, size: 12),
                      const SizedBox(width: 3),
                      Text('4.9 · 120 rentals · Since 2019',
                          style: TextStyle(fontSize: 11, color: textSec)),
                    ]),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5),
                    ),
                    child: const Text('Chat',
                        style: TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),

              const SizedBox(height: 20),

              // ── Reviews section ──
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPri)),
                Text('${widget.reviews} total', style: TextStyle(fontSize: 12, color: textSec)),
              ]),
              const SizedBox(height: 12),

              // Guest: blur overlay
              if (!AuthService.isLoggedIn) ...[
                _GuestReviewGate(
                  card: card, border: border, textPri: textPri, textSec: textSec,
                  onSignIn: () {
                    // pendingRoute already set if they came via Book Now;
                    // for reviews-only gate, send to user home after login
                    if (!AuthService.isLoggedIn && AuthService.pendingRoute == null) {
                      AuthService.setPending('/user/home');
                    }
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ] else ...[
                ..._dummyReviews.map((r) => _ReviewCard(
                  review: r, card: card, border: border, textPri: textPri, textSec: textSec,
                )),
              ],

              const SizedBox(height: 80), // bottom padding for CTA
            ]),
          )),
        ]),

        // ── Sticky bottom CTA ──
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: bg,
                border: Border(top: BorderSide(color: border, width: 0.5)),
              ),
              child: Row(children: [
                // Price summary
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total / day', style: TextStyle(fontSize: 11, color: textSec)),
                  Text(widget.price,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.gold)),
                ]),
                const SizedBox(width: 20),
                // Book button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!AuthService.isLoggedIn) {
                        // Build a car map matching kAllCars format for BookingFlowScreen
                        AuthService.setPending('/user/booking', args: <String, dynamic>{
                          'id':           '',
                          'name':         widget.carName,
                          'brand':        widget.company,
                          'year':         '2023',
                          'category':     widget.category,
                          'price':        widget.price, // keep as string e.g. "$45"
                          'rating':       widget.rating,
                          'seats':        widget.seats,
                          'transmission': widget.transmission,
                          'fuel':         widget.fuel,
                          'range':        'N/A',
                          'color':        '0xFF37474F', // string to avoid DDC int loss
                          'company':      widget.company,
                          'desc':         '',
                        });
                        _showSignUpGate(context, isDark, card, border, textPri, textSec);
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(
                          carName: widget.carName, company: widget.company,
                          price: widget.price, category: widget.category,
                          seats: widget.seats, fuel: widget.fuel,
                          transmission: widget.transmission,
                        )));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('Book Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16, color: Colors.black),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  void _showSignUpGate(BuildContext context, bool isDark, Color card, Color border, Color textPri, Color textSec) {
    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.lock_outline, color: AppColors.gold, size: 26),
          ),
          const SizedBox(height: 16),
          Text('Sign in to book', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
          const SizedBox(height: 6),
          Text('Create a free account to book cars, track rentals and chat with companies.',
              style: TextStyle(fontSize: 13, color: textSec, height: 1.5), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ...[
            [Icons.check_circle_outline, 'Book and pay securely'],
            [Icons.check_circle_outline, 'Track your rentals live'],
            [Icons.check_circle_outline, 'Message companies directly'],
            [Icons.check_circle_outline, 'Read full reviews'],
          ].map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Icon(item[0] as IconData, color: const Color(0xFF1D9E75), size: 18),
              const SizedBox(width: 10),
              Text(item[1] as String, style: TextStyle(fontSize: 13, color: textPri)),
            ]),
          )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pushNamed(context, '/register'); },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold, foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Create free account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              // pendingRoute already set by Book Now handler above
              Navigator.pushNamed(context, '/login');
            },
            child: Text('Already have an account? Sign in',
                style: TextStyle(fontSize: 13, color: textSec)),
          ),
        ]),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color textPri, textSec;
  const _SpecItem({required this.icon, required this.label, required this.value, required this.textPri, required this.textSec});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: AppColors.gold, size: 18),
    ),
    const SizedBox(height: 6),
    Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
    const SizedBox(height: 2),
    Text(label, style: TextStyle(fontSize: 10, color: textSec)),
  ]));
}

class _Divider extends StatelessWidget {
  final Color border;
  const _Divider({required this.border});
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 50, color: border, margin: const EdgeInsets.symmetric(horizontal: 4));
}

class _FeatureBadge extends StatelessWidget {
  final String label;
  final Color surface, border, textSec;
  const _FeatureBadge({required this.label, required this.surface, required this.border, required this.textSec});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: surface, borderRadius: BorderRadius.circular(20),
      border: Border.all(color: border, width: 0.5),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.check, color: AppColors.gold, size: 12),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 12, color: textSec)),
    ]),
  );
}

class _GuestReviewGate extends StatelessWidget {
  final Color card, border, textPri, textSec;
  final VoidCallback onSignIn;
  const _GuestReviewGate({required this.card, required this.border, required this.textPri, required this.textSec, required this.onSignIn});
  @override
  Widget build(BuildContext context) => Stack(children: [
    // Blurred dummy reviews
    Column(children: [
      _DummyReviewBlur(border: border),
      const SizedBox(height: 8),
      _DummyReviewBlur(border: border),
    ]),
    // Overlay
    Positioned.fill(child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.transparent, card.withOpacity(0.95)],
        ),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        const Icon(Icons.lock_outline, color: AppColors.gold, size: 24),
        const SizedBox(height: 8),
        Text('Sign in to read reviews', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPri)),
        const SizedBox(height: 4),
        Text('See what other customers say', style: TextStyle(fontSize: 12, color: textSec)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onSignIn,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(8)),
            child: const Text('Sign in', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black)),
          ),
        ),
        const SizedBox(height: 16),
      ]),
    )),
  ]);
}

class _DummyReviewBlur extends StatelessWidget {
  final Color border;
  const _DummyReviewBlur({required this.border});
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: 0.3,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: border.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 14, backgroundColor: border),
          const SizedBox(width: 8),
          Container(width: 80, height: 10, color: border),
          const Spacer(),
          Container(width: 40, height: 10, color: border),
        ]),
        const SizedBox(height: 8),
        Container(width: double.infinity, height: 8, color: border),
        const SizedBox(height: 4),
        Container(width: 200, height: 8, color: border),
      ]),
    ),
  );
}

class _ReviewCard extends StatelessWidget {
  final _Review review;
  final Color card, border, textPri, textSec;
  const _ReviewCard({required this.review, required this.card, required this.border, required this.textPri, required this.textSec});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.gold.withOpacity(0.15),
          child: Text(review.avatar, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(review.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
          Text(review.date, style: TextStyle(fontSize: 11, color: textSec)),
        ])),
        Row(children: List.generate(review.rating, (_) => const Icon(Icons.star, color: AppColors.gold, size: 13))),
      ]),
      const SizedBox(height: 8),
      Text(review.comment, style: TextStyle(fontSize: 12, color: textSec, height: 1.5)),
    ]),
  );
}

class _Review {
  final String name, avatar, comment, date;
  final int rating;
  const _Review({required this.name, required this.avatar, required this.rating, required this.comment, required this.date});
}
