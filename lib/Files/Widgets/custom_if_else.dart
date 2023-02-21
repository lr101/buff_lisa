import 'package:flutter/cupertino.dart';

class CustomIfElse extends StatelessWidget {

  final Widget ifWidget;
  final Widget elseWidget;
  final bool Function() ifTest;
  const CustomIfElse({super.key, required this.ifWidget, required this.elseWidget, required this.ifTest});

  @override
  Widget build(BuildContext context) {
    if (ifTest()) {
      return ifWidget;
    } else {
      return elseWidget;
    }
  }

}