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
      ),
      body: SizedBox(
          width: size,
          height: size,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Type Password:"),
                SizedBox (
                  height: 50,
                  width: 200,
                  child: TextFormField(obscureText: true, enableSuggestions: false, autocorrect: false, validator: LoginScreen.validator, controller: controller1,),
                ),
                const Text("Repeat Password:"),
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
                        RestAPI.changePassword(global.username, Secure.setPassword(controller1.text)).then((value) {
                          if (value) {
                            Navigator.pop(context);
                          }
                        })
                      }
                    }, child: const Text("Submit")),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel")
                    )
                  ],
                )
              ]
          )
      ),
    );
  }
}