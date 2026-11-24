import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_header_bar.dart';
import '../../cat_dex/data/repositories/mock_cat_repository.dart';
import '../models/territory_model.dart';
import 'territory_detail_screen.dart';

enum MapAtmosphereMode {
  auto,
  morning,
  dusk,
  night,
}

enum _ResolvedTimeOfDay {
  morning,
  dusk,
  night,
}

extension MapAtmosphereModeInfo on MapAtmosphereMode {
  String get buttonLabel {
    switch (this) {
      case MapAtmosphereMode.auto:
        return '🕒 Otomatis';
      case MapAtmosphereMode.morning:
        return '☀️ Pagi';
      case MapAtmosphereMode.dusk:
        return '🌅 Senja';
      case MapAtmosphereMode.night:
        return '🌙 Malam';
    }
  }

  MapAtmosphereMode get next {
    switch (this) {
      case MapAtmosphereMode.auto:
        return MapAtmosphereMode.morning;
      case MapAtmosphereMode.morning:
        return MapAtmosphereMode.dusk;
      case MapAtmosphereMode.dusk:
        return MapAtmosphereMode.night;
      case MapAtmosphereMode.night:
        return MapAtmosphereMode.auto;
    }
  }
}

class _PatrolRoute {
  final String id;
  final List<Offset> points;
  final String walk1Asset;
  final String walk2Asset;
  final double initialPhase;
  final int durationSeconds;

  const _PatrolRoute({
    required this.id,
    required this.points,
    required this.walk1Asset,
    required this.walk2Asset,
    required this.initialPhase,
    required this.durationSeconds,
  });
}

class _EasterEggSpot {
  final String id;
  final String title;
  final Offset position;
  final String peekAsset;
  final List<String> lines;

  const _EasterEggSpot({
    required this.id,
    required this.title,
    required this.position,
    required this.peekAsset,
    required this.lines,
  });
}

class _ActiveEasterEgg {
  final _EasterEggSpot spot;
  final String message;

  const _ActiveEasterEgg({
    required this.spot,
    required this.message,
  });
}

class TerritoryMapScreen extends StatefulWidget {
  const TerritoryMapScreen({super.key});

  @override
  State<TerritoryMapScreen> createState() => _TerritoryMapScreenState();
}

