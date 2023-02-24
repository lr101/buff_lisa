import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/hive_handler.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/DTOClasses/user.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/hidden_user_page.dart';
import 'package:buff_lisa/Providers/user_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'hidden_user_ui.dart';


class HiddenUsers extends StatefulWidget {
  const HiddenUsers({super.key});


  @override
  HiddenUsersState createState() => HiddenUsersState();
}

class HiddenUsersState extends State<HiddenUsers>{


  @override
  late BuildContext context;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadOffline();
    });
  }

  /// adds a ChangeNotifierProvider to the build
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HiddenUserPageNotifier>(create: (_) {
      return HiddenUserPageNotifier();
    }, builder: ((context, child) {
      this.context = context;
      return HiddenUsersUI(state: this);
    }));
  }


  Future<void> unHideUser(User user) async {
    List<Group> groups = Provider.of<ClusterNotifier>(context, listen: false).getGroups;
    await Provider.of<HiddenUserPageNotifier>(context, listen: false).unHideUser(user);
    if (!mounted) return;
    for (Group group in groups) {
      Set<Pin> pins = await FetchPins.fetchUserPinsOfGroup(user.username, group);
      if (!mounted) return;
      Provider.of<ClusterNotifier>(context, listen: false).addPins(pins);
    }
  }

  Future<void> loadOffline() async{
    Set<User> users = {};
    HiveHandler<String, DateTime> hiddenUsers = global.localData.hiddenUsers;
    for (String username in await hiddenUsers.keys()) {
      if (!mounted) return;
      users.add(Provider.of<UserNotifier>(context, listen: false).getUser(username));
    }
    if (!mounted) return;
    Provider.of<HiddenUserPageNotifier>(context, listen: false).setUsers(users);
  }




}