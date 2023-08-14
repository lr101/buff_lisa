import 'package:buff_lisa/Files/Themes/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';

class DarkTheme {


  static const Color blackOrWhite = Colors.black;


  /// TODO [Balti] dark theme color palate
  static final darkTheme = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      //colorSchemeSeed: const Color(0xFFc66500),
      colorScheme:  SeedColorScheme.fromSeeds(
         brightness: Brightness.dark,
         primaryKey:  const Color(0xFFc66500),
         secondaryKey: const Color(0xFF63baab),
         tertiaryKey:  const Color(0xFF4c8077),
         tones: FlexTones.vivid(Brightness.dark),
      ),
      applyElevationOverlayColor: false,
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