class _TerritoryMapScreenState extends State<TerritoryMapScreen>
    with TickerProviderStateMixin {
  static const List<_PatrolRoute> _patrolRoutes = [
    _PatrolRoute(
      id: 'patrol_north_center',
      points: [
        Offset(0.36, 0.22),
        Offset(0.36, 0.34),
        Offset(0.44, 0.45),
        Offset(0.49, 0.53),
      ],
      walk1Asset: AppAssets.catOrenWalk1,
      walk2Asset: AppAssets.catOrenWalk2,
      initialPhase: 0.0,
      durationSeconds: 18,
    ),
    _PatrolRoute(
      id: 'patrol_lake_front',
      points: [
        Offset(0.44, 0.45),
        Offset(0.53, 0.44),
        Offset(0.68, 0.45),
      ],
      walk1Asset: AppAssets.catPutihWalk1,
      walk2Asset: AppAssets.catPutihWalk2,
      initialPhase: 0.25,
      durationSeconds: 15,
    ),
    _PatrolRoute(
      id: 'patrol_center_north',
      points: [
        Offset(0.49, 0.53),
        Offset(0.44, 0.45),
        Offset(0.36, 0.34),
        Offset(0.36, 0.22),
      ],
      walk1Asset: AppAssets.catHitamWalk1,
      walk2Asset: AppAssets.catHitamWalk2,
      initialPhase: 0.45,
      durationSeconds: 21,
    ),
  ];

  static const List<_EasterEggSpot> _easterEggSpots = [
    _EasterEggSpot(
      id: 'egg_lake',
      title: 'Danau Situ Techno',
      position: Offset(0.59, 0.52),
      peekAsset: AppAssets.catHitamHead,
      lines: [
        'Ada ikan di danau Situ Techno nih!',
        'Sssst... aku lagi mengintip dari tepi danau!',
        'Meow! Ketahuan deh!',
      ],
    ),
    _EasterEggSpot(
      id: 'egg_monument',
      title: 'Taman Tugu & Lapangan Atas',
      position: Offset(0.53, 0.27),
      peekAsset: AppAssets.catPutihHead,
      lines: [
        'Sssst... aku lagi sembunyi!',
        'Angin di taman tugu sejuk banget buat tidur!',
        'Meow! Ketahuan deh!',
      ],
    ),
    _EasterEggSpot(
      id: 'egg_bench',
      title: 'Taman Bangku Kampus',
      position: Offset(0.31, 0.61),
      peekAsset: AppAssets.catOrenHead,
      lines: [
        'Sssst... aku lagi sembunyi di bawah bangku!',
        'Kalau duduk di sini, jangan lupa bawa camilan ya!',
        'Meow! Ketahuan deh!',
      ],
    ),
  ];

  static const List<Offset> _nightLightSpots = [
    Offset(0.36, 0.22),
    Offset(0.36, 0.34),
    Offset(0.44, 0.45),
    Offset(0.53, 0.44),
    Offset(0.68, 0.45),
    Offset(0.49, 0.53),
    Offset(0.31, 0.61),
    Offset(0.53, 0.27),
    Offset(0.74, 0.50),
  ];

  static const List<String> _zoneChatterOptions = [
    'Meow!',
    '🐟',
    '💤',
  ];

  final math.Random _random = math.Random();
  TerritoryModel? _selectedTerritory;
  MapAtmosphereMode _atmosphereMode = MapAtmosphereMode.auto;
  Brightness? _lastBrightness;
  _ActiveEasterEgg? _activeEasterEgg;
  Timer? _easterEggTimer;
  Timer? _walkFrameTimer;
  bool _walkFrameOne = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_lastBrightness != brightness) {
      if (brightness == Brightness.dark) {
        _atmosphereMode = MapAtmosphereMode.night;
      } else if (_lastBrightness == Brightness.dark) {
        _atmosphereMode = MapAtmosphereMode.auto;
      }
      _lastBrightness = brightness;
    }
  }

  late final AnimationController _cloudController;
  late final AnimationController _ambientController;
  late final AnimationController _rippleController;
  late final List<AnimationController> _patrolControllers;

  @override
  void initState() {
    super.initState();

    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 34),
    )..repeat();

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _patrolControllers = _patrolRoutes.map((route) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: route.durationSeconds),
      );
      controller.value = route.initialPhase;
      controller.repeat(reverse: true);
      return controller;
    }).toList();

    _walkFrameTimer = Timer.periodic(const Duration(milliseconds: 240), (_) {
      if (!mounted) return;
      setState(() {
        _walkFrameOne = !_walkFrameOne;
      });
    });
  }

  @override
  void dispose() {
    _easterEggTimer?.cancel();
    _walkFrameTimer?.cancel();
    _cloudController.dispose();
    _ambientController.dispose();
    _rippleController.dispose();
    for (final controller in _patrolControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  _ResolvedTimeOfDay _resolveTimeOfDay() {
    switch (_atmosphereMode) {
      case MapAtmosphereMode.morning:
        return _ResolvedTimeOfDay.morning;
      case MapAtmosphereMode.dusk:
        return _ResolvedTimeOfDay.dusk;
      case MapAtmosphereMode.night:
        return _ResolvedTimeOfDay.night;
      case MapAtmosphereMode.auto:
        final now = DateTime.now();
        final minutes = now.hour * 60 + now.minute;
        if (minutes >= 360 && minutes < 960) {
          // 06:00 - 15:59
          return _ResolvedTimeOfDay.morning;
        }
        if (minutes >= 960 && minutes < 1110) {
          // 16:00 - 18:29
          return _ResolvedTimeOfDay.dusk;
        }
        // 18:30 - 05:59
        return _ResolvedTimeOfDay.night;
    }
  }

  void _cycleAtmosphereMode() {
    setState(() {
      _atmosphereMode = _atmosphereMode.next;
    });
  }

  void _triggerEasterEgg(_EasterEggSpot spot) {
    HapticFeedback.selectionClick();
    _easterEggTimer?.cancel();
    final message = spot.lines[_random.nextInt(spot.lines.length)];
    _rippleController.forward(from: 0.0);
    setState(() {
      _activeEasterEgg = _ActiveEasterEgg(spot: spot, message: message);
    });
    _easterEggTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() {
        _activeEasterEgg = null;
      });
    });
  }

  Offset _interpolatePolyline(List<Offset> points, double t) {
    if (points.length < 2) return points.first;
    final segmentCount = points.length - 1;
    final scaled = (t.clamp(0.0, 1.0)) * segmentCount;
    final index = math.min(scaled.floor(), segmentCount - 1);
    final localT = scaled - index;
    return Offset.lerp(points[index], points[index + 1], localT)!;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MockCatRepository(),
      builder: (context, _) {
        final repo = MockCatRepository();
        final territories = repo.territories;
        final resolvedTime = _resolveTimeOfDay();

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg(context),
          appBar: const AppHeaderBar(
            title: 'Peta Teritorial Kucing',
            subtitle: 'TelCat World • Kampus Tel-U',
            statusText: '4 Zona',
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.marginHorizontal,
                AppDimensions.spaceMd,
                AppDimensions.marginHorizontal,
                84,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1:1 Interactive Campus Map Card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.cardBg(context),
                      border: Border.all(
                        color: AppColors.borderOf(context),
                        width: 1.5,
                      ),
                      boxShadow: AppDimensions.cardShadow,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18.5),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Stack(
                        children: [
                          Positioned.fill(
                            child: InteractiveViewer(
                              minScale: 1.0,
                              maxScale: 2.6,
                              boundaryMargin: const EdgeInsets.all(24),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final mapSize = constraints.maxWidth;
                                  return Stack(
                                    children: [
                                      // Base 1:1 Campus Map Image
                                      Positioned.fill(
                                        child: Image.asset(
                                          AppAssets.campusMap,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            color: AppColors.surfaceSubtle,
                                            child: const Center(
                                              child: Icon(
                                                Icons.map_rounded,
                                                size: 54,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Patrol Cats on Campus Roads (zooms with map)
                                      ...List.generate(_patrolRoutes.length,
                                          (index) {
                                        final route = _patrolRoutes[index];
                                        final controller =
                                            _patrolControllers[index];
                                        return AnimatedBuilder(
                                          animation: controller,
                                          builder: (context, _) {
                                            final t = controller.value;
                                            final pos = _interpolatePolyline(
                                                route.points, t);
                                            final isForward = controller.status !=
                                                AnimationStatus.reverse;
                                            final prevT = isForward
                                                ? math.max(0.0, t - 0.02)
                                                : math.min(1.0, t + 0.02);
                                            final prevPos =
                                                _interpolatePolyline(
                                                    route.points, prevT);
                                            final movingLeft =
                                                pos.dx < prevPos.dx - 0.0005;

                                            return Positioned(
                                              left: pos.dx * mapSize - 14,
                                              top: pos.dy * mapSize - 16,
                                              child: IgnorePointer(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Transform.flip(
                                                      flipX: movingLeft,
                                                      child: Image.asset(
                                                        _walkFrameOne
                                                            ? route.walk1Asset
                                                            : route.walk2Asset,
                                                        width: 28,
                                                        height: 28,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 16,
                                                      height: 4,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.18),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }),

                                      // Atmosphere Lighting Filter (Morning / Dusk / Night)
                                      if (resolvedTime !=
                                          _ResolvedTimeOfDay.morning)
                                        Positioned.fill(
                                          child: IgnorePointer(
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 350),
                                              color: resolvedTime ==
                                                      _ResolvedTimeOfDay.dusk
                                                  ? Colors.deepOrange
                                                      .withOpacity(0.16)
                                                  : const Color(0xFF1A237E)
                                                      .withOpacity(0.28),
                                            ),
                                          ),
                                        ),

                                      // Warm Streetlights at Night
                                      if (resolvedTime ==
                                          _ResolvedTimeOfDay.night)
                                        ..._nightLightSpots.map((spot) {
                                          return Positioned(
                                            left: spot.dx * mapSize - 10,
                                            top: spot.dy * mapSize - 10,
                                            child: IgnorePointer(
                                              child: AnimatedBuilder(
                                                animation: _ambientController,
                                                builder: (context, _) {
                                                  final glow = 0.55 +
                                                      0.45 *
                                                          _ambientController
                                                              .value;
                                                  return Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: RadialGradient(
                                                        colors: [
                                                          const Color(
                                                                  0xFFFFE082)
                                                              .withOpacity(
                                                                  0.85 * glow),
                                                          const Color(
                                                                  0xFFFFB300)
                                                              .withOpacity(
                                                                  0.25 * glow),
                                                          Colors.transparent,
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        }),

                                      // Drifting Soft Clouds
                                      Positioned.fill(
                                        child: IgnorePointer(
                                          child: AnimatedBuilder(
                                            animation: _cloudController,
                                            builder: (context, _) {
                                              final t = _cloudController.value;
                                              return Stack(
                                                children: [
                                                  _buildCloud(
                                                    x: ((t * 1.35) % 1.35 -
                                                            0.25) *
                                                        mapSize,
                                                    y: 0.10 * mapSize,
                                                    width: 74,
                                                    opacity: 0.45,
                                                  ),
                                                  _buildCloud(
                                                    x: (((t + 0.42) * 1.35) %
                                                                1.35 -
                                                            0.25) *
                                                        mapSize,
                                                    y: 0.34 * mapSize,
                                                    width: 92,
                                                    opacity: 0.36,
                                                  ),
                                                  _buildCloud(
                                                    x: (((t + 0.78) * 1.35) %
                                                                1.35 -
                                                            0.25) *
                                                        mapSize,
                                                    y: 0.69 * mapSize,
                                                    width: 68,
                                                    opacity: 0.4,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),

                                      // 3 Hidden Environment Easter Egg Hotspots
                                      ..._easterEggSpots.map((spot) {
                                        final isActive =
                                            _activeEasterEgg?.spot.id ==
                                                spot.id;
                                        return Positioned(
                                          left: spot.position.dx * mapSize - 22,
                                          top: spot.position.dy * mapSize - 22,
                                          child: GestureDetector(
                                            key: ValueKey(spot.id),
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () =>
                                                _triggerEasterEgg(spot),
                                            child: SizedBox(
                                              width: 44,
                                              height: 44,
                                              child: isActive
                                                  ? AnimatedBuilder(
                                                      animation:
                                                          _rippleController,
                                                      builder: (context, _) {
                                                        final p =
                                                            _rippleController
                                                                .value;
                                                        return Center(
                                                          child: Container(
                                                            width: 14 + 28 * p,
                                                            height: 14 + 28 * p,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                color: AppColors
                                                                    .primary
                                                                    .withOpacity(
                                                                        1 - p),
                                                                width: 2.2,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        );
                                      }),

                                      // 4 Precision Campus Zone Pins + Zone Chatter Bubble
                                      ...List.generate(territories.length,
                                          (index) {
                                        final territory = territories[index];
                                        final hasUnscannedCat =
                                            territory.residentCatIds.any((id) =>
                                                !repo.isScannedToday(id));
                                        final chatterText =
                                            _zoneChatterOptions[index %
                                                _zoneChatterOptions.length];

                                        return Positioned(
                                          left: territory.mapDx * mapSize,
                                          top: territory.mapDy * mapSize,
                                          child: FractionalTranslation(
                                            translation:
                                                const Offset(-0.5, -0.88),
                                            child: _buildMapPin(
                                              territory,
                                              isSelected:
                                                  _selectedTerritory?.id ==
                                                      territory.id,
                                              chatterText: hasUnscannedCat
                                                  ? chatterText
                                                  : null,
                                            ),
                                          ),
                                        );
                                      }),

                                      // Active Easter Egg Pop-up Bubble
                                      if (_activeEasterEgg != null)
                                        Positioned(
                                          left: (_activeEasterEgg!
                                                      .spot.position.dx *
                                                  mapSize)
                                              .clamp(78.0, mapSize - 78.0),
                                          top: (_activeEasterEgg!
                                                      .spot.position.dy *
                                                  mapSize -
                                              26)
                                              .clamp(46.0, mapSize - 24.0),
                                          child: FractionalTranslation(
                                            translation:
                                                const Offset(-0.5, -1.0),
                                            child: IgnorePointer(
                                              child: _buildEasterEggPopup(
                                                _activeEasterEgg!,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),

                          // Top Left Campus Tag (Fixed HUD)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.cardBg(context).withOpacity(0.92),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusFull),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.14),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.school_rounded,
                                      size: 14,
                                      color: AppColors.primaryOf(context)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Denah Telkom University',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimaryOf(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Top Right Atmosphere Toggle Pill (Fixed HUD)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Material(
                              color: AppColors.cardBg(context).withOpacity(0.92),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull),
                              elevation: 2,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusFull),
                                onTap: _cycleAtmosphereMode,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusFull),
                                    border: Border.all(
                                      color: AppColors.borderInteractiveOf(
                                          context),
                                    ),
                                  ),
                                  child: Text(
                                    _atmosphereMode.buttonLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimaryOf(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                  const SizedBox(height: AppDimensions.spaceLg),

                  // Territory List Heading
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Zona Teritorial Kampus',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryOf(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${territories.length} Wilayah',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryOf(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spaceSm),

                  // List of 4 Territory Cards
                  ...territories.map((t) => _buildTerritoryCard(context, t)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCloud({
    required double x,
    required double y,
    required double width,
    required double opacity,
  }) {
    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: width,
          height: width * 0.38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(width),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.55),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEasterEggPopup(_ActiveEasterEgg active) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 185),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.18),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Container(
              width: 28,
              height: 28,
              color: AppColors.primaryPeach,
              child: Image.asset(
                active.spot.peekAsset,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              active.message,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin(
    TerritoryModel territory, {
    required bool isSelected,
    String? chatterText,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTerritory = territory;
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TerritoryDetailScreen(territory: territory),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chatterText != null)
            AnimatedBuilder(
              animation: _ambientController,
              builder: (context, child) {
                final dy = -3.0 * _ambientController.value;
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: child,
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryPeach,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.12),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  chatterText,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryPeachDark,
                  ),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(color: AppColors.primary, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Text(
              territory.shortLabel,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 1),
          Icon(
            Icons.location_on_rounded,
            size: 22,
            color: isSelected ? AppColors.primaryLight : AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTerritoryCard(BuildContext context, TerritoryModel territory) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TerritoryDetailScreen(territory: territory),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
            child: Row(
              children: [
                // Landmark thumbnail
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    color: AppColors.peachBgOf(context),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    territory.imageAsset,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        territory.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryOf(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        territory.landmark,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryOf(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.pets,
                              size: 12, color: AppColors.primaryOf(context)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${territory.residentCatIds.length} Kucing Penghuni',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryOf(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textSecondaryOf(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
