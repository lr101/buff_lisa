import 'package:buff_lisa/7_Settings/app_settings_ui.dart';
import 'package:buff_lisa/7_Settings/email_ui.dart';
import 'package:buff_lisa/7_Settings/password_logic.dart';
import 'package:buff_lisa/7_Settings/profile_settings_ui.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../0_ScreenSignIn/login_logic.dart';
import '../0_ScreenSignIn/secure.dart';
import '../Files/Other/global.dart' as global;
import '../Providers/theme_provider.dart';
import 'email_logic.dart';
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