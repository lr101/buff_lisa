import 'dart:typed_data';
import 'package:buff_lisa/7_Settings/AppSettings/hidden_user_logic.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:images_picker/images_picker.dart' as picker;
import 'package:buff_lisa/9_Profile/profile_ui.dart';
import 'package:flutter/material.dart';
import 'package:image_cropping/image_cropping.dart';
import 'package:provider/provider.dart';
import '../7_Settings/Report/report_user.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Providers/theme_provider.dart';

import '../Files/Widgets/CustomImagePicker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProfilePageUI(state: this);
  }

 void handlePushPage(Widget widget) {
   Navigator.push(
     context,
     MaterialPageRoute(builder: (context) => widget),
   );
 }


  @override
  bool get wantKeepAlive => true;
}