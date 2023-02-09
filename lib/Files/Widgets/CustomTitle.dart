import 'dart:typed_data';

import 'package:flutter/material.dart';

class CustomTitle extends StatefulWidget {
  const CustomTitle({
    super.key,
    required this.title,
    this.imageCallback,
    this.back = true,
    this.action,
    this.child = const SizedBox.shrink()
  });

  final String title;
  final Future<Uint8List> Function()? imageCallback;
  final bool back;
  final CustomAction? action;
  final Widget child;

  @override
  CustomTitleState createState() => CustomTitleState();
}

class CustomTitleState extends State<CustomTitle> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            actions(),
            const SizedBox(height: 10,),
            image(),
            widget.child
          ],
        )
    );
  }

  Widget image() {
    if (widget.imageCallback == null) {
      return const SizedBox.shrink();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder<Uint8List>(
            future: widget.imageCallback!(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                  return CircleAvatar(backgroundImage: Image.memory(snapshot.requireData).image, radius: 50,);
              } else {
                return CircleAvatar(backgroundImage: const Image(image: AssetImage("images/profile.jpg")).image, radius: 50,);
              }
            },
          ),
          const SizedBox(height: 10,)
        ],
      );
    }
  }

  Widget actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        (widget.back) ? IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)) : const SizedBox(width: 48,),
        Text( widget.title, style: const TextStyle(fontSize: 20),),
        (widget.action != null) ? IconButton(onPressed: widget.action?.action, icon: widget.action!.icon) : const SizedBox(width: 48,),
      ],
    );
  }


}

class CustomAction {

  CustomAction({required this.icon, required this.action});

  final Icon icon;
  final VoidCallback action;
}
