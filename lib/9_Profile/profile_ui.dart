import 'dart:typed_data';

import 'package:buff_lisa/9_Profile/profile_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_sliver_list.dart';
import 'package:buff_lisa/Files/Widgets/custom_show_and_pick.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/user_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../7_Settings/settings_logic.dart';

class ProfilePageUI extends StatefulUI<ProfilePage, ProfilePageState> {

  const ProfilePageUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
          body: CustomSliverList(
            title: _title(),
            appBar: getImage(),
            appBarHeight: 130,
            initPagedList: () => state.init(Provider.of<UserNotifier>(context).getUser(widget.username).getPins),
            pagingController: state.pagingController,
          )
    );
  }

  Widget getImage() {
    if (widget.username == global.localData.username) {
      return CustomShowAndPick(
          provide: () =>
              Provider.of<UserNotifier>(state.context, listen: false).getUser(widget.username).profileImage.asyncValue(),
          updateCallback: state.provideProfileImage,
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => state.handleOpenImage(),
            child:  FutureBuilder<Uint8List>(
              future: FetchUsers.fetchProfilePicture(widget.username),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CircleAvatar(backgroundImage: Image.memory(snapshot.requireData).image, radius: 50,);
                } else {
                  return CircleAvatar(backgroundImage: const Image(image: AssetImage("images/profile.jpg")).image, radius: 50,);
                }
              },
            ),
          ),
        ],
      );
    }
  }

  CustomEasyTitle _title() {
    if (widget.username == global.localData.username) {
      return CustomEasyTitle(
        title: widget.username,
        back: false,
        right: CustomEasyAction(
          child: const Icon(Icons.settings),
          action: () async => state.handlePushPage(const Settings())
        ),
      );
    } else {
      return CustomEasyTitle(
        title: widget.username,
      );
    }
  }


}