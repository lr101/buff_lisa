import 'dart:typed_data';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:images_picker/images_picker.dart' as picker;
import 'package:buff_lisa/7_Settings/settings_logic.dart';
import 'package:buff_lisa/9_Profile/profile_ui.dart';
import 'package:flutter/material.dart';
import 'package:image_cropping/image_cropping.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../0_ScreenSignIn/login_logic.dart';
import '../0_ScreenSignIn/secure.dart';
import '../7_Settings/email_logic.dart';
import '../7_Settings/password_logic.dart';
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


  void openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Settings()),
    );
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
      if ((dimensions.width < 100 && dimensions.height < 100) || dimensions.width != dimensions.height) return; //TODO error message -> picture to small
      if (await FetchUsers.changeProfilePicture(global.username, croppedBytes)) {
        setState(() {});
      }
    }
  }

  /// on password button press the password widget page is opened
  void handlePasswordPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Password()),
    );
  }

  /// on email button press the email widget page is opened
  void handleEmailPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Email()),
    );
  }

  /// on logout button press all existing open pages are closed and the token and username or removed
  /// the login screen widget page is opened
  void handleLogoutPress(BuildContext context) {
    global.token = "";
    Secure.removeSecure("auth");
    global.username = "";
    Secure.removeSecure("username");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const LoginScreen()
        ),
        ModalRoute.withName("/login")
    );
  }

  void handleChangeTheme(BuildContext context) {
    Provider.of<ThemeProvider>(context, listen: false).toggleThemeMode();
  }

  @override
  bool get wantKeepAlive => true;
}