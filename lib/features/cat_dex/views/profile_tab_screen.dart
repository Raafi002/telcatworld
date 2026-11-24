import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/app_header_bar.dart';
import '../../../core/widgets/demo_debug_sheet.dart';
import '../data/models/cat_model.dart';
import '../data/repositories/mock_cat_repository.dart';

class _ProfileMedal {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int current;
  final int target;

  const _ProfileMedal({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.current,
    required this.target,
  });

  bool get isUnlocked => current >= target;

  String get miniProgressLabel =>
      isUnlocked ? 'Tercapai' : '${current.clamp(0, target)}/$target';
}

class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  String _resolveDynamicTitle(int totalEncounters) {
    if (totalEncounters >= 15) {
      return 'Pawang Kucing Tel-U';
    }
    if (totalEncounters >= 5) {
      return 'Sahabat Kucing Kampus';
    }
    return 'Pendatang Baru';
  }

  List<_ProfileMedal> _buildMedals(MockCatRepository repo) {
    final encounteredCount = repo.encounteredCats.length;
    final totalCatsCount = repo.allCats.length;
    final maxEncounter = repo.maxEncounterCount;
    final totalEncounters = repo.totalEncounters;
    final lockedNamesCount = repo.lockedNamesCount;

    return [
      _ProfileMedal(
        id: 'medal_bestie',
        title: 'Sahabat Sejati',
        description:
            'Capai 5x pertemuan dengan 1 kucing kampus untuk membuka hak memberi nama permanen.',
        icon: Icons.workspace_premium_rounded,
        current: maxEncounter,
        target: 5,
      ),
      _ProfileMedal(
        id: 'medal_explorer',
        title: 'Penjelajah Kampus',
        description:
            'Temui dan jinakkan minimal 3 kucing kampus berbeda di lingkungan Telkom University.',
        icon: Icons.explore_rounded,
        current: encounteredCount,
        target: 3,
      ),
      _ProfileMedal(
        id: 'medal_pawang',
        title: 'Pawang Tel-U',
        description:
            'Capai total 15 pertemuan sah bersama kucing-kucing kampus.',
        icon: Icons.auto_awesome_rounded,
        current: totalEncounters,
        target: 15,
      ),
      _ProfileMedal(
        id: 'medal_namer',
        title: 'Penjaga Nama',
        description:
            'Beri nama permanen unik kepada 4 ekor kucing kampus setelah 5x pertemuan.',
        icon: Icons.badge_rounded,
        current: lockedNamesCount,
        target: 4,
      ),
      _ProfileMedal(
        id: 'medal_collector',
        title: 'Kolektor Penuh',
        description:
            'Temui seluruh $totalCatsCount kucing kampus yang terdaftar di katalog Cat-Dex.',
        icon: Icons.pets_rounded,
        current: encounteredCount,
        target: totalCatsCount,
      ),
      _ProfileMedal(
        id: 'medal_veteran',
        title: 'Sahabat Setia 30x',
        description:
            'Kumpulkan total 30 pertemuan penuh kasih tanpa kontak paksa terhadap satwa.',
        icon: Icons.favorite_rounded,
        current: totalEncounters,
        target: 30,
      ),
    ];
  }

  void _showCapstoneInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBg(dialogContext),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AppColors.primaryOf(dialogContext),
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tentang TelCat World',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryOf(dialogContext),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TelCat World — Super App Kucing Kampus',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryOf(dialogContext),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'TelCat World adalah game interaksi dan koleksi kucing kampus Telkom University berbasis lokasi. Temui kucing di area kampus, jinakkan lewat mini-game elus lembut tanpa kekerasan, lengkapi Cat-Dex, dan bermain bersama di Kafe Kucing!\n\nDikembangkan oleh Kelompok SUPER-SUB (S1 Sistem Informasi Telkom University).',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryOf(dialogContext),
                height: 1.45,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Tutup',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryOf(dialogContext),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarPickerSheet(BuildContext context, MockCatRepository repo) {
    final metCats = repo.encounteredCats;
    final selectedId = repo.selectedAvatarCat?.id;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderInteractiveOf(sheetContext),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Pilih Avatar Kucing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryOf(sheetContext),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih ilustrasi kucing yang sudah pernah kamu temui.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryOf(sheetContext),
                  ),
                ),
                const SizedBox(height: 14),
                if (metCats.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusCard),
                    ),
                    child: const Text(
                      'Belum ada kucing yang ditemui. Pindai QR kucing kampus terlebih dahulu!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: metCats.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.86,
                      ),
                      itemBuilder: (context, index) {
                        final cat = metCats[index];
                        final isSelected = cat.id == selectedId;
                        return InkWell(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusCard),
                          onTap: () {
                            repo.selectProfileAvatar(cat.id);
                            Navigator.of(sheetContext).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.peachBgOf(sheetContext)
                                  : AppColors.subtleBg(sheetContext),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusCard),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryOf(sheetContext)
                                    : AppColors.borderOf(sheetContext),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            AppColors.catAvatarBgOf(sheetContext),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryOf(sheetContext)
                                              : AppColors.borderInteractiveOf(
                                                  sheetContext),
                                          width: 1.5,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.asset(
                                        cat.headPoseAsset,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        right: -2,
                                        bottom: -2,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryOf(
                                                sheetContext),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check_rounded,
                                            size: 11,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color:
                                        AppColors.textPrimaryOf(sheetContext),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMedalDetailDialog(BuildContext context, _ProfileMedal medal) {
    final unlocked = medal.isUnlocked;
    final displayCurrent = medal.current.clamp(0, medal.target);

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.cardBg(dialogContext),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMedalCircle(medal: medal, size: 78, iconSize: 38),
              const SizedBox(height: 14),
              Text(
                medal.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryOf(dialogContext),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: unlocked
                      ? AppColors.sweetSpotGreenBg
                      : AppColors.subtleBg(dialogContext),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: unlocked
                        ? AppColors.sweetSpotGreen.withOpacity(0.4)
                        : AppColors.borderInteractiveOf(dialogContext),
                  ),
                ),
                child: Text(
                  unlocked
                      ? 'Terbuka • $displayCurrent / ${medal.target}'
                      : 'Terkunci • Progres $displayCurrent / ${medal.target}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: unlocked
                        ? AppColors.sweetSpotGreen
                        : AppColors.textSecondaryOf(dialogContext),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                medal.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryOf(dialogContext),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.peachBgOf(dialogContext),
                    foregroundColor: AppColors.peachTextOf(dialogContext),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedalCircle({
    required _ProfileMedal medal,
    double size = 50,
    double iconSize = 24,
  }) {
    final unlocked = medal.isUnlocked;

    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: unlocked
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFD56B),
                  AppColors.primary,
                ],
              )
            : null,
        color: unlocked ? null : AppColors.surfaceSubtle,
        border: Border.all(
          color: unlocked ? const Color(0xFFD97706) : AppColors.borderInteractive,
          width: unlocked ? 2.5 : 1.5,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          medal.icon,
          size: iconSize,
          color: unlocked ? Colors.white : AppColors.textTertiary,
        ),
      ),
    );

    if (unlocked) {
      return circle;
    }

    return Opacity(
      opacity: 0.58,
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MockCatRepository(),
      builder: (context, _) {
        final repo = MockCatRepository();
        final collected = repo.collectedCats.length;
        final totalEncounters = repo.totalEncounters;
        final dynamicTitle = _resolveDynamicTitle(totalEncounters);
        final CatModel? bestBuddy = repo.bestBuddyCat;
        final medals = _buildMedals(repo);

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg(context),
          appBar: AppHeaderBar(
            title: 'Profil Pengguna',
            subtitle: 'TelCat World • Civitas Akademika',
            statusText: 'Terverifikasi',
            onTitleHoldTwoSeconds: () => showDemoDebugSheet(context),
            onInfoPressed: () => _showCapstoneInfoDialog(context),
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
                  // User Profile Hero Card
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spaceLg),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg(context),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusCard),
                      border: Border.all(color: AppColors.borderOf(context)),
                      boxShadow: AppDimensions.cardShadow,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Interactive Cat Avatar with Edit Badge
                        GestureDetector(
                          onTap: () => _showAvatarPickerSheet(context, repo),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.catAvatarBgOf(context),
                                  border: Border.all(
                                    color: AppColors.primaryOf(context),
                                    width: 2.2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    repo.selectedProfileAvatarAsset,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.pets_rounded,
                                      size: 34,
                                      color: AppColors.primaryOf(context),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryOf(context),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.cardBg(context),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mahasiswa Telkom University',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimaryOf(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'S1 Sistem Informasi • 120220xxxx',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryOf(context),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.verified_user_rounded,
                                    size: 14,
                                    color: AppColors.sweetSpotGreen,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      dynamicTitle,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.sweetSpotGreen,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.peachBgOf(context),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusFull,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primaryOf(context)
                                        .withOpacity(0.28),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.favorite_rounded,
                                      size: 13,
                                      color: AppColors.primaryOf(context),
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        bestBuddy != null
                                            ? 'Best Buddy: ${bestBuddy.name} (${bestBuddy.encounterCount}x)'
                                            : 'Best Buddy: Belum ada',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.peachTextOf(context),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceMd),

                  // Two Stat Metrics (Collection & Encounters, no points)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context: context,
                          title: 'Kucing Terkoleksi',
                          value: '$collected',
                          emoji: '🐾',
                          color: AppColors.sweetSpotGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          context: context,
                          title: 'Total Pertemuan',
                          value: '$totalEncounters',
                          emoji: '💖',
                          color: AppColors.primaryOf(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spaceMd),

                  // Quick Dark Mode Switch Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg(context),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusCard),
                      border: Border.all(color: AppColors.borderOf(context)),
                      boxShadow: AppDimensions.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.peachBgOf(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            AppColors.isDark(context)
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            size: 20,
                            color: AppColors.primaryOf(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mode Gelap',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryOf(context),
                                ),
                              ),
                              Text(
                                AppColors.isDark(context)
                                    ? 'Nuansa Cozy Warm Espresso aktif'
                                    : 'Tampilan siang cerah aktif',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondaryOf(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: AppColors.isDark(context),
                          activeColor: AppColors.darkPrimary,
                          onChanged: (_) =>
                              ThemeController.instance.toggleTheme(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceLg),

                  // Grid Medali Visual 3 Kolom
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Lencana Pertemanan Kampus',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryOf(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ketuk medali',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiaryOf(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: medals.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final medal = medals[index];
                      final unlocked = medal.isUnlocked;
                      return GestureDetector(
                        onTap: () => _showMedalDetailDialog(context, medal),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: unlocked
                                ? AppColors.cardBg(context)
                                : AppColors.subtleBg(context),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusCard),
                            border: Border.all(
                              color: unlocked
                                  ? AppColors.primaryOf(context)
                                      .withOpacity(0.45)
                                  : AppColors.borderOf(context),
                              width: unlocked ? 1.5 : 1,
                            ),
                            boxShadow:
                                unlocked ? AppDimensions.cardShadow : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildMedalCircle(medal: medal),
                              const SizedBox(height: 8),
                              Text(
                                medal.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  color: unlocked
                                      ? AppColors.textPrimaryOf(context)
                                      : AppColors.textSecondaryOf(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: unlocked
                                      ? AppColors.peachBgOf(context)
                                      : AppColors.cardBg(context),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  medal.miniProgressLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: unlocked
                                        ? AppColors.peachTextOf(context)
                                        : AppColors.textTertiaryOf(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String emoji,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryOf(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
