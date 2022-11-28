import 'package:buff_lisa/0_ScreenSignIn/login_ui.dart';
import 'package:buff_lisa/0_ScreenSignIn/secure.dart';
import 'package:buff_lisa/1_BottomNavigationBar/navbar_logic.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:buff_lisa/Files/ServerCalls/restAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../Files/global.dart' as global;

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  /// Login time sleeper used to wait shortly before login
  Duration get loginTime => const Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) => LoginUI(widget: this);

  /// Navigates to the NavBar Widget when authentication was successful
  void handleLoginComplete(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>const BottomNavigationWidget(),
      )
    );
  }


  /// This method is called when the user tries to login with a username and password to an existing account
  /// return returns null when login was successful and an error message on errors
  Future<String?> authUser(LoginData data) {
    global.username = data.name;
    return Secure.loginAuthentication(data.name, data.password, ).then((value) {
      return value ? null : 'username or password are wrong';
    });
  }

  /// This method is called when a user completed the signup form and tries to signup
  /// return returns null when signup was successful and an error message on errors
  Future<String?> signupUser(SignupData data) {
    return Future.delayed(loginTime).then((_) async {
      if (data.name != null && data.password != null && emailValidator(data.additionalSignupData!["email"])) {
        return Secure.signupAuthentication(data.name!, data.password!, data.additionalSignupData!["email"]!).then((value) {
          return value ? null : 'Username already exists or check your internet';
        });
      }
      return 'Signup not possible';
    });

  }

  /// This method starts the recovery process for a given existing username
  /// Returns null on a successful call to the server or an error message on errors
  Future<String?> recoverPassword(String name) {
    return FetchUsers.recover(name).then((value) {
      return value ? null : 'User does not have an email address';
    });
  }

  /// Validator Method for validating password
  /// returns null on success or an error message for an incorrect input
  static String? validator(String? s) {
    final alphanumeric = RegExp(r'^[a-zA-Z][a-zA-Z0-9!?#$%&+]+$');
    if (s == null || s.length < 2 || s.length > 30 || !alphanumeric.hasMatch(s)) {
      return "input not valid";
    }
    return null;
  }

  /// Validator method for validating emails
  /// returns true on success or false for an incorrect input
  static bool emailValidator(String? s) {
    if (s != null && RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(s)){
      return true;
    } else {
      return false;
    }
  }
}