import 'package:buff_lisa/6_Group_Search/create_group_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Providers/create_group_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Files/Other/global.dart' as global;
import '../Files/Widgets/CustomTitle.dart';


class CreateGroupUI extends StatefulUI<CreateGroupPage, CreateGroupPageState>{

  const CreateGroupUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    TextEditingController t1 = Provider.of<CreateGroupNotifier>(context).getText1;
    TextEditingController t2 = Provider.of<CreateGroupNotifier>(context).getText2;
    return SafeArea(child:
        Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // -- title --
              CustomTitle(
                title: "Create Group",
                back: true,
                action: CustomAction(icon: const Icon(Icons.add_task), action: () => state.createGroup(context)),
              ),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => state.handleImageUpload(context),
                      child: CircleAvatar(backgroundImage: state.getImageWidget(Provider.of<CreateGroupNotifier>(context).getImage).image, radius: 50,),
                    )
                  ]
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
                  ),
                  const Text("private")
                ],
              )
            ],
          ),
        )
    );
  }

}