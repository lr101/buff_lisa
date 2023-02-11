import 'package:buff_lisa/7_Settings/EditPassword/password_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/0_ScreenSignIn/login_logic.dart';
import 'package:buff_lisa/Files/Widgets/CustomTitle.dart';

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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomTitle(
                  titleBar: CustomTitleBar(
                    title: "Edit Password",
                    back: true,
                    action: CustomAction(icon: const Icon(Icons.add_task), action: () => widget.handleSubmitPress(controller1, controller2, context)),
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