import 'package:buff_lisa/Files/Themes/custom_theme.dart';
import 'package:buff_lisa/Files/Themes/light_theme.dart';
import 'package:flutter/material.dart';

import '../Files/Themes/dark_theme.dart';

class ThemeProvider with ChangeNotifier {

  final  CustomTheme darkTheme = DarkTheme.darkThemeFactory();
  final CustomTheme lightTheme = LightTheme.lightThemeFactory();
  late bool _first;

  ThemeProvider(bool brightness) {
    _first = brightness;
  }

  void toggleThemeMode() {
    _first = !_first;
    notifyListeners();
  }

  ThemeData get getTheme {
    return (_first ? darkTheme.theme : lightTheme.theme);
  }

  CustomTheme get getCustomTheme {
    return (_first ? darkTheme : lightTheme);
  }


}