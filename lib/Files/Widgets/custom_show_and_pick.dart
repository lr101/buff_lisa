import 'dart:typed_data';

import 'package:buff_lisa/9_Profile/ClickOnProfileImage/show_profile_image_logic.dart';
import 'package:buff_lisa/Files/Widgets/custom_round_image.dart';
import 'package:flutter/material.dart';

import '../Routes/routing.dart';
import '../Themes/custom_theme.dart';
import 'custom_image_picker.dart';

class CustomShowAndPick extends StatefulWidget {
  const CustomShowAndPick({super.key, required this.updateCallback, this.defaultImage = const Image(image: AssetImage("images/profile.jpg")), required this.provide, this.size = 50, this.iconSize = 18});

  final Future<Uint8List?> Function() provide;
  final Future<Uint8List?> Function(Uint8List, BuildContext context) updateCallback;
  final Image defaultImage;
  final double size;
  final double iconSize;

  @override
  CustomShowAndPickState createState() => CustomShowAndPickState();
}

class CustomShowAndPickState extends State<CustomShowAndPick> {

  Uint8List? image;
  bool updating = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
              future:  getImage(),
              builder: (context, snapshot) {
                  return GestureDetector(
                      onTap: handleOpenImage,
                      child: CustomRoundImage(
                        imageCallback: getImage,
                        size: widget.size,
                        child: Stack(
                            children: [
                              Center(child: snapshot.connectionState == ConnectionState.done && !updating ? const SizedBox.shrink() : const CircularProgressIndicator()),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: GestureDetector(
                                    onTap: () => handleImageUpload(context),
                                    child: CircleAvatar(
                                      radius: widget.iconSize,
                                      child: const Icon(Icons.edit),
                                    )
                                ),
                              ),
                            ]
                        ),
                      )
                  );
              }
    );
  }

  Future<Uint8List?> getImage() {
    if (image == null) {
      return widget.provide();
    } else {
      return Future(() => image);
    }
  }


  ImageProvider<Object> getProfile(Uint8List? image) {
    final ImageProvider<Object> imageProvider;
    if (image != null) {
      imageProvider = Image.memory(image).image;
    } else {
      imageProvider = widget.defaultImage.image;
    }
    return imageProvider;

  }


  /// opens the input picker for selecting the group logo from gallery
  /// after selecting an image it is opened in an image cropper
  /// check if 100 < width, height and image is square
  /// saves image in Provider to trigger reload of image preview
  Future<void> handleImageUpload(BuildContext context) async {
    Color theme = CustomTheme.c1;
    Uint8List? pickedImage = await CustomImagePicker.pickAndCrop(minHeight: 100, minWidth: 100, color: theme, context: context);
    if(!mounted || pickedImage == null) return;
    setState(() {
      updating = true;
    });
    image = await widget.updateCallback(pickedImage, context);
    setState(() {
      updating = false;
    });
  }


  void handleOpenImage() {
    Routing.to(context,  ShowProfileImage(provide: getImage, defaultImage: widget.defaultImage,));
  }

}