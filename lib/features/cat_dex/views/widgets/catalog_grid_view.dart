import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../data/models/cat_model.dart';
import '../../data/repositories/mock_cat_repository.dart';
import 'catbook_polaroid_modal.dart';

enum CatalogFilter {
  all,
  collected,
  uncollected,
}

class CatalogGridView extends StatefulWidget {
  final VoidCallback onVisitInCafe;

  const CatalogGridView({
    super.key,
    required this.onVisitInCafe,
  });

  @override
  State<CatalogGridView> createState() => _CatalogGridViewState();
}

class _CatalogGridViewState extends State<CatalogGridView> {
  CatalogFilter _selectedFilter = CatalogFilter.all;

  @override
  Widget build(BuildContext context) {
    final repo = MockCatRepository();
    final allCats = repo.allCats;
    final collectedCount = repo.collectedCats.length;
    final totalCount = allCats.length;

    List<CatModel> displayedCats;
    switch (_selectedFilter) {
      case CatalogFilter.all:
        displayedCats = allCats;
        break;
      case CatalogFilter.collected:
        displayedCats = repo.collectedCats;
        break;
      case CatalogFilter.uncollected:
        displayedCats = repo.uncollectedCats;
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.marginHorizontal,
        vertical: AppDimensions.spaceMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Collection Progress Card
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
            decoration: BoxDecoration(
              color: AppColors.cardBg(context),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.borderOf(context)),
              boxShadow: AppDimensions.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '$collectedCount dari $totalCount Kucing Kampus',
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
                      '${((collectedCount / totalCount) * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryOf(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: collectedCount / totalCount,
                    minHeight: 8,
                    backgroundColor: AppColors.subtleBg(context),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryOf(context),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spaceMd),

          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua ($totalCount)', CatalogFilter.all),
                const SizedBox(width: 8),
                _buildFilterChip('Terkoleksi ($collectedCount)', CatalogFilter.collected),
                const SizedBox(width: 8),
                _buildFilterChip('Belum Ditemukan (${totalCount - collectedCount})', CatalogFilter.uncollected),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spaceMd),

          // 2-Column Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedCats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final cat = displayedCats[index];
              return _buildCatCard(context, cat);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, CatalogFilter filter) {
    final isSelected = _selectedFilter == filter;
    final primary = AppColors.primaryOf(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary : AppColors.cardBg(context),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isSelected ? primary : AppColors.borderInteractiveOf(context),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textPrimaryOf(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCatCard(BuildContext context, CatModel cat) {
    final isDark = AppColors.isDark(context);
    if (cat.isCollected) {
      // Collected Card (Full Color)
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => CatbookPolaroidModal(
              cat: cat,
              onVisitInCafe: widget.onVisitInCafe,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg(context),
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: AppColors.borderOf(context)),
            boxShadow: AppDimensions.cardShadow,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Expanded(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.catAvatarBgOf(context),
                      border: Border.all(
                        color: AppColors.primaryOf(context).withOpacity(
                          cat.variant == CatVariant.hitam && isDark ? 0.55 : 0.3,
                        ),
                        width: 2,
                      ),
                      boxShadow: cat.variant == CatVariant.hitam && isDark
                          ? [
                              BoxShadow(
                                color: AppColors.darkPrimary.withOpacity(0.18),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      cat.avatarAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cat.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryOf(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                cat.zone,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondaryOf(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cat.isNameLocked
                      ? AppColors.sweetSpotGreenBg
                      : AppColors.peachBgOf(context),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.isNameLocked
                          ? Icons.lock_rounded
                          : Icons.pets_rounded,
                      size: 12,
                      color: cat.isNameLocked
                          ? AppColors.sweetSpotGreen
                          : AppColors.peachTextOf(context),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        cat.isNameLocked
                            ? 'Nama Terkunci'
                            : 'Pertemuan ${cat.encounterCount}/5',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: cat.isNameLocked
                              ? AppColors.sweetSpotGreen
                              : AppColors.peachTextOf(context),
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
      );
    } else {
      // Uncollected Card (Dark Silhouette & Question mark)
      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: AppColors.borderOf(context), width: 1),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Silhouette Avatar with ???
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF2C2C34),
                        BlendMode.srcIn,
                      ),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pets_rounded,
                          size: 56,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: const Text(
                        '???',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Belum Ditemukan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Petunjuk: ${cat.zone}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(color: AppColors.borderInteractive),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_rounded, size: 12, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'Pindai QR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
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
}
