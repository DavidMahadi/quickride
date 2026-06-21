import 'package:flutter/material.dart';
import 'dart:async';
import 'package:swiftride/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _featureFadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _featureFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigate after 3.5 seconds
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AuthService.isLoggedIn ? '/user/home' : '/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // ── Background gradient overlay ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0E1A),
                  Color(0xFF0D1424),
                  Color(0xFF0A0E1A),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Car hero image ──
          // Car icon — no external asset needed
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 220,
              child: Center(
                child: Icon(
                  Icons.directions_car_rounded,
                  size: 160,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
          ),

          // ── Radial glow behind car ──
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    const Color(0xFFD4A017).withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom gold curve bar ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: _GoldCurvePainter(),
              size: const Size(double.infinity, 6),
            ),
          ),

          // ── Main content ──
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo + title
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => Opacity(
                    opacity: _fadeAnim.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnim.value),
                      child: Column(
                        children: [
                          // Car line icon (SVG-style using CustomPaint)
                          CustomPaint(
                            painter: _CarLinePainter(),
                            size: const Size(120, 40),
                          ),
                          const SizedBox(height: 16),

                          // CAR RENTAL text
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'CAR ',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                                TextSpan(
                                  text: 'RENTAL',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFD4A017),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Divider with tagline
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 1,
                                color: const Color(0xFFD4A017),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'Drive Your Journey',
                                  style: TextStyle(
                                    color: Color(0xFFD4A017),
                                    fontSize: 13,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 1,
                                color: const Color(0xFFD4A017),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Feature icons row
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => Opacity(
                    opacity: _featureFadeAnim.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          _FeatureItem(
                            icon: Icons.calendar_month_outlined,
                            label: 'Easy Booking',
                          ),
                          _FeatureItem(
                            icon: Icons.directions_car_outlined,
                            label: 'Wide Selection',
                          ),
                          _FeatureItem(
                            icon: Icons.verified_user_outlined,
                            label: 'Safe & Reliable',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature icon + label widget ──────────────────────────────────────────────

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFD4A017).withOpacity(0.4),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFD4A017),
            size: 26,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ── Gold curve bottom bar painter ────────────────────────────────────────────

class _GoldCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4A017)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.25, 0,
        size.width * 0.5, size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height,
        size.width, size.height * 0.5,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Car silhouette line painter ───────────────────────────────────────────────

class _CarLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4A017)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.05, size.height * 0.65)
      ..lineTo(size.width * 0.15, size.height * 0.35)
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.1,
        size.width * 0.5, size.height * 0.1,
      )
      ..quadraticBezierTo(
        size.width * 0.7, size.height * 0.1,
        size.width * 0.85, size.height * 0.35,
      )
      ..lineTo(size.width * 0.95, size.height * 0.65);

    canvas.drawPath(path, paint);

    // Wheels
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.75),
      size.height * 0.18,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.75),
      size.height * 0.18,
      paint,
    );

    // Body bottom line
    canvas.drawLine(
      Offset(size.width * 0.05, size.height * 0.65),
      Offset(size.width * 0.95, size.height * 0.65),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
