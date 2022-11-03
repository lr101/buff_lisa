import 'package:buff_lisa/7_Settings/password_ui.dart';
import 'package:flutter/material.dart';
import '../0_ScreenSignIn/secure.dart';
import '../Files/global.dart' as global;
import '../0_ScreenSignIn/login_logic.dart';
import '../Files/restAPI.dart';

class Password extends StatelessWidget {
  const Password({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => PasswordUI(widget: this);

  /// on submit of new password button triggers the update on server
  /// on success the page is closed
  void handleSubmitPress(controller1, controller2, BuildContext context) {
    if (controller1.text == controller2.text && LoginScreen.validator(controller1.text) == null) {
      RestAPI.changePassword(global.username, Secure.encryptPassword(controller1.text)).then((value) {
        if (value) {
          Navigator.pop(context);
        }
      });
    }
  }

  /// button press of cancel button closes the page without an action
  void handleCancelPress(BuildContext context) {
    Navigator.pop(context);
  }
}