import 'package:buff_lisa/Files/Themes/custom_theme.dart';
import 'package:flutter/material.dart';

class DarkTheme {

  /// TODO [Balti] dark theme color palate
  static final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF455a64)

  );

  static const Color selectGroupColor = Color(0xFF455a64);

  static CustomTheme darkThemeFactory() {
    return CustomTheme(theme: darkTheme, selectGroupColor: selectGroupColor);
  }


}