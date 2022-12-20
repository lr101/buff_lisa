import 'package:buff_lisa/6_Group_Search/create_group_logic.dart';
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
    var size = MediaQuery.of(context).size.width;
    final providerListen = Provider.of<CreateGroupNotifier>(context);
    final provider = Provider.of<CreateGroupNotifier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Edit Group'),
        backgroundColor: global.cThird,
      ),
      body: SizedBox(
          width: size,
          height: size,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Type Name:", style: TextStyle(color: global.cPrime)),
                SizedBox (
                    height: 50,
                    width: 200,
                    child: TextFormField(controller: provider.getText1, style: const TextStyle(color: global.cPrime,))
                ),
                const Text("Type Description:", style: TextStyle(color: global.cPrime)),
                SizedBox (
                  height: 50,
                  width: 200,
                  child: TextFormField(controller: provider.getText2,),
                ),
                const Text("Group Admin:"),
                DropdownButton(
                    items: Provider.of<CreateGroupNotifier>(context).menuItems,
                    onChanged: (String? value) => Provider.of<CreateGroupNotifier>(context, listen: false).currentItem = value,
                    value: global.username
                ),
                Slider(
                  value: providerListen.getSliderValue,
                  max: 1,
                  divisions: 1,
                  label: (providerListen.getSliderValue == 0 ? "public" : "private"),
                  onChanged: (_) => state.sliderOnChange(_, context),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox (
                          height: size /4,
                          width: size /4,
                          child: IconButton(
                            icon: const Icon(Icons.upload_file),
                            onPressed: () => state.handleImageUpload(context),
                          )
                      ),
                      SizedBox(
                        height: size/4,
                        width: size/4,
                        child: state.getImageWidget(providerListen.getImage),
                      ),
                    ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () => state.editGroup(context),
                        style: TextButton.styleFrom(backgroundColor: global.cThird),
                        child: const Text("Submit", style: TextStyle(color: Colors.white))
                    ),
                    const SizedBox(width: 10,),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(backgroundColor: global.cFourth),
                        child: const Text("Cancel", style: TextStyle(color: Colors.white))
                    )
                  ],
                )
              ]
          )
      ),
    );
  }

}