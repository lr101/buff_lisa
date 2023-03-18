import 'package:buff_lisa/7_Settings/HiddenUsers/hidden_user_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/user.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_sliver_list.dart';
import 'package:buff_lisa/Files/Widgets/custom_list_tile.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/hidden_user_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Providers/theme_provider.dart';

class HiddenUsersUI extends StatefulUI<HiddenUsers, HiddenUsersState> {

  const HiddenUsersUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    Set<User> users = Provider.of<HiddenUserPageNotifier>(context).users;
    return Scaffold(appBar: null,
        body: CustomTitle(
          title: CustomEasyTitle(
            title: Text("Hidden Users", style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
            back: true,
          ),
          sliverList: CustomSliverList(
            itemCount: users.length,
            itemBuilder: (index) => CustomListTile(
                leading: Text("${index + 1}."),
                title: Text("Post by: ${users.elementAt(index).username}", style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
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
                ),
            )
          ),
        )
    );
  }
}