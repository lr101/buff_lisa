import 'package:buff_lisa/7_Settings/HiddenUsers/hidden_user_logic.dart';
import 'package:buff_lisa/7_Settings/OrderGroups/order_groups_logic.dart';
import 'package:buff_lisa/7_Settings/settings_ui.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../0_ScreenSignIn/login_logic.dart';
import 'EditEmail/email_logic.dart';
import 'EditPassword/password_logic.dart';
import 'HiddenPins/hidden_pin_logic.dart';
import 'Report/report_user.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SettingsUI(widget: this);


  /// Perform toggle theme change and notify.
  void handleChangeTheme(BuildContext context) {
    Provider.of<ThemeNotifier>(context, listen: false).toggleThemeMode();
  }

  /// Opends hidden pins as a new page.
  void handleHiddenPins(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HiddenPin()),
    );
  }

  /// Opens hidden user as a new page.
  void handleHiddenUsers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HiddenUsers()),
    );
  }

  /// Opens order group as a new page.
  void handleOrderGroups(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrderGroups()),
    );
  }

  /// on password button press the password widget page is opened
  void handlePasswordPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Password()),
    );
  }

  /// on email button press the email widget page is opened
  void handleEmailPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Email()),
    );
  }

  /// on logout button press all existing open pages are closed and the token and username or removed
  /// the login screen widget page is opened
  Future<void> handleLogoutPress(BuildContext context) async {
    Provider.of<ClusterNotifier>(context, listen: false).clearAll();
    await global.localData.logout().then((value) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const LoginScreen()
          ),
          ModalRoute.withName("/login")
      );
    });
  }

  /// Open report page to contact developer.
  Future<void> handleReportPost(BuildContext context) async {
    String username = global.localData.username;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ReportUser(content: "Contacted by: $username", title: "Contact Developer", hintText: "Describe the problem...",userText: "Reported by: $username",)),
    );
  }

}