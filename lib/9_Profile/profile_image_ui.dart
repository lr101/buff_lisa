import 'package:buff_lisa/9_Profile/profile_image_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/pin.dart';

class ProfileImagePageUI
    extends StatefulUI<ProfileImagePage, ProfileImagePageState> {

  const ProfileImagePageUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: Future.delayed(Duration(milliseconds: state.widget.duration)).then((value) => false),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
           return FutureBuilder<Pin>(
                future:FetchPins.fetchUserPin(state.widget.id, Provider.of<ClusterNotifier>(context, listen: false).getGroups),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.requireData.image.getWidget();
                  } else {
                    return const CircularProgressIndicator();
                  }
                })
            );
          } else {
            return const CircularProgressIndicator();
          }
        })
    );
  }
}