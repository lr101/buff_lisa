import 'dart:typed_data';

import 'package:buff_lisa/9_Profile/profile_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_sliver_list.dart';
import 'package:buff_lisa/Files/Widgets/custom_profile_layout.dart';
import 'package:buff_lisa/Files/Widgets/custom_round_image.dart';
import 'package:buff_lisa/Files/Widgets/custom_show_and_pick.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/user_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../7_Settings/settings_logic.dart';
import '../Files/DTOClasses/pin.dart';
import '../Providers/theme_provider.dart';

class ProfilePageUI extends StatefulUI<ProfilePage, ProfilePageState> {

  const ProfilePageUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
          body: CustomTitle(
            title: _title(context),
            sliverList: CustomSliverList(
              initPagedList: () async => state.init(await Provider.of<UserNotifier>(context).getUser(widget.username).getPins),
              pagingController: state.pagingController,
            ),
          )
    );
  }

  Widget getImage() {
    if (widget.username == global.localData.username) {
      return CustomShowAndPick(
          provide: Provider.of<UserNotifier>(state.context, listen: false).getUser(widget.username).profileImage.asyncValue,
          updateCallback: state.provideProfileImage,
      );
    } else {
      return CustomRoundImage(
          imageCallback: Provider.of<UserNotifier>(state.context, listen: false).getUser(widget.username).profileImage.asyncValue,
          size: 50
      );
    }
  }

  CustomEasyTitle _title(BuildContext context) {
    if (widget.username == global.localData.username) {
      return CustomEasyTitle(
        customBackground: CustomProfileLayout(
          image: getImage(),
          posts: Consumer<UserNotifier>(
            builder: (context, value, child) => FutureBuilder<List<Pin>?>(
              future: () {
                if (!context.mounted) return null;
                return value.getUser(widget.username).getPins;
              }(),
              builder: (context, snapshot) => Text(snapshot.data != null ? snapshot.requireData!.length.toString() : "---"),
            ),
          )
        ),
        title: Text(widget.username, style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
        back: false,
        right: CustomEasyAction(
          child: const Icon(Icons.settings),
          action: () async => state.handlePushPage(const Settings())
        ),
      );
    } else {
      return CustomEasyTitle(
        customBackground: CustomProfileLayout(
          image: getImage(),
          posts: Consumer<UserNotifier>(
            builder: (context, value, child) => FutureBuilder<List<Pin>?>(
              future: () {
                if (!context.mounted) return null;
                return value.getUser(widget.username).getPins;
              }(),
              builder: (context, snapshot) => Text(snapshot.data != null ? snapshot.requireData!.length.toString() : "---"),
            ),
          )
        ),
        title: Text(widget.username, style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
      );
    }
  }


}