import 'dart:typed_data';

import 'package:buff_lisa/6_Group_Search/show_group_logic.dart';
import 'package:flutter/material.dart';
import '../Files/AbstractClasses/abstract_widget_ui.dart';
import '../Files/DTOClasses/ranking.dart';
import '../Files/global.dart' as global;
import '../Files/DTOClasses/group.dart';


class ShowGroupUI extends StatefulUI<ShowGroupPage, ShowGroupPageState>{

  const ShowGroupUI({super.key, required state}) : super(state: state);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: global.cThird,
          centerTitle: true,
          actions: [
            IconButton(onPressed: () => state.editAsAdmin(), icon: const Icon(Icons.edit))
          ],
          title: Row(
            children: [
              FutureBuilder<Uint8List>(
                future: state.widget.group.getProfileImage(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return CircleAvatar(backgroundImage: Image.memory(snapshot.data!).image, radius: 20,);
                  } else {
                    return const CircleAvatar(backgroundColor: Colors.grey, radius: 20,);
                  }
                },
              ),
              const SizedBox(width: 20,),
              Text(state.widget.group.name)
            ]
          ),
      ),
      backgroundColor: Colors.white,
      body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: double.infinity,
                        minHeight: 35.0,
                        maxHeight: 100.0,
                      ),
                      child: SingleChildScrollView(
                       child: Container(
                         padding: const EdgeInsets.all(3),
                         margin: const EdgeInsets.all(15.0),
                         decoration: BoxDecoration(
                             border: Border.all(color: Colors.blueAccent)
                         ),
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             _getDescription()
                           ],
                         ),
                       )
                      )
                    ),
                    const SizedBox(height: 10,),
                    state.getMembers(),
                  ],
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    margin: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent)
                    ),
                    child: _getButton(context),
                  ),
                )
              ]
          ),
    );
  }

  /// returns the leave group or join group button depending on if the current user is a member of the group
  Widget _getButton(BuildContext context) {
    if (state.widget.myGroup) {
      return TextButton(
          onPressed: () => state.leaveGroup(),
          child: const Text("Leave Group")
      );
    } else {
      if (state.widget.group.visibility != 0) {
        TextEditingController controller = TextEditingController();
        return Row(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter invite code here',
                  )
                )
            ),
            TextButton(
                onPressed: () => state.joinPrivateGroup(controller),
                child: const Text("Join"))
          ],
        );
      } else {
        return TextButton(
          onPressed: () => state.joinPublicGroup(),
          child: const Text("Join"),
        );
      }
    }
  }

  /// returns the description of a group
  Widget _getDescription() {
    Group group = state.widget.group;
    if (group.visibility != 0 && !widget.myGroup) {
      return Row(
          children: const [
            Text("Description: "),
            Icon(Icons.lock)
          ]
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Description:"),
          group.getDescriptionWidget()
        ],
      );
    }
  }
}