import 'package:buff_lisa/9_Profile/profile_image_ui.dart';
import 'package:flutter/cupertino.dart';

class ProfileImagePage extends StatefulWidget {
  const ProfileImagePage({super.key, required this.id, required this.duration});

  final int id;
  final int duration;

  @override
  ProfileImagePageState createState() => ProfileImagePageState();
}

class ProfileImagePageState extends State<ProfileImagePage> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);
   return ProfileImagePageUI(state: this);
  }


  @override
  bool get wantKeepAlive => true;
}