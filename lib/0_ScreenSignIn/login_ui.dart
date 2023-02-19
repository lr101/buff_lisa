import 'package:buff_lisa/0_ScreenSignIn/login_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

import '../7_Settings/WebView/show_web_widget.dart';

class LoginUI extends StatelessUI<LoginScreen> {
  const LoginUI({super.key, required widget}) : super(widget: widget);

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Login',
      termsOfService: [
        TermOfService(id: "0", text: "Terms of Service", mandatory: true),
        TermOfService(id: "0", text: "Privacy Policy", mandatory: true)
      ],
      onLogin: widget.authUser,
      onSignup: widget.signupUser,
      userType: LoginUserType.name,
      userValidator: LoginScreen.validator,
      passwordValidator: LoginScreen.validator,
      onSubmitAnimationCompleted: () => widget.handleLoginComplete(context),
      onRecoverPassword: widget.recoverPassword,
      messages: LoginMessages(recoverPasswordDescription: "Check your mails to reset password"),
      additionalSignupFields: const [UserFormField(keyName: "email", userType: LoginUserType.email)],
      children: [ Positioned.fill(
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: privacyPolicyLinkAndTermsOfService(context),
              )
          )
      ),],
    );
  }

  /// creates the text, that is shown at the bottom of the login screen
  /// 'Terms of Service' and 'Privacy Policy' are clickable
  /// Click opens the corresponding page of the [ShowWebWidget]
  Widget privacyPolicyLinkAndTermsOfService(BuildContext context) {
    return Text.rich(
        TextSpan(
            text: 'By continuing, you agree to our ', style: const TextStyle(
            fontSize: 16,
        ),
            children: <TextSpan>[
              TextSpan(
                  text: 'Terms of Service', style: const TextStyle(
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ShowWebWidget(route: "public/agb",title: "Terms of Service",)),
                      );
                    }
              ),
              TextSpan(
                  text: ' and ', style: const TextStyle(
                  fontSize: 18,
              ),
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Privacy Policy', style: const TextStyle(
                        fontSize: 18,
                        decoration: TextDecoration.underline
                    ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ShowWebWidget(route: "public/privacy-policy",title: "Privacy Policy",)),
                            );
                          }
                    )
                  ]
              )
            ]
        )
    );
  }
}