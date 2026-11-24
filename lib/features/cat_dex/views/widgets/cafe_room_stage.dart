import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../data/models/cat_model.dart';

enum CafeTheme {
  cozy,
  pastel,
  night,
}

extension CafeThemeInfo on CafeTheme {
  String get label {
    switch (this) {
      case CafeTheme.cozy:
        return 'Kafe Hangat';
      case CafeTheme.pastel:
        return 'Taman Pastel';
      case CafeTheme.night:
        return 'Kafe Malam';
    }
  }

  String get assetPath {
    switch (this) {
      case CafeTheme.cozy:
        return AppAssets.cafeBgCozy;
      case CafeTheme.pastel:
        return AppAssets.cafeBgPastel;
      case CafeTheme.night:
        return AppAssets.cafeBgNight;
    }
  }

  Color get ambientBackdropColor {
    switch (this) {
      case CafeTheme.cozy:
        return const Color(0xFFFBF2E6);
      case CafeTheme.pastel:
        return const Color(0xFFFCF0F5);
      case CafeTheme.night:
        return const Color(0xFF1D1A2B);
    }
  }

  CafeTheme get next {
    switch (this) {
      case CafeTheme.cozy:
        return CafeTheme.pastel;
      case CafeTheme.pastel:
        return CafeTheme.night;
      case CafeTheme.night:
        return CafeTheme.cozy;
    }
  }
}

enum _FurnitureKind {
  sleep,
  food,
}

class _FurnitureZone {
  final Offset center;
  final double radius;
  final _FurnitureKind kind;

  const _FurnitureZone({
    required this.center,
    required this.radius,
    required this.kind,
  });
}

enum _DropReaction {
  none,
  sleep,
  food,
}

enum _CatLoopBehavior {
  walking,
  idleSit,
  idleBelly,
  idleLookAround,
  tappedHappy,
  dragging,
  furnitureSleep,
  furnitureEat,
  socialChat,
}

class CafeRoomStage extends StatefulWidget {
  final List<CatModel> activeCats;
  final CafeTheme theme;
  final bool isLaserMode;
  final ValueChanged<CatModel> onCatInteracted;
  final ValueChanged<bool>? onInteractionLockChanged;

  const CafeRoomStage({
    super.key,
    required this.activeCats,
    required this.theme,
    required this.onCatInteracted,
    this.isLaserMode = false,
    this.onInteractionLockChanged,
  });

  @override
  State<CafeRoomStage> createState() => CafeRoomStageState();
}

