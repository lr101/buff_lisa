import 'package:buff_lisa/7_Settings/AppSettings/app_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'hidden_pin_logic.dart';
import 'hidden_user_logic.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AppSettingsUI(widget: this);


  void handleChangeTheme(BuildContext context) {
    Provider.of<ThemeProvider>(context, listen: false).toggleThemeMode();
  }

  void handleHiddenPins(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HiddenPin()),
    );
  }

  void handleHiddenUsers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HiddenUsers()),
    );
  }

}