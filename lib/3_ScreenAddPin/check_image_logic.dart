
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Files/DTOClasses/group.dart';
import '../Providers/cluster_notifier.dart';
import 'check_image_ui.dart';

class CheckImageWidget extends StatefulWidget {
  const CheckImageWidget({Key? key, this.image}) : super(key: key);

  /// the image shown for checking if correct
  final Uint8List? image;

  @override
  State<StatefulWidget> createState() => StateCheckImageWidget();
}


class StateCheckImageWidget extends State<CheckImageWidget>{

  @override
  Widget build(BuildContext context)  => CheckImageIU(state: this);

  /// on button press of approve button
  /// returns back to the camera page with the type information selected by the user
  void handleApprove() {
    Group? group = Provider.of<ClusterNotifier>(context, listen:false).getLastSelected;
    if (group != null) {
      Navigator.pop(context, {"approve" : true, "type": group});
    }
  }

  /// on button press of back button
  /// returns back to the camera
  void handleBack() {
    Navigator.pop(context, {"approve" : false});
  }

  /// builds the image widget
  Future<Widget> handleFutureImage() async{
    return Image.memory(widget.image!);
  }

}