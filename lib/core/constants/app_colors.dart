import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Accents
  static const Color primary = Color(0xFFF26A1B); // Vibrant Cat Orange
  static const Color primaryLight = Color(0xFFFF7A00); // Bright Orange Hover/Active
  static const Color primaryPeach = Color(0xFFFFF3EB); // Soft Peach
  static const Color primaryPeachDark = Color(0xFF9A3412); // Deep Terracotta for text on peach

  // Canvas & Surfaces
  static const Color background = Color(0xFFF8F9FA); // Soft Off-White
  static const Color surface = Color(0xFFFFFFFF); // Pure White Card
  static const Color surfaceSubtle = Color(0xFFF4F4F5); // Gray-Blue Callout Container
  static const Color surfaceHover = Color(0xFFF0EDF1);

  // Borders
  static const Color borderCard = Color(0xFFEDEDED); // Subtle card outline
  static const Color borderSubtle = Color(0xFFEFEFEF);
  static const Color borderInteractive = Color(0xFFE4E4E7);

  // Typography
  static const Color textPrimary = Color(0xFF18181B); // Charcoal Black
  static const Color textSecondary = Color(0xFF71717A); // Muted Gray
  static const Color textTertiary = Color(0xFFA1A1AA);

  // Status Semantics
  static const Color sweetSpotGreen = Color(0xFF16A34A); // Success
  static const Color sweetSpotGreenLight = Color(0xFF22C55E);
  static const Color sweetSpotGreenBg = Color(0xFFDCFCE7);

  static const Color goodYellow = Color(0xFFEAB308); // Warning
  static const Color goodYellowBg = Color(0xFFFEF9C3);

  static const Color missRed = Color(0xFFDC2626); // Danger / Error
  static const Color missRedLight = Color(0xFFEF4444);
  static const Color missRedBg = Color(0xFFFEE2E2);

  // Catbook Polaroid Tone
  static const Color polaroidCard = Color(0xFFFFFDF5); // Warm Cream Notebook

  // V2 Game Screens Tokens (Stitch V2)
  static const Color gameSplashTop = Color(0xFFF26A1B);
  static const Color gameSplashBottom = Color(0xFFFF7A00);
  static const Color gameSplashText = Color(0xFF7C2D12);
  static const Color gameSunburst = Color(0xFFFFF3EB);

  static const Color pettingBgHeadTop = Color(0xFFFDEBC8);
  static const Color pettingBgHeadBottom = Color(0xFFEFE3B5);

  static const Color pettingBgBellyTop = Color(0xFFFCE3D2);
  static const Color pettingBgBellyBottom = Color(0xFFFBEDEA);

  static const Color celebrationBgTop = Color(0xFFFFD9CC);
  static const Color celebrationBgBottom = Color(0xFFFBEFE6);
  static const Color celebrationTitle = Color(0xFF501C00);

  static const Color swipeOrbStart = Color(0xFFF97316);
  static const Color swipeOrbEnd = Color(0xFFF26A1B);
  static const Color swipeHalo = Color(0xFFFACC15);
  static const Color swipePath = Color(0xFFFDBA74);

  static const Color heartAccent = Color(0xFFEF4444);
  static const Color heartPink = Color(0xFFFB7185);

  // Cozy Warm Espresso Dark Mode Tokens
  static const Color darkBackground = Color(0xFF1C1917);
  static const Color darkSurface = Color(0xFF292524);
  static const Color darkSurfaceElevated = Color(0xFF35302E);
  static const Color darkBorder = Color(0xFF44403C);
  static const Color darkPrimary = Color(0xFFFB923C);
  static const Color darkTextPrimary = Color(0xFFFAF5EE);
  static const Color darkTextSecondary = Color(0xFFD6CFC7);
  static const Color darkTextTertiary = Color(0xFFA8A29E);
  static const Color darkCatAvatarBg = Color(0xFF3A3532);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color scaffoldBg(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color cardBg(BuildContext context) => Theme.of(context).cardColor;

  static Color subtleBg(BuildContext context) =>
      isDark(context) ? darkSurfaceElevated : surfaceSubtle;

  static Color borderOf(BuildContext context) =>
      isDark(context) ? darkBorder : borderCard;

  static Color borderInteractiveOf(BuildContext context) =>
      isDark(context) ? darkBorder : borderInteractive;

  static Color primaryOf(BuildContext context) =>
      isDark(context) ? darkPrimary : primary;

  static Color textPrimaryOf(BuildContext context) =>
      isDark(context) ? darkTextPrimary : textPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      isDark(context) ? darkTextSecondary : textSecondary;

  static Color textTertiaryOf(BuildContext context) =>
      isDark(context) ? darkTextTertiary : textTertiary;

  static Color peachBgOf(BuildContext context) =>
      isDark(context) ? darkSurfaceElevated : primaryPeach;

  static Color peachTextOf(BuildContext context) =>
      isDark(context) ? darkPrimary : primaryPeachDark;

  static Color catAvatarBgOf(BuildContext context) =>
      isDark(context) ? darkCatAvatarBg : primaryPeach;

  static Color polaroidBgOf(BuildContext context) =>
      isDark(context) ? const Color(0xFF302B29) : polaroidCard;
}
