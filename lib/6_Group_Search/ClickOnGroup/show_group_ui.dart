import 'package:buff_lisa/6_Group_Search/ClickOnGroup/show_group_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/ranking.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Widgets/custom_action_button.dart';
import 'package:buff_lisa/Files/Widgets/custom_profile_layout.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../Files/Widgets/CustomSliverList/custom_easy_title.dart';
import '../../Files/Widgets/CustomSliverList/custom_sliver_list.dart';
import '../../Files/Widgets/cusotm_alert_dialog.dart';
import '../../Files/Widgets/custom_round_image.dart';


class ShowGroupUI extends StatefulUI<ShowGroupPage, ShowGroupPageState>{

  const ShowGroupUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null,
      body: CustomTitle(
        title: CustomEasyTitle(
            customBackground: CustomProfileLayout(
              posts: state.calcNumPosts,
              members: state.calcNumMembers,
              image:  CustomRoundImage(imageCallback: widget.group.profileImage.asyncValue, size: 50),
              children: _getChildren()
            ),
            title: Text(widget.group.name, style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
            right: state.widget.group.groupAdmin.syncValue == global.localData.username ? CustomEasyAction(child: const Icon(Icons.edit), action: () => state.editAsAdmin()) : null),
        sliverList: CustomSliverList(
          pagingController: state.controller,
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

  CustomAlertDialog getPopup() {
    TextEditingController controller = TextEditingController();
    if (state.widget.myGroup) {
      return CustomAlertDialog(text1: "Cancel", text2: "Yes", title: "Leave ${widget.group.name}?", onPressed: state.leaveGroup);
    } else {
      return CustomAlertDialog(text1: "Cancel", text2: "Yes", title: "Join ${widget.group.name}?", onPressed: getCallback(controller), child: getChild(controller),);
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

  List<Widget> _getChildren() {
    List<Widget> children = [];
    children.add(_getDescription());
    if (state.widget.group.visibility != 0 && widget.myGroup) {
      children.add(_getInviteLink());
    }
    return children;
  }


  /// returns the description of a group
  Widget _getDescription() {
    if (state.widget.group.visibility == 0 || widget.myGroup) {
      return FutureBuilder<String?>(
          future: state.widget.group.description.asyncValue(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Description:"),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(snapshot.requireData != null ? snapshot.requireData! : "Could not be loaded"),
                            )
                          ],
                        )
                    )
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
  }


}