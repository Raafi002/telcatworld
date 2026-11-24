import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../data/repositories/mock_cat_repository.dart';

class RenameCatDialog extends StatefulWidget {
  final String catId;

  const RenameCatDialog({
    super.key,
    required this.catId,
  });

  @override
  State<RenameCatDialog> createState() => _RenameCatDialogState();
}

class _RenameCatDialogState extends State<RenameCatDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitRename() {
    final error = MockCatRepository().renameCat(widget.catId, _controller.text);
    if (error != null) {
      setState(() {
        _errorText = error;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cat = MockCatRepository().getCatById(widget.catId);

    return Dialog(
      backgroundColor: AppColors.cardBg(context),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPeach,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Beri Nama Kucing Ini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Kamu telah menemui ${cat.name} sebanyak 5 kali! Nama permanen bersifat unik dan tidak dapat diubah setelah disimpan.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLength: 20,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() {
                    _errorText = null;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Contoh: Cimol, Oyen TULT, Biskuit...',
                filled: true,
                fillColor: AppColors.surfaceSubtle,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  borderSide:
                      const BorderSide(color: AppColors.borderInteractive),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  borderSide:
                      const BorderSide(color: AppColors.borderInteractive),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 16,
                    color: AppColors.missRed,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _errorText!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.missRed,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Simpan Nama Permanen',
              icon: Icons.lock_rounded,
              onPressed: _submitRename,
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Batal',
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
