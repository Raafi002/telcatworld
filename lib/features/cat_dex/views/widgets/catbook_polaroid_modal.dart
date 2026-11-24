import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../data/models/cat_model.dart';
import '../../data/repositories/mock_cat_repository.dart';
import 'rename_cat_dialog.dart';

class CatbookPolaroidModal extends StatelessWidget {
  final CatModel cat;
  final VoidCallback onVisitInCafe;

  const CatbookPolaroidModal({
    super.key,
    required this.cat,
    required this.onVisitInCafe,
  });

  @override
  Widget build(BuildContext context) {
    final repo = MockCatRepository();

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final currentCat = repo.getCatById(cat.id);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.spaceLg),
            decoration: BoxDecoration(
              color: AppColors.polaroidBgOf(context),
              borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
              border: Border.all(
                color: AppColors.isDark(context)
                    ? AppColors.darkBorder
                    : const Color(0xFFEADBCE),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  blurRadius: 28,
                  offset: Offset(0, 10),
                )
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header title with lock badge + close icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              color: AppColors.peachTextOf(context),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Catbook: ${currentCat.name}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimaryOf(context),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (currentCat.isNameLocked) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.lock_rounded,
                                size: 15,
                                color: AppColors.sweetSpotGreen,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.textSecondaryOf(context),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Polaroid Section: Photo on Left, Stats on Right
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Polaroid Photo Frame
                      Container(
                        width: 130,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.borderOf(context),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.14),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.catAvatarBgOf(context),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Image.asset(
                                  currentCat.happyPoseAsset,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    currentCat.avatarAsset,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentCat.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textPrimaryOf(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              currentCat.zone,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondaryOf(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Stats on Right
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatRow(
                              'Kepribadian',
                              currentCat.personality,
                              Icons.psychology_rounded,
                            ),
                            const SizedBox(height: 8),
                            _buildStatRow(
                              'Progres Pertemuan',
                              currentCat.isNameLocked
                                  ? '${currentCat.encounterCount}x (Nama Terkunci)'
                                  : 'Pertemuan ${currentCat.encounterCount} / 5',
                              Icons.pets_rounded,
                            ),
                            const SizedBox(height: 8),
                            _buildStatRow(
                              'Terakhir Disapa',
                              currentCat.formattedLastScannedDate,
                              Icons.schedule_rounded,
                            ),
                            const SizedBox(height: 8),
                            _buildStatRow(
                              'Kondisi (Pengelola)',
                              currentCat.healthStatus,
                              Icons.verified_rounded,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Speech Bubble Box (Quote Si Kucing)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg(context),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusCard),
                      border: Border.all(
                        color: AppColors.primaryOf(context).withOpacity(0.28),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 16,
                            color: AppColors.peachTextOf(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '"${currentCat.quote}"',
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimaryOf(context),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Permanent Rename CTA when 5x encounters unlocked
                  if (currentCat.canBeNamed) ...[
                    PrimaryButton(
                      label: 'Beri Nama Permanen',
                      icon: Icons.edit_rounded,
                      onPressed: () {
                        showDialog<bool>(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.55),
                          builder: (_) => RenameCatDialog(catId: currentCat.id),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    SecondaryButton(
                      label: 'Kunjungi di Kafe Kucing ☕',
                      icon: Icons.coffee_rounded,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onVisitInCafe();
                      },
                    ),
                  ] else ...[
                    PrimaryButton(
                      label: 'Kunjungi di Kafe Kucing ☕',
                      icon: Icons.coffee_rounded,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onVisitInCafe();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.peachTextOf(context)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryOf(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}
