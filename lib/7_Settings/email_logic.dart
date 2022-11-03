import 'package:buff_lisa/7_Settings/email_ui.dart';
import 'package:flutter/material.dart';
import '../Files/global.dart' as global;
import '../0_ScreenSignIn/login_logic.dart';
import '../Files/restAPI.dart';

class Email extends StatelessWidget {
  const Email({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MailUI(widget: this);

  /// on submit of new email triggers the update on server
  /// on success the page is closed
  void changeMail(TextEditingController controller1, TextEditingController controller2, BuildContext context) {
    if (controller1.text == controller2.text &&  LoginScreen.emailValidator(controller1.text)) {
      RestAPI.changeEmail(global.username, controller1.text).then((value) => (value ? Navigator.pop(context) : null));
    }
  }
}