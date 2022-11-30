import 'package:flutter/material.dart';

import 'custom_theme.dart';

class LightTheme {

  /// TODO [Balti] light theme color palate
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF208581)
  );

  static const Color selectGroupColor = Color(0xFF15Fa64);

  static CustomTheme lightThemeFactory() {
    return CustomTheme(theme: lightTheme, selectGroupColor: selectGroupColor);
  }
}