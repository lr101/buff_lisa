import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomActionButton extends StatefulWidget {
  const CustomActionButton({super.key, required this.text, this.popup, this.onPressed});

  final String text;
  final CustomPrompt? popup;
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

class CustomPrompt extends StatelessWidget {
  const CustomPrompt({super.key, this.text1,required this.text2,required this.onPressed, this.child, required this.title,});
  final String? text1;
  final String text2;
  final String title;
  final VoidCallback onPressed;
  final Widget? child;



  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title, style: TextStyle(color: Provider.of<ThemeProvider>(context).getCustomTheme.c1)),
      content: Padding(padding: const EdgeInsets.all(10), child: Material(child: child)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: text1 != null ? Text(text1!,  style: TextStyle(color: Provider.of<ThemeProvider>(context).getCustomTheme.c1)) : const SizedBox.shrink(),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onPressed();
          },
          child: Text(text2, style: TextStyle(color: Provider.of<ThemeProvider>(context).getCustomTheme.c1)),
        ),
      ],
    );
  }



}