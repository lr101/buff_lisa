import 'dart:typed_data';

import 'package:buff_lisa/9_Profile/profile_image_logic.dart';
import 'package:buff_lisa/9_Profile/profile_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:buff_lisa/Providers/profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../7_Settings/show_web_widget.dart';
import '../Files/Other/global.dart' as global;
import '../Files/ServerCalls/fetch_pins.dart';

class ProfilePageUI extends StatefulUI<ProfilePage, ProfilePageState> {

  const ProfilePageUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: FutureBuilder<Uint8List?>(
              future: FetchUsers.fetchProfilePicture(global.username),
              builder: (context, snapshot) {
                return getList(snapshot.data, context);
              },
            )
        )
    );
  }

  Widget getList(Uint8List? image, BuildContext context) {
    List<Widget> settings = getSettings(context);
    return ListView.builder(
      itemCount: settings.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return getTitle(image, context);
        } else {
          return settings[index - 1];
        }
      },
    );
  }

  Widget getTitle(Uint8List? profileImage, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40,),
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => state.handleImageUpload(context),
                child: getProfile(profileImage)
              )
            ]
        ),
        const SizedBox(height: 20,),
        Text("username: ${global.username}"),
        const SizedBox(height: 50,)
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

  List<Widget> getSettings(BuildContext context) {
    return [
      Card(
        child: TextButton(
          onPressed: () => state.handlePasswordPress(context),
          child: const Text("Change Password", ),
        ),
      ),
      Card(
        child: TextButton(
          onPressed: () => state.handleEmailPress(context),
          child: const Text("Change email", ),
        ),
      ),
      Card(
        child: TextButton(
          onPressed: () => state.handleLogoutPress(context),
          child: const Text("Logout", ),
        ),
      ),
      Card(
        child: TextButton(
          onPressed: () => state.handleChangeTheme(context),
          child: const Text("Change Theme", ),
        ),
      ),
      Card(
        child: TextButton(
          onPressed: () => state.handleHiddenPins(context),
          child: const Text("Edit hidden pins", ),
        ),
      ),
      Card(
        child: TextButton(
          onPressed: () => state.handleHiddenUsers(context),
          child: const Text("Edit hidden users", ),
        ),
      ),
      Card(child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShowWebWidget(route: "public/agb",title: "Terms of Service",)),
          );
        },
        child: const Text("Open Terms of Service"),
      ),),
      Card(child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShowWebWidget(route: "public/privacy-policy",title: "Privacy Policy",)),
          );
        },
        child: const Text("Open Privacy Policy"),
      ),),
    ];
  }
}