import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/primary_button.dart';
import '../../cat_dex/data/repositories/mock_cat_repository.dart';
import '../../cat_dex/views/widgets/rename_cat_dialog.dart';
import '../../navigation/views/main_navigation_screen.dart';

class CelebrationScreen extends StatefulWidget {
  final String catId;

  const CelebrationScreen({
    super.key,
    required this.catId,
  });

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _jumpController;
  late final Animation<double> _jumpAnimation;
  late final AnimationController _confettiController;

  @override
  void initState() {
    super.initState();

    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    _jumpAnimation = Tween<double>(begin: 0.0, end: -18.0).animate(
      CurvedAnimation(
        parent: _jumpController,
        curve: Curves.easeInOutSine,
      ),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(initialIndex: 0),
      ),
      (route) => false,
    );
  }

  Future<void> _openRenameDialog() async {
    final renamed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => RenameCatDialog(catId: widget.catId),
    );

    if (renamed == true && mounted) {
      final updatedName = MockCatRepository().getCatById(widget.catId).name;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat! Nama permanen "$updatedName" berhasil dikunci.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = MockCatRepository();

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final cat = repo.getCatById(widget.catId);
        final displayEncounter = cat.encounterCount.clamp(1, 5);

        String titleText;
        String subtitleText;
        if (cat.canBeNamed) {
          titleText = 'Kucing Kampus Resmi\nJadi Sahabatmu!';
          subtitleText = 'Kamu membuka status pertemanan sejati 🌟';
        } else if (cat.isNameLocked) {
          titleText = '${cat.name} Senang\nBertemu Lagi!';
          subtitleText = 'Ikatan persahabatan kalian makin erat 💖';
        } else {
          final remaining = (5 - cat.encounterCount).clamp(1, 5);
          titleText = 'Kamu Berhasil\nMenjinakkannya!';
          subtitleText =
              'Sapa $remaining kali lagi untuk memberi nama permanen!';
        }

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Pastel Celebration Gradient Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.celebrationBgTop,
                      AppColors.celebrationBgBottom,
                    ],
                  ),
                ),
              ),

              // Radial Sunburst
              CustomPaint(
                painter: _CelebrationSunburstPainter(
                  rayColor: Colors.white.withOpacity(0.45),
                ),
              ),

              // Animated Falling Confetti & Hearts
              AnimatedBuilder(
                animation: _confettiController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiHeartsPainter(
                      progress: _confettiController.value,
                    ),
                  );
                },
              ),

              // Main Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.marginHorizontal,
                    vertical: AppDimensions.spaceMd,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Top Ribbon Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.swipeOrbStart,
                              AppColors.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.32),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          '★  IKATAN TERJALIN!  ★',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.9,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Big Celebration Title
                      Text(
                        titleText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          color: AppColors.celebrationTitle,
                          height: 1.18,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitleText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF78350F),
                        ),
                      ),

                      // Jumping Happy Cat Sprite (transparent, no white box)
                      Expanded(
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 240,
                                height: 240,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.65),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _jumpAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _jumpAnimation.value),
                                    child: child,
                                  );
                                },
                                child: Image.asset(
                                  cat.happyPoseAsset,
                                  width: 245,
                                  height: 245,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.pets_rounded,
                                    size: 110,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Encounter Pill Badge: "Pertemuan X / 5"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.borderSubtle),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryPeach,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.pets_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              cat.isNameLocked
                                  ? 'Pertemuan $displayEncounter / 5 • ${cat.name}'
                                  : 'Pertemuan $displayEncounter / 5',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: AppColors.sweetSpotGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Action Buttons
                      if (cat.canBeNamed) ...[
                        PrimaryButton(
                          label: 'Beri Nama',
                          icon: Icons.edit_rounded,
                          onPressed: _openRenameDialog,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _goToHome,
                          child: const Text(
                            'Selesai',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ] else ...[
                        PrimaryButton(
                          label: 'Selesai',
                          icon: Icons.check_rounded,
                          onPressed: _goToHome,
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CelebrationSunburstPainter extends CustomPainter {
  final Color rayColor;

  const _CelebrationSunburstPainter({required this.rayColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.48);
    final radius = math.max(size.width, size.height) * 0.9;
    final paint = Paint()
      ..color = rayColor
      ..style = PaintingStyle.fill;

    const rayCount = 12;
    const step = (2 * math.pi) / rayCount;
    const halfWidth = step * 0.22;

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
  bool shouldRepaint(covariant _CelebrationSunburstPainter oldDelegate) =>
      oldDelegate.rayColor != rayColor;
}

class _ConfettiHeartsPainter extends CustomPainter {
  final double progress;

  const _ConfettiHeartsPainter({required this.progress});

  static const _items = [
    (0.12, 0.10, Color(0xFFFACC15), 7.0),
    (0.86, 0.16, Color(0xFFFB7185), 8.0),
    (0.22, 0.34, Color(0xFFF97316), 6.0),
    (0.78, 0.42, Color(0xFFFACC15), 7.0),
    (0.15, 0.62, Color(0xFFFB7185), 8.0),
    (0.88, 0.68, Color(0xFF22C55E), 6.0),
    (0.32, 0.80, Color(0xFFFACC15), 7.0),
    (0.70, 0.84, Color(0xFFF97316), 6.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _items.length; i++) {
      final (xFactor, ySeed, color, radius) = _items[i];
      final yPos = ((ySeed + progress + (i * 0.09)) % 1.0) * size.height;
      final xPos =
          xFactor * size.width + math.sin((progress * 2 * math.pi) + i) * 10;

      final paint = Paint()..color = color.withOpacity(0.75);
      canvas.drawCircle(Offset(xPos, yPos), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiHeartsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
