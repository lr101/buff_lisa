import 'package:buff_lisa/7_Settings/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import '../0_ScreenSignIn/login_logic.dart';
import '../0_ScreenSignIn/secure.dart';
import '../Files/DTOClasses/group_repo.dart';
import '../Files/DTOClasses/hive_handler.dart';
import '../Files/DTOClasses/pin_repo.dart';
import '../Files/Widgets/cusotm_alert_dialog.dart';
import 'EditEmail/email_logic.dart';
import 'EditPassword/password_logic.dart';
import 'Report/report_user.dart';
import 'HiddenPins/hidden_pin_logic.dart';
import 'package:buff_lisa/7_Settings/HiddenUsers/hidden_user_logic.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SettingsUI(widget: this);


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

    global.token = "";
    Secure.removeSecure("auth");
    global.username = "";
    Secure.removeSecure("username");
    final HiveHandler<int, dynamic> offlineActiveGroups = await HiveHandler.fromInit<int, dynamic>("activeGroups");
    await offlineActiveGroups.clear();
    HiveHandler<String, DateTime> hiddenUsers = await HiveHandler.fromInit<String, DateTime>(global.hiddenUsers);
    await hiddenUsers.clear();
    HiveHandler<int, DateTime> hiddenPosts = await HiveHandler.fromInit<int, DateTime>(global.hiddenPosts);
    await hiddenPosts.clear();
    GroupRepo repo = GroupRepo();
    await repo.init(global.groupFileName);
    await repo.clear();
    PinRepo pinRepo = PinRepo();
    await pinRepo.init(global.fileName);
    await pinRepo.deleteAll().then((value) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const LoginScreen()
          ),
          ModalRoute.withName("/login")
      );
    });
  }

  Future<void> handleReportPost(BuildContext context) async {
    String username = global.username;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ReportUser(content: "Contacted by: $username", title: "Contact Developer", hintText: "Describe the problem...",userText: "Reported by: $username",)),
    );
  }

}