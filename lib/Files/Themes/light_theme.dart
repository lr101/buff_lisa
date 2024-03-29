import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';

import 'custom_theme.dart';

class LightTheme {

  static const Color blackOrWhite = Colors.white;

  /// TODO [Balti] light theme color palate
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme:  SeedColorScheme.fromSeeds(
      brightness: Brightness.light,
      primaryKey:  const Color(0xFFc66500),
      secondaryKey: const Color(0xFF63baab),
      tertiaryKey:  const Color(0xFF4c8077),
      tones: FlexTones.vivid(Brightness.light),
    ),
    applyElevationOverlayColor: false,
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          overlayColor: MaterialStateColor.resolveWith((states) =>  CustomTheme.c2.withOpacity(0.2)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0), side: const BorderSide(color: CustomTheme.c1)),),
        )
    ),
  );

  static CustomTheme lightThemeFactory() {
    return CustomTheme(theme: lightTheme,blackOrWhite: blackOrWhite);
  }
}