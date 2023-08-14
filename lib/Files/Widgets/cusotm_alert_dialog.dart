import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({super.key, this.text1,required this.text2,required this.onPressed, this.child, required this.title,});
  final String? text1;
  final String text2;
  final String title;
  final VoidCallback onPressed;
  final Widget? child;



  @override
  Widget build(BuildContext context) {
    return dialog(
        Text(title),
        child == null ? null : Material(color: Colors.transparent,child: child,),
        <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: text1 != null ? Text(text1!) : const SizedBox.shrink(),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onPressed();
            },
            child: Text(text2),
          ),
        ],
    );
  }

  Widget dialog(Widget title, Widget? content, List<Widget> actions) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: title,
        content: content,
        actions: actions,
      );
    } else {
      return AlertDialog(
        title: title,
        content: content,
        actions: actions,
      );
    }
  }


}