import 'package:buff_lisa/Files/Themes/custom_theme.dart';
import 'package:flutter/material.dart';

class DarkTheme {


  static const Color blackOrWhite = Colors.black;


  /// TODO [Balti] dark theme color palate
  static final darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFc66500), brightness: Brightness.dark, secondary: const Color(0xFF5a7b73)),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          overlayColor: MaterialStateColor.resolveWith((states) =>  CustomTheme.c2.withOpacity(0.2)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0), side: const BorderSide(color: CustomTheme.c1)),),
        )
      ),

  );

  static CustomTheme darkThemeFactory() {
    return CustomTheme(theme: darkTheme, blackOrWhite: blackOrWhite);
  }


}