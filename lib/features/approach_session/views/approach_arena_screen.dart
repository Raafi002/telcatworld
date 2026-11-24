import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../cat_dex/data/models/cat_model.dart';
import '../../cat_dex/data/repositories/mock_cat_repository.dart';
import '../../encounter_result/views/celebration_screen.dart';

enum PettingPose {
  head,
  belly,
}

class ApproachArenaScreen extends StatefulWidget {
  final String catId;

  const ApproachArenaScreen({
    super.key,
    required this.catId,
  });

  @override
  State<ApproachArenaScreen> createState() => _ApproachArenaScreenState();
}

class _ApproachArenaScreenState extends State<ApproachArenaScreen>
    with TickerProviderStateMixin {
  final math.Random _random = math.Random();

  late final PettingPose _firstPose;
  late final AnimationController _breathController;
  late final Animation<double> _breathAnimation;
  late final Ticker _gameTicker;

  Timer? _spawnTimer;
  Timer? _reactionResetTimer;
  Duration _lastTick = Duration.zero;

  double _progress = 0.0;
  bool _hasSwitchedPhase = false;
  bool _isCompleted = false;
  bool _isPaused = false;
  bool _isMuted = false;
  bool _hasSwipedOnce = false;

  // Cat squish & wiggle reaction state
  double _catReactionScale = 1.0;
  double _catWiggleTurns = 0.0;
  int _wiggleDirection = 1;

  // Active orbs, floating heart particles, and swipe trail points
  final List<_SwipeOrb> _orbs = [];
  final List<_HeartParticle> _particles = [];
  final List<_TrailPoint> _trailPoints = [];
  int _orbCounter = 0;

  @override
  void initState() {
    super.initState();
    _firstPose = _random.nextBool() ? PettingPose.head : PettingPose.belly;

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );

    _gameTicker = createTicker(_onTick)..start();
    _spawnOrb();
    _startSpawnTimer();
  }

  void _startSpawnTimer() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!mounted || _isPaused || _isCompleted) return;
      if (_orbs.length < 5) {
        _spawnOrb();
      }
    });
  }

  void _spawnOrb() {
    _orbCounter++;
    final spawnFromLeft = _orbCounter.isOdd;
    final icons = [
      Icons.pets_rounded,
      Icons.favorite_rounded,
      Icons.auto_awesome_rounded,
    ];

    setState(() {
      _orbs.add(
        _SwipeOrb(
          id: _orbCounter,
          fromLeft: spawnFromLeft,
          t: 0.0,
          speed: 0.34 + _random.nextDouble() * 0.14,
          arcOffset: (_random.nextDouble() - 0.5) * 0.16,
          radius: _orbCounter == 1 ? 33.0 : (26.0 + _random.nextDouble() * 6.0),
          icon: icons[_orbCounter % icons.length],
        ),
      );
    });
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final dt = ((elapsed - _lastTick).inMicroseconds / 1000000.0)
        .clamp(0.0, 0.05);
    _lastTick = elapsed;

    if (!mounted || _isPaused || _isCompleted) return;

    setState(() {
      // Advance orbs along curved paths
      for (final orb in _orbs) {
        orb.t += orb.speed * dt;
      }
      _orbs.removeWhere((orb) => orb.t >= 1.15);

      // Update floating heart particles
      for (final p in _particles) {
        p.age += dt;
        p.offset = Offset(
          p.offset.dx + p.driftX * dt,
          p.offset.dy - 72.0 * dt,
        );
      }
      _particles.removeWhere((p) => p.age >= p.lifetime);

      // Fade swipe trail points
      for (final pt in _trailPoints) {
        pt.age += dt;
      }
      _trailPoints.removeWhere((pt) => pt.age >= 0.28);
    });
  }

  PettingPose get _currentPose {
    if (!_hasSwitchedPhase) return _firstPose;
    return _firstPose == PettingPose.head
        ? PettingPose.belly
        : PettingPose.head;
  }

  Offset _resolveOrbPosition(_SwipeOrb orb, Size stageSize) {
    final cx = stageSize.width * 0.5;
    final cy = stageSize.height * 0.5;
    final catSpan = math.min(stageSize.width * 0.72, 290.0);

    if (_currentPose == PettingPose.head) {
      // Arc path curving across the upper/head area from left side or center
      final t = orb.t.clamp(0.0, 1.0);
      final startX = orb.fromLeft ? cx - catSpan * 0.55 : cx;
      final endX = cx + catSpan * 0.50;
      final baseX = startX + (endX - startX) * t;
      final arcLift = math.sin(t * math.pi) * (catSpan * 0.36);
      final baseY = (cy - catSpan * 0.02) - arcLift + orb.arcOffset * catSpan;
      return Offset(baseX, baseY);
    } else {
      // Orbital ring path around the cat's belly from left or center
      final t = orb.t.clamp(0.0, 1.0);
      final startAngle = orb.fromLeft ? math.pi : -math.pi * 0.5;
      final angle = startAngle + t * (math.pi * 1.45);
      final radiusX = (orb.fromLeft ? catSpan * 0.42 : catSpan * 0.30) +
          orb.arcOffset * 40;
      final radiusY = (orb.fromLeft ? catSpan * 0.34 : catSpan * 0.25) +
          orb.arcOffset * 30;
      return Offset(
        cx + math.cos(angle) * radiusX,
        cy + catSpan * 0.06 + math.sin(angle) * radiusY,
      );
    }
  }

  void _handlePointer(Offset localPosition, Size stageSize) {
    if (_isPaused || _isCompleted) return;

    setState(() {
      _trailPoints.add(_TrailPoint(offset: localPosition));
    });

    final hitIds = <int>[];
    final hitPositions = <Offset>[];

    for (final orb in _orbs) {
      final pos = _resolveOrbPosition(orb, stageSize);
      if ((pos - localPosition).distance <= orb.radius + 18.0) {
        hitIds.add(orb.id);
        hitPositions.add(pos);
      }
    }

    if (hitIds.isEmpty) return;

    if (!_isMuted) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _hasSwipedOnce = true;
      _orbs.removeWhere((o) => hitIds.contains(o.id));

      for (final hitPos in hitPositions) {
        for (var i = 0; i < 3; i++) {
          _particles.add(
            _HeartParticle(
              offset: hitPos +
                  Offset((_random.nextDouble() - 0.5) * 26, -8.0 * i),
              driftX: (_random.nextDouble() - 0.5) * 34,
              size: 16.0 + _random.nextDouble() * 10.0,
              lifetime: 0.75 + _random.nextDouble() * 0.25,
            ),
          );
        }
      }

      // Squish & gentle wiggle feedback
      _wiggleDirection = -_wiggleDirection;
      _catReactionScale = 0.93;
      _catWiggleTurns = _wiggleDirection * 0.024;

      _reactionResetTimer?.cancel();
      _reactionResetTimer = Timer(const Duration(milliseconds: 140), () {
        if (!mounted) return;
        setState(() {
          _catReactionScale = 1.05;
          _catWiggleTurns = -_wiggleDirection * 0.012;
        });
        _reactionResetTimer = Timer(const Duration(milliseconds: 120), () {
          if (!mounted) return;
          setState(() {
            _catReactionScale = 1.0;
            _catWiggleTurns = 0.0;
          });
        });
      });

      final nextProgress = (_progress + hitIds.length * 0.10).clamp(0.0, 1.0);
      _progress = nextProgress;

      // Auto-switch pose at 50%
      if (!_hasSwitchedPhase && _progress >= 0.50 && _progress < 1.0) {
        _hasSwitchedPhase = true;
        _orbs.clear();
        if (!_isMuted) {
          HapticFeedback.mediumImpact();
        }
        _spawnOrb();
      }
    });

    if (_progress >= 1.0 && !_isCompleted) {
      _completeSession();
    }
  }

  void _completeSession() {
    _isCompleted = true;
    _spawnTimer?.cancel();
    _reactionResetTimer?.cancel();

    if (!_isMuted) {
      HapticFeedback.heavyImpact();
    }

    MockCatRepository().recordEncounter(widget.catId);

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => CelebrationScreen(catId: widget.catId),
          transitionDuration: const Duration(milliseconds: 380),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _reactionResetTimer?.cancel();
    _gameTicker.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = MockCatRepository().getCatById(widget.catId);
    final isHeadPose = _currentPose == PettingPose.head;
    final currentAsset = isHeadPose ? cat.headPoseAsset : cat.bellyPoseAsset;
    final progressPct = (_progress * 100).round().clamp(0, 100);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isHeadPose
                ? const [
                    AppColors.pettingBgHeadTop,
                    AppColors.pettingBgHeadBottom,
                  ]
                : const [
                    AppColors.pettingBgBellyTop,
                    AppColors.pettingBgBellyBottom,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Minimal HUD Header
              _buildTopHud(cat, progressPct, isHeadPose),

              // Main Interactive Stage
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stageSize =
                        Size(constraints.maxWidth, constraints.maxHeight);
                    final catSize = math.min(stageSize.width * 0.72, 290.0);

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) =>
                          _handlePointer(details.localPosition, stageSize),
                      onPanUpdate: (details) =>
                          _handlePointer(details.localPosition, stageSize),
                      onPanEnd: (_) => setState(() => _trailPoints.clear()),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Soft ambient heart & sparkle decorations
                          Positioned(
                            top: 28,
                            left: 36,
                            child: Icon(
                              Icons.favorite_border_rounded,
                              size: 20,
                              color: AppColors.primary.withOpacity(0.45),
                            ),
                          ),
                          Positioned(
                            top: 48,
                            right: 40,
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 22,
                              color: AppColors.swipeHalo.withOpacity(0.8),
                            ),
                          ),
                          Positioned(
                            bottom: 36,
                            left: 44,
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 20,
                              color: AppColors.primary.withOpacity(0.55),
                            ),
                          ),
                          Positioned(
                            bottom: 42,
                            right: 44,
                            child: Icon(
                              Icons.favorite_border_rounded,
                              size: 22,
                              color: AppColors.primaryPeachDark.withOpacity(0.4),
                            ),
                          ),

                          // Soft ground shadow beneath cat
                          Center(
                            child: Transform.translate(
                              offset: Offset(0, catSize * 0.40),
                              child: Container(
                                width: catSize * 0.62,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.14),
                                      blurRadius: 22,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Transparent 2D Cat Sprite (no white background box)
                          Center(
                            child: ScaleTransition(
                              scale: _breathAnimation,
                              child: AnimatedScale(
                                scale: _catReactionScale,
                                duration: const Duration(milliseconds: 140),
                                curve: Curves.easeOutBack,
                                child: AnimatedRotation(
                                  turns: _catWiggleTurns,
                                  duration: const Duration(milliseconds: 140),
                                  curve: Curves.easeOut,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    switchInCurve: Curves.easeOut,
                                    switchOutCurve: Curves.easeIn,
                                    child: Image.asset(
                                      currentAsset,
                                      key: ValueKey<String>(currentAsset),
                                      width: catSize,
                                      height: catSize,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.pets_rounded,
                                        size: 110,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Dashed Charged-Attack Path Guide
                          IgnorePointer(
                            child: CustomPaint(
                              size: stageSize,
                              painter: _SwipeGuidePainter(
                                pose: _currentPose,
                                catSpan: catSize,
                                pathColor: AppColors.swipePath.withOpacity(0.75),
                              ),
                            ),
                          ),

                          // Finger Swipe Trail
                          IgnorePointer(
                            child: CustomPaint(
                              size: stageSize,
                              painter: _SwipeTrailPainter(
                                points: _trailPoints,
                              ),
                            ),
                          ),

                          // Interactive Glowing Swipe Orbs
                          ..._orbs.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final orb = entry.value;
                            final pos = _resolveOrbPosition(orb, stageSize);
                            final showHandHint = !_hasSwipedOnce && idx == 0;

                            return Positioned(
                              left: pos.dx - orb.radius,
                              top: pos.dy - orb.radius,
                              child: IgnorePointer(
                                child: _GlowingOrbWidget(
                                  orb: orb,
                                  showHandHint: showHandHint,
                                ),
                              ),
                            );
                          }),

                          // Floating Heart Particles on Swipe Hit
                          ..._particles.map((p) {
                            final lifeProgress =
                                (p.age / p.lifetime).clamp(0.0, 1.0);
                            final opacity = (1.0 - lifeProgress).clamp(0.0, 1.0);
                            return Positioned(
                              left: p.offset.dx - p.size / 2,
                              top: p.offset.dy - p.size / 2,
                              child: IgnorePointer(
                                child: Opacity(
                                  opacity: opacity,
                                  child: Icon(
                                    Icons.favorite_rounded,
                                    size: p.size,
                                    color: AppColors.heartPink,
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Pause Overlay (minimal)
                          if (_isPaused)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.35),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _isPaused = false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.18),
                                            blurRadius: 20,
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.play_arrow_rounded,
                                            color: AppColors.primary,
                                            size: 28,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Lanjutkan',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Minimal Footer Controls
              _buildFooterControls(isHeadPose),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHud(CatModel cat, int progressPct, bool isHeadPose) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Circular Back Button
          _CircleHudButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 8),

          // Cat Name Badge Pill
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.pets_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      cat.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Affection Progress Capsule
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.heartAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isHeadPose)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Text(
                          'MANJA',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppColors.primaryPeachDark,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: 62,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 8,
                          backgroundColor: AppColors.surfaceSubtle,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPeach,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$progressPct%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryPeachDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterControls(bool isHeadPose) {
    final activePhaseIndex = _hasSwitchedPhase ? 1 : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleHudButton(
            icon: _isMuted
                ? Icons.volume_off_rounded
                : Icons.volume_up_rounded,
            onTap: () => setState(() => _isMuted = !_isMuted),
          ),

          // Phase Indicator Pill (Dot 1 - Paw - Dot 2)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activePhaseIndex == 0
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.35),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.pets_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activePhaseIndex == 1
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ),

          _CircleHudButton(
            icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            onTap: () => setState(() => _isPaused = !_isPaused),
          ),
        ],
      ),
    );
  }
}

class _CircleHudButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleHudButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _GlowingOrbWidget extends StatelessWidget {
  final _SwipeOrb orb;
  final bool showHandHint;

  const _GlowingOrbWidget({
    required this.orb,
    required this.showHandHint,
  });

  @override
  Widget build(BuildContext context) {
    final size = orb.radius * 2;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.swipeOrbStart,
                AppColors.swipeOrbEnd,
              ],
            ),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.swipeHalo.withOpacity(0.75),
                blurRadius: 16,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Icon(
            orb.icon,
            color: Colors.white,
            size: orb.radius * 0.9,
          ),
        ),
        if (showHandHint)
          Positioned(
            bottom: -14,
            right: -12,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primaryPeach,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.swipe_rounded,
                size: 16,
                color: AppColors.primaryPeachDark,
              ),
            ),
          ),
      ],
    );
  }
}

