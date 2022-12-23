import 'dart:typed_data';

import 'package:buff_lisa/9_Profile/profile_image_logic.dart';
import 'package:buff_lisa/9_Profile/profile_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:buff_lisa/Providers/profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/Other/global.dart' as global;
import '../Files/ServerCalls/fetch_pins.dart';

class ProfilePageUI extends StatefulUI<ProfilePage, ProfilePageState> {

  const ProfilePageUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<int>>(
            future: FetchPins.fetchUserPins(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Widget> widgets = [];
                int duration = 0;
                for (int i in snapshot.requireData) {
                  widgets.add(ProfileImagePage(id: i, duration:  duration,));
                  duration = (duration + 200) % 3000;
                }
                return ListView.builder(
                    itemCount: widgets.length ~/ 3 + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return FutureBuilder<Uint8List?>(
                            future: FetchUsers.fetchProfilePicture(global.username),
                            builder: ((context, snapshot) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [IconButton(onPressed: state.openSettings, icon: const Icon(Icons.settings))],
                                  ),
                                  Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [getProfile(snapshot.data)]
                                  ),
                                  const SizedBox(height: 20,),
                                  Text("username: ${global.username}"),
                                  const SizedBox(height: 50,)
                                ],
                              );
                            })
                        );
                      } else {
                        index--;
                        Widget widget1 =  (index * 3 < widgets.length) ? widgets[index * 3] : Container();
                        Widget widget2 =  (index * 3 + 1 < widgets.length) ? widgets[index * 3 + 1] : Container();
                        Widget widget3 =  (index * 3 + 2 < widgets.length) ? widgets[index * 3 + 2] : Container();
                        return getRow(widget1, widget2, widget3, context);
                      }
                    },
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          )
    );
  }

  Widget getRow(widget1, widget2, widget3, BuildContext context) {
    final width = MediaQuery.of(context).size.width / 3;
    return Row(
        children: [
          SizedBox(height: width, width: width, child: widget1),
          SizedBox(height: width, width: width, child: widget2),
          SizedBox(height: width, width: width, child: widget3),
        ],
    );
  }
  
  Widget getProfile(Uint8List? image) {
    if (image != null) {
      return CircleAvatar(backgroundImage: Image.memory(image).image, radius: 50,);
    } else {
      return CircleAvatar(backgroundImage: const Image(image: AssetImage("images/profile.jpg"),).image, radius: 50,);
    }
    
  }
}