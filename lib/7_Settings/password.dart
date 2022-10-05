import 'package:flutter/material.dart';
import '../0_ScreenSignIn/secure.dart';
import '../Files/global.dart' as global;
import '../0_ScreenSignIn/login.dart';
import '../Files/restAPI.dart';

class Password extends StatelessWidget {
  const Password({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    final controller1 = TextEditingController();
    final controller2 = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Change Password'),
        backgroundColor: global.cThird,
      ),
      body: SizedBox(
          width: size,
          height: size,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Type Password:", style: TextStyle(color: global.cPrime)),
                SizedBox (
                  height: 50,
                  width: 200,
                  child: TextFormField(obscureText: true, enableSuggestions: false, autocorrect: false, validator: LoginScreen.validator, controller: controller1,),
                ),
                const Text("Repeat Password:", style: TextStyle(color: global.cPrime)),
                SizedBox (
                  height: 50,
                  width: 200,
                  child: TextFormField(obscureText: true, enableSuggestions: false, autocorrect: false, validator: LoginScreen.validator, controller: controller2,),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(onPressed: () => {
                      if (controller1.text == controller2.text && LoginScreen.validator(controller1.text) == null) {
                        RestAPI.changePassword(global.username, Secure.encryptPassword(controller1.text)).then((value) {
                          if (value) {
                            Navigator.pop(context);
                          }
                        })
                      }
                    },  style: TextButton.styleFrom(backgroundColor: global.cThird),
                        child: const Text("Submit", style: TextStyle(color: Colors.white))),
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(backgroundColor: global.cFourth),
                        child: const Text("Cancel", style: TextStyle(color: Colors.white))
                    )
                  ],
                )
              ]
          )
      ),
    );
  }
}