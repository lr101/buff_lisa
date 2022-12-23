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
      body: SizedBox(
          width: size,
          height: size,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(onPressed: () => widget.handleCancelPress(context), icon: const Icon(Icons.arrow_back)),
                            IconButton(onPressed: () =>  widget.handleSubmitPress(controller1, controller2, context), icon: const Icon(Icons.add_task)),
                          ],
                        ),
                        const SizedBox(height: 18,),
                        const Text("Change Password", style: TextStyle(fontSize: 20),)
                      ]
                  ),
                ),
                const Text("Type Password:", style: TextStyle(color: global.cPrime)),
                Padding (
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(obscureText: true, enableSuggestions: false, autocorrect: false, validator: LoginScreen.validator, controller: controller1,),
                ),
                const SizedBox(height: 20,),
                const Text("Repeat Password:", style: TextStyle(color: global.cPrime)),
                Padding (
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(obscureText: true, enableSuggestions: false, autocorrect: false, validator: LoginScreen.validator, controller: controller2,),
                ),
              ]
          )
      ),
    );
  }
}