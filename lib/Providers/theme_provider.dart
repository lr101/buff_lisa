import 'package:buff_lisa/Files/Themes/custom_theme.dart';
import 'package:buff_lisa/Files/Themes/dark_theme.dart';
import 'package:buff_lisa/Files/Themes/light_theme.dart';
import 'package:flutter/material.dart';

import '../Files/Other/global.dart' as global;

class ThemeProvider with ChangeNotifier {

  final  CustomTheme darkTheme = DarkTheme.darkThemeFactory();
  final CustomTheme lightTheme = LightTheme.lightThemeFactory();
  /// flog for current theme color
  /// true: shows dark theme
  /// false: shows light theme
  late bool _first;

  ThemeProvider(bool brightness) {
    _first = brightness;
  }

  void toggleThemeMode() {
    _first = !_first;
    global.localData.setTheme(getTheme.brightness);
    notifyListeners();
  }

  ThemeData get getTheme {
    return (_first ? darkTheme.theme : lightTheme.theme);
  }

  CustomTheme get getCustomTheme {
    return (_first ? darkTheme : lightTheme);
  }

  bool get currentBrightness => _first;


}