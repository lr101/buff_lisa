import 'package:flutter/material.dart';

class CustomTheme {

  final ThemeData theme;
  final String mapUrl;
  final Color c1;
  final Color c2;
  final Color blackOrWhite;
  final Color transparent = const Color(0x22000000);

  const CustomTheme({required this.blackOrWhite,required this.theme, required this.mapUrl, required this.c1, required this.c2});

}