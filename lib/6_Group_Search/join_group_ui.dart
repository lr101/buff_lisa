import 'dart:typed_data';

import 'package:buff_lisa/Files/fetch_groups.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../Files/DTOClasses/group.dart';
import '../Files/restAPI.dart';


class JoinGroupUI {

  static Widget build(BuildContext context, Size size, Group group) {
    return AlertDialog(
        content: SizedBox(
          height: size.height - 300,
          width: size.width - 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text("Logo: "),
                        SizedBox(
                          height: 40,
                          child: group.getProfileImageWidget()
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text("Group name: "),
                        Text(group.name),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      height: 50,
                      child: SingleChildScrollView(
                       child: _getDescription(group),
                      )
                    ),
                    const SizedBox(height: 10,),
                    JoinGroupLogic.getMembers(group)
                  ],
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  height: 50,
                  child: _getJoinButton(group, context),
                )
              ]
          ),
        )
    );
  }

  static Widget _getJoinButton(Group group, BuildContext alertContext) {
    if (group.visibility != 0) {
      TextEditingController controller = TextEditingController();
      return Row(
        children: [
          SizedBox(
              width: 100,
              child: TextField(
                controller: controller,
              )
          ),
          TextButton(
              onPressed: () => JoinGroupLogic.joinPrivateGroup(group, alertContext, controller),
              child: const Text("Join"))
        ],
      );
    } else {
      return TextButton(
        onPressed: () => JoinGroupLogic.joinPublicGroup(group, alertContext),
        child: const Text("Join"),
      );
    }
  }

  static Widget _getDescription(Group group) {
    if (group.visibility != 0) {
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


  static Widget _buildList(Set<String> members) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Members: "),
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: members.length,
          itemBuilder: (_, index) => Card(
            child:  ListTile(
              leading: Text("${index+1}. "),
              title: Text(members.elementAt(index)),
            )
          )
        )
      ],
    );
  }
}

class JoinGroupLogic {

  static Widget getMembers(Group group) {
    if  (group.visibility != 0) {
      return Row(
        children: const [
          Text("Members:"),
          Icon(Icons.lock)
        ],
      );
    } else {
      return FutureBuilder<Set<String>>(
          future: group.getMembers(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return JoinGroupUI._buildList(snapshot.requireData);
            } else {
              return const CircularProgressIndicator();
            }
          }
      );
    }
  }

  static void joinPublicGroup(Group group, BuildContext context) {
    FetchGroups.joinGroup(group.groupId, null).then((value) {
      Provider.of<ClusterNotifier>(context, listen: false).addGroup(value);
      Navigator.pop(context);
    });
  }

  static void joinPrivateGroup(Group group, BuildContext context, TextEditingController controller)  {
    try {
      FetchGroups.joinGroup(group.groupId, controller.text).then((value) {
        Provider.of<ClusterNotifier>(context, listen: false).addGroup(value);
        Navigator.pop(context);
      });
    } catch(e) {
      //TODO wrong invite code
    }
  }

}