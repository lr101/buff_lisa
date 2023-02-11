import 'dart:io';
import 'dart:typed_data';

import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:buff_lisa/Files/Widgets/CustomImagePicker.dart';
import 'package:buff_lisa/Providers/create_group_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'create_group_ui.dart';

//TODO Gruppen werden dobbelt ge-POST-tet
class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  CreateGroupPageState createState() => CreateGroupPageState();
}

class CreateGroupPageState extends State<CreateGroupPage> {

  /// adds a ChangeNotifierProvider to the build
  @override
  Widget build(BuildContext context) {
    final state = this;
    return ChangeNotifierProvider<CreateGroupNotifier>(
      create: (_) {
      return CreateGroupNotifier();
      },
        builder: ((context, child) => CreateGroupUI(state: state))
    );
  }

  /// when the slider is moved the value is registered in the Provider to trigger a rebuild of the slider widget
  void sliderOnChange(double value, BuildContext context) {
    Provider.of<CreateGroupNotifier>(context, listen: false).setSliderValue(value);
  }

  /// Tries to create the Group with the context given in the input fields
  /// TODO input values checked for constrains. What are the Constraines?
  void createGroup(BuildContext context) {
    final controller1 = Provider.of<CreateGroupNotifier>(context, listen: false).getText1;
    final controller2 = Provider.of<CreateGroupNotifier>(context, listen: false).getText2;
    final image = Provider.of<CreateGroupNotifier>(context, listen: false).getImage;
    final sliderValue = Provider.of<CreateGroupNotifier>(context, listen: false).getSliderValue;
    if (controller1.text.isNotEmpty && controller2.text.isNotEmpty && image != null) {
      FetchGroups.postGroup(controller1.text, controller2.text, image, sliderValue.toInt()).then((group) {
        if (group != null) {
          Provider.of<ClusterNotifier>(context, listen:false).addGroup(group);
          Navigator.pop(context);
        }
      });
    }
  }

  /// opens the input picker for selecting the group logo from gallery
  /// after selecting an image it is opened in an image cropper
  /// check if 100 < width, height and image is square
  /// saves image in Provider to trigger reload of image preview
  Future<void> handleImageUpload(BuildContext context) async {
    Color theme = Provider.of<ThemeProvider>(context, listen: false).getCustomTheme.c1;
    Uint8List? image = await CustomImagePicker.pick(minHeight: 100, minWidth: 100, color: theme, context: context);
    if(!mounted) return;
    if (image != null) {
      Provider.of<CreateGroupNotifier>(context, listen: false).setImage(image);
    } else {
      //TODO error message
    }
  }

  /// shows image if selected
  /// if not selected an image icon is shown
  Image getImageWidget(Uint8List? image) {
    if (image != null) {
      return Image.memory(image);
    } else {
      return const Image(image: AssetImage("images/profile.jpg"),);
    }
  }

}

