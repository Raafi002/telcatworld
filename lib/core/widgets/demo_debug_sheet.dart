// TODO: Hapus atau nonaktifkan Mode Demo ini sebelum rilis produksi Play Store/App Store
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'primary_button.dart';
import 'secondary_button.dart';
import '../../features/cat_dex/data/repositories/mock_cat_repository.dart';

// TODO: Hapus atau nonaktifkan Mode Demo ini sebelum rilis produksi Play Store/App Store
Future<void> showDemoDebugSheet(
  BuildContext context, {
  String? initialCatId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.cardBg(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusModal),
      ),
    ),
    builder: (sheetContext) => _DemoDebugBottomSheet(
      parentContext: context,
      initialCatId: initialCatId,
    ),
  );
}

class _DemoDebugBottomSheet extends StatefulWidget {
  final BuildContext parentContext;
  final String? initialCatId;

  const _DemoDebugBottomSheet({
    required this.parentContext,
    this.initialCatId,
  });

  @override
  State<_DemoDebugBottomSheet> createState() => _DemoDebugBottomSheetState();
}

class _DemoDebugBottomSheetState extends State<_DemoDebugBottomSheet> {
  late String _selectedCatId;

  @override
  void initState() {
    super.initState();
    final repo = MockCatRepository();
    _selectedCatId = widget.initialCatId ?? repo.allCats.first.id;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = MockCatRepository();
    final selectedCat = repo.getCatById(_selectedCatId);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.marginHorizontal,
          14,
          AppDimensions.marginHorizontal,
          AppDimensions.spaceLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderInteractive,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPeach,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bug_report_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode Demo / Debug',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Panel simulasi pengujian alur pertemuan & cooldown',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Target Kucing:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCatId,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: AppColors.surfaceSubtle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  borderSide:
                      const BorderSide(color: AppColors.borderInteractive),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  borderSide:
                      const BorderSide(color: AppColors.borderInteractive),
                ),
              ),
              items: repo.allCats.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat.id,
                  child: Text(
                    '${cat.name} (Pertemuan ${cat.encounterCount}/5)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCatId = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              label: 'Reset Cooldown Hari Ini',
              icon: Icons.refresh_rounded,
              onPressed: () {
                repo.resetAllDailyCooldowns();
                Navigator.of(context).pop();
                _showSnack('Cooldown harian seluruh kucing berhasil direset!');
              },
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Simulasi 4x Pertemuan',
              icon: Icons.fast_forward_rounded,
              onPressed: () {
                repo.simulateFourEncounters(_selectedCatId);
                Navigator.of(context).pop();
                _showSnack(
                  '${selectedCat.name} diset ke 4x pertemuan. Scan berikutnya membuka fitur Rename!',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
