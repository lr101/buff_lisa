import 'dart:typed_data';

import 'package:buff_lisa/6_Group_Search/show_group_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../Files/AbstractClasses/abstract_widget_ui.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/ranking.dart';
import '../Files/Other/global.dart' as global;


class ShowGroupUI extends StatefulUI<ShowGroupPage, ShowGroupPageState>{

  const ShowGroupUI({super.key, required state}) : super(state: state);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : FutureBuilder<List<Widget>>(
        future: getGroupInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.requireData.length,
              itemBuilder: (context, index) => snapshot.requireData[index],
            );
          } else {
            return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) => getTopBar(null, null, null)
            );
          }
        },
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
  Widget _getDescription(String? description) {
    if (description == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("Description: "),
            Icon(Icons.lock)
          ]
      );
    } else {
      return Column(
        children: [
          const Text("Description:"),
          Text(description, overflow: TextOverflow.ellipsis,)
        ],
      );
    }
  }

  Future<List<Widget>> getGroupInfo() async {
    List<Widget> widgets = [];
    List<Ranking> ranking = [];
    if (state.widget.group.visibility == 0 || widget.myGroup) ranking = await state.widget.group.getMembers();
    String? inviteUrl;
    String? description;
    if (state.widget.group.visibility != 0 && widget.myGroup) inviteUrl = await state.widget.group.getInviteUrl();
    if (state.widget.group.visibility == 0 || widget.myGroup) description = await state.widget.group.getDescription();
    Uint8List image = await state.widget.group.getProfileImage();
    widgets.add(getTopBar(image, inviteUrl, description));
    for (int i = 0; i < ranking.length; i++) {
      widgets.add(buildCard(ranking[i], i));
    }
    return widgets;
  }

  Widget buildCard(member, index) {
    String adminString = "";
    if (member.username == widget.group.groupAdmin!) adminString = "(admin)";
    return Card(
        child: ListTile(
          leading: Text("${index + 1}. "),
          title: Text("${member.username} $adminString"),
          trailing: Text("${member.points} points"),
        )
    );
  }

  Widget getTopBar(Uint8List? groupImage, String? inviteUrl, String? description) {
    Image image = (groupImage != null) ? Image.memory(groupImage) : const Image(image: AssetImage("images/profile.jpg"));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: () => state.close(), icon: const Icon(Icons.arrow_back)),
            getAdminButton()
          ],
        ),
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircleAvatar(backgroundImage: image.image, radius: 50,)]
        ),
        const SizedBox(height: 10,),
        Text("group name: ${state.widget.group.name}"),
        if (inviteUrl != null) const SizedBox(height: 10,),
        if (inviteUrl != null) TextButton(onPressed: () => Clipboard.setData(ClipboardData(text: inviteUrl)), child: Text("Password: $inviteUrl")),
        const SizedBox(height: 10,),
        _getDescription(description),
        const SizedBox(height: 50,)
      ],
    );
  }

  Widget getAdminButton() {
    if (state.widget.group.groupAdmin == global.username) {
      return IconButton(onPressed: () => state.editAsAdmin(), icon: const Icon(Icons.edit));
    } else {
      return Container();
    }
  }
}