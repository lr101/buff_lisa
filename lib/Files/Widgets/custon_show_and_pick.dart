import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Providers/theme_provider.dart';
import 'custom_image_picker.dart';

class CustomShowAndPick extends StatefulWidget {
  const CustomShowAndPick({super.key, required this.updateCallback, this.defaultImage = const Image(image: AssetImage("images/profile.jpg")), this.provide});

  final Future<Uint8List?> Function()? provide;
  final Future<Uint8List?> Function(Uint8List, BuildContext context) updateCallback;
  final Image defaultImage;

  @override
  CustomShowAndPickState createState() => CustomShowAndPickState();
}

class CustomShowAndPickState extends State<CustomShowAndPick> {

  Uint8List? image;

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<Uint8List?>(
              future:  getImage(),
              builder: (context, snapshot) => CircleAvatar(
                backgroundImage: getProfile(snapshot.data),
                radius: 50,
                child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () => handleImageUpload(context),
                            child: const CircleAvatar(
                                radius: 18,
                                child: Icon(Icons.edit),
                            )
                          ),
                        ),
                      ]
                  ),
              )
            )
        ]
    );
  }

  Future<Uint8List?> getImage() {
    if (image == null && widget.provide != null) {
      return widget.provide!();
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
    Color theme = Provider.of<ThemeProvider>(context, listen: false).getCustomTheme.c1;
    Uint8List? pickedImage = await CustomImagePicker.pick(minHeight: 100, minWidth: 100, color: theme, context: context);
    if(!mounted || pickedImage == null) return;
    image = await widget.updateCallback(pickedImage, context);
    setState(() {});
  }


}