class _SwipeOrb {
  final int id;
  final bool fromLeft;
  double t;
  final double speed;
  final double arcOffset;
  final double radius;
  final IconData icon;

  _SwipeOrb({
    required this.id,
    required this.fromLeft,
    required this.t,
    required this.speed,
    required this.arcOffset,
    required this.radius,
    required this.icon,
  });
}

class _HeartParticle {
  Offset offset;
  final double driftX;
  final double size;
  final double lifetime;
  double age = 0.0;

  _HeartParticle({
    required this.offset,
    required this.driftX,
    required this.size,
    required this.lifetime,
  });
}

class _TrailPoint {
  final Offset offset;
  double age = 0.0;

  _TrailPoint({required this.offset});
}

class _SwipeGuidePainter extends CustomPainter {
  final PettingPose pose;
  final double catSpan;
  final Color pathColor;

  const _SwipeGuidePainter({
    required this.pose,
    required this.catSpan,
    required this.pathColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final paint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (pose == PettingPose.head) {
      final rect = Rect.fromCenter(
        center: Offset(cx, cy - catSpan * 0.02),
        width: catSpan * 1.05,
        height: catSpan * 0.72,
      );
      path.addArc(rect, math.pi, math.pi);
    } else {
      final rect = Rect.fromCenter(
        center: Offset(cx, cy + catSpan * 0.06),
        width: catSpan * 0.84,
        height: catSpan * 0.68,
      );
      path.addOval(rect);
    }

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 8.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SwipeGuidePainter oldDelegate) =>
      oldDelegate.pose != pose ||
      oldDelegate.catSpan != catSpan ||
      oldDelegate.pathColor != pathColor;
}

class _SwipeTrailPainter extends CustomPainter {
  final List<_TrailPoint> points;

  const _SwipeTrailPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final alpha = (1.0 - (p1.age / 0.28)).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = AppColors.swipeHalo.withOpacity(alpha * 0.85)
        ..strokeWidth = 10.0 * alpha
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p0.offset, p1.offset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SwipeTrailPainter oldDelegate) => true;
}
