import 'dart:typed_data';

import 'package:buff_lisa/7_Settings/hidden_pin_ui.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/hidden_pin_page.dart';
import 'package:buff_lisa/Providers/hidden_user_page.dart';
import 'package:buff_lisa/Providers/user_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/hive_handler.dart';
import '../Files/DTOClasses/pin.dart';
import '../Files/DTOClasses/user.dart';
import '../Files/Other/global.dart' as global;
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
    for (int id in await FetchPins.fetchUserPins(user.username)) {
      if (!mounted) return;
      Provider.of<ClusterNotifier>(context, listen: false).addPin(await FetchPins.fetchUserPin(id, groups));
    }
  }

  Future<void> loadOffline() async{
    Set<User> users = {};
    HiveHandler<String, DateTime> hiddenPosts = await HiveHandler.fromInit<String, DateTime>(global.hiddenUsers);
    for (String username in await hiddenPosts.keys()) {
      if (!mounted) return;
      users.add(Provider.of<UserNotifier>(context, listen: false).getUser(username));
    }
    if (!mounted) return;
    Provider.of<HiddenUserPageNotifier>(context, listen: false).setUsers(users);
  }




}