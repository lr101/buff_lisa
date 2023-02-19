import 'package:buff_lisa/7_Settings/HiddenPins/hidden_pin_logic.dart';
import 'package:buff_lisa/7_Settings/HiddenUsers/hidden_user_logic.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/user.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/hidden_pin_page.dart';
import 'package:buff_lisa/Providers/hidden_user_page.dart';

class HiddenUsersUI extends StatefulUI<HiddenUsers, HiddenUsersState> {

  const HiddenUsersUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    Set<User> users = Provider.of<HiddenUserPageNotifier>(context).users;
    return Scaffold(appBar: null,
        body: ListView.builder(
          itemCount: users.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const CustomTitle(
                titleBar: CustomTitleBar(
                  title: "Hidden Users",
                  back: true,
                ),
              );
            }
            index--;
            return Card(
              child: ListTile(
                  leading: Text("${index + 1}."),
                  title: Text("Post by: ${users.elementAt(index).username}"),
                  trailing: SizedBox(
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed:() => state.unHideUser(users.elementAt(index)),
                            child: const Text("add"),
                          ),
                        ],
                      )
                  )
              ),
            );
          },
        )
    );
  }
}