import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Providers/theme_provider.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({super.key, this.text1,required this.text2,required this.onPressed, this.child, required this.title,});
  final String? text1;
  final String text2;
  final String title;
  final VoidCallback onPressed;
  final Widget? child;



  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Padding(padding: const EdgeInsets.all(10), child: Material(child: child)),
      actions: <Widget>[
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



}