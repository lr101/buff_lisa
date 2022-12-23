import 'package:buff_lisa/7_Settings/email_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import '../Files/Other/global.dart' as global;

class MailUI extends StatelessUI<Email> {

  const MailUI({super.key, required widget}) : super(widget: widget);

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
                            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                            IconButton(onPressed: () =>  widget.changeMail(controller1, controller2, context), icon: const Icon(Icons.add_task)),
                          ],
                        ),
                        const SizedBox(height: 18,),
                        const Text("Change Email", style: TextStyle(fontSize: 20),)
                      ]
                  ),
                ),
                const Text("Type Email:", style: TextStyle(color: global.cPrime)),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(controller: controller1, style: const TextStyle(color: global.cPrime,)) ,
                ),
                const SizedBox(height: 20,),
                const Text("Repeat Email:", style: TextStyle(color: global.cPrime)),
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