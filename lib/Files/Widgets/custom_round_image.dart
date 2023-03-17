import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../9_Profile/ClickOnProfileImage/show_profile_image_logic.dart';

class CustomRoundImage extends StatelessWidget {

  final ImageProvider<Object>? image;

  final Future<Uint8List> Function()? imageCallback;

  final double size;

  final Widget? child;

  final bool clickable;

  const CustomRoundImage({super.key,this.image, this.imageCallback, required this.size, this.child, this.clickable = true}) : assert(image != null || imageCallback != null);



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _clickable(
          context: context,
          child:  FutureBuilder<ImageProvider<Object>>(
            future: _image(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CircleAvatar(backgroundImage:snapshot.requireData, radius: size, backgroundColor: Colors.transparent,child: child,);
              }else if (image != null) {
                return CircleAvatar(backgroundImage: image!, radius: size, backgroundColor: Colors.transparent,child: child,);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return CircleAvatar(radius: size, backgroundColor: Colors.grey ,child: child);
              } else {
                return CircleAvatar(backgroundImage: const Image(image: AssetImage("images/profile.jpg")).image, radius: size, backgroundColor: Colors.transparent);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _clickable({required Widget child, required BuildContext context}) {
    if (clickable) {
      return GestureDetector(
          onTap: () => handleOpenImage(context),
          child: child
      );
    } else {
      return child;
    }
  }

  Future<ImageProvider<Object>> _image() async {
    if (imageCallback != null) {
      return Image.memory(await imageCallback!()).image;
    } else {
      return Future<ImageProvider<Object>>(() => image!);
    }
  }

  void handleOpenImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => ShowProfileImage(provide: imageCallback != null ? imageCallback! : () async => Future<Uint8List?>(() => null), defaultImage: const Image(image: AssetImage("images/profile.jpg"),))
      ),
    );
  }

}