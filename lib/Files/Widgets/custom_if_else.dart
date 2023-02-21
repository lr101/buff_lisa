import 'package:flutter/cupertino.dart';

class CustomIfElse extends StatelessWidget {
  final bool Function() ifTest;
  final Widget ifWidget;
  final Widget elseWidget;

  const CustomIfElse({super.key,required this.ifTest, required this.ifWidget, required this.elseWidget});

  @override
  Widget build(BuildContext context) {
    if (ifTest()) {
      return ifWidget;
    } else {
      return elseWidget;
    }
  }

}