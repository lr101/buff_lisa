import 'package:buff_lisa/0_ScreenSignIn/login.dart';
import 'package:buff_lisa/7_Settings/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../0_ScreenSignIn/secure.dart';
import '../Files/global.dart' as global;
import 'email.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {



    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text('Settings'),
        ),
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Password()),
                );
              },
              child: const Text("Change Password"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Email()),
                );
              },
              child: const Text("Change email"),
            ),
            TextButton(
              onPressed: () {
                Secure.removeUsername(const FlutterSecureStorage());
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text("Logout"),
            ),
          ],
        ));
  }

}