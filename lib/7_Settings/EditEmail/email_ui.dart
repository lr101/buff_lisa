import 'package:buff_lisa/7_Settings/EditEmail/email_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Files/Themes/custom_theme.dart';
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
            ),
            child: SingleChildScrollView( child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5,),
                  Container(
                    color: CustomTheme.grey, width: MediaQuery.of(context).size.width,
                    child: Padding(padding: const EdgeInsets.all( 10),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Current email",style:  TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.normal)) ,
                                Text("coming soon...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                ),
                              ]
                          )
                      ),),),
                  const SizedBox(height: 5,),
                  Container(
                    color: CustomTheme.grey, width: MediaQuery.of(context).size.width,
                    child: Padding(padding: const EdgeInsets.all( 10),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("New email",style:  TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.normal)) ,
                                TextFormField(
                                  textAlign: TextAlign.start,
                                  keyboardType: TextInputType.url,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  decoration: const InputDecoration(hintText: "New email"),
                                  maxLines: 1,
                                  controller: controller1,
                                ),
                              ]
                          )
                      ),),),
                  const SizedBox(height: 5,),
                  Container(
                    color: CustomTheme.grey, width: MediaQuery.of(context).size.width,
                    child: Padding(padding: const EdgeInsets.all( 10),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Repeat email",style:  TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.normal)) ,
                                TextFormField(
                                  textAlign: TextAlign.start,
                                  keyboardType: TextInputType.url,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  decoration: const InputDecoration(hintText: "Repeat email"),
                                  maxLines: 1,
                                  controller: controller2,
                                ),
                              ]
                          )
                      ),),),
                ]
            )
        ),),
      floatingActionButton: FloatingActionButton(
          onPressed: () async => widget.changeMail(controller1, controller2, context),
          child: const Icon(Icons.check),
      ),
    );
  }
}