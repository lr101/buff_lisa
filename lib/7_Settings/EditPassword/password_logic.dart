import 'package:buff_lisa/0_ScreenSignIn/login_logic.dart';
import 'package:buff_lisa/0_ScreenSignIn/secure.dart';
import 'package:buff_lisa/7_Settings/EditPassword/password_ui.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:flutter/material.dart';

class Password extends StatelessWidget {
  const Password({super.key});

  @override
  Widget build(BuildContext context) => PasswordUI(widget: this);

  /// on submit of new password button triggers the update on server
  /// on success the page is closed
  void handleSubmitPress(controller1, controller2, BuildContext context) {
    if (controller1.text == controller2.text && LoginScreen.validator(controller1.text) == null) {
      FetchUsers.changePassword(global.localData.username, Secure.encryptPassword(controller1.text)).then((value) {
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