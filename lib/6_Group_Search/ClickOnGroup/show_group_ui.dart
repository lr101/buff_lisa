import 'dart:typed_data';

import 'package:buff_lisa/6_Group_Search/ClickOnGroup/show_group_logic.dart';
import 'package:buff_lisa/Files/Widgets/CustomActionButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/ranking.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Widgets/CustomTitle.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';


class ShowGroupUI extends StatefulUI<ShowGroupPage, ShowGroupPageState>{

  const ShowGroupUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Ranking>>(
        future: (state.widget.group.visibility != 0 && !widget.myGroup) ? Future(() => []) : widget.group.members.asyncValue(),
        builder: (context, snapshot) => ListView.builder(
          itemCount: 1 + (snapshot.hasData ? snapshot.requireData.length : 0),
          itemBuilder: (context, index) {
            if (index == 0) {
              return CustomTitle(
                title: widget.group.name,
                back: true,
                action: (state.widget.group.groupAdmin.syncValue == global.username) ? CustomAction(icon: const Icon(Icons.edit), action: () => state.editAsAdmin()) : null,
                imageCallback: widget.group.profileImage.asyncValue,
                child: Column(
                  children: [
                    _getDescription(),
                    _getInviteLink(),
                    const SizedBox(height: 10,),
                    snapshot.hasData ? const SizedBox.shrink() : const CircularProgressIndicator()
                  ],
                )
            );
          } else {
            return buildCard(snapshot.requireData[index-1], index-1);
          }
        }
      ),
      ),
      floatingActionButton: CustomActionButton(
        text: getText(),
        popup: getPopup(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String getText() {
    if(state.widget.myGroup) {
      return "Leave Group";
    } else {
      return "Join Group";
    }
  }

  CustomPrompt getPopup() {
    TextEditingController controller = TextEditingController();
    if (state.widget.myGroup) {
      return CustomPrompt(text1: "Cancel", text2: "Yes", title: "Leave ${widget.group.name}?", onPressed: state.leaveGroup);
    } else {
      return CustomPrompt(text1: "Cancel", text2: "Yes", title: "Join ${widget.group.name}?", onPressed: getCallback(controller), child: getChild(controller),);
    }
  }

  VoidCallback getCallback(TextEditingController controller) {
    if (state.widget.group.visibility != 0) {
      return () => state.joinPrivateGroup(controller);
    } else {
      return state.joinPublicGroup;
    }
  }

  Widget getChild(TextEditingController controller) {
    if (state.widget.group.visibility != 0) {
      return TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter invite code here',
          )
      );
    } else {
      return const SizedBox.shrink();
    }
  }


  /// returns the description of a group
  Widget _getDescription() {
    if (state.widget.group.visibility == 0 || widget.myGroup) {
      return FutureBuilder<String>(
          future: state.widget.group.description.asyncValue(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Description:"),
                  Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(snapshot.requireData, overflow: TextOverflow.ellipsis,))
                  )
                ],
              );
            } else {
              return const Text("Description: LOADING...");
            }
          }
      );
    } else {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("Description: "),
            Icon(Icons.lock)
          ]
      );
    }
  }

  Widget _getInviteLink() {
    if (state.widget.group.visibility != 0 && widget.myGroup) {
      return FutureBuilder<String>(
        future: state.widget.group.getInviteUrl(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return TextButton(onPressed: () => Clipboard.setData(ClipboardData(text: snapshot.requireData)), child: Text("Password: ${snapshot.requireData}"));
          } else {
            return const Text("LOADING");
          }
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildCard(member, index) {
    String adminString = "";
    if (member.username == widget.group.groupAdmin.syncValue!) adminString = "(admin)";
    return Card(
      color: (member.username == global.username) ? Provider.of<ThemeProvider>(state.context).getCustomTheme.c1 : null,
        child: ListTile(
          leading: Text("${index + 1}. "),
          title: Text("${member.username} $adminString"),
          trailing: Text("${member.points} points"),
        )
    );
  }
}