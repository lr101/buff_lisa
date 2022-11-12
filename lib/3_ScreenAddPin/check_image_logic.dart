
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/global.dart' as global;
import 'check_image_ui.dart';

class CheckImageWidget extends StatefulWidget {
  const CheckImageWidget({Key? key, this.image}) : super(key: key) ;
  final File? image;

  @override
  State<StatefulWidget> createState() => StateCheckImageWidget();
}


class StateCheckImageWidget extends State<CheckImageWidget>{

  @override
  Widget build(BuildContext context)  => CheckImageIU(state: this);

  /// on button press of approve button
  /// returns back to the camera page with the type information selected by the user
  void handleApprove() {
    int? groupId; //TODO get groupId
    if (groupId != null) {
      Navigator.pop(context, {"approve" : true, "type":groupId});
    }
  }

  /// on button press of back button
  /// returns back to the camera
  void handleBack() {
    Navigator.pop(context, {"approve" : false});
  }

  /// builds the image widget
  Future<Widget> handleFutureImage() async{
    final bytes = await widget.image?.readAsBytes();
    return Image.memory(bytes!);
  }




}