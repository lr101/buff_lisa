import 'package:buff_lisa/0_ScreenSignIn/login_logic.dart';
import 'package:buff_lisa/7_Settings/EditPassword/password_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:flutter/material.dart';

import '../../Files/Widgets/CustomSliverList/custom_easy_title.dart';

class PasswordUI extends StatelessUI<Password> {

  const PasswordUI({super.key, required widget}) : super(widget: widget);

  @override
  Widget build(BuildContext context) {
    final controller1 = TextEditingController();
    final controller2 = TextEditingController();
    return Scaffold(appBar: null,
      body: CustomTitle(
          title: CustomEasyTitle(
              title: const Text("Edit Password"),
              back: true,
              right: CustomEasyAction(
                child: const Icon(Icons.add_task),
                action: () async => widget.handleSubmitPress(controller1, controller2, context)
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                const Text("Type Password:"),
                Padding (
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(obscureText: true, enableSuggestions: false, autocorrect: false, validator: LoginScreen.validator, controller: controller1,),
                ),
                const SizedBox(height: 20,),
                const Text("Repeat Password:"),
                Padding (
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(obscureText: true, enableSuggestions: false, autocorrect: false, validator: LoginScreen.validator, controller: controller2,),
                )
            ]
        )
      )
    );
  }
}