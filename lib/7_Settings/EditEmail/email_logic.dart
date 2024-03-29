import 'package:buff_lisa/0_ScreenSignIn/login_logic.dart';
import 'package:buff_lisa/7_Settings/EditEmail/email_ui.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:flutter/material.dart';

class Email extends StatelessWidget {
  const Email({super.key});

  @override
  Widget build(BuildContext context) => MailUI(widget: this);

  /// on submit of new email triggers the update on server
  /// on success the page is closed
  void changeMail(TextEditingController controller1, TextEditingController controller2, BuildContext context) {
    if (controller1.text == controller2.text &&  LoginScreen.emailValidator(controller1.text)) {
      FetchUsers.changeEmail(global.localData.username, controller1.text).then((value) => (value ? Navigator.pop(context) : null));
    }
  }
}