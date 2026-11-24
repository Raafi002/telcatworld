import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../cat_dex/views/cat_dex_tab_screen.dart';
import '../../map_territory/views/territory_map_screen.dart';
import '../../cat_dex/views/profile_tab_screen.dart';
import '../../qr_scan/views/qr_scan_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  final int initialCatDexTab;
  final String? openCatProfileId;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
    this.initialCatDexTab = 0,
    this.openCatProfileId,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _openQrScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const QrScanScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Active Screen Body
          IndexedStack(
            index: _currentIndex,
            children: [
              CatDexTabScreen(
                initialTabIndex: widget.initialCatDexTab,
                openCatProfileId: widget.openCatProfileId,
              ),
              const TerritoryMapScreen(),
              const ProfileTabScreen(),
            ],
          ),

          // Floating Action Button (Floating Capsule min 24px above Bottom Bar)
          Positioned(
            left: 0,
            right: 0,
            bottom: 84 + MediaQuery.of(context).padding.bottom,
            child: Center(
              child: GestureDetector(
                onTap: _openQrScanner,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(242, 106, 27, 0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Pindai QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Fixed Bottom Navigation Bar (3 items: Cat-Dex, Peta, Profil)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg(context),
          border: Border(
            top: BorderSide(color: AppColors.borderOf(context), width: 1),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  label: 'Cat-Dex',
                  icon: Icons.pets_rounded,
                ),
                _buildNavItem(
                  index: 1,
                  label: 'Peta',
                  icon: Icons.map_rounded,
                ),
                _buildNavItem(
                  index: 2,
                  label: 'Profil',
                  icon: Icons.person_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = AppColors.primaryOf(context);
    final inactiveColor = AppColors.textSecondaryOf(context);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        splashColor: AppColors.peachBgOf(context),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
