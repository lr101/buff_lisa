import 'package:buff_lisa/6_Group_Search/edit_group_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Providers/create_group_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Files/Other/global.dart' as global;


class EditGroupUI extends StatefulUI<EditGroupPage, EditGroupPageState>{

  const EditGroupUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    TextEditingController t1 = Provider.of<CreateGroupNotifier>(context).getText1;
    TextEditingController t2 = Provider.of<CreateGroupNotifier>(context).getText2;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).viewPadding.top,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () => state.close(), icon: const Icon(Icons.arrow_back)),
              IconButton(onPressed: () => state.editGroup(context), icon: const Icon(Icons.add_task)),
            ],
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
          const Text("group admin:"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton(
                isExpanded: true,
                items: Provider.of<CreateGroupNotifier>(context).menuItems,
                onChanged: (String? value) => Provider.of<CreateGroupNotifier>(context, listen: false).currentItem = value,
                value: global.username
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
    );
  }

}