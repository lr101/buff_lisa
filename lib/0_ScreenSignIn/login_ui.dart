import 'package:buff_lisa/0_ScreenSignIn/login_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

import '../Files/Other/global.dart' as global;

class LoginUI extends StatelessUI<LoginScreen> {
  const LoginUI({super.key, required widget}) : super(widget: widget);

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Mona',
      onLogin: widget.authUser,
      onSignup: widget.signupUser,
      userType: LoginUserType.name,
      userValidator: LoginScreen.validator,
      passwordValidator: LoginScreen.validator,
      onSubmitAnimationCompleted: () => widget.handleLoginComplete(context),
      onRecoverPassword: widget.recoverPassword,
      messages: LoginMessages(recoverPasswordDescription: "Check your mails to reset password"),
      additionalSignupFields: const [UserFormField(keyName: "email", userType: LoginUserType.email)],
    );
  }
}