class CafeRoomStageState extends State<CafeRoomStage>
    with SingleTickerProviderStateMixin {
  final math.Random _random = math.Random();

  /// 10 titik koordinat aman pada area lantai isometrik, bantal, kardus, cat tree, & mangkuk.
  static const List<Offset> _cafeWaypoints = [
    Offset(0.28, 0.59), // Bantal lantai kiri
    Offset(0.39, 0.51), // Bantal lantai tengah
    Offset(0.57, 0.53), // Bantal lantai kanan
    Offset(0.49, 0.43), // Cat Tree pojok atas
    Offset(0.41, 0.69), // Kardus tengah bawah
    Offset(0.73, 0.65), // Mangkuk makanan kanan
    Offset(0.65, 0.59), // Lantai depan pintu kaca
    Offset(0.54, 0.67), // Lantai kayu tengah
    Offset(0.64, 0.72), // Lantai kanan bawah
    Offset(0.49, 0.78), // Lantai bawah dekat tanaman
  ];

  /// Zona perabotan untuk interaksi drop khusus (tidur Zzz / makan ikan).
  static const List<_FurnitureZone> _furnitureZones = [
    _FurnitureZone(
      center: Offset(0.49, 0.43),
      radius: 0.11,
      kind: _FurnitureKind.sleep,
    ),
    _FurnitureZone(
      center: Offset(0.28, 0.59),
      radius: 0.09,
      kind: _FurnitureKind.sleep,
    ),
    _FurnitureZone(
      center: Offset(0.39, 0.51),
      radius: 0.09,
      kind: _FurnitureKind.sleep,
    ),
    _FurnitureZone(
      center: Offset(0.57, 0.53),
      radius: 0.09,
      kind: _FurnitureKind.sleep,
    ),
    _FurnitureZone(
      center: Offset(0.41, 0.69),
      radius: 0.10,
      kind: _FurnitureKind.sleep,
    ),
    _FurnitureZone(
      center: Offset(0.73, 0.65),
      radius: 0.10,
      kind: _FurnitureKind.food,
    ),
  ];

  static const List<String> _chatSymbols = ['❤️', '🐾', '❓', '🎵'];

  final Map<String, GlobalKey<_CafeWalkingCatState>> _catKeys = {};
  final Map<String, int> _catWaypointIndices = {};
  final Map<String, Offset> _catPositions = {};
  final Map<String, Duration> _catMoveDurations = {};
  final Map<String, DateTime> _chatCooldownUntil = {};

  String? _draggingCatId;
  bool _isTouchingCat = false;

  // Mainan 1: Snack Ikan
  Offset? _fishSnackPos;
  Timer? _fishSnackTimer;
  late final AnimationController _fishBounceController;

  // Mainan 2: Laser Pointer
  Offset? _laserPos;
  DateTime _lastLaserChaseDispatch = DateTime.fromMillisecondsSinceEpoch(0);

  // Obrolan simbol antar-kucing
  Timer? _proximityTimer;

  @override
  void initState() {
    super.initState();
    _fishBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..repeat(reverse: true);

    _proximityTimer = Timer.periodic(
      const Duration(milliseconds: 1400),
      (_) => _checkNearbyCatsForChat(),
    );
  }

  @override
  void didUpdateWidget(covariant CafeRoomStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLaserMode && !widget.isLaserMode && _laserPos != null) {
      setState(() {
        _laserPos = null;
      });
    }
  }

  @override
  void dispose() {
    _fishSnackTimer?.cancel();
    _proximityTimer?.cancel();
    _fishBounceController.dispose();
    super.dispose();
  }

  void _notifyLockChanged() {
    widget.onInteractionLockChanged?.call(
      _isTouchingCat || _draggingCatId != null || widget.isLaserMode,
    );
  }

  void _syncActiveCatWaypoints(List<CatModel> cats) {
    final activeIds = cats.map((c) => c.id).toSet();
    _catKeys.removeWhere((id, _) => !activeIds.contains(id));
    _catWaypointIndices.removeWhere((id, _) => !activeIds.contains(id));
    _catPositions.removeWhere((id, _) => !activeIds.contains(id));
    _catMoveDurations.removeWhere((id, _) => !activeIds.contains(id));
    _chatCooldownUntil.removeWhere((id, _) => !activeIds.contains(id));

    const spreadOrder = [0, 3, 4, 5, 9, 2, 6, 1, 7, 8];
    for (final cat in cats) {
      _catKeys.putIfAbsent(
        cat.id,
        () => GlobalKey<_CafeWalkingCatState>(),
      );
      if (!_catWaypointIndices.containsKey(cat.id)) {
        final usedIndices = _catWaypointIndices.values.toSet();
        var candidate = 0;
        for (final idx in spreadOrder) {
          if (!usedIndices.contains(idx)) {
            candidate = idx;
            break;
          }
        }
        _catWaypointIndices[cat.id] = candidate;
        _catPositions[cat.id] = _cafeWaypoints[candidate];
        _catMoveDurations[cat.id] = const Duration(milliseconds: 2800);
      }
    }
  }

  /// Memicu Snack Ikan di tengah lantai kafe selama 6 detik.
  void triggerFishSnack() {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    const fishTarget = Offset(0.54, 0.63);

    _fishSnackTimer?.cancel();
    setState(() {
      _fishSnackPos = fishTarget;
    });

    final cats = widget.activeCats;
    for (var i = 0; i < cats.length; i++) {
      final cat = cats[i];
      if (_draggingCatId == cat.id) continue;

      final currentPos = _catPositions[cat.id] ?? fishTarget;
      final angle = (i * 2 * math.pi) / math.max(1, cats.length);
      final target = Offset(
        (fishTarget.dx + math.cos(angle) * 0.08).clamp(0.18, 0.82),
        (fishTarget.dy + math.sin(angle) * 0.06).clamp(0.40, 0.82),
      );
      final distance = (target - currentPos).distance;
      final durationMs =
          (850 + (distance / 0.50) * 850).round().clamp(850, 1700);
      final duration = Duration(milliseconds: durationMs);
      final facingLeft = target.dx < currentPos.dx;

      setState(() {
        _catPositions[cat.id] = target;
        _catMoveDurations[cat.id] = duration;
      });
      _catKeys[cat.id]?.currentState?.attractToFish(duration, facingLeft);
    }

    _fishSnackTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      setState(() {
        _fishSnackPos = null;
      });
      for (final cat in widget.activeCats) {
        _catKeys[cat.id]?.currentState?.endToyAttraction();
      }
    });
  }

  void _updateLaserTarget(Offset localPos, Size canvasSize) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) return;
    final dx = (localPos.dx / canvasSize.width).clamp(0.12, 0.88);
    final dy = (localPos.dy / canvasSize.height).clamp(0.30, 0.84);
    final nextLaser = Offset(dx, dy);

    setState(() {
      _laserPos = nextLaser;
    });

    final now = DateTime.now();
    if (now.difference(_lastLaserChaseDispatch).inMilliseconds < 220) {
      return;
    }
    _lastLaserChaseDispatch = now;

    final cats = widget.activeCats;
    for (var i = 0; i < cats.length; i++) {
      final cat = cats[i];
      if (_draggingCatId == cat.id) continue;

      final currentPos = _catPositions[cat.id] ?? nextLaser;
      final angle = (i * 2 * math.pi) / math.max(1, cats.length);
      final target = Offset(
        (nextLaser.dx + math.cos(angle) * 0.055).clamp(0.16, 0.84),
        (nextLaser.dy + math.sin(angle) * 0.045).clamp(0.36, 0.82),
      );
      final distance = (target - currentPos).distance;
      final durationMs =
          (450 + (distance / 0.50) * 550).round().clamp(450, 1000);
      final duration = Duration(milliseconds: durationMs);
      final facingLeft = target.dx < currentPos.dx;

      setState(() {
        _catPositions[cat.id] = target;
        _catMoveDurations[cat.id] = duration;
      });
      _catKeys[cat.id]?.currentState?.chaseLaser(duration, facingLeft);
    }
  }

  void _clearLaserDot() {
    if (_laserPos == null) return;
    setState(() {
      _laserPos = null;
    });
    for (final cat in widget.activeCats) {
      _catKeys[cat.id]?.currentState?.endToyAttraction();
    }
  }

  void _checkNearbyCatsForChat() {
    if (!mounted ||
        _draggingCatId != null ||
        _fishSnackPos != null ||
        _laserPos != null) {
      return;
    }

    final now = DateTime.now();
    final cats = widget.activeCats;
    for (var i = 0; i < cats.length; i++) {
      for (var j = i + 1; j < cats.length; j++) {
        final a = cats[i];
        final b = cats[j];

        final coolA = _chatCooldownUntil[a.id];
        final coolB = _chatCooldownUntil[b.id];
        if ((coolA != null && now.isBefore(coolA)) ||
            (coolB != null && now.isBefore(coolB))) {
          continue;
        }

        final stateA = _catKeys[a.id]?.currentState;
        final stateB = _catKeys[b.id]?.currentState;
        if (stateA == null ||
            stateB == null ||
            !stateA.isEligibleForChat ||
            !stateB.isEligibleForChat) {
          continue;
        }

        final posA = _catPositions[a.id];
        final posB = _catPositions[b.id];
        if (posA == null || posB == null) continue;

        if ((posA - posB).distance <= 0.16) {
          final symA = _chatSymbols[_random.nextInt(_chatSymbols.length)];
          final symB = _chatSymbols[_random.nextInt(_chatSymbols.length)];
          _chatCooldownUntil[a.id] = now.add(const Duration(seconds: 8));
          _chatCooldownUntil[b.id] = now.add(const Duration(seconds: 8));

          stateA.showSocialChat(symA, posB.dx < posA.dx);
          stateB.showSocialChat(symB, posA.dx < posB.dx);
          return;
        }
      }
    }
  }

  _WaypointMoveResult _requestNextWaypoint(String catId) {
    final currentIndex = _catWaypointIndices[catId] ?? 0;
    final currentPos = _catPositions[catId] ?? _cafeWaypoints[currentIndex];

    final occupiedByOthers = <int>{};
    _catWaypointIndices.forEach((id, wpIdx) {
      if (id != catId) {
        occupiedByOthers.add(wpIdx);
      }
    });

    final available = <int>[];
    for (var i = 0; i < _cafeWaypoints.length; i++) {
      if (i != currentIndex && !occupiedByOthers.contains(i)) {
        available.add(i);
      }
    }

    final nextIndex = available.isNotEmpty
        ? available[_random.nextInt(available.length)]
        : (currentIndex + 1) % _cafeWaypoints.length;

    final nextPos = _cafeWaypoints[nextIndex];
    final distance = (nextPos - currentPos).distance;
    final durationMs =
        (2500 + (distance / 0.55) * 2000).round().clamp(2500, 4500);
    final duration = Duration(milliseconds: durationMs);
    final facingLeft = nextPos.dx < currentPos.dx;

    if (mounted) {
      setState(() {
        _catWaypointIndices[catId] = nextIndex;
        _catPositions[catId] = nextPos;
        _catMoveDurations[catId] = duration;
      });
    }

    return _WaypointMoveResult(
      duration: duration,
      facingLeft: facingLeft,
    );
  }

  void _handleDragStart(CatModel cat) {
    setState(() {
      _draggingCatId = cat.id;
      _catMoveDurations[cat.id] = Duration.zero;
    });
    _notifyLockChanged();
    widget.onCatInteracted(cat);
  }

  void _handleDragUpdate(String catId, double deltaDx, double deltaDy) {
    final current = _catPositions[catId] ?? const Offset(0.5, 0.6);
    final nextX = (current.dx + deltaDx).clamp(0.10, 0.90);
    final nextY = (current.dy + deltaDy).clamp(0.18, 0.88);
    setState(() {
      _catPositions[catId] = Offset(nextX, nextY);
      _catMoveDurations[catId] = Duration.zero;
    });
  }

  _DropReaction _handleDragEnd(String catId) {
    final dropPos = _catPositions[catId] ?? const Offset(0.5, 0.6);

    // Validasi jarak ke waypoint lantai isometrik terdekat
    var nearestIndex = 0;
    var minDist = double.infinity;
    for (var i = 0; i < _cafeWaypoints.length; i++) {
      final d = (dropPos - _cafeWaypoints[i]).distance;
      if (d < minDist) {
        minDist = d;
        nearestIndex = i;
      }
    }

    const maxSafeFloorDistance = 0.14;
    final finalPos =
        minDist <= maxSafeFloorDistance ? dropPos : _cafeWaypoints[nearestIndex];

    // Cek apakah posisi akhir mendarat di atas / dekat perabotan kafe
    var reaction = _DropReaction.none;
    var bestFurnitureDist = double.infinity;
    for (final zone in _furnitureZones) {
      final d = (finalPos - zone.center).distance;
      if (d <= zone.radius && d < bestFurnitureDist) {
        bestFurnitureDist = d;
        reaction = zone.kind == _FurnitureKind.food
            ? _DropReaction.food
            : _DropReaction.sleep;
      }
    }

    setState(() {
      _draggingCatId = null;
      _catWaypointIndices[catId] = nearestIndex;
      _catPositions[catId] = finalPos;
      _catMoveDurations[catId] = const Duration(milliseconds: 360);
    });
    _notifyLockChanged();

    return reaction;
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.activeCats;
    _syncActiveCatWaypoints(cats);

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final canvasWidth = constraints.maxWidth;
          final canvasHeight = constraints.maxHeight;
          final canvasSize = Size(canvasWidth, canvasHeight);

          return Stack(
            children: [
              // Animated Theme Background Switcher
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: Image.asset(
                    widget.theme.assetPath,
                    key: ValueKey<CafeTheme>(widget.theme),
                    fit: BoxFit.cover,
                    width: canvasWidth,
                    height: canvasHeight,
                    errorBuilder: (_, __, ___) => Container(
                      color: widget.theme.ambientBackdropColor,
                      child: const Center(
                        child: Icon(
                          Icons.coffee_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Subtle ambient lighting tint
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(
                            widget.theme == CafeTheme.night ? 0.22 : 0.08,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Snack Ikan Toy on Cafe Floor
              if (_fishSnackPos != null)
                Positioned(
                  left: (_fishSnackPos!.dx * canvasWidth) - 22,
                  top: (_fishSnackPos!.dy * canvasHeight) - 22,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _fishBounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -6 * _fishBounceController.value),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.90),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.swipeHalo.withOpacity(0.75),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text('🐟', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                  ),
                ),

              // Independent Wandering & Draggable Cats
              ...cats.map((cat) {
                final spot = _catPositions[cat.id] ??
                    _cafeWaypoints[_catWaypointIndices[cat.id] ?? 0];
                final isDraggingThis = _draggingCatId == cat.id;
                final duration = isDraggingThis
                    ? Duration.zero
                    : (_catMoveDurations[cat.id] ??
                        const Duration(milliseconds: 2800));

                const actorWidth = 96.0;
                const actorHeight = 88.0;
                final left = (spot.dx * canvasWidth) - (actorWidth / 2);
                final top = (spot.dy * canvasHeight) - (actorHeight - 10);

                return AnimatedPositioned(
                  key: ValueKey<String>('pos_${cat.id}'),
                  duration: duration,
                  curve: Curves.easeInOutSine,
                  left: left.clamp(4.0, canvasWidth - actorWidth - 4),
                  top: top.clamp(4.0, canvasHeight - actorHeight - 4),
                  width: actorWidth,
                  height: actorHeight,
                  child: Listener(
                    onPointerDown: (_) {
                      if (!_isTouchingCat) {
                        setState(() => _isTouchingCat = true);
                        _notifyLockChanged();
                      }
                    },
                    onPointerUp: (_) {
                      if (_isTouchingCat) {
                        setState(() => _isTouchingCat = false);
                        _notifyLockChanged();
                      }
                    },
                    onPointerCancel: (_) {
                      if (_isTouchingCat) {
                        setState(() => _isTouchingCat = false);
                        _notifyLockChanged();
                      }
                    },
                    child: _CafeWalkingCat(
                      key: _catKeys[cat.id],
                      cat: cat,
                      canvasSize: canvasSize,
                      onRequestNextWaypoint: () => _requestNextWaypoint(cat.id),
                      onTapped: () => widget.onCatInteracted(cat),
                      onDragStart: () => _handleDragStart(cat),
                      onDragUpdate: (dx, dy) =>
                          _handleDragUpdate(cat.id, dx, dy),
                      onDragEnd: () => _handleDragEnd(cat.id),
                    ),
                  ),
                );
              }),

              // Laser Pointer Gesture Layer (only active when Laser Mode is toggled ON)
              if (widget.isLaserMode)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanStart: (details) =>
                        _updateLaserTarget(details.localPosition, canvasSize),
                    onPanUpdate: (details) =>
                        _updateLaserTarget(details.localPosition, canvasSize),
                    onPanEnd: (_) => _clearLaserDot(),
                    onPanCancel: _clearLaserDot,
                    child: const SizedBox.expand(),
                  ),
                ),

              // Glowing Red Laser Dot
              if (_laserPos != null)
                Positioned(
                  left: (_laserPos!.dx * canvasWidth) - 8,
                  top: (_laserPos!.dy * canvasHeight) - 8,
                  child: IgnorePointer(
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF1744),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF1744).withOpacity(0.85),
                            blurRadius: 16,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _WaypointMoveResult {
  final Duration duration;
  final bool facingLeft;

  const _WaypointMoveResult({
    required this.duration,
    required this.facingLeft,
  });
}

class _CafeWalkingCat extends StatefulWidget {
  final CatModel cat;
  final Size canvasSize;
  final _WaypointMoveResult Function() onRequestNextWaypoint;
  final VoidCallback onTapped;
  final VoidCallback onDragStart;
  final void Function(double deltaDx, double deltaDy) onDragUpdate;
  final _DropReaction Function() onDragEnd;

  const _CafeWalkingCat({
    super.key,
    required this.cat,
    required this.canvasSize,
    required this.onRequestNextWaypoint,
    required this.onTapped,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  State<_CafeWalkingCat> createState() => _CafeWalkingCatState();
}

class _CafeWalkingCatState extends State<_CafeWalkingCat>
    with TickerProviderStateMixin {
  final math.Random _random = math.Random();

  late final AnimationController _breathController;
  late final Animation<double> _breathAnimation;
  late final AnimationController _jumpController;
  late final Animation<double> _jumpAnimation;
  late final AnimationController _heartController;
  late final AnimationController _dragSwayController;
  late final Animation<double> _dragSwayAnimation;

  _CatLoopBehavior _behavior = _CatLoopBehavior.idleSit;
  bool _facingLeft = false;
  int _walkFrame = 0;
  bool _isDragging = false;
  bool _showHearts = false;
  bool _sleepUseBelly = true;
  String? _bubbleText;

  Timer? _stateTimer;
  Timer? _walkFrameTimer;
  Timer? _lookAroundTimer;
  Timer? _resumeTimer;

  bool get isEligibleForChat =>
      !_isDragging &&
      (_behavior == _CatLoopBehavior.idleSit ||
          _behavior == _CatLoopBehavior.idleBelly ||
          _behavior == _CatLoopBehavior.idleLookAround);

  @override
  void initState() {
    super.initState();

    final initialPoses = [
      _CatLoopBehavior.idleSit,
      _CatLoopBehavior.idleBelly,
      _CatLoopBehavior.idleLookAround,
    ];
    _behavior = initialPoses[_random.nextInt(initialPoses.length)];
    _facingLeft = _random.nextBool();

    _breathController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2200 + _random.nextInt(700)),
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );

    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _jumpAnimation = Tween<double>(begin: 0.0, end: -12.0).animate(
      CurvedAnimation(
        parent: _jumpController,
        curve: Curves.easeOut,
      ),
    );

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _dragSwayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _dragSwayAnimation = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(
        parent: _dragSwayController,
        curve: Curves.easeInOutSine,
      ),
    );

    final initialDelay = Duration(milliseconds: 600 + _random.nextInt(2200));
    _stateTimer = Timer(initialDelay, _startWalking);
  }

  void _cancelPhaseTimers() {
    _stateTimer?.cancel();
    _walkFrameTimer?.cancel();
    _lookAroundTimer?.cancel();
  }

  void _startWalking() {
    if (!mounted || _isDragging) return;
    _cancelPhaseTimers();

    final move = widget.onRequestNextWaypoint();
    setState(() {
      _behavior = _CatLoopBehavior.walking;
      _facingLeft = move.facingLeft;
      _walkFrame = 0;
      _bubbleText = null;
      _showHearts = false;
    });

    _walkFrameTimer = Timer.periodic(const Duration(milliseconds: 220), (_) {
      if (!mounted || _behavior != _CatLoopBehavior.walking) return;
      setState(() {
        _walkFrame = (_walkFrame + 1) % 2;
      });
    });

    _stateTimer = Timer(move.duration, _startRandomIdle);
  }

  void _startRandomIdle() {
    if (!mounted || _isDragging) return;
    _cancelPhaseTimers();

    final idleChoices = [
      _CatLoopBehavior.idleSit,
      _CatLoopBehavior.idleBelly,
      _CatLoopBehavior.idleLookAround,
    ];
    final chosenIdle = idleChoices[_random.nextInt(idleChoices.length)];
    final idleDuration = Duration(milliseconds: 3000 + _random.nextInt(3001));

    setState(() {
      _behavior = chosenIdle;
      _walkFrame = 0;
      _showHearts = false;
      _bubbleText = null;
    });

    if (chosenIdle == _CatLoopBehavior.idleLookAround) {
      _lookAroundTimer = Timer.periodic(
        Duration(milliseconds: 1100 + _random.nextInt(600)),
        (_) {
          if (!mounted || _behavior != _CatLoopBehavior.idleLookAround) return;
          setState(() {
            _facingLeft = !_facingLeft;
          });
        },
      );
    }

    _stateTimer = Timer(idleDuration, _startWalking);
  }

  /// Dipanggil oleh CafeRoomStage saat Snack Ikan dilempar ke lantai.
  void attractToFish(Duration travelDuration, bool facingLeft) {
    if (!mounted || _isDragging) return;
    _cancelPhaseTimers();
    _resumeTimer?.cancel();
    _jumpController.stop();
    _jumpController.reset();

    setState(() {
      _behavior = _CatLoopBehavior.walking;
      _facingLeft = facingLeft;
      _walkFrame = 0;
      _bubbleText = null;
      _showHearts = false;
    });

    _walkFrameTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted || _behavior != _CatLoopBehavior.walking) return;
      setState(() {
        _walkFrame = (_walkFrame + 1) % 2;
      });
    });

    _stateTimer = Timer(travelDuration, () {
      if (!mounted || _isDragging) return;
      _walkFrameTimer?.cancel();
      setState(() {
        _behavior = _CatLoopBehavior.tappedHappy;
        _showHearts = true;
      });
      _jumpController.repeat(reverse: true);
      _heartController.forward(from: 0.0);
    });
  }

  /// Dipanggil oleh CafeRoomStage saat Laser Pointer aktif dan digeser.
  void chaseLaser(Duration travelDuration, bool facingLeft) {
    if (!mounted || _isDragging) return;
    _cancelPhaseTimers();
    _resumeTimer?.cancel();
    _jumpController.stop();
    _jumpController.reset();

    setState(() {
      _behavior = _CatLoopBehavior.walking;
      _facingLeft = facingLeft;
      _bubbleText = null;
      _showHearts = false;
    });

    _walkFrameTimer = Timer.periodic(const Duration(milliseconds: 170), (_) {
      if (!mounted || _behavior != _CatLoopBehavior.walking) return;
      setState(() {
        _walkFrame = (_walkFrame + 1) % 2;
      });
    });

    _stateTimer = Timer(travelDuration, () {
      if (!mounted || _isDragging) return;
      _walkFrameTimer?.cancel();
      setState(() {
        _behavior = _CatLoopBehavior.idleLookAround;
      });
    });
  }

  /// Mengakhiri mode mengejar mainan dan kembali ke loop normal.
  void endToyAttraction() {
    if (!mounted || _isDragging) return;
    _jumpController.stop();
    _jumpController.reset();
    _startRandomIdle();
  }

  /// Memunculkan gelembung komik simbol selama 2 detik saat berdekatan dengan kucing lain.
  void showSocialChat(String symbol, bool faceOther) {
    if (!mounted || _isDragging) return;
    _cancelPhaseTimers();
    _resumeTimer?.cancel();

    setState(() {
      _behavior = _CatLoopBehavior.socialChat;
      _facingLeft = faceOther;
      _bubbleText = symbol;
      _showHearts = false;
    });

    _resumeTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted || _isDragging) return;
      setState(() {
        _bubbleText = null;
      });
      _startRandomIdle();
    });
  }

  void _triggerHappyBounceAndHearts({required Duration resumeDelay}) {
    _resumeTimer?.cancel();

    setState(() {
      _behavior = _CatLoopBehavior.tappedHappy;
      _showHearts = true;
      _bubbleText = null;
    });

    _jumpController.repeat(reverse: true);
    _heartController.forward(from: 0.0);

    _resumeTimer = Timer(resumeDelay, () {
      if (!mounted || _isDragging) return;
      _jumpController.stop();
      _jumpController.reset();
      _startRandomIdle();
    });
  }

  void _triggerFurnitureSleep() {
    _resumeTimer?.cancel();

    setState(() {
      _behavior = _CatLoopBehavior.furnitureSleep;
      _sleepUseBelly = _random.nextBool();
      _showHearts = false;
      _bubbleText = 'Zzz... 💤';
    });

    _heartController.repeat();

    _resumeTimer = Timer(const Duration(milliseconds: 4200), () {
      if (!mounted || _isDragging) return;
      _heartController.stop();
      _heartController.reset();
      setState(() {
        _bubbleText = null;
      });
      _startRandomIdle();
    });
  }

  void _triggerFurnitureEat() {
    _resumeTimer?.cancel();

    setState(() {
      _behavior = _CatLoopBehavior.furnitureEat;
      _showHearts = true;
      _bubbleText = '🐟';
    });

    _jumpController.repeat(reverse: true);
    _heartController.forward(from: 0.0);

    _resumeTimer = Timer(const Duration(milliseconds: 3600), () {
      if (!mounted || _isDragging) return;
      _jumpController.stop();
      _jumpController.reset();
      setState(() {
        _bubbleText = null;
        _showHearts = false;
      });
      _startRandomIdle();
    });
  }

  void _onTapCat() {
    if (_isDragging) return;
    HapticFeedback.lightImpact();
    widget.onTapped();
    _cancelPhaseTimers();
    _triggerHappyBounceAndHearts(
      resumeDelay: const Duration(milliseconds: 1700),
    );
  }

  void _onPanStart(DragStartDetails details) {
    _cancelPhaseTimers();
    _resumeTimer?.cancel();
    _jumpController.stop();
    _jumpController.reset();
    _heartController.stop();
    _heartController.reset();

    HapticFeedback.selectionClick();
    widget.onDragStart();

    setState(() {
      _isDragging = true;
      _showHearts = false;
      _bubbleText = null;
      _behavior = _CatLoopBehavior.dragging;
    });

    _dragSwayController.repeat(reverse: true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging ||
        widget.canvasSize.width <= 0 ||
        widget.canvasSize.height <= 0) {
      return;
    }
    final deltaDx = details.delta.dx / widget.canvasSize.width;
    final deltaDy = details.delta.dy / widget.canvasSize.height;
    widget.onDragUpdate(deltaDx, deltaDy);
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _dragSwayController.stop();
    _dragSwayController.reset();

    HapticFeedback.lightImpact();
    final reaction = widget.onDragEnd();

    setState(() {
      _isDragging = false;
    });

    switch (reaction) {
      case _DropReaction.sleep:
        _triggerFurnitureSleep();
        break;
      case _DropReaction.food:
        _triggerFurnitureEat();
        break;
      case _DropReaction.none:
        _triggerHappyBounceAndHearts(
          resumeDelay: const Duration(milliseconds: 950),
        );
        break;
    }
  }

  @override
  void dispose() {
    _cancelPhaseTimers();
    _resumeTimer?.cancel();
    _breathController.dispose();
    _jumpController.dispose();
    _heartController.dispose();
    _dragSwayController.dispose();
    super.dispose();
  }

  String _resolveSpriteAsset() {
    switch (_behavior) {
      case _CatLoopBehavior.walking:
        return _walkFrame == 0
            ? widget.cat.walk1PoseAsset
            : widget.cat.walk2PoseAsset;
      case _CatLoopBehavior.idleSit:
        return widget.cat.headPoseAsset;
      case _CatLoopBehavior.idleBelly:
        return widget.cat.bellyPoseAsset;
      case _CatLoopBehavior.furnitureSleep:
        return _sleepUseBelly
            ? widget.cat.bellyPoseAsset
            : widget.cat.headPoseAsset;
      case _CatLoopBehavior.idleLookAround:
      case _CatLoopBehavior.socialChat:
        return widget.cat.walk1PoseAsset;
      case _CatLoopBehavior.tappedHappy:
      case _CatLoopBehavior.dragging:
      case _CatLoopBehavior.furnitureEat:
        return widget.cat.happyPoseAsset;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spriteAsset = _resolveSpriteAsset();
    final isWalking = _behavior == _CatLoopBehavior.walking;
    final isHappyBouncing = _behavior == _CatLoopBehavior.tappedHappy ||
        _behavior == _CatLoopBehavior.furnitureEat;
    final isBreathing = _behavior == _CatLoopBehavior.idleSit ||
        _behavior == _CatLoopBehavior.idleBelly ||
        _behavior == _CatLoopBehavior.furnitureSleep;

    final walkHopY = (isWalking && _walkFrame == 1) ? -3.5 : 0.0;

    Widget spriteWidget = Image.asset(
      spriteAsset,
      width: 58,
      height: 58,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.pets_rounded,
        size: 32,
        color: AppColors.primary,
      ),
    );

    if (_facingLeft && !isHappyBouncing && !_isDragging) {
      spriteWidget = Transform.flip(
        flipX: true,
        child: spriteWidget,
      );
    }

    if (isBreathing) {
      spriteWidget = ScaleTransition(
        scale: _breathAnimation,
        child: spriteWidget,
      );
    }

    if (_isDragging) {
      spriteWidget = AnimatedBuilder(
        animation: _dragSwayAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _dragSwayAnimation.value,
            child: child,
          );
        },
        child: spriteWidget,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: _onTapCat,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Soft contact shadow
          Positioned(
            bottom: _isDragging ? -4 : 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _isDragging ? 52 : 40,
              height: _isDragging ? 14 : 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.black.withOpacity(_isDragging ? 0.14 : 0.16),
                boxShadow: _isDragging
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
          ),

          // Cat Column: Name Pill + Transparent Sprite
          AnimatedScale(
            scale: _isDragging ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutBack,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.14),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('❤️', style: TextStyle(fontSize: 9)),
                      const SizedBox(width: 3),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 66),
                        child: Text(
                          widget.cat.name,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryPeachDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedBuilder(
                  animation: _jumpAnimation,
                  builder: (context, child) {
                    final totalDy = _isDragging
                        ? -8.0
                        : (isHappyBouncing ? _jumpAnimation.value : walkHopY);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 110),
                      transform: Matrix4.translationValues(0, totalDy, 0),
                      child: child,
                    );
                  },
                  child: spriteWidget,
                ),
              ],
            ),
          ),

          // Comic Bubble for Sleep (Zzz... 💤), Food (🐟), or Social Chat (❤️/🐾/❓/🎵)
          if (_bubbleText != null)
            Positioned(
              top: _behavior == _CatLoopBehavior.furnitureSleep ? -22 : -18,
              right: 2,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _heartController,
                  builder: (context, child) {
                    final dy = _behavior == _CatLoopBehavior.furnitureSleep
                        ? -(_heartController.value * 10)
                        : 0.0;
                    return Transform.translate(
                      offset: Offset(0, dy),
                      child: child,
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderInteractive,
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.14),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _bubbleText!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Floating Heart Particles on Tap / Fish / Landing
          if (_showHearts)
            AnimatedBuilder(
              animation: _heartController,
              builder: (context, _) {
                final t = _heartController.value;
                final opacity = (1.0 - t).clamp(0.0, 1.0);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -12 - (t * 28),
                      left: 16 - (t * 8),
                      child: Opacity(
                        opacity: opacity,
                        child: const Text('❤️', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    Positioned(
                      top: -6 - (t * 34),
                      right: 14 - (t * 6),
                      child: Opacity(
                        opacity: opacity,
                        child: const Text('💖', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
