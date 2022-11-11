import 'package:buff_lisa/0_ScreenSignIn/login_logic.dart';
import 'package:buff_lisa/7_Settings/password_logic.dart';
import 'package:buff_lisa/7_Settings/settings_ui.dart';
import 'package:buff_lisa/Providers/points_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../0_ScreenSignIn/secure.dart';
import '../Files/global.dart' as global;
import 'email_logic.dart';

class Settings extends StatelessWidget  {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SettingsUI(widget: this);

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
  void handleLogoutPress(BuildContext context) {
    global.token = "";
    Secure.removeSecure("auth");
    global.username = "";
    Secure.removeSecure("username");
    Provider.of<PointsNotifier>(context, listen: false).setUserPoints(0);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const LoginScreen()
        ),
        ModalRoute.withName("/login")
    );
  }

}