import 'dart:typed_data';

import 'package:buff_lisa/6_Group_Search/show_group_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../Files/AbstractClasses/abstract_widget_ui.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/ranking.dart';
import '../Files/Other/global.dart' as global;
import '../Files/Widgets/CustomTitle.dart';


class ShowGroupUI extends StatefulUI<ShowGroupPage, ShowGroupPageState>{

  const ShowGroupUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Ranking>>(
        future: widget.group.members.asyncValue(),
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
      floatingActionButton: Container(
          width: MediaQuery.of(context).size.width - 50,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: const Color(0x99ffffff)
          ),
          child: _getButton(context)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
          mainAxisAlignment: MainAxisAlignment.center,
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
      color: (member.username == global.username) ? Colors.green : null,
        child: ListTile(
          leading: Text("${index + 1}. "),
          title: Text("${member.username} $adminString"),
          trailing: Text("${member.points} points"),
        )
    );
  }
}