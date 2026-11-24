import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class AnimalWelfareCard extends StatelessWidget {
  const AnimalWelfareCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.subtleBg(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCallout),
        border: Border.all(
          color: AppColors.borderInteractiveOf(context),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.peachBgOf(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets_rounded,
              size: 18,
              color: AppColors.peachTextOf(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sebelum Mulai: Etika Kesejahteraan Satwa',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Amati dari jarak aman. Jangan mengejar, memegang paksa, atau menyalakan lampu kilat (flash) langsung ke mata kucing.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryOf(context),
                        height: 1.4,
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
