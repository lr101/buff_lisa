import 'package:flutter/material.dart';

import 'custom_theme.dart';

class LightTheme {

  static const Color c1 = Color(0xFFFF9400);
  static const Color c2 = Color(0xFFFDAD3E);

  /// TODO [Balti] light theme color palate
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: c1,
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          overlayColor: MaterialStateColor.resolveWith((states) =>  c2.withOpacity(0.2)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0), side: const BorderSide(color: c1)),),
        )
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: c1
    ),
    hintColor: c2
  );

  static const String url = "https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png";

  static CustomTheme lightThemeFactory() {
    return CustomTheme(theme: lightTheme, mapUrl: url, c1: c1, c2: c2);
  }
}