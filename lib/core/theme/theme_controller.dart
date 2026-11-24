import 'package:flutter/material.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._() : super(ThemeMode.light);

  static final ThemeController instance = ThemeController._();

  bool get isDarkMode => value == ThemeMode.dark;

  void toggleTheme([BuildContext? context]) {
    if (value == ThemeMode.system && context != null) {
      final platformDark =
          MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      value = platformDark ? ThemeMode.light : ThemeMode.dark;
      return;
    }
    value = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    if (value == mode) return;
    value = mode;
  }
}
