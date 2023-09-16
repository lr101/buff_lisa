
import 'dart:async';

import 'package:buff_lisa/Files/DTOClasses/pin_repo.dart';
import 'package:buff_lisa/Files/Widgets/custom_round_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../10_UploadOffline/upload_offline_logic.dart';
import '../Files/DTOClasses/group_repo.dart';
import '../Files/Other/global.dart' as global;
import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/pin.dart';
import '../Files/Other/local_data.dart';
import '../Files/ServerCalls/fetch_groups.dart';
import '../Files/Widgets/custom_error_message.dart';
import '../Providers/cluster_notifier.dart';
import 'navbar_logic.dart';

class SplashLoading extends StatefulWidget {
  const SplashLoading({super.key});

  @override
  SplashLoadingState createState() => SplashLoadingState();
}

class SplashLoadingState extends State<SplashLoading> with TickerProviderStateMixin {

  late AnimationController controller;
  bool determinate = false;

  String offlineMessage = "Connecting to server";

  @override
  void initState() {
    Timer(const Duration(seconds: 8, milliseconds: 50), () {
      if(mounted) {
        setState(() {
          offlineMessage = "Logging in offline";
        });
      }
    });
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
      setState(() {});
    });
    controller.repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getGroups();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CustomRoundImage(asset: "images/pinGui.png", size: 50),
            const SizedBox(height: 30),
            const Text(
              'Loading your group information',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            LinearProgressIndicator(
              value: controller.value,
              semanticsLabel: 'Linear progress indicator',
            ),
            const SizedBox(height: 10),
            Text(offlineMessage)
          ],
        ),
      ),
    );
  }

  /// tries loading the groups of user from server
  /// on success: call groupsOnline()
  /// on error: must be an internet error: load saved offline pins by calling groupsOffline()
  Future<void> _getGroups() async {
    try {
      List<Group> offlineGroups = global.localData.groupRepo.getGroups();
      List<Group> groups = await FetchGroups.getUserGroups();
      for (var group in groups) {
        if (group.lastUpdated != null) {
          offlineGroups.where((g) => group.groupId == g.groupId).forEach((g) {
            if (g.lastUpdated != null && (g.lastUpdated!.isAfter(group.lastUpdated!) || g.lastUpdated!.isAtSameMomentAs(group.lastUpdated!))) {
              group.profileImage.setValue(g.profileImage.syncValue!);
              group.pinImage.setValue(g.pinImage.syncValue!);
            }
          });
        }
      }

      await groupsOnline(groups);
    } on Exception catch (_, e) {
      if (kDebugMode )print(_);
      groupsOffline();
    }

  }

  /// add loaded groups to notifier, then
  /// load existing offline pins from device storage -> open upload page, then
  /// load and activate previous active groups
  Future<void> groupsOnline(List<Group> groups) async {
    // add groups to global notifier
    if (!mounted) return;
    Provider.of<ClusterNotifier>(context, listen:false).addGroups(List.from(groups));
    // load all offline pins from files
    Set<Pin> value = (await PinRepo.fromInit(LocalData.pinFileNameKey)).getPins(groups);
    if (value.isNotEmpty && mounted) {
      // open upload page if offline saved pins exist
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => UploadOfflinePage(pins: value)
          ),
          ModalRoute.withName("/offline")
      );
    } else {
      finish();
    }
  }

  @override
  void dispose() {
    controller.stop();
    controller.dispose();
    super.dispose();
  }

  /// load saved groups from device storage
  /// load saved pins from device storage and add them to show on map
  Future<void> groupsOffline() async {
    // show error message
    //CustomErrorMessage.message(context: context, message: "Cannot connect to server, offline groups are displayed");
    Provider.of<ClusterNotifier>(context, listen:false).offline = true;
    // load previous offline saved groups
    await Provider.of<ClusterNotifier>(context, listen:false).loadOfflineGroups();
    if (!mounted) return;
    finish();
  }

  void finish() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const BottomNavigationWidget()
        ),
        ModalRoute.withName("/navbar")
    );
  }

}