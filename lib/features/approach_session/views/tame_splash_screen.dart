import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'approach_arena_screen.dart';

class TameSplashScreen extends StatefulWidget {
  final String catId;

  const TameSplashScreen({
    super.key,
    required this.catId,
  });

  @override
  State<TameSplashScreen> createState() => _TameSplashScreenState();
}

class _TameSplashScreenState extends State<TameSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _sunburstController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutBack,
      ),
    );

    _sunburstController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _entryController.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ApproachArenaScreen(catId: widget.catId),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entryController.dispose();
    _sunburstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen warm orange gradient with soft peach center glow
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.gameSplashTop,
                  Color(0xFFFA9D62),
                  AppColors.gameSplashBottom,
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.82,
                colors: [
                  AppColors.gameSunburst.withOpacity(0.88),
                  AppColors.gameSunburst.withOpacity(0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Rotating radial sunburst rays
          AnimatedBuilder(
            animation: _sunburstController,
            builder: (context, _) {
              return Transform.rotate(
                angle: _sunburstController.value * 2 * math.pi,
                child: CustomPaint(
                  painter: _SunburstPainter(
                    rayColor: AppColors.gameSunburst.withOpacity(0.42),
                  ),
                ),
              );
            },
          ),

          // Subtle background edge paws & stars (no text)
          Positioned(
            top: 72,
            left: 36,
            child: Transform.rotate(
              angle: -0.3,
              child: Icon(
                Icons.pets_rounded,
                size: 32,
                color: AppColors.gameSplashText.withOpacity(0.16),
              ),
            ),
          ),
          Positioned(
            top: 120,
            right: 40,
            child: Icon(
              Icons.star_border_rounded,
              size: 30,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
          Positioned(
            bottom: 130,
            left: 42,
            child: Transform.rotate(
              angle: -0.25,
              child: Icon(
                Icons.pets_rounded,
                size: 38,
                color: Colors.white.withOpacity(0.28),
              ),
            ),
          ),
          Positioned(
            bottom: 165,
            right: 52,
            child: Transform.rotate(
              angle: 0.25,
              child: Icon(
                Icons.pets_rounded,
                size: 26,
                color: AppColors.gameSplashText.withOpacity(0.14),
              ),
            ),
          ),

          // Only "Jinakkan Kucing!" sticker title with flanking paw emblems
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildFlankingPawBadge(isLeft: true),
                      const SizedBox(width: 6),
                      _buildStickerTitle(),
                      const SizedBox(width: 6),
                      _buildFlankingPawBadge(isLeft: false),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlankingPawBadge({required bool isLeft}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.gameSplashText.withOpacity(0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.pets_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        Positioned(
          top: isLeft ? -4 : null,
          bottom: isLeft ? null : -4,
          left: isLeft ? -6 : null,
          right: isLeft ? null : -6,
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: Color(0xFFFACC15),
          ),
        ),
      ],
    );
  }

  Widget _buildStickerTitle() {
    const baseStyle = TextStyle(
      fontSize: 38,
      fontWeight: FontWeight.w800,
      height: 1.08,
      letterSpacing: -0.8,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // Warm brown drop shadow
        Transform.translate(
          offset: const Offset(0, 4),
          child: Text(
            'Jinakkan\nKucing!',
            textAlign: TextAlign.center,
            style: baseStyle.copyWith(
              color: const Color(0xFF9A3412).withOpacity(0.45),
            ),
          ),
        ),
        // Thick white sticker outline
        Text(
          'Jinakkan\nKucing!',
          textAlign: TextAlign.center,
          style: baseStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 7
              ..strokeJoin = StrokeJoin.round
              ..color = Colors.white,
          ),
        ),
        // Deep terracotta fill
        Text(
          'Jinakkan\nKucing!',
          textAlign: TextAlign.center,
          style: baseStyle.copyWith(
            color: AppColors.gameSplashText,
          ),
        ),
      ],
    );
  }
}

class _SunburstPainter extends CustomPainter {
  final Color rayColor;

  const _SunburstPainter({required this.rayColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * 0.9;
    final paint = Paint()
      ..color = rayColor
      ..style = PaintingStyle.fill;

    const rayCount = 10;
    const step = (2 * math.pi) / rayCount;
    const halfWidth = step * 0.24;

    for (var i = 0; i < rayCount; i++) {
      final angle = i * step;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + radius * math.cos(angle - halfWidth),
          center.dy + radius * math.sin(angle - halfWidth),
        )
        ..lineTo(
          center.dx + radius * math.cos(angle + halfWidth),
          center.dy + radius * math.sin(angle + halfWidth),
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) =>
      oldDelegate.rayColor != rayColor;
}
