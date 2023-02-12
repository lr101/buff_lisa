import 'package:buff_lisa/Files/Themes/custom_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DarkTheme {

  static const Color c1 = Color(0xFFFF9400);
  static const Color c2 = Color(0xFFFDAD3E);

  /// TODO [Balti] dark theme color palate
  static final darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFc66500), brightness: Brightness.dark, secondary: const Color(0xFF5a7b73)),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          overlayColor: MaterialStateColor.resolveWith((states) =>  c2.withOpacity(0.2)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0), side: const BorderSide(color: c1)),),
        )
      ),

  );

  static const String url = "https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png";

  static CustomTheme darkThemeFactory() {
    return CustomTheme(theme: darkTheme, mapUrl: url, c2: c2, c1: c1);
  }


}