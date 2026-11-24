import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../data/models/cat_model.dart';
import '../../data/repositories/mock_cat_repository.dart';
import 'cafe_room_stage.dart';

class CafeSanctuaryView extends StatefulWidget {
  final VoidCallback onSwitchToCatalog;

  const CafeSanctuaryView({
    super.key,
    required this.onSwitchToCatalog,
  });

  @override
  State<CafeSanctuaryView> createState() => _CafeSanctuaryViewState();
}

class _CafeSanctuaryViewState extends State<CafeSanctuaryView> {
  CatModel? _activeTappedCat;
  CafeTheme _currentTheme = CafeTheme.cozy;
  bool _isStageInteractionLocked = false;
  Brightness? _lastBrightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_lastBrightness != brightness) {
      if (brightness == Brightness.dark) {
        _currentTheme = CafeTheme.night;
      } else if (_lastBrightness == Brightness.dark) {
        _currentTheme = CafeTheme.cozy;
      }
      _lastBrightness = brightness;
    }
  }

  void _cycleTheme() {
    setState(() {
      _currentTheme = _currentTheme.next;
    });
  }

  Future<void> _openFullScreen(List<CatModel> activeCats) async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (_, __, ___) => _CafeFullScreenPage(
          activeCats: activeCats,
          initialTheme: _currentTheme,
          onThemeChanged: (newTheme) {
            if (mounted) {
              setState(() {
                _currentTheme = newTheme;
              });
            }
          },
          onCatInteracted: (cat) {
            if (mounted) {
              setState(() {
                _activeTappedCat = cat;
              });
            }
          },
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = MockCatRepository();
    final activeCats = repo.cafeActiveCats.take(5).toList();

    return SingleChildScrollView(
      physics: _isStageInteractionLocked
          ? const NeverScrollableScrollPhysics()
          : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.marginHorizontal,
        vertical: AppDimensions.spaceMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sanctuary Room Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardBg(context),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.borderOf(context)),
              boxShadow: AppDimensions.cardShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.sweetSpotGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${activeCats.length} Kucing Bermain di Kafe',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryOf(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _cycleTheme,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.peachBgOf(context),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          size: 13,
                          color: AppColors.peachTextOf(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _currentTheme.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.peachTextOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spaceMd),

          // Isometric Cafe Card with Top-Right Full Screen Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _currentTheme.ambientBackdropColor,
              boxShadow: AppDimensions.cardShadow,
              border: Border.all(
                color: AppColors.borderOf(context),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.5),
              child: Stack(
                children: [
                  CafeRoomStage(
                    activeCats: activeCats,
                    theme: _currentTheme,
                    onCatInteracted: (cat) {
                      setState(() {
                        _activeTappedCat = cat;
                      });
                    },
                    onInteractionLockChanged: (locked) {
                      if (_isStageInteractionLocked != locked) {
                        setState(() {
                          _isStageInteractionLocked = locked;
                        });
                      }
                    },
                  ),

                  // Tombol Mode Full Screen di sudut kanan atas kartu
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Tooltip(
                      message: 'Mode Layar Penuh',
                      child: Material(
                        color: AppColors.cardBg(context).withOpacity(0.92),
                        shape: const CircleBorder(),
                        elevation: 3,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _openFullScreen(activeCats),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.fullscreen,
                              size: 22,
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

          const SizedBox(height: AppDimensions.spaceMd),

          // Speech Bubble Card when a cat is tapped or dragged
          if (_activeTappedCat != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(AppDimensions.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.cardBg(context),
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(
                  color: AppColors.primaryOf(context).withOpacity(0.35),
                  width: 1.5,
                ),
                boxShadow: AppDimensions.cardShadow,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.catAvatarBgOf(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Image.asset(
                      _activeTappedCat!.happyPoseAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.pets_rounded,
                        color: AppColors.primaryOf(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                _activeTappedCat!.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimaryOf(context),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _activeTappedCat!.isNameLocked
                                    ? AppColors.sweetSpotGreenBg
                                    : AppColors.peachBgOf(context),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                              ),
                              child: Text(
                                _activeTappedCat!.isNameLocked
                                    ? 'Nama Permanen'
                                    : 'Pertemuan: ${_activeTappedCat!.encounterCount} / 5',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _activeTappedCat!.isNameLocked
                                      ? AppColors.sweetSpotGreen
                                      : AppColors.peachTextOf(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"${_activeTappedCat!.quote}"',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondaryOf(context),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.subtleBg(context),
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(color: AppColors.borderOf(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: 20,
                    color: AppColors.primaryOf(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sentuh atau geser kucing ke kardus/bantal/mangkuk, atau buka Full Screen untuk bermain!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryOf(context),
                        fontWeight: FontWeight.w500,
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
}

class _CafeFullScreenPage extends StatefulWidget {
  final List<CatModel> activeCats;
  final CafeTheme initialTheme;
  final ValueChanged<CafeTheme> onThemeChanged;
  final ValueChanged<CatModel> onCatInteracted;

  const _CafeFullScreenPage({
    required this.activeCats,
    required this.initialTheme,
    required this.onThemeChanged,
    required this.onCatInteracted,
  });

  @override
  State<_CafeFullScreenPage> createState() => _CafeFullScreenPageState();
}

class _CafeFullScreenPageState extends State<_CafeFullScreenPage> {
  final GlobalKey<CafeRoomStageState> _stageKey =
      GlobalKey<CafeRoomStageState>();

  late CafeTheme _theme;
  bool _isLaserMode = false;
  bool _isInteractionLocked = false;
  bool _isPhotoModeHidingHud = false;
  double _flashOpacity = 0.0;

  Timer? _photoHudTimer;
  Timer? _flashTimer;

  @override
  void initState() {
    super.initState();
    _theme = widget.initialTheme;
  }

  @override
  void dispose() {
    _photoHudTimer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _cycleTheme() {
    setState(() {
      _theme = _theme.next;
    });
    widget.onThemeChanged(_theme);
  }

  void _toggleLaserMode() {
    HapticFeedback.selectionClick();
    setState(() {
      _isLaserMode = !_isLaserMode;
    });
  }

  void _triggerFishSnack() {
    if (_isLaserMode) {
      setState(() {
        _isLaserMode = false;
      });
    }
    _stageKey.currentState?.triggerFishSnack();
  }

  void _triggerPhotoMode() {
    HapticFeedback.mediumImpact();
    _photoHudTimer?.cancel();
    _flashTimer?.cancel();

    setState(() {
      _isPhotoModeHidingHud = true;
      _flashOpacity = 0.92;
    });

    _flashTimer = Timer(const Duration(milliseconds: 70), () {
      if (!mounted) return;
      setState(() {
        _flashOpacity = 0.0;
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 Foto Kafe Tersimpan!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    _photoHudTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isPhotoModeHidingHud = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNight = _theme == CafeTheme.night;

    return Scaffold(
      backgroundColor: _theme.ambientBackdropColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        color: _theme.ambientBackdropColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full Screen Pinch-to-Zoom Cafe Stage
            InteractiveViewer(
              minScale: 1.0,
              maxScale: 2.5,
              panEnabled: !_isInteractionLocked && !_isLaserMode,
              scaleEnabled: true,
              boundaryMargin: const EdgeInsets.all(36),
              child: Center(
                child: CafeRoomStage(
                  key: _stageKey,
                  activeCats: widget.activeCats,
                  theme: _theme,
                  isLaserMode: _isLaserMode,
                  onCatInteracted: widget.onCatInteracted,
                  onInteractionLockChanged: (locked) {
                    if (_isInteractionLocked != locked) {
                      setState(() {
                        _isInteractionLocked = locked;
                      });
                    }
                  },
                ),
              ),
            ),

            // Top HUD Overlay (Exit Full Screen, Theme Pill, Palette, Photo Mode)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: IgnorePointer(
                  ignoring: _isPhotoModeHidingHud,
                  child: AnimatedOpacity(
                    opacity: _isPhotoModeHidingHud ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Pojok Kiri Atas: Keluar Full Screen
                          _FullScreenHudButton(
                            icon: Icons.fullscreen_exit,
                            tooltip: 'Keluar Layar Penuh',
                            onTap: () => Navigator.of(context).pop(),
                          ),

                          // Indikator Tema Aktif
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isNight
                                  ? Colors.black.withOpacity(0.55)
                                  : Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              _theme.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isNight
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),

                          // Pojok Kanan Atas: Ganti Tema & Photo Mode
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _FullScreenHudButton(
                                icon: Icons.palette_outlined,
                                tooltip: 'Ganti Tema Ruangan',
                                onTap: _cycleTheme,
                              ),
                              const SizedBox(width: 8),
                              _FullScreenHudButton(
                                icon: Icons.camera_alt_rounded,
                                tooltip: 'Photo Mode',
                                onTap: _triggerPhotoMode,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Floating Action Bar: Mainan Snack Ikan & Laser Pointer
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  ignoring: _isPhotoModeHidingHud,
                  child: AnimatedOpacity(
                    opacity: _isPhotoModeHidingHud ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.94),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.16),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ToyButton(
                              emoji: '🐟',
                              label: 'Snack Ikan',
                              isActive: false,
                              onTap: _triggerFishSnack,
                            ),
                            const SizedBox(width: 8),
                            _ToyButton(
                              emoji: '🔴',
                              label: 'Laser Pointer',
                              isActive: _isLaserMode,
                              onTap: _toggleLaserMode,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Camera Flash Overlay Effect
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _flashOpacity,
                duration: const Duration(milliseconds: 280),
                child: Container(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenHudButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _FullScreenHudButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withOpacity(0.92),
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 22,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToyButton extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToyButton({
    required this.emoji,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.borderInteractive,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
