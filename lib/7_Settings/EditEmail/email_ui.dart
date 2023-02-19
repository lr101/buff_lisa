import 'package:buff_lisa/7_Settings/EditEmail/email_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Widgets/custom_title.dart';

class MailUI extends StatelessUI<Email> {

  const MailUI({super.key, required widget}) : super(widget: widget);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    final controller1 = TextEditingController();
    final controller2 = TextEditingController();
    return Scaffold(appBar: null,

      body: SizedBox(
          width: size,
          height: size,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomTitle(
                  titleBar: CustomTitleBar(
                    title: "Edit Email",
                    back: true,
                    action: CustomAction(icon: const Icon(Icons.add_task), action: () =>  widget.changeMail(controller1, controller2, context)),
                  ),
                ),
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
      ),
    );
  }
}