import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'CustomAlertDialog.dart';

class CustomActionButton extends StatefulWidget {
  const CustomActionButton({super.key, required this.text, this.popup, this.onPressed});

  final String text;
  final CustomAlertDialog? popup;
  final VoidCallback? onPressed;


  @override
  CustomActionButtonState createState() => CustomActionButtonState();
}

class CustomActionButtonState extends State<CustomActionButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width - 50,
        height: 50,
        child: OutlinedButton(
          style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) =>  Provider.of<ThemeProvider>(context).getCustomTheme.transparent)),
            onPressed: () {
              if (widget.popup != null) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => widget.popup!
                );
              } else if (widget.onPressed != null) {
                widget.onPressed!();
              }
            },
            child: Text(widget.text, style: TextStyle(color: Provider.of<ThemeProvider>(context).getCustomTheme.c1),)
        )
    );
  }

}

