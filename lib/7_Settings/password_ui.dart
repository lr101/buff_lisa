import 'package:buff_lisa/7_Settings/password_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import '../Files/Other/global.dart' as global;
import '../0_ScreenSignIn/login_logic.dart';

class PasswordUI extends StatelessUI<Password> {

  const PasswordUI({super.key, required widget}) : super(widget: widget);

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
                    TextButton(
                        onPressed: () => widget.handleSubmitPress(controller1, controller2, context),
                        style: TextButton.styleFrom(backgroundColor: global.cThird),
                        child: const Text("Submit", style: TextStyle(color: Colors.white))),
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton(
                        onPressed: () => widget.handleCancelPress(context),
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