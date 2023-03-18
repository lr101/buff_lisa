import 'package:buff_lisa/7_Settings/EditEmail/email_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Files/Widgets/CustomSliverList/custom_easy_title.dart';
import '../../Providers/theme_provider.dart';

class MailUI extends StatelessUI<Email> {

  const MailUI({super.key, required widget}) : super(widget: widget);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    final controller1 = TextEditingController();
    final controller2 = TextEditingController();
    return Scaffold(appBar: null,
        body: CustomTitle(
            title: CustomEasyTitle(
              title: Text("Edit Email", style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
              back: true,
              right: CustomEasyAction(
                  child: const Icon(Icons.add_task),
                  action: () async => widget.changeMail(controller1, controller2, context)
              ),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Type Email:"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(controller: controller1) ,
                  ),
                  const SizedBox(height: 20,),
                  const Text("Repeat Email:"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(controller: controller2,),
                  ),
                ]
            )
        )
    );
  }
}