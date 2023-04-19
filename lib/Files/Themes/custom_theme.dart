import 'package:flutter/material.dart';

class CustomTheme {

  static const Color c1 = Color(0xFFFF9400);
  static const Color c2 = Color(0xFFFDAD3E);
  static Color grey = Colors.blueGrey.withOpacity(0.1);

  final ThemeData theme;
  final Color blackOrWhite;
  final Color transparent = const Color(0x22000000);

  const CustomTheme({required this.blackOrWhite,required this.theme});

}