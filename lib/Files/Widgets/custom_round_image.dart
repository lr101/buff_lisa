import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../9_Profile/ClickOnProfileImage/show_profile_image_logic.dart';
import '../Routes/routing.dart';

class CustomRoundImage extends StatelessWidget {

  final Future<Uint8List?> Function()? imageCallback;

  final Future<Uint8List?> Function()? imageCallbackClickable;

  final String? asset;

  final double size;

  final Widget? child;

  final bool clickable;

  const CustomRoundImage({super.key, this.imageCallback, required this.size, this.child, this.clickable = true, this.asset, this.imageCallbackClickable}) : assert (imageCallback != null || asset != null);



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _clickable(
          context: context,
          child:  FutureBuilder<ImageProvider<Object>?>(
            future: _image(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CircleAvatar(backgroundImage: snapshot.requireData,
                  radius: size,
                  backgroundColor: Colors.transparent,
                  child: child,);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return CircleAvatar(radius: size, backgroundColor: Colors.grey ,child: child);
              } else {
                return CircleAvatar(backgroundImage: const Image(image: AssetImage("images/profile.jpg")).image, radius: size, backgroundColor: Colors.transparent, child: child,);
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

  Future<ImageProvider<Object>?> _image() async {
    if (imageCallback != null) {
      Uint8List? image = await imageCallback!();
      if (image == null) return null;
      return Image.memory(image).image;
    } else {
      return Future<ImageProvider<Object>>(() => Image(image: AssetImage(asset!)).image);
    }
  }

  Future<Uint8List> _bytes() async {
    final ByteData bytes = await rootBundle.load(asset!);
    return bytes.buffer.asUint8List();
  }

  void handleOpenImage(BuildContext context) {
    Routing.to(context,  ShowProfileImage(
        provide: imageCallbackClickable != null ? imageCallbackClickable! :
          imageCallback != null ? imageCallback! : _bytes,
        defaultImage: const Image(image: AssetImage("images/profile.jpg"),))
    );
  }

}