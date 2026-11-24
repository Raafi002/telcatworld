import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_assets.dart';
import '../theme/theme_controller.dart';

class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final String statusText;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? trailing;
  final VoidCallback? onTitleHoldTwoSeconds;
  final VoidCallback? onInfoPressed;

  const AppHeaderBar({
    super.key,
    this.title = 'Kucing Kampus',
    this.subtitle = 'TelCat World • Kampus Tel-U',
    this.statusText = 'Aktif',
    this.showBackButton = false,
    this.onBack,
    this.trailing,
    this.onTitleHoldTwoSeconds,
    this.onInfoPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68.0);

  @override
  Widget build(BuildContext context) {
    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryOf(context),
                height: 1.15,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    final isDark = AppColors.isDark(context);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: AppDimensions.marginHorizontal,
        right: AppDimensions.marginHorizontal,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context).withOpacity(0.94),
        border: Border(
          bottom: BorderSide(color: AppColors.borderOf(context), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.textPrimaryOf(context),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            const SizedBox(width: 8),
          ],
          // Mascot Icon Box
          Container(
            width: AppDimensions.mascotIconSize,
            height: AppDimensions.mascotIconSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.peachBgOf(context),
              border: Border.all(color: AppColors.borderOf(context), width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              AppAssets.logo,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.pets_rounded,
                color: AppColors.primaryOf(context),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title & Subtitle (with optional 2s hold debug trigger)
          Expanded(
            child: onTitleHoldTwoSeconds == null
                ? titleColumn
                : _TwoSecondHoldDetector(
                    onHoldComplete: onTitleHoldTwoSeconds!,
                    child: titleColumn,
                  ),
          ),
          const SizedBox(width: 6),
          // Trailing or Status Pill + Theme Toggle + Optional Info Button
          trailing ??
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg(context),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(
                          color: AppColors.borderInteractiveOf(context),
                          width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.04),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.sweetSpotGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Tooltip(
                    message: isDark ? 'Mode Terang' : 'Mode Gelap',
                    child: Material(
                      color: AppColors.subtleBg(context),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => ThemeController.instance.toggleTheme(context),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.borderInteractiveOf(context),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            isDark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            size: 16,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (onInfoPressed != null) ...[
                    const SizedBox(width: 5),
                    Tooltip(
                      message: 'Informasi Proyek',
                      child: Material(
                        color: AppColors.subtleBg(context),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onInfoPressed,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.borderInteractiveOf(context),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.textSecondaryOf(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
        ],
      ),
    );
  }
}

class _TwoSecondHoldDetector extends StatefulWidget {
  final VoidCallback onHoldComplete;
  final Widget child;

  const _TwoSecondHoldDetector({
    required this.onHoldComplete,
    required this.child,
  });

  @override
  State<_TwoSecondHoldDetector> createState() => _TwoSecondHoldDetectorState();
}

class _TwoSecondHoldDetectorState extends State<_TwoSecondHoldDetector> {
  Timer? _holdTimer;

  void _startHold() {
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onHoldComplete();
      }
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  @override
  void dispose() {
    _cancelHold();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _cancelHold(),
      onTapCancel: _cancelHold,
      child: widget.child,
    );
  }
}
