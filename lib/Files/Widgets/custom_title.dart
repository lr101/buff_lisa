import 'dart:typed_data';

import 'package:flutter/material.dart';

class CustomTitle extends StatefulWidget {
  const CustomTitle({
    super.key,
    this.imageCallback,
    this.child = const SizedBox.shrink(),
    required this.titleBar
  });

  final Future<Uint8List> Function()? imageCallback;
  final CustomTitleBar titleBar;
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
            widget.titleBar,
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




}

class CustomAction {

  CustomAction({required this.icon, required this.action});

  final Icon icon;
  final VoidCallback action;
}

class CustomTitleBar extends StatelessWidget {

  final bool? back;
  final Widget? actionBar;
  final String? title;
  final CustomAction? action;

  const CustomTitleBar(
      {super.key, this.back = true, this.actionBar, this.title, this.action});


  @override
  Widget build(BuildContext context) {
    if (actionBar == null) {
      return actions(context);
    } else {
      return SizedBox(height: 48, child: actionBar);
    }
  }

  Widget actions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        (back!) ?
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)) :
          const SizedBox.square(dimension: 48,),

        Text(title!, style: const TextStyle(fontSize: 20),),

        (action != null)
            ? IconButton(onPressed: action?.action, icon: action!.icon)
            : const SizedBox.square(dimension: 48,),
      ],
    );
  }
}