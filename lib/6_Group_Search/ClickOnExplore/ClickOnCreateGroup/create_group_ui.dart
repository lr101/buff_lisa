import 'package:buff_lisa/6_Group_Search/ClickOnExplore/ClickOnCreateGroup/create_group_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/create_group_notifier.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Files/Widgets/custom_show_and_pick.dart';


class CreateGroupUI extends StatefulUI<CreateGroupPage, CreateGroupPageState>{

  const CreateGroupUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    TextEditingController t1 = Provider.of<CreateGroupNotifier>(context).getText1;
    TextEditingController t2 = Provider.of<CreateGroupNotifier>(context).getText2;
    return Scaffold(appBar: null,
          resizeToAvoidBottomInset: false,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // -- title --
              CustomTitle(
                titleBar: CustomTitleBar(
                  title: "Create Group",
                  back: true,
                  action: CustomAction(icon: const Icon(Icons.add_task), action: () => state.createGroup(context)),
                )
              ),
              CustomShowAndPick(
                updateCallback: (p0, context) {
                  Provider.of<CreateGroupNotifier>(context, listen: false).setImage(p0);
                  return Future(() => p0);
                },
                provide: () => Future(() => null),
              ),
              const SizedBox(height: 20,),
              const Text("group name:"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextFormField(
                    textAlign: TextAlign.center,
                    controller: t1
                ),
              ),
              const SizedBox(height: 20,),
              const Text("Description:"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: t2,
                ),
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("public "),
                  Switch(
                    value: Provider.of<CreateGroupNotifier>(context).getSliderValue != 0,
                    onChanged: (value) => state.sliderOnChange(value ? 1 : 0, context),
                    focusColor: Provider.of<ThemeProvider>(context).getCustomTheme.c1,
                  ),
                  const Text("private")
                ],
              )
            ],
          ),
        );
  }

}