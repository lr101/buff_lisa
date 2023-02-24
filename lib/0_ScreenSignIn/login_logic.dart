import 'package:buff_lisa/0_ScreenSignIn/login_ui.dart';
import 'package:buff_lisa/0_ScreenSignIn/secure.dart';
import 'package:buff_lisa/1_BottomNavigationBar/navbar_logic.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
    global.localData.username = data.name;
    try {
      return Secure.loginAuthentication(data.name, data.password, ).then((value) {
        return value ? null : 'username or password are wrong';
      });
    } on Exception catch (_, e) {
      print(_);
      return Future<String>.value("cannot connect to server");
    }

  }

  /// This method is called when a user completed the signup form and tries to signup
  /// return returns null when signup was successful and an error message on errors
  Future<String?> signupUser(SignupData data) {
    try {
      return Future.delayed(Duration.zero).then((_) async {
        if (data.name == null || data.password  == null) {
          return Future<String>.value("name or password ar not valid");
        } else if (!emailValidator(data.additionalSignupData!["email"])) {
          return Future<String>.value("email does not have the correct format");
        } else {
          return Secure.signupAuthentication(data.name!, data.password!, data.additionalSignupData!["email"]!)
              .then((value) {
                return value
                    ? null
                    : 'Username already exists or check your internet';
              });
          }
      });
    } catch (e) {
      return Future<String>.value("cannot connect to server");
    }

  }

  /// This method starts the recovery process for a given existing username
  /// Returns null on a successful call to the server or an error message on errors
  Future<String?> recoverPassword(String name) {
    try {
      return FetchUsers.recover(name).then((value) {
        return value ? null : 'User does not have an email address';
      });
    } catch (e) {
      return Future<String>.value("cannot connect to server");
    }
  }

  /// Validator Method for validating password
  /// returns null on success or an error message for an incorrect input
  static String? validator(String? s) {
    final alphanumeric = RegExp(r'^[a-zA-Z][a-zA-Z0-9!?#$%&+]+$');
    if (s == null ) {
      return "input is not valid";
    } else if (s.length < 2 ) {
      return "at least 2 characters";
    } else if (s.length > 29) {
      return "shorter than 30 characters";
    } else  if (!alphanumeric.hasMatch(s)) {
      return "start with a letter - allowed: 0-9!?#\$%&+";
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