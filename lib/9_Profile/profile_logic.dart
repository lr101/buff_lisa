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


  /// opens the input picker for selecting the group logo from gallery
  /// after selecting an image it is opened in an image cropper
  /// check if 100 < width, height and image is square
  /// saves image in Provider to trigger reload of image preview
  Future<void> handleImageUpload(BuildContext context) async {
    Color theme = Provider.of<ThemeProvider>(context, listen: false).getCustomTheme.c1;
    Uint8List? image = await CustomImagePicker.pick(minHeight: 100, minWidth: 100, color: theme, context: context);
    if(!mounted || image == null) return;
    if (await FetchUsers.changeProfilePicture(global.username, image)) {
      setState(() {});
    }
  }

 void handlePushPage(Widget widget) {
   Navigator.push(
     context,
     MaterialPageRoute(builder: (context) => widget),
   );
 }

  Future<void> handleReportPost(BuildContext context) async {
    String username = global.username;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ReportUser(content: "Contacted by: $username", title: "Contact Developer", hintText: "Describe the problem...",userText: "Reported by: $username",)),
    );
  }


  @override
  bool get wantKeepAlive => true;
}