import 'package:buff_lisa/0_ScreenSignIn/secure.dart';
import 'package:buff_lisa/1_BottomNavigationBar/bottomNavigationBar.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../Files/global.dart' as global;

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  Duration get loginTime => const Duration(milliseconds: 200);

  Future<String?> _authUser(LoginData data) {
    global.username = data.name;
    return Secure.loginAuthentication(data.name, data.password, ).then((value) {
      return value ? null : 'username or password are wrong';
    });
  }

  Future<String?> _signupUser(SignupData data) {
    return Future.delayed(loginTime).then((_) async {
      if (data.name != null && data.password != null && emailValidator(data.additionalSignupData!["email"])) {
        return Secure.signupAuthentication(data.name!, data.password!, data.additionalSignupData!["email"]!).then((value) {
          return value ? null : 'Username already exists or check your internet';
        });
      }
      return 'Signup not possible';
    });

  }

  Future<String?> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return RestAPI.checkUser(name).then((element) {
      if (element == null || element.isEmpty) {
        return 'username or password are wrong';
      }
      return 'Send personal request to Lukasr101@gmail.com';
    });
  }



  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      // STYLES
      theme: LoginTheme(
          buttonTheme: const LoginButtonTheme(backgroundColor: global.cThird),
          titleStyle: const TextStyle(color: Colors.white),
          primaryColor: global.cThird,
      ),
      title: 'Mona',
      onLogin: _authUser,
      onSignup: _signupUser,
      userType: LoginUserType.name,
      userValidator: validator,
      passwordValidator: validator,
      onSubmitAnimationCompleted: () {

        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>const BottomNavigationWidget(),
        ));
      },
      onRecoverPassword: _recoverPassword,
      additionalSignupFields: const [UserFormField(keyName: "email", userType: LoginUserType.email)],
    );
  }

  static String? validator(String? s) {
    final alphanumeric = RegExp(r'^[a-zA-Z][a-zA-Z0-9!?#$%&+]+$');
    if (s == null || s.length < 2 || s.length > 30 || !alphanumeric.hasMatch(s)) {
      return "input not valid";
    }
    return null;
  }

  static bool emailValidator(String? s) {
    if (s != null && RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(s)){
      return true;
    } else {
      return false;
    }
  }
}