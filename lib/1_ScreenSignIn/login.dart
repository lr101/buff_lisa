import 'package:buff_lisa/1_ScreenSignIn/secure.dart';
import 'package:buff_lisa/2_BottomNavigationBar/bottomNavigationBar.dart';
import 'package:buff_lisa/2_ScreenMaps/maps.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Files/global.dart' as global;


class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  Duration get loginTime => const Duration(milliseconds: 200);
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<String?> _authUser(LoginData data) {
    global.username = data.name;
    return Secure.checkPasswordOnline(data.name, data.password, storage).then((value) {
      if (value) {
        return null;
      } else {
        return 'username or password are wrong';
      }
    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) async {
      if (data.name != null) {
        String psw = Secure.setPassword(data.name!, data.password!);
        bool response = await RestAPI.postUsername(data.name!, psw);
        if (response) {
          Secure.setUsername(data.name!, storage);
          return null;
        } else {
          return 'Username already exists or check your internet';
        }
      }
      return 'Username is null';
    });
  }

  Future<String?> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return RestAPI.checkUser().then((element) {
      if (element == null || element.isEmpty) {
        return 'username or password are wrong';
      }
      return 'Send personal request to Lukasr101@gmail.com';
    });
  }



  @override
  Widget build(BuildContext context) {
    Secure.tryLocalLogin(storage).then((value) { if (value) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const BottomNavigationWidget(),
        ));
      }
    });
    return FlutterLogin(
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
    );
  }

  String? validator(String? s) {
    final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    if (s == null || s.length < 2 || s.length > 30 || !alphanumeric.hasMatch(s)) {
      return "input not valid";
    }
    return null;
  }
}