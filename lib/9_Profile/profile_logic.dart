import 'dart:typed_data';
import 'package:buff_lisa/7_Settings/hidden_user_logic.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:images_picker/images_picker.dart' as picker;
import 'package:buff_lisa/9_Profile/profile_ui.dart';
import 'package:flutter/material.dart';
import 'package:image_cropping/image_cropping.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../0_ScreenSignIn/login_logic.dart';
import '../0_ScreenSignIn/secure.dart';
import '../7_Settings/email_logic.dart';
import '../7_Settings/hidden_pin_logic.dart';
import '../7_Settings/password_logic.dart';
import '../7_Settings/report_user.dart';
import '../Files/Other/global.dart' as global;
import '../Providers/theme_provider.dart';

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
    List<picker.Media>? res = await picker.ImagesPicker.pick(
      count: 1,
      pickType: picker.PickType.image,
    );
    if (res != null && res.length == 1) {
      Uint8List? croppedBytes = await ImageCropping.cropImage(
        context: context,
        imageBytes: File(res[0].path).readAsBytesSync(),
        isConstrain: true,
        visibleOtherAspectRatios: false,
        selectedImageRatio: const CropAspectRatio(
          ratioX: 1,
          ratioY: 1,
        ),
        squareCircleColor: Colors.red,
        defaultTextColor: Colors.black,
        colorForWhiteSpace: Colors.black,
        outputImageFormat: OutputImageFormat.jpg,
        onImageDoneListener: (_) {},
      );
      if(croppedBytes == null) return;
      final dimensions = await decodeImageFromList(croppedBytes);
      if ((dimensions.width < 500 && dimensions.height < 500)) return; //TODO error message -> picture to small
      if (await FetchUsers.changeProfilePicture(global.username, croppedBytes)) {
        setState(() {});
      